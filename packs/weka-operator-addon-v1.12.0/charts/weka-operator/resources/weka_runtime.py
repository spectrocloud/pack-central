import base64
import fcntl
import ipaddress
import json
import logging
import os
import re
import socket
import struct
import subprocess
import sys
import threading
import time
import uuid
from dataclasses import dataclass, asdict, fields
from functools import lru_cache, partial
from os.path import exists
from textwrap import dedent
from typing import Any, Dict, List, Optional, Tuple, Set, Union
from urllib.parse import urlparse


@dataclass
class SignOptions:
    allowEraseWekaPartitions: bool = False
    allowEraseNonWekaPartitions: bool = False
    allowNonEmptyDevice: bool = False
    skipTrimFormat: bool = False


@dataclass
class Disk:
    path: str
    is_mounted: bool
    serial_id: Optional[str]
    capacity_gib: Optional[int] = None


MODE = os.environ.get("MODE")
assert MODE != ""
NUM_CORES = int(os.environ.get("CORES", 0))
CORE_IDS = os.environ.get("CORE_IDS", "auto")
CPU_POLICY = os.environ.get("CPU_POLICY", "auto")
# Flags for `weka local resources cores`.
MODE_CORES_FLAG = {
    "compute": "--only-compute-cores",
    "drive": "--only-drives-cores",
    "client": "--only-frontend-cores",
    "s3": "--only-frontend-cores",
    "nfs": "--only-frontend-cores",
    "smbw": "--only-frontend-cores",
    "data-services": "--only-dataserv-cores",
}

NAME = os.environ["NAME"]
NETWORK_DEVICE = os.environ.get("NETWORK_DEVICE", "")
SUBNETS = os.environ.get("SUBNETS", "")
NETWORK_SELECTORS = os.environ.get("NETWORK_SELECTORS", "")
MANAGEMENT_IPS_SELECTORS = os.environ.get("MANAGEMENT_IPS_SELECTORS", "")
PORT = os.environ.get("PORT", "")
AGENT_PORT = os.environ.get("AGENT_PORT", "")
RESOURCES = {}  # to be populated at later stage
MEMORY = os.environ.get("MEMORY", "")
JOIN_IPS = os.environ.get("JOIN_IPS", "")
DIST_SERVICE = os.environ.get("DIST_SERVICE")
DRIVERS_BUILD_ID = os.environ.get("DRIVERS_BUILD_ID", "")
OS_DISTRO = ""
OS_BUILD_ID = ""
DISCOVERY_SCHEMA = 1
INSTRUCTIONS = os.environ.get("INSTRUCTIONS", "")
NODE_NAME = os.environ["NODE_NAME"]
POD_ID = os.environ.get("POD_ID", "")
POD_NAME = os.environ.get("POD_NAME", "")
POD_NAMESPACE = os.environ.get("POD_NAMESPACE", "")
FAILURE_DOMAIN = os.environ.get("FAILURE_DOMAIN", None)
MACHINE_IDENTIFIER = os.environ.get("MACHINE_IDENTIFIER", None)
NET_GATEWAY = os.environ.get("NET_GATEWAY", None)
IS_IPV6 = os.environ.get("IS_IPV6", "false") == "true"
MANAGEMENT_IPS = []  # to be populated at later stage
UDP_MODE = os.environ.get("UDP_MODE", "false") == "true"
DUMPER_CONFIG_MODE = os.environ.get("DUMPER_CONFIG_MODE", "auto")
EXCLUDED_DRIVE_PATHS = []  # List of device paths to exclude from signing

# SSD Proxy socket path for sign-drives operations (mounted at /host-binds/ssdproxy-local-socket)
SSDPROXY_SOCKET_PATH = "/host-binds/ssdproxy-local-socket/container.sock"

# OpenTelemetry configuration
OTEL_EXPORTER_OTLP_ENDPOINT = os.environ.get("OTEL_EXPORTER_OTLP_ENDPOINT", "")
OTEL_EXPORTER_OTLP_LOGS_ENDPOINT = os.environ.get("OTEL_EXPORTER_OTLP_LOGS_ENDPOINT", "")
OTEL_EXPORTER_OTLP_HEADERS = os.environ.get("OTEL_EXPORTER_OTLP_HEADERS", "")
OTEL_EXPORTER_OTLP_LOGS_HEADERS = os.environ.get("OTEL_EXPORTER_OTLP_LOGS_HEADERS", "")
OTEL_SERVICE_NAME = os.environ.get("OTEL_SERVICE_NAME", "weka-operator-runtime")
OTEL_SERVICE_VERSION = os.environ.get("OTEL_SERVICE_VERSION", "1.0.0")
OTEL_LOGS_ENABLED = os.environ.get("OTEL_LOGS_ENABLED", "true").lower() == "true"
OTEL_AVAILABLE = False  # Will be set to True if OTEL packages are available

KUBERNETES_DISTRO_OPENSHIFT = "openshift"
KUBERNETES_DISTRO_GKE = "gke"
OS_NAME_GOOGLE_COS = "cos"
OS_NAME_REDHAT_COREOS = "rhcos"
OS_NAME_UBUNTU = "ubuntu"

UBUNTU24_BUILD_ID = "ubuntu24.04"

MAX_TRACE_CAPACITY_GB = os.environ.get("MAX_TRACE_CAPACITY_GB", 10)
ENSURE_FREE_SPACE_GB = os.environ.get("ENSURE_FREE_SPACE_GB", 20)

WEKA_CONTAINER_ID = os.environ.get("WEKA_CONTAINER_ID", "")
WEKA_PERSISTENCE_DIR = "/host-binds/opt-weka"
WEKA_PERSISTENCE_MODE = os.environ.get("WEKA_PERSISTENCE_MODE", "local")
WEKA_PERSISTENCE_GLOBAL_DIR = "/opt/weka-global-persistence"
if WEKA_PERSISTENCE_MODE == "global":
    WEKA_PERSISTENCE_DIR = os.path.join(WEKA_PERSISTENCE_GLOBAL_DIR, "containers", WEKA_CONTAINER_ID)

WEKA_COS_ALLOW_HUGEPAGE_CONFIG = True if os.environ.get("WEKA_COS_ALLOW_HUGEPAGE_CONFIG", "false") == "true" else False
WEKA_COS_ALLOW_DISABLE_DRIVER_SIGNING = True if os.environ.get("WEKA_COS_ALLOW_DISABLE_DRIVER_SIGNING",
                                                               "false") == "true" else False
WEKA_COS_GLOBAL_HUGEPAGE_SIZE = os.environ.get("WEKA_COS_GLOBAL_HUGEPAGE_SIZE", "2M").lower()
WEKA_COS_GLOBAL_HUGEPAGE_COUNT = int(os.environ.get("WEKA_COS_GLOBAL_HUGEPAGE_COUNT", 4000))

AWS_VENDOR_ID = "1d0f"
AWS_DEVICE_ID = "cd01"
GCP_VENDOR_ID = "0x1ae0"
GCP_DEVICE_ID = "0x001f"
AUTO_REMOVE_TIMEOUT = int(os.environ.get("AUTO_REMOVE_TIMEOUT", "0"))

# for client dynamic port allocation
BASE_PORT = os.environ.get("BASE_PORT", "")
PORT_RANGE = os.environ.get("PORT_RANGE", "0")
WEKA_CONTAINER_PORT_SUBRANGE = 100
MAX_PORT = 65535

SUBPROCESS_DEFAULT_TIMEOUT_SEC = 30

# Define global variables
exiting = 0


def setup_otel_logging():
    """Setup OpenTelemetry logging with OTLP exporter."""

    # Check if init container successfully installed OTEL packages
    otel_packages_dir = "/shared-python-packages"
    success_marker = os.path.join(otel_packages_dir, ".otel-packages-installed")
    failure_marker = os.path.join(otel_packages_dir, ".otel-packages-failed")

    if os.path.exists(success_marker):
        print("OTEL packages were successfully installed by init container")
        # Add the shared packages directory to Python path if not already there
        if otel_packages_dir not in sys.path:
            sys.path.insert(0, otel_packages_dir)

        # Try to import OTEL packages that should now be available
        try:
            global OTEL_AVAILABLE
            from opentelemetry.exporter.otlp.proto.grpc._log_exporter import OTLPLogExporter
            from opentelemetry.sdk._logs import LoggerProvider, LoggingHandler
            from opentelemetry.sdk._logs.export import BatchLogRecordProcessor
            from opentelemetry.sdk.resources import Resource
            from opentelemetry.semconv.resource import ResourceAttributes
            OTEL_AVAILABLE = True
            print("Successfully imported OTEL packages from init container installation")
        except ImportError as e:
            print(f"Warning: Failed to import OTEL packages even after init container installation: {e}")
            OTEL_AVAILABLE = False
    elif os.path.exists(failure_marker):
        print("Init container failed to install OTEL packages. Falling back to standard logging.")
        OTEL_AVAILABLE = False
    else:
        print("No OTEL package installation markers found. Checking for pre-installed packages...")

    if not OTEL_AVAILABLE or not OTEL_LOGS_ENABLED:
        return setup_standard_logging()

    try:
        # Determine the OTLP endpoint for logs
        logs_endpoint = OTEL_EXPORTER_OTLP_LOGS_ENDPOINT or OTEL_EXPORTER_OTLP_ENDPOINT
        if not logs_endpoint:
            print("Warning: No OTEL endpoint configured. Falling back to standard logging.")
            return setup_standard_logging()

        # Parse headers for logs
        headers = {}
        headers_str = OTEL_EXPORTER_OTLP_LOGS_HEADERS or OTEL_EXPORTER_OTLP_HEADERS
        if headers_str:
            for header in headers_str.split(','):
                if '=' in header:
                    key, value = header.strip().split('=', 1)
                    headers[key] = value

        # Create resource with service information
        resource = Resource.create({
            ResourceAttributes.SERVICE_NAME: OTEL_SERVICE_NAME,
            ResourceAttributes.SERVICE_VERSION: OTEL_SERVICE_VERSION,
            ResourceAttributes.SERVICE_INSTANCE_ID: POD_ID or NODE_NAME,
            "k8s.node.name": NODE_NAME,
            "k8s.pod.uid": POD_ID,
            "k8s.pod.name": POD_NAME,
            "k8s.namespace.name": POD_NAMESPACE,
        })

        # Create OTLP log exporter
        otlp_exporter = OTLPLogExporter(
            endpoint=logs_endpoint,
            headers=headers,
        )

        # Create logger provider
        logger_provider = LoggerProvider(resource=resource)

        # Add batch processor
        logger_provider.add_log_record_processor(
            BatchLogRecordProcessor(otlp_exporter)
        )

        # Create OTEL logging handler
        otel_handler = LoggingHandler(
            level=logging.DEBUG,
            logger_provider=logger_provider,
        )

        # Create standard handlers for local logging
        stdout_handler = logging.StreamHandler(sys.stdout)
        stdout_handler.setLevel(logging.DEBUG)
        stderr_handler = logging.StreamHandler(sys.stderr)
        stderr_handler.setLevel(logging.WARNING)

        # Formatter
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        stdout_handler.setFormatter(formatter)
        stderr_handler.setFormatter(formatter)

        # Configure root logger with both OTEL and standard handlers
        root_logger = logging.getLogger()
        root_logger.setLevel(logging.DEBUG)
        root_logger.addHandler(otel_handler)
        root_logger.addHandler(stdout_handler)
        root_logger.addHandler(stderr_handler)

        print(f"OTEL logging configured successfully. Endpoint: {logs_endpoint}")
        return True

    except Exception as e:
        print(f"Failed to setup OTEL logging: {e}. Falling back to standard logging.")
        return setup_standard_logging()


def setup_standard_logging():
    """Setup standard logging as fallback."""
    # Formatter with channel name
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

    # Define handlers for stdout and stderr
    stdout_handler = logging.StreamHandler(sys.stdout)
    stdout_handler.setLevel(logging.DEBUG)
    stderr_handler = logging.StreamHandler(sys.stderr)
    stderr_handler.setLevel(logging.WARNING)

    stdout_handler.setFormatter(formatter)
    stderr_handler.setFormatter(formatter)

    # Basic configuration
    logging.basicConfig(
        level=logging.DEBUG,  # Global minimum logging level
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',  # Include timestamp
        handlers=[stdout_handler, stderr_handler]
    )
    return False


# Initialize logging
otel_enabled = setup_otel_logging()
if otel_enabled:
    logging.info("OpenTelemetry logging initialized successfully")
else:
    logging.info("Using standard logging configuration")

def use_go_syslog() -> bool:
    syslog_package = os.environ.get("SYSLOG_PACKAGE", "auto")
    if syslog_package == "auto":
        return os.path.exists("/usr/sbin/go-syslog")

    if syslog_package == "go-syslog":
        return True

    if syslog_package == "syslog-ng":
        return False

    raise ValueError(f"Invalid SYSLOG_PACKAGE value: {syslog_package}. Expected 'auto', 'go-syslog', or 'syslog-ng'.")



class FeaturesFlags:
    # Bit positions (class-level ints) – will be shadowed by bools on the instance
    traces_override_partial_support: Union[bool, int] = 0
    traces_override_in_slash_traces: Union[bool, int] = 1
    supports_binding_to_not_all_interfaces: Union[bool, int] = 2
    agent_validate_60_ports_per_container: Union[bool, int] = 3
    allow_per_container_driver_interfaces: Union[bool, int] = 4
    weka_get_copy_local_driver_files: Union[bool, int] = 5
    driver_supports_auto_drain: Union[bool, int] = 6
    ssd_proxy_iommu_support: Union[bool, int] = 7
    # flag 8 is not used by the operator
    ssd_proxy_includes_dpdk_memory: Union[bool, int] = 9

    def __init__(self, b64_flags: Optional[str]) -> None:
        active: Set[int] = set(parse_feature_bitmap(b64_flags or ""))

        # Walk over class attributes that are ints (flag indices)
        for name, bit in self.__class__.__dict__.items():
            if isinstance(bit, int):  # skip dunders, methods, etc.
                # true  ⇢ flag bit present, false ⇢ absent
                setattr(self, name, bit in active)

        # Store raw list/set if needed elsewhere
        self._active_bits: Set[int] = active


    def get_feature_map(self) -> Dict[str, bool]:
        """
        Returns a dictionary mapping feature names to their boolean values.
        """
        feature_map: Dict[str, bool] = {}
        for name in dir(self):
            if not name.startswith('_'):
                value = getattr(self, name)
                if isinstance(value, bool):
                    feature_map[name] = value

        return feature_map


def parse_feature_bitmap(b64_str: str) -> list[int]:
    """
    Reverse of get_feature_bitmap():
    * Accepts the Base-64 string produced by get_feature_bitmap
    * Returns a sorted list of bit indexes that are set (e.g. [1, 5, 30])
    """
    if not b64_str:  # empty / None -> no features
        return []

    bitmap: bytes = base64.b64decode(b64_str)
    indexes: list[int] = []

    for byte_idx, byte in enumerate(bitmap):
        if byte == 0:  # quick skip for sparse bitmaps
            continue
        for bit_idx in range(8):
            if byte & (1 << bit_idx):  # same bit ordering as encoder
                indexes.append(byte_idx * 8 + bit_idx)

    return indexes


def iu_size_to_drive_type(iu_size: int) -> str:
    """
    Convert IU size in bytes to drive type string.
    """
    if iu_size >= 16384:
        return "QLC"
    else:
        return "TLC"


async def get_serial_id_cos_specific(device_path: str) -> Optional[str]:
    """
    Get serial ID for Google COS
    """
    logging.info(f"Getting serial ID for {device_path} using COS-specific method")
    device_name = os.path.basename(device_path)  # Returns "nvme0n1"

    cmd = f"cat /sys/block/{device_name}/wwid 2>/dev/null || echo 'None'"

    stdout, stderr, ec = await run_command(cmd)

    if ec != 0:
        logging.warning(f"COS-specific fallback failed: could not get info for {device_path}: {stderr.decode()}")
        return None

    serial_id = stdout.decode().strip()
    if serial_id and serial_id != 'None':
        logging.info(f"COS-specific fallback successful for {device_path}, found serial id: {serial_id}")
        return serial_id

    logging.warning(f"COS-specific fallback failed: could not find serial id for {device_name}")
    return None


async def sign_drives_by_pci_info(vendor_id: str, device_id: str, options: dict) -> List[str]:
    logging.info("Signing drives. Vendor ID: %s, Device ID: %s", vendor_id, device_id)

    if not vendor_id or not device_id:
        raise ValueError("Vendor ID and Device ID are required")

    cmd = f"lspci -d {vendor_id}:{device_id}" + " | sort | awk '{print $1}'"
    stdout, stderr, ec = await run_command(cmd)
    if ec != 0:
        return

    pci_devices = stdout.decode().strip().split()
    devices = [f"/dev/disk/by-path/pci-{pci_device}-nvme-1" for pci_device in pci_devices]
    return await sign_device_paths_batch(devices, options)


async def find_disks() -> List[Disk]:
    """
    Find all disk devices and check if they or their partitions are mounted.
    :return: A list of Disk objects.
    """
    logging.info("Finding disks and checking mount status")
    # Use -J for JSON output, -p for full paths, -o to specify columns
    # TODO: We are dependant on lsblk here on host here. Is it a problem? potentially
    cmd = "nsenter --mount --pid --target 1 -- lsblk -p -J -o NAME,TYPE,MOUNTPOINT,SERIAL"
    stdout, stderr, ec = await run_command(cmd, capture_stdout=True)
    if ec != 0:
        logging.error(f"Failed to execute lsblk: {stderr.decode()}")
        return []

    try:
        data = json.loads(stdout)
    except json.JSONDecodeError:
        logging.error(f"Failed to parse lsblk JSON output: {stdout.decode()}")
        return []

    disks = []

    def has_mountpoint(device_info: dict) -> bool:
        """Recursively check if a device or any of its children has a mountpoint."""
        if device_info.get("mountpoint"):
            return True
        if "children" in device_info:
            for child in device_info["children"]:
                if has_mountpoint(child):
                    return True
        return False

    async def get_capacity_gib(device_path: str) -> int:
        """Get the capacity of the device in GiB."""
        cmd = f"blockdev --getsize64 {device_path}"
        stdout, stderr, ec = await run_command(cmd, capture_stdout=True)
        if ec == 0:
            size_bytes = int(stdout.decode().strip())
            if size_bytes == 0:
                logging.warning(f"Device {device_path} reported zero capacity, skipping")
                return None

            return size_bytes // (1024 ** 3)  # Convert to GiB
        else:
            raise Exception(f"Failed to get capacity for {device_path}: {stderr.decode()}")

    for device in data.get("blockdevices", []):
        if device.get("type") == "disk":
            is_mounted = has_mountpoint(device)
            device_path = device["name"]
            serial_id = await get_device_serial_id(device_path)
            capacity_gib = await get_capacity_gib(device_path)
            if capacity_gib is None:
                continue

            logging.info(f"Found drive: {device_path}, mounted: {is_mounted}, serial: {serial_id}")
            disks.append(Disk(path=device_path, is_mounted=is_mounted, serial_id=serial_id, capacity_gib=capacity_gib))

    return disks


async def sign_not_mounted(options: dict) -> List[str]:
    """
    Signs all disk devices that are not mounted and have no mounted partitions.
    :param options:
    :return: list of signed drive paths
    """
    logging.info("Signing drives that are not mounted")
    all_disks = await find_disks()

    unmounted_disks = [disk for disk in all_disks if not disk.is_mounted]
    logging.info(f"Found {len(unmounted_disks)} unmounted disks to sign: {[d.path for d in unmounted_disks]}")

    signed_drives = await sign_device_paths_batch([disk.path for disk in unmounted_disks], options)
    return signed_drives


async def sign_device_paths(devices_paths, options) -> List[str]:
    return await sign_device_paths_batch(list(devices_paths), options)


class SignException(Exception):
    pass


async def get_drives_with_cluster_guid(use_proxy_socket: bool = False) -> dict:
    """
    Get all drives from weka-sign-drive list and return dict mapping serial -> path
    for drives that have a cluster_guid (i.e., are claimed by a Weka cluster).

    Args:
        use_proxy_socket: If True, use the ssdproxy socket to see proxy-taken drives
    """
    try:
        cmd = "/weka-sign-drive list -j"
        if use_proxy_socket and os.path.exists(SSDPROXY_SOCKET_PATH):
            logging.info(f"Using proxy socket at {SSDPROXY_SOCKET_PATH}")
            cmd = f"/weka-sign-drive --unix-socket {SSDPROXY_SOCKET_PATH}:/api/v1 list -j"

        stdout, stderr, ec = await run_command(cmd)
        if ec != 0:
            logging.warning(f"Failed to list drives: {stderr}")
            return {}

        drive_list = json.loads(stdout.decode())
        drives_with_guid = {}

        for device in drive_list.get('devices', []):
            hardware = device.get('hardware', {})
            weka_info = device.get('weka_info') or {}
            serial = hardware.get('serial_number')
            path = device.get('path')
            cluster_guid = weka_info.get('cluster_guid')

            if serial and path and cluster_guid:
                drives_with_guid[serial] = path
                logging.debug(f"Drive {path} (serial {serial}) has cluster_guid: {cluster_guid}")

        logging.info(f"Found {len(drives_with_guid)} drives with cluster_guid")
        return drives_with_guid
    except Exception as e:
        logging.error(f"Error getting drives with cluster_guid: {e}")
        return {}


def _build_sign_params(options: SignOptions) -> List[str]:
    params = []
    if options.allowEraseWekaPartitions:
        params.append("--allow-erase-weka-partitions")
    if options.allowEraseNonWekaPartitions:
        params.append("--allow-erase-non-weka-partitions")
    if options.allowNonEmptyDevice:
        params.append("--allow-non-empty-device")
    if options.skipTrimFormat:
        params.append("--skip-trim-format")
    return params


async def sign_device_path(device_path, options: SignOptions):
    # Check if device path should be excluded
    if device_path in EXCLUDED_DRIVE_PATHS:
        logging.info(f"Skipping drive {device_path} - in exclusion list")
        return

    logging.info(f"Signing drive {device_path}")
    params = _build_sign_params(options)

    stdout, stderr, ec = await run_command(
        f"/weka-sign-drive {' '.join(params)} -- {device_path}")
    if ec != 0:
        err = f"Failed to sign drive {device_path}: {stderr}"
        raise SignException(err)


async def sign_device_path_for_proxy(device_path: str, options: SignOptions):
    """
    Sign a drive for proxy mode using weka-sign-drive sign proxy.
    Sets the proxy SystemGUID automatically.
    """
    logging.info(f"Signing drive for proxy: {device_path}")
    params = ["sign", "proxy"] + _build_sign_params(options)

    stdout, stderr, ec = await run_command(
        f"/weka-sign-drive {' '.join(params)} -- {device_path}")
    if ec != 0:
        # Check if drive is already signed for proxy
        if "already a Weka partition" in stderr.decode():
            logging.info(f"Drive {device_path} already signed for proxy, querying info")
            return await get_proxy_drive_info(device_path)

        err = f"Failed to sign drive {device_path} for proxy: {stderr}"
        logging.error(err)
        raise SignException(err)

    # Parse signing output (may contain info, but we'll use show command for consistency)
    logging.info(f"Successfully signed {device_path} for proxy")
    return await get_proxy_drive_info(device_path)


async def sign_device_paths_batch(device_paths: List[str], options: SignOptions) -> List[str]:
    paths = [p for p in device_paths if p not in EXCLUDED_DRIVE_PATHS]
    if not paths:
        return []
    params = _build_sign_params(options)
    params_str = (" ".join(params) + " ") if params else ""
    cmd = f"/weka-sign-drive sign {params_str}-- {' '.join(paths)}"
    stdout, stderr, ec = await run_command(cmd)
    if ec == 0:
        return paths
    logging.warning(f"Batch sign failed (ec={ec}), falling back to per-device signing: {stderr}")
    signed = []
    for p in paths:
        try:
            await sign_device_path(p, options)
            signed.append(p)
        except SignException as e:
            logging.error(str(e))
    return signed


async def sign_device_paths_for_proxy_batch(device_paths: List[str], options: SignOptions) -> List[dict]:
    paths = [p for p in device_paths if p not in EXCLUDED_DRIVE_PATHS]
    if not paths:
        return []
    params = ["sign", "proxy"] + _build_sign_params(options)
    cmd = f"/weka-sign-drive {' '.join(params)} -- {' '.join(paths)}"
    stdout, stderr, ec = await run_command(cmd)
    if ec == 0:
        results = await asyncio.gather(*[get_proxy_drive_info(p) for p in paths], return_exceptions=True)
        return [r for r in results if not isinstance(r, Exception)]
    stderr_str = stderr.decode() if isinstance(stderr, bytes) else stderr
    logging.warning(f"Batch proxy sign failed (ec={ec}), falling back to per-device signing: {stderr_str}")
    infos = []
    for p in paths:
        try:
            info = await sign_device_path_for_proxy(p, options)
            infos.append(info)
        except SignException as e:
            logging.error(str(e))
    return infos


async def get_device_serial_id(device_path: str) -> str:
    """
    Get serial ID for a block device.
    Supports both NVMe and SCSI/SATA devices.
    Returns serial ID string, or empty string if not found.
    """
    try:
        # Get the block device name (e.g., nvme0n1, sda, nvme0n1p1)
        device_name = os.path.basename(device_path)

        # Resolve to the actual device in sysfs
        pci_device_path = subprocess.check_output(
            f"readlink -f /sys/class/block/{device_name}",
            shell=True,
            timeout=SUBPROCESS_DEFAULT_TIMEOUT_SEC,
        ).decode().strip()

        if "nvme" in device_name.lower():
            # NVMe device: serial is 1 directory up from the namespace
            # /sys/devices/pci.../nvme/nvme0/nvme0n1 -> need /sys/devices/pci.../nvme/nvme0/serial
            # Remove last element (nvme0n1) to get the nvme0 directory
            serial_id_path = "/".join(pci_device_path.split("/")[:-1]) + "/serial"
            serial_id = subprocess.check_output(f"cat {serial_id_path}", shell=True,
                                                timeout=SUBPROCESS_DEFAULT_TIMEOUT_SEC).decode().strip()

            # Google COS specific handling if needed
            if is_google_cos():
                serial_id = await get_serial_id_cos_specific(device_name)

            return serial_id
        else:
            # SCSI/SATA device: get from udev data
            dev_index = subprocess.check_output(
                f"cat /sys/block/{device_name}/dev",
                shell=True,
                timeout=SUBPROCESS_DEFAULT_TIMEOUT_SEC,
            ).decode().strip()

            serial_id_cmd = (
                f"grep -m1 'ID_SERIAL=' /host/run/udev/data/b{dev_index} | cut -d= -f2-"
            )
            serial_id = subprocess.check_output(
                serial_id_cmd,
                shell=True,
                timeout=SUBPROCESS_DEFAULT_TIMEOUT_SEC,
            ).decode().strip()
            return serial_id

    except (Exception, subprocess.TimeoutExpired) as e:
        logging.warning(f"Failed to get serial ID for {device_path}: {e}")
        return ""


async def get_proxy_drive_info(device_path: str):
    """
    Get drive information after proxy signing using weka-sign-drive show.
    Returns dict with physical_uuid, serial, and capacity_gib.
    """
    logging.info(f"Getting proxy drive info for {device_path}")
    stdout, stderr, ec = await run_command(f"/weka-sign-drive show {device_path} --json")
    if ec != 0:
        raise SignException(f"Failed to get drive info for {device_path}: {stderr}")

    try:
        drive_info = json.loads(stdout.decode())
        logging.debug(f"Drive info JSON for {device_path}: {json.dumps(drive_info, indent=2)}")

        if not drive_info.get('partitions') or len(drive_info['partitions']) == 0:
            raise SignException(f"No partitions found for {device_path}")

        partition = drive_info['partitions'][0]
        header = partition.get('header', {})

        if not header.get('is_proxy'):
            raise SignException(f"Drive {device_path} is not signed for proxy mode")

        physical_uuid = header.get('physical_uuid')
        if not physical_uuid:
            raise SignException(f"No physical_uuid found for {device_path}")

        # Get serial number - try multiple sources
        serial = None
        iu_size = 0

        # 1. Try from JSON hardware first (most reliable if present)
        hardware_info = drive_info.get('hardware', {})
        if hardware_info:
            iu_size = hardware_info.get('iu_size', 0)

            serial = hardware_info.get('serial_number') or hardware_info.get('serial')
            if serial:
                logging.debug(f"Serial from hardware info: {serial}")

        # 2. Use generic serial resolution function (same logic as find_weka_drives)
        if not serial:
            serial = await get_device_serial_id(device_path)
            if serial:
                logging.debug(f"Serial from get_device_serial_id: {serial}")

        # Get capacity in GiB from partition size
        capacity_bytes = partition.get('size', 0)

        # If size is 0 or not present, try to get from device using lsblk
        if capacity_bytes == 0:
            try:
                # Use head -1 to get only the device size (not partition sizes)
                lsblk_cmd = f"lsblk -bno SIZE {device_path} | head -1"
                size_stdout, _, size_ec = await run_command(lsblk_cmd)
                if size_ec == 0:
                    size_str = size_stdout.decode().strip()
                    if size_str:
                        capacity_bytes = int(size_str)
                        logging.debug(f"Capacity from lsblk: {capacity_bytes} bytes")
            except Exception as e:
                logging.warning(f"Failed to get capacity from lsblk for {device_path}: {e}")

        capacity_gib = capacity_bytes // (1024 ** 3) if capacity_bytes > 0 else 0

        logging.info(f"Drive info extracted: UUID={physical_uuid}, Serial={serial or 'UNKNOWN'}, Capacity={capacity_gib} GiB, IU Size={iu_size}")

        return {
            'physical_uuid': physical_uuid,
            'serial': serial or 'UNKNOWN',
            'capacity_gib': capacity_gib,
            'device_path': device_path,
            'type': iu_size_to_drive_type(iu_size),
        }
    except (json.JSONDecodeError, KeyError) as e:
        raise SignException(f"Failed to parse drive info for {device_path}: {e}")


async def sign_not_mounted_for_proxy(options: SignOptions) -> List[dict]:
    """
    Sign unmounted drives for proxy mode.
    Returns list of dicts with physical_uuid, serial, capacity_gib for each drive.
    """
    logging.info("Signing unmounted drives for proxy mode")
    all_disks = await find_disks()

    unmounted_disks = [disk for disk in all_disks if not disk.is_mounted]
    logging.info(f"Found {len(unmounted_disks)} unmounted disks to sign for proxy: {[d.path for d in unmounted_disks]}")

    return await sign_device_paths_for_proxy_batch([disk.path for disk in unmounted_disks], options)


async def sign_device_paths_for_proxy(devices_paths: List[str], options: SignOptions) -> List[dict]:
    """
    Sign specific device paths for proxy mode.
    Returns list of dicts with physical_uuid, serial, capacity_gib for each drive.
    """
    logging.info(f"Signing {len(devices_paths)} device paths for proxy mode: {devices_paths}")
    return await sign_device_paths_for_proxy_batch(list(devices_paths), options)


async def sign_drives_for_proxy_by_pci_info(vendor_id: str, device_id: str, options: SignOptions) -> List[dict]:
    """
    Sign drives for proxy mode by PCI info (uses lspci and /dev/disk/by-path/).
    Returns list of dicts with physical_uuid, serial, capacity_gib for each drive.
    """
    logging.info(f"Signing drives for proxy (PCI). Vendor ID: {vendor_id}, Device ID: {device_id}")

    if not vendor_id or not device_id:
        raise ValueError("Vendor ID and Device ID are required")

    # Find PCI devices matching vendor and device ID
    cmd = f"lspci -d {vendor_id}:{device_id}" + " | sort | awk '{print $1}'"
    stdout, stderr, ec = await run_command(cmd)
    if ec != 0:
        logging.info("No devices found matching PCI info")
        return []

    pci_devices = stdout.decode().strip().split()
    devices = [f"/dev/disk/by-path/pci-{pci_device}-nvme-1" for pci_device in pci_devices]
    return await sign_device_paths_for_proxy_batch(devices, options)


async def sign_drives_for_proxy_gke(vendor_id: str, device_id: str, options: SignOptions) -> List[dict]:
    """
    Sign drives for proxy mode using GKE/sysfs discovery (uses /sys/block/ and /dev/ paths).
    Returns list of dicts with physical_uuid, serial, capacity_gib for each drive.
    """
    logging.info(f"Signing drives for proxy (GKE). Vendor ID: {vendor_id}, Device ID: {device_id}")

    if not vendor_id or not device_id:
        raise ValueError("Vendor ID and Device ID are required")

    # Use sysfs to find block devices by vendor/device ID
    cmd = f"""for dev in /sys/block/*; do
if [ -f "$dev/device/device/vendor" ] &&
   [ "$(cat $dev/device/device/vendor 2>/dev/null)" = "{vendor_id}" ] &&
   [ "$(cat $dev/device/device/device 2>/dev/null)" = "{device_id}" ]; then
    echo $(basename $dev)
fi
done"""

    stdout, stderr, ec = await run_command(cmd)
    if ec != 0:
        logging.info("No devices found via sysfs")
        return []

    dev_devices = stdout.decode().strip().split("\n")
    devices = [f"/dev/{dev_device}" for dev_device in dev_devices if dev_device]
    logging.info(f"Found {len(devices)} drives to sign for proxy")
    return await sign_device_paths_for_proxy_batch(devices, options)


async def sign_drives_gke(vendor_id: str, device_id: str, options: dict) -> List[str]:
    logging.info("Signing drives (GKE). Vendor ID: %s, Device ID: %s", vendor_id, device_id)

    if not vendor_id or not device_id:
        raise ValueError("Vendor ID and Device ID are required")

    cmd = f"""for dev in /sys/block/*; do
if [ -f "$dev/device/device/vendor" ] &&
   [ "$(cat $dev/device/device/vendor 2>/dev/null)" = "{vendor_id}" ] &&
   [ "$(cat $dev/device/device/device 2>/dev/null)" = "{device_id}" ]; then
    echo $(basename $dev)
fi
done"""

    stdout, stderr, ec = await run_command(cmd)
    if ec != 0:
        return

    dev_devices = stdout.decode().strip().split("\n")
    devices = [f"/dev/{dev_device}" for dev_device in dev_devices if dev_device]
    logging.info(f"Found {len(devices)} drives to sign")
    return await sign_device_paths_batch(devices, options)

async def sign_drives(instruction: dict):
    """
    Sign drives for either regular or proxy mode.
    Returns either List[str] for regular mode or List[dict] for proxy mode.
    """
    global EXCLUDED_DRIVE_PATHS

    type = instruction['type']
    for_proxy = instruction.get('shared', False)
    options = SignOptions(**instruction.get('options', {})) if instruction.get('options') else SignOptions()

    # Extract excluded serial IDs and filter to only include drives with cluster_guid
    # (drives without cluster_guid are not truly claimed by Weka and should be available for signing)
    # Use proxy socket when signing for proxy mode to see proxy-taken drives
    excluded_serials = instruction.get('excludedSerialIds', [])
    drives_with_guid = await get_drives_with_cluster_guid(use_proxy_socket=for_proxy)
    EXCLUDED_DRIVE_PATHS = []
    for serial in excluded_serials:
        if serial in drives_with_guid:
            EXCLUDED_DRIVE_PATHS.append(drives_with_guid[serial])
            logging.info(f"Serial {serial} -> {drives_with_guid[serial]} (has cluster_guid, will exclude)")
        else:
            logging.info(f"Serial {serial} has no cluster_guid or not found, NOT excluding")
    logging.info(f"Final excluded paths: {EXCLUDED_DRIVE_PATHS}")

    # Route to proxy signing functions if shared is true
    if for_proxy:
        logging.info("Signing drives for proxy mode")
        if type == "aws-all":
            return await sign_drives_for_proxy_by_pci_info(
                vendor_id=AWS_VENDOR_ID,
                device_id=AWS_DEVICE_ID,
                options=options
            )
        elif type == "gcp-all":
            return await sign_drives_for_proxy_gke(
                vendor_id=GCP_VENDOR_ID,
                device_id=GCP_DEVICE_ID,
                options=options
            )
        elif type == "device-identifiers":
            return await sign_drives_for_proxy_by_pci_info(
                vendor_id=instruction.get('pciDevices', {}).get('vendorId'),
                device_id=instruction.get('pciDevices', {}).get('deviceId'),
                options=options
            )
        elif type == "all-not-root":
            return await sign_not_mounted_for_proxy(options)
        elif type == "device-paths":
            return await sign_device_paths_for_proxy(instruction['devicePaths'], options)
        else:
            raise ValueError(f"Proxy signing not supported for instruction type: {type}")

    # Regular signing (non-proxy)
    if type == "aws-all":
        return await sign_drives_by_pci_info(
            vendor_id=AWS_VENDOR_ID,
            device_id=AWS_DEVICE_ID,
            options=options
        )
    elif type == "gcp-all":
        return await sign_drives_gke(
            vendor_id=GCP_VENDOR_ID,
            device_id=GCP_DEVICE_ID,
            options=options
    )
    elif type == "device-identifiers":
        return await sign_drives_by_pci_info(
            vendor_id=instruction.get('pciDevices', {}).get('vendorId'),
            device_id=instruction.get('pciDevices', {}).get('deviceId'),
            options=options
        )
    elif type == "all-not-root":
        return await sign_not_mounted(options)
    elif type == "device-paths":
        return await sign_device_paths(instruction['devicePaths'], options)
    else:
        raise ValueError(f"Unknown instruction type: {type}")


async def force_resign_drives_by_paths(devices_paths: List[str]):
    logging.info("Force resigning drives by paths: %s", devices_paths)
    options = SignOptions(allowEraseWekaPartitions=True)
    signed_drives = await sign_device_paths_batch(devices_paths, options)
    write_results(dict(
        err=None,
        drives=signed_drives
    ))


async def force_resign_drives_by_serials(serials: List[str]):
    logging.info("Force resigning drives by serials: %s", serials)
    device_paths = []
    for serial in serials:
        device_path = await get_block_device_path_by_serial(serial)
        device_paths.append(device_path)

    await force_resign_drives_by_paths(device_paths)


async def get_block_device_path_by_serial(serial: str):
    logging.info(f"Getting block device path by serial {serial}")
    stdout, stderr, ec = await run_command(
        "lsblk -dpno NAME | grep -w $(basename $(ls -la /dev/disk/by-id/ | grep -m 1 " + serial + " | awk '{print $NF}'))")
    if ec != 0:
        logging.error(f"Failed to get block device path by serial {serial}: {stderr}")
        return None
    device_path = stdout.decode().strip()
    return device_path


async def discover_drives():
    drives = await find_weka_drives()
    raw_disks = await find_disks()
    write_results(dict(
        err=None,
        drives=drives,
        raw_drives=[asdict(d) for d in raw_disks],
    ))


async def discover_ssdproxy_drives():
    drives = await list_weka_proxy_drives_with_sign_tool()
    write_results(dict(
        err=None,
        proxy_drives=drives,
    ))


async def list_weka_proxy_drives_with_sign_tool():
    """
    List drives using weka-sign-drive list command and return simplified drive information.
    Returns list of dicts with physical_uuid, serial, capacity_gib, device_path for weka_formatted drives only.
    """
    try:
        # Execute weka-sign-drive list -j for JSON output
        # Use proxy socket if available to see proxy-taken drives
        cmd = "/weka-sign-drive list -j"
        if os.path.exists(SSDPROXY_SOCKET_PATH):
            logging.info(f"Using proxy socket at {SSDPROXY_SOCKET_PATH}")
            cmd = f"/weka-sign-drive --unix-socket {SSDPROXY_SOCKET_PATH}:/api/v1 list -j"

        stdout, stderr, ec = await run_command(cmd)
        if ec != 0:
            logging.error(f"Failed to list drives with weka-sign-drive: {stderr}")
            raise Exception("weka-sign-drive list command failed")

        # Parse JSON output - skip non-JSON lines at the beginning
        try:
            output_text = stdout.decode('utf-8')

            # Find the start of JSON (first '{' character)
            json_start = output_text.find('{')
            if json_start == -1:
                raise ValueError("No JSON found in weka-sign-drive output")

            # Extract JSON portion
            json_text = output_text[json_start:]
            drive_data = json.loads(json_text)
        except json.JSONDecodeError as e:
            logging.error(f"Failed to parse weka-sign-drive output as JSON: {e}")
            raise

        # Extract simplified drive information for weka_formatted drives only
        drives = []
        for device_data in drive_data.get('devices', []):
            try:
                # Only process weka_formatted drives that are usable
                if device_data.get('status') != 'weka_formatted':
                    logging.debug(f"Skipping non-weka_formatted drive: {device_data.get('path', 'unknown')}")
                    continue

                weka_info = device_data.get('weka_info', {})
                cluster_guid = weka_info.get('cluster_guid') or ''
                is_proxy = weka_info.get('is_proxy', False)

                # 026938d8-a8a2-4ad4-a316-2f23358a1e7a means signed for proxy (but not yet added to proxy)
                # TODO: hardcoded "Proxy GUID" is weka bug, remove when fixed
                if cluster_guid.lower() not in ("026938d8-a8a2-4ad4-a316-2f23358a1e7a", "proxy guid") and not is_proxy:
                    logging.debug(f"Skipping drive not signed for proxy: {device_data.get('path', 'unknown')}")
                    continue

                # Extract required fields
                physical_uuid = device_data.get('physical_uuid', '')
                if not physical_uuid:
                    logging.debug(f"Skipping drive with missing physical_uuid: {device_data.get('path', 'unknown')}")
                    continue

                # Get serial number from hardware info
                hardware = device_data.get('hardware', {})
                serial = hardware.get('serial_number', '')
                iu_size = hardware.get('iu_size', 0)

                # Calculate capacity in GiB from size_bytes
                size_bytes = hardware.get('size_bytes', 0)
                if size_bytes > 0:
                    capacity_gib = int(size_bytes / (1024 ** 3))
                else:
                    logging.error(f"Drive {device_data.get('path', 'unknown')} has invalid size_bytes: {size_bytes}")
                    continue

                drives.append({
                    'physical_uuid': physical_uuid,
                    'serial': serial,
                    'capacity_gib': capacity_gib,
                    'type': iu_size_to_drive_type(iu_size),
                })

            except (KeyError, TypeError) as e:
                logging.warning(f"Failed to parse device data: {e}")
                continue

        logging.info(f"Found {len(drives)} usable weka-formatted drives")
        return drives

    except Exception as e:
        logging.error(f"Error listing drives with weka-sign-drive: {e}")
        return []


async def find_weka_drives():
    drives = []
    # ls /dev/disk/by-path/pci-0000\:03\:00.0-scsi-0\:0\:3\:0  | ssd

    devices_by_id = subprocess.check_output("ls /dev/disk/by-id/", shell=True,
                                             timeout=SUBPROCESS_DEFAULT_TIMEOUT_SEC).decode().strip().split()
    if os.path.exists("/dev/disk/by-path"):
        devices_by_path = subprocess.check_output("ls /dev/disk/by-path/", shell=True,
                                                   timeout=SUBPROCESS_DEFAULT_TIMEOUT_SEC).decode().strip().split()
    else:
        devices_by_path = []

    part_names = []

    def resolve_to_part_name():
        # TODO: A bit dirty, consolidate paths
        for device in devices_by_path:
            try:
                part_name = subprocess.check_output(f"basename $(readlink -f /dev/disk/by-path/{device})",
                                                    shell=True,
                                                    timeout=SUBPROCESS_DEFAULT_TIMEOUT_SEC).decode().strip()
            except (subprocess.CalledProcessError, subprocess.TimeoutExpired):
                logging.error(f"Failed to get part name for {device}")
                continue
            part_names.append(part_name)
        for device in devices_by_id:
            try:
                part_name = subprocess.check_output(f"basename $(readlink -f /dev/disk/by-id/{device})",
                                                    shell=True,
                                                    timeout=SUBPROCESS_DEFAULT_TIMEOUT_SEC).decode().strip()
                if part_name in part_names:
                    continue
            except (subprocess.CalledProcessError, subprocess.TimeoutExpired):
                logging.error(f"Failed to get part name for {device}")
                continue
            part_names.append(part_name)

    resolve_to_part_name()

    logging.info(f"All found in kernel block devices: {part_names}")
    for part_name in part_names:
        try:
            type_id = subprocess.check_output(f"blkid -s PART_ENTRY_TYPE -o value -p /dev/{part_name}",
                                              shell=True,
                                              timeout=SUBPROCESS_DEFAULT_TIMEOUT_SEC).decode().strip()
        except (subprocess.CalledProcessError, subprocess.TimeoutExpired):
            logging.error(f"Failed to get PART_ENTRY_TYPE for {part_name}")
            continue

        if type_id == "993ec906-b4e2-11e7-a205-a0a8cd3ea1de":
            # Read drive signature to determine if it's signed
            # Signature is at offset 8, 16 bytes
            try:
                signature_cmd = f"hexdump -v -e '1/1 \"%.2x\"' -s 8 -n 16 /dev/{part_name}"
                signature = subprocess.check_output(signature_cmd, shell=True,
                                                    timeout=SUBPROCESS_DEFAULT_TIMEOUT_SEC).decode().strip()
            except (subprocess.CalledProcessError, subprocess.TimeoutExpired):
                logging.error(f"Failed to read signature for {part_name}")
                signature = ""

            # Check if drive is signed by Weka
            # Unsigned drives have signature: 90f0090f90f0090f90f0090f90f0090f
            is_signed = signature != "" and signature != "90f0090f90f0090f90f0090f90f0090f"

            # Format weka_guid (cluster ID) if signed
            weka_guid = ""
            if is_signed and len(signature) == 32:
                # Format signature as UUID with dashes
                weka_guid = f"{signature[0:8]}-{signature[8:12]}-{signature[12:16]}-{signature[16:20]}-{signature[20:32]}"

            # resolve block_device to serial id
            pci_device_path = subprocess.check_output(f"readlink -f /sys/class/block/{part_name}",
                                                      shell=True,
                                                      timeout=SUBPROCESS_DEFAULT_TIMEOUT_SEC).decode().strip()
            device_path = "/dev/" + pci_device_path.split("/")[-2]
            serial_id = await get_device_serial_id(device_path)

            drives.append({
                "partition": "/dev/" + part_name,
                "block_device": device_path,
                "serial_id": serial_id,
                "weka_guid": weka_guid,
                "is_signed": is_signed
            })

    return drives


def is_google_cos():
    return OS_DISTRO == OS_NAME_GOOGLE_COS


def is_rhcos():
    return OS_DISTRO == OS_NAME_REDHAT_COREOS


def is_ubuntu():
    return OS_DISTRO == OS_NAME_UBUNTU


def get_ubuntu_major_version():
    """Returns the major version number (e.g., 22 or 24) if Ubuntu, otherwise None"""
    if not is_ubuntu() or not OS_BUILD_ID:
        return None
    try:
        # VERSION_ID is typically in format "22.04" or "24.04"
        return int(OS_BUILD_ID.split('.')[0])
    except (ValueError, IndexError):
        return None


def is_ubuntu_22():
    """Check if running Ubuntu 22.x"""
    return get_ubuntu_major_version() == 22

def is_ubuntu_24():
    """Check if running Ubuntu 24.x"""
    return get_ubuntu_major_version() == 24

def is_k8s_service_url(url: str) -> bool:
    p = urlparse(url)
    return (
            p.scheme in ("http", "https")
            and p.hostname is not None
            and p.hostname.endswith(".svc.cluster.local")
    )

# weka_dist_service - any distribution service weka owns (not client maintained)
def weka_dist_service():
    return DIST_SERVICE == 'https://drivers.weka.io' or is_k8s_service_url(DIST_SERVICE)


async def ensure_drivers():
    logging.info("waiting for drivers")
    drivers = "wekafsio wekafsgw mpin_user".split()
    if not is_google_cos():
        drivers.append("igb_uio")
        if version_params.get('uio_pci_generic') is not False:
            drivers.append("uio_pci_generic")
    driver_mode = await is_legacy_driver_cmd()
    logging.info(f"validating drivers in mode {MODE}, driver mode: {driver_mode}")
    if not await is_legacy_driver_cmd() and MODE in ["client", "s3",
                                                     "nfs"]:  # we are not using legacy driver on backends, as it should not be validating specific versions, so just lsmoding
        while not exiting:
            version = await get_weka_version()
            stdout, stderr, ec = await run_command(f"weka driver ready --without-agent --version {version}")
            if ec != 0:
                with open("/tmp/weka-drivers.log_tmp", "w") as f:
                    f.write("weka-drivers-loading")
                    logging.warning(f"Drivers are not loaded, waiting for them")
                os.rename("/tmp/weka-drivers.log_tmp", "/tmp/weka-drivers.log")
                logging.error(f"Failed to validate drivers {stderr.decode('utf-8')}: exc={ec}")
                await asyncio.sleep(1)
                continue
            logging.info("drivers are ready")
            break
    else:
        for driver in drivers:
            while True:
                stdout, stderr, ec = await run_command(f"lsmod | grep -w {driver}")
                if ec == 0:
                    break
                # write driver name into /tmp/weka-drivers.log
                logging.info(f"Driver {driver} not loaded, waiting for it")
                with open("/tmp/weka-drivers.log_tmp", "w") as f:
                    logging.warning(f"Driver {driver} not loaded, waiting for it")
                    f.write(driver)
                os.rename("/tmp/weka-drivers.log_tmp", "/tmp/weka-drivers.log")
                await asyncio.sleep(1)
                continue

    with open("/tmp/weka-drivers.log_tmp", "w") as f:
        f.write("")
    os.rename("/tmp/weka-drivers.log_tmp", "/tmp/weka-drivers.log")
    logging.info("All drivers loaded successfully")


# This atrocities should be replaced by new weka driver build/publish/download/install functionality
VERSION_TO_DRIVERS_MAP_WEKAFS = {
    "4.3.1.29791-9f57657d1fb70e71a3fb914ff7d75eee-dev": dict(
        wekafs="cc9937c66eb1d0be-GW_556972ab1ad2a29b0db5451e9db18748",
        uio_pci_generic=False,
        dependencies="6b519d501ea82063",
    ),
    "4.3.2.560-842278e2dca9375f84bd3784a4e7515c-dev3": dict(
        wekafs="1acd22f9ddbda67d-GW_556972ab1ad2a29b0db5451e9db18748",
        uio_pci_generic=False,
        dependencies="6b519d501ea82063",
    ),
    "4.3.2.560-842278e2dca9375f84bd3784a4e7515c-dev4": dict(
        wekafs="1acd22f9ddbda67d-GW_556972ab1ad2a29b0db5451e9db18748",
        uio_pci_generic=False,
        dependencies="6b519d501ea82063",
    ),
    "4.3.2.560-842278e2dca9375f84bd3784a4e7515c-dev5": dict(
        wekafs="1acd22f9ddbda67d-GW_556972ab1ad2a29b0db5451e9db18748",
        uio_pci_generic=False,
        dependencies="6b519d501ea82063",
    ),
    "4.3.2.783-f5fe2ec58286d9fa8fc033f920e6c842-dev": dict(
        wekafs="1cb1639d52a2b9ca-GW_556972ab1ad2a29b0db5451e9db18748",
        uio_pci_generic=False,
        dependencies="6b519d501ea82063",
    ),
    "4.3.3.28-k8s-alpha-dev": dict(
        wekafs="1cb1639d52a2b9ca-GW_556972ab1ad2a29b0db5451e9db18748",
        uio_pci_generic=False,
        dependencies="6b519d501ea82063",
    ),
    "4.3.3.28-k8s-alpha-dev2": dict(
        wekafs="1cb1639d52a2b9ca-GW_556972ab1ad2a29b0db5451e9db18748",
        uio_pci_generic=False,
        dependencies="6b519d501ea82063",
    ),
    "4.3.3.28-k8s-alpha-dev3": dict(
        wekafs="1cb1639d52a2b9ca-GW_556972ab1ad2a29b0db5451e9db18748",
        uio_pci_generic=False,
        dependencies="6b519d501ea82063",
    ),
    "4.3.2.783-f5fe2ec58286d9fa8fc033f920e6c842-dev2": dict(
        wekafs="1cb1639d52a2b9ca-GW_556972ab1ad2a29b0db5451e9db18748",
        uio_pci_generic=False,
        dependencies="6b519d501ea82063",
    ),
    "4.3.2.783-f5fe2ec58286d9fa8fc033f920e6c842-dev3": dict(
        wekafs="1cb1639d52a2b9ca-GW_556972ab1ad2a29b0db5451e9db18748",
        uio_pci_generic=False,
        dependencies="6b519d501ea82063",
    ),
    "4.2.7.64-k8so-beta.10": dict(
        wekafs="1.0.0-995f26b334137fd78d57c264d5b19852-GW_aedf44a11ca66c7bb599f302ae1dff86",
    ),
    "4.2.10.1693-251d3172589e79bd4960da8031a9a693-dev": dict(  # dev 4.2.7-based version
        wekafs="1.0.0-995f26b334137fd78d57c264d5b19852-GW_aedf44a11ca66c7bb599f302ae1dff86",
    ),
    "4.2.10.1290-e552f99e92504c69126da70e1740f6e4-dev": dict(
        wekafs="1.0.0-c50570e208c935e9129c9054140ab11a-GW_aedf44a11ca66c7bb599f302ae1dff86",
    ),
    "4.2.10-k8so.0": dict(
        wekafs="1.0.0-c50570e208c935e9129c9054140ab11a-GW_aedf44a11ca66c7bb599f302ae1dff86",
    ),
    "4.2.10.1671-363e1e8fcfb1290e061815445e973310-dev": dict(
        wekafs="1.0.0-c50570e208c935e9129c9054140ab11a-GW_aedf44a11ca66c7bb599f302ae1dff86",
    ),
    "4.3.3": dict(
        wekafs="cbd05f716a3975f7-GW_556972ab1ad2a29b0db5451e9db18748",
        uio_pci_generic=False,
        dependencies="7955984e4bce9d8b",
        weka_drivers_handling=False,
    ),
}
# WEKA_DRIVER_VERSION_OPTIONS = [
#     "1.0.0-c50570e208c935e9129c9054140ab11a-GW_aedf44a11ca66c7bb599f302ae1dff86",
#     "1.0.0-995f26b334137fd78d57c264d5b19852-GW_aedf44a11ca66c7bb599f302ae1dff86",
# ]
IGB_UIO_DRIVER_VERSION = "weka1.0.2"
MPIN_USER_DRIVER_VERSION = "1.0.1"
UIO_PCI_GENERIC_DRIVER_VERSION = "5f49bb7dc1b5d192fb01b442b17ddc0451313ea2"
DEFAULT_DEPENDENCY_VERSION = "1.0.0-024f0fdaa33ec66087bc6c5631b85819"

IMAGE_NAME = os.environ.get("IMAGE_NAME")
DEFAULT_PARAMS = dict(
    weka_drivers_handling=True,
    uio_pci_generic=False,
)
version_params = VERSION_TO_DRIVERS_MAP_WEKAFS.get(os.environ.get("IMAGE_NAME").split(":")[-1], DEFAULT_PARAMS)
if "4.2.7.64-s3multitenancy." in IMAGE_NAME:
    version_params = dict(
        wekafs="1.0.0-995f26b334137fd78d57c264d5b19852-GW_aedf44a11ca66c7bb599f302ae1dff86",
        mpin_user="f8c7f8b24611c2e458103da8de26d545",
        igb_uio="b64e22645db30b31b52f012cc75e9ea0",
        uio_pci_generic="1.0.0-929f279ce026ddd2e31e281b93b38f52",
    )
assert version_params

WEKA_DRIVERS_HANDLING = True if version_params.get("weka_drivers_handling") else False

# Implement the rest of your logic here
import asyncio
import os
import signal

loop = asyncio.get_event_loop()


async def get_weka_version():
    release_dirs = ["/opt/weka/dist/release", "/shared-weka-version/opt-weka/dist/release"]
    for release_dir in release_dirs:
        if os.path.isdir(release_dir):
            files = os.listdir(release_dir)
            if files:
                assert len(files) == 1, Exception(f"More then one release found: {files}")
                version = files[0].partition(".spec")[0]
                return version
    raise Exception(f"No release files found in any of: {release_dirs}")



@dataclass
class ReleaseSpec:
    feature_flags: Optional[str] = None


async def get_release_spec() -> ReleaseSpec:
    release_dir = "/opt/weka/dist/release"
    files = os.listdir(release_dir)
    assert len(files) == 1, Exception(f"Expected one release spec file, found: {files}")
    spec_file_path = os.path.join(release_dir, files[0])

    with open(spec_file_path, 'r') as f:
        data = json.load(f)

    # Get defined fields for ReleaseSpec to avoid TypeError with extra keys in JSON
    spec_fields = {f.name for f in fields(ReleaseSpec)}
    # Filter data to include only known fields
    filtered_data = {k: v for k, v in data.items() if k in spec_fields}

    return ReleaseSpec(**filtered_data)


async def get_feature_flags() -> FeaturesFlags:
    spec = await get_release_spec()
    return FeaturesFlags(spec.feature_flags)


async def write_feature_flags_json(result_file_name: str = "/opt/weka/k8s-runtime/feature_flags.json"):
    ff = await get_feature_flags()
    feature_flags_dict = ff.get_feature_map()

    # Write to temporary file first, then rename for atomicity
    temp_path = result_file_name + ".tmp"

    with open(temp_path, "w") as f:
        json.dump(feature_flags_dict, f)

    os.rename(temp_path, result_file_name)
    logging.info(f"Feature flags written to {result_file_name}: {feature_flags_dict}")


async def load_drivers():
    def should_skip_uio_pci_generic():
        return version_params.get('uio_pci_generic') is False or should_skip_uio()

    def should_skip_uio():
        return is_google_cos()

    def should_skip_igb_uio():
        return should_skip_uio()

    if is_rhcos():
        if os.path.isdir("/hostpath/lib/modules"):
            os.system("cp -r /hostpath/lib/modules/* /lib/modules/")

    if not WEKA_DRIVERS_HANDLING:
        # LEGACY MODE
        weka_driver_version = version_params.get('wekafs')
        download_cmds = [
            (f"mkdir -p /opt/weka/dist/drivers", "creating drivers directory"),
            (
                f"curl -kfo /opt/weka/dist/drivers/weka_driver-wekafsgw-{weka_driver_version}-$(uname -r).$(uname -m).ko {DIST_SERVICE}/dist/v1/drivers/weka_driver-wekafsgw-{weka_driver_version}-$(uname -r).$(uname -m).ko",
                "downloading wekafsgw driver"),
            (
                f"curl -kfo /opt/weka/dist/drivers/weka_driver-wekafsio-{weka_driver_version}-$(uname -r).$(uname -m).ko {DIST_SERVICE}/dist/v1/drivers/weka_driver-wekafsio-{weka_driver_version}-$(uname -r).$(uname -m).ko",
                "downloading wekafsio driver"),
            (
                f"curl -kfo /opt/weka/dist/drivers/mpin_user-{MPIN_USER_DRIVER_VERSION}-$(uname -r).$(uname -m).ko {DIST_SERVICE}/dist/v1/drivers/mpin_user-{MPIN_USER_DRIVER_VERSION}-$(uname -r).$(uname -m).ko",
                "downloading mpin_user driver")
        ]
        if not should_skip_igb_uio():
            download_cmds.append((
                f"curl -kfo /opt/weka/dist/drivers/igb_uio-{IGB_UIO_DRIVER_VERSION}-$(uname -r).$(uname -m).ko {DIST_SERVICE}/dist/v1/drivers/igb_uio-{IGB_UIO_DRIVER_VERSION}-$(uname -r).$(uname -m).ko",
                "downloading igb_uio driver"))
        if not should_skip_uio_pci_generic():
            download_cmds.append((
                f"curl -kfo /opt/weka/dist/drivers/uio_pci_generic-{UIO_PCI_GENERIC_DRIVER_VERSION}-$(uname -r).$(uname -m).ko {DIST_SERVICE}/dist/v1/drivers/uio_pci_generic-{UIO_PCI_GENERIC_DRIVER_VERSION}-$(uname -r).$(uname -m).ko",
                "downloading uio_pci_generic driver"))

        load_cmds = [
            (
                f"lsmod | grep -w wekafsgw || insmod /opt/weka/dist/drivers/weka_driver-wekafsgw-{weka_driver_version}-$(uname -r).$(uname -m).ko",
                "loading wekafsgw driver"),
            (
                f"lsmod | grep -w wekafsio || insmod /opt/weka/dist/drivers/weka_driver-wekafsio-{weka_driver_version}-$(uname -r).$(uname -m).ko",
                "loading wekafsio driver"),
            (
                f"lsmod | grep -w mpin_user || insmod /opt/weka/dist/drivers/mpin_user-{MPIN_USER_DRIVER_VERSION}-$(uname -r).$(uname -m).ko",
                "loading mpin_user driver")
        ]
        if not should_skip_uio():
            load_cmds.append((f"lsmod | grep -w uio || modprobe uio", "loading uio driver"))
        if not should_skip_igb_uio():
            load_cmds.append((
                f"lsmod | grep -w igb_uio || insmod /opt/weka/dist/drivers/igb_uio-{IGB_UIO_DRIVER_VERSION}-$(uname -r).$(uname -m).ko",
                "loading igb_uio driver"))

    else:
        # list directory /opt/weka/dist/version
        # assert single json file and take json filename
        version = await get_weka_version()


        kernelBuildIdArg = ""
        if DRIVERS_BUILD_ID != 'auto':
            kernelBuildIdArg = f"--kernel-build-id {DRIVERS_BUILD_ID}"
        elif is_google_cos():
            kernelBuildIdArg = f"--kernel-build-id {OS_BUILD_ID}"
        elif is_ubuntu_24() and weka_dist_service():
            kernelBuildIdArg = f"--kernel-build-id {UBUNTU24_BUILD_ID}"

        # When TARGET_IMAGE_NAME differs from IMAGE_NAME, weka files are copied
        # from cluster image to /shared-weka-version/ via init container
        target_image_name = os.environ.get("TARGET_IMAGE_NAME")
        if target_image_name and target_image_name != IMAGE_NAME:
            version_get_cmd = f"weka version get --without-agent --driver-only --from file://shared-weka-version/opt-weka {version}"
        else:
            version_get_cmd = f"weka version get --without-agent --driver-only {version}"

        download_cmds = [
            (version_get_cmd, "Getting version"),
            (f"weka driver download --from '{DIST_SERVICE}' --without-agent --version {version} {kernelBuildIdArg}", "Downloading drivers")
        ]
        load_cmds = [
            (f"rmmod wekafsio || echo could not unload old wekafsio driver, still trying to proceed",
             "unloading wekafsio"),
            (f"rmmod wekafsgw || echo could not unload old wekafsgw driver, still trying to proceed",
             "unloading wekafsgw"),
            (f"weka driver install --without-agent --version {version} {kernelBuildIdArg}", "loading drivers"),
        ]
    if not should_skip_uio_pci_generic():
        load_cmds.append((
            f"lsmod | grep -w uio_pci_generic || insmod /opt/weka/dist/drivers/uio_pci_generic-{UIO_PCI_GENERIC_DRIVER_VERSION}-$(uname -r).$(uname -m).ko",
            "loading uio_pci_generic driver"))

    # load vfio-pci if not loaded and iommu groups are present
    cmd = """
    if [ "$(ls -A /sys/kernel/iommu_groups/ 2>/dev/null)" ]; then
        lsmod | grep -w vfio_pci || modprobe vfio-pci
    fi
    """
    if is_google_cos():
        cmd = 'lsmod | grep -w vfio_pci || modprobe vfio-pci'
    _, stderr, ec = await run_command(cmd)
    if ec != 0:
        logging.error(f"Failed to load vfio-pci {stderr.decode('utf-8')}: exc={ec}, last command: {cmd}")
        # No exception on purpose, as we might fail various clients like openshift, that might not be able to load
        # For drives, vfio-pci is asserted in assert_vfio_pci_loaded_if_required() called from ensure_drives()

    cmd = 'lsmod | grep -w arp_tables || modprobe arp_tables'
    _, stderr, ec = await run_command(cmd)
    if ec != 0:
        logging.warning(f"Failed to load arp_tables {stderr.decode('utf-8')}: exc={ec}, last command: {cmd}")

    logging.info("Downloading and loading drivers")
    for cmd, desc in download_cmds + load_cmds:
        logging.info(f"Driver loading step: {desc}")
        stdout, stderr, ec = await run_command(cmd)
        if ec != 0:
            logging.error(f"Failed to load drivers {stderr.decode('utf-8')}: exc={ec}, last command: {cmd}")
            raise Exception(f"Failed to load drivers: {stderr.decode('utf-8')}")
    logging.info("All drivers loaded successfully")


async def setup_overlayfs_for_lib_modules():
    """
    Set up overlayfs for /lib/modules to allow writes on top of readonly host mount.
    This is needed for drivers-loader mode where we need to load kernel modules
    but want to keep the host /lib/modules readonly.

    Uses tmpfs for overlay storage and handles /lib -> usr/lib symlinks properly.
    """
    logging.info("Setting up overlayfs for /lib/modules")

    # Get the real path of /lib/modules (handles symlinks like /lib -> usr/lib)
    stdout, stderr, ec = await run_command("readlink -f /lib/modules")
    if ec != 0:
        raise Exception(f"Failed to get real path of /lib/modules: {stderr.decode('utf-8')}")
    real_path = stdout.decode('utf-8').strip()
    logging.info(f"Real path of /lib/modules: {real_path}")

    # Setup paths
    ovl_root = "/tmp/ovl-libmodules"
    upper_dir = f"{ovl_root}/upper"
    work_dir = f"{ovl_root}/work"
    ovl_mnt = f"{ovl_root}/mnt"

    # Create overlay root directory
    os.makedirs(ovl_root, exist_ok=True)

    # Check if tmpfs is already mounted, if not mount it
    stdout, stderr, ec = await run_command(f"mountpoint -q {ovl_root}")
    if ec != 0:
        # Not mounted yet, create tmpfs
        stdout, stderr, ec = await run_command(f"mount -t tmpfs -o size=512m tmpfs {ovl_root}")
        if ec != 0:
            raise Exception(f"Failed to mount tmpfs at {ovl_root}: {stderr.decode('utf-8')}")
        logging.info(f"Mounted tmpfs at {ovl_root}")

    # Create overlay directories
    os.makedirs(upper_dir, exist_ok=True)
    os.makedirs(work_dir, exist_ok=True)
    os.makedirs(ovl_mnt, exist_ok=True)

    # Create overlay view
    overlay_opts = f"lowerdir={real_path},upperdir={upper_dir},workdir={work_dir}"
    stdout, stderr, ec = await run_command(f"mount -t overlay overlay -o {overlay_opts} {ovl_mnt}")
    if ec != 0:
        raise Exception(f"Failed to mount overlayfs: {stderr.decode('utf-8')}")
    logging.info(f"Created overlay at {ovl_mnt}")

    # Overmount the real path in this mount namespace
    stdout, stderr, ec = await run_command(f"mount --bind {ovl_mnt} {real_path}")
    if ec != 0:
        raise Exception(f"Failed to bind mount overlay over {real_path}: {stderr.decode('utf-8')}")
    logging.info(f"Overmounted {real_path} with overlay")

    # If /lib/modules is not the same as real_path, keep /lib/modules consistent too
    if real_path != "/lib/modules":
        stdout, stderr, ec = await run_command(f"mount --bind {real_path} /lib/modules")
        if ec != 0:
            raise Exception(f"Failed to bind mount {real_path} to /lib/modules: {stderr.decode('utf-8')}")
        logging.info("Ensured /lib/modules points to overlay")

    logging.info(f"Overlayfs active: lower={real_path} upper={upper_dir} work={work_dir}")


async def cos_build_drivers():
    weka_driver_version = version_params["wekafs"]
    weka_driver_file_version = weka_driver_version.rsplit("-", 1)[0]
    mpin_driver_version = version_params["mpin_user"]
    igb_uio_driver_version = version_params["igb_uio"]
    uio_pci_generic_driver_version = version_params.get("uio_pci_generic", "1.0.0-929f279ce026ddd2e31e281b93b38f52")
    weka_driver_squashfs = f'/opt/weka/dist/image/weka-driver-{weka_driver_file_version}.squashfs'
    mpin_driver_squashfs = f'/opt/weka/dist/image/driver-mpin-user-{mpin_driver_version}.squashfs'
    igb_uio_driver_squashfs = f'/opt/weka/dist/image/driver-igb-uio-{igb_uio_driver_version}.squashfs'
    uio_pci_driver_squashfs = f'/opt/weka/dist/image/driver-uio-pci-generic-{uio_pci_generic_driver_version}.squashfs'
    logging.info(f"Building drivers for Google Container-Optimized OS release {OS_BUILD_ID}")
    for cmd, desc in [
        (f"apt-get install -y squashfs-tools", "installing squashfs-tools"),
        (f"mkdir -p /opt/weka/data/weka_driver/{weka_driver_version}/$(uname -r)", "downloading weka driver"),
        (f"mkdir -p /opt/weka/data/mpin_user/{MPIN_USER_DRIVER_VERSION}/$(uname -r)", "downloading mpin driver"),
        (f"mkdir -p /opt/weka/data/igb_uio/{IGB_UIO_DRIVER_VERSION}/$(uname -r)", "downloading igb_uio driver"),
        (f"mkdir -p /opt/weka/data/uio_generic/{UIO_PCI_GENERIC_DRIVER_VERSION}/$(uname -r)",
         "downloading uio_pci_generic driver"),
        (f"unsquashfs -i -f -d /opt/weka/data/weka_driver/{weka_driver_version}/$(uname -r) {weka_driver_squashfs}",
         "extracting weka driver"),
        (f"unsquashfs -i -f -d /opt/weka/data/mpin_user/{MPIN_USER_DRIVER_VERSION}/$(uname -r) {mpin_driver_squashfs}",
         "extracting mpin driver"),
        (f"unsquashfs -i -f -d /opt/weka/data/igb_uio/{IGB_UIO_DRIVER_VERSION}/$(uname -r) {igb_uio_driver_squashfs}",
         "extracting igb_uio driver"),
        (
                f"unsquashfs -i -f -d /opt/weka/data/uio_generic/{UIO_PCI_GENERIC_DRIVER_VERSION}/$(uname -r) {uio_pci_driver_squashfs}",
                "extracting uio_pci_generic driver"),
        (f"cd /opt/weka/data/weka_driver/{weka_driver_version}/$(uname -r) && /devenv.sh -R {OS_BUILD_ID} -m ",
         "building weka driver"),
        (f"cd /opt/weka/data/mpin_user/{MPIN_USER_DRIVER_VERSION}/$(uname -r) && /devenv.sh -R {OS_BUILD_ID} -m",
         "building mpin driver"),
        (f"cd /opt/weka/data/igb_uio/{IGB_UIO_DRIVER_VERSION}/$(uname -r) && /devenv.sh -R {OS_BUILD_ID} -m",
         "building igb_uio driver"),
        (
                f"cd /opt/weka/data/uio_generic/{UIO_PCI_GENERIC_DRIVER_VERSION}/$(uname -r) && /devenv.sh -R {OS_BUILD_ID} -m",
                "building uio_pci_generic driver"),
    ]:
        logging.info(f"COS driver building step: {desc}")
        stdout, stderr, ec = await run_command(cmd)
        if ec != 0:
            logging.error(f"Failed to build drivers {stderr}: exc={ec}, last command: {cmd}")
            raise Exception(f"Failed to build drivers: {stderr}")

    logging.info("Done building drivers")


def parse_cpu_allowed_list(path="/proc/1/status"):
    with open(path) as file:
        for line in file:
            if line.startswith("Cpus_allowed_list"):
                return expand_ranges(line.strip().split(":\t")[1])
    return []


def expand_ranges(ranges_str):
    ranges = []
    for part in ranges_str.split(','):
        if '-' in part:
            start, end = map(int, part.split('-'))
            ranges.extend(list(range(start, end + 1)))
        else:
            ranges.append(int(part))
    return ranges


def read_siblings_list(cpu_index):
    path = f"/sys/devices/system/cpu/cpu{cpu_index}/topology/thread_siblings_list"
    with open(path) as file:
        return expand_ranges(file.read().strip())


@dataclass
class HostInfo:
    kubernetes_distro = 'k8s'
    os = 'unknown'
    os_build_id = ''  # this is either COS build ID, OpenShift version tag (e.g. 415.92.202406111137-0), or Ubuntu VERSION_ID (e.g. 22.04, 24.04)

    def is_rhcos(self):
        return self.os == OS_NAME_REDHAT_COREOS

    def is_cos(self):
        return self.os == OS_NAME_GOOGLE_COS

    def is_ubuntu(self):
        return self.os == OS_NAME_UBUNTU


def get_host_info():
    raw_data = {}
    ret = HostInfo()
    with open("/hostside/etc/os-release") as file:
        for line in file:
            try:
                k, v = line.strip().split("=")
            except ValueError:
                continue
            if v:
                raw_data[k] = v.strip().replace('"', '')

    ret.os = raw_data.get("ID", "")

    if ret.is_rhcos():
        ret.kubernetes_distro = KUBERNETES_DISTRO_OPENSHIFT
        ret.os_build_id = raw_data.get("VERSION", "")

    elif ret.is_cos():
        ret.kubernetes_distro = KUBERNETES_DISTRO_GKE
        ret.os_build_id = raw_data.get("BUILD_ID", "")

    elif ret.is_ubuntu():
        ret.os_build_id = raw_data.get("VERSION_ID", "")
    return ret


@lru_cache
def find_full_cores(n):
    if CORE_IDS != "auto":
        return list(CORE_IDS.split(","))

    available_cores = parse_cpu_allowed_list()
    zero_siblings = [] if 0 not in available_cores else read_siblings_list(0)

    # Non-HT dedicated mode: exclude only CPU 0 (management/sidecar), not its full sibling
    # group. Unlike HT mode, no sibling pairing is required, so excluding zero_siblings would
    # unnecessarily shrink the pool — on a tight cpuset (e.g., mismatch recovery) this would
    # prevent finding enough cores even when sufficient CPUs are available.
    if CPU_POLICY == "dedicated":
        selected = [c for c in available_cores if c != 0]
        if len(selected) < n:
            logging.error(f"Error: cannot find {n} full cores")
            sys.exit(1)
        return selected[:n]

    selected_siblings = []

    for cpu_index in available_cores:
        if cpu_index in zero_siblings:
            continue

        siblings = read_siblings_list(cpu_index)
        if all(sibling in available_cores for sibling in siblings):
            if any(sibling in selected_siblings for sibling in siblings):
                continue
            selected_siblings.append(siblings[0])  # Select one sibling (the first for simplicity)
            if len(selected_siblings) == n:
                break

    if len(selected_siblings) < n:
        # If cpuset is too small for n HT pairs, the pod was likely created with wrong
        # (non-HT) CPU count — emit a clear diagnostic to identify the root cause.
        min_needed = n * 2
        if len(available_cores) < min_needed:
            logging.error(
                f"Error: cannot find {n} full cores — cpuset has only {len(available_cores)} "
                f"CPUs but {min_needed} are required for {n} HT core pairs. "
                f"Pod was likely created with incorrect (non-HT) CPU count. "
                f"Operator should recreate the pod with enough CPUs for {n} HT sibling pairs "
                f"plus management overhead (exact count depends on ExtraCores and container role)."
            )
        else:
            logging.error(f"Error: cannot find {n} full cores")
        sys.exit(1)
    else:
        return selected_siblings


def get_data_path_cores():
    """Get cores used by data path wekanode processes (slot != 0).

    These are the high-performance drive/compute/client processes that need
    dedicated cores.
    """
    try:
        result = subprocess.run(
            ["ps", "aux"],
            capture_output=True,
            text=True,
            check=True,
            timeout=SUBPROCESS_DEFAULT_TIMEOUT_SEC,
        )

        data_path_pids = []
        for line in result.stdout.splitlines():
            # Find wekanode processes that are NOT slot 0 (i.e., slot 1, 2, 3, etc.)
            if "/weka/wekanode" in line and "--slot" in line and "--slot 0" not in line:
                parts = line.split()
                if len(parts) > 1:
                    pid = parts[1]
                    data_path_pids.append(pid)

        # Get CPU affinity for each data path PID
        data_path_cores = set()
        for pid in data_path_pids:
            try:
                affinity_result = subprocess.run(
                    ["taskset", "-cp", pid],
                    capture_output=True,
                    text=True,
                    check=True,
                    timeout=SUBPROCESS_DEFAULT_TIMEOUT_SEC,
                )
                # Parse output like "pid 1673's current affinity list: 6"
                for line in affinity_result.stdout.splitlines():
                    if "affinity list:" in line:
                        affinity_str = line.split("affinity list:")[-1].strip()
                        cores = expand_ranges(affinity_str)
                        data_path_cores.update(cores)
            except subprocess.CalledProcessError as e:
                logging.debug(f"Failed to get affinity for PID {pid}: {e}")
                continue

        return list(data_path_cores)
    except Exception as e:
        logging.debug(f"Failed to get data path cores: {e}")
        return []


def get_all_reserved_cores():
    """Get all cores reserved for data path including their siblings.

    When we assign core X to a data path process, we implicitly isolate its
    sibling as well, so both X and its sibling should not be used for management.
    """
    data_path_cores = get_data_path_cores()
    all_reserved_cores = set(data_path_cores)

    # Add siblings of data path cores
    for core in data_path_cores:
        try:
            siblings = read_siblings_list(core)
            all_reserved_cores.update(siblings)
        except Exception as e:
            logging.debug(f"Failed to get siblings for core {core}: {e}")

    return list(all_reserved_cores)


def get_remaining_cores():
    """Get cores that should be used for management and other processes.

    These are the cores NOT assigned to data path processes (slot != 0)
    and NOT siblings of data path cores.
    """
    available_cores = parse_cpu_allowed_list()
    reserved_cores = get_all_reserved_cores()
    remaining = [core for core in available_cores if core not in reserved_cores]
    return remaining


def get_process_uptime(pid):
    """Get process uptime in seconds.

    Returns:
        float: Uptime in seconds, or None if unable to determine
    """
    try:
        with open(f"/proc/{pid}/stat") as f:
            stat_data = f.read()
            # Field 22 is starttime (in clock ticks since system boot)
            parts = stat_data.split()
            if len(parts) < 22:
                return None
            starttime_ticks = int(parts[21])

            # Get system uptime
            with open("/proc/uptime") as uptime_file:
                system_uptime = float(uptime_file.read().split()[0])

            # Get clock ticks per second
            clock_ticks = os.sysconf(os.sysconf_names['SC_CLK_TCK'])

            # Calculate process uptime
            starttime_seconds = starttime_ticks / clock_ticks
            process_uptime = system_uptime - starttime_seconds

            return process_uptime
    except Exception:
        return None


def get_processes_to_reassign():
    """Get PIDs of processes that should be reassigned to remaining cores.

    Excludes:
    - PID 1 (weka_runtime.py - the script doing the calculations)
    - wekanode processes with slot != 0 (drive/compute processes)
    - Processes running for less than 10 seconds (to avoid race conditions)
    """
    try:
        result = subprocess.run(
            ["ps", "aux"],
            capture_output=True,
            text=True,
            check=True,
            timeout=SUBPROCESS_DEFAULT_TIMEOUT_SEC,
        )

        pids_to_reassign = []
        for line in result.stdout.splitlines():
            parts = line.split()
            if len(parts) < 2:
                continue

            pid = parts[1]

            # Skip header line
            if pid == "PID":
                continue

            # Skip PID 1 (weka_runtime.py)
            if pid == "1":
                continue

            # Skip wekanode processes that are NOT slot 0
            # (slot 0 is management, slot 1,2,etc are drive/compute/client)
            if "/weka/wekanode" in line and "--slot 0" not in line:
                continue

            # Skip processes running for less than 10 seconds to avoid race conditions
            # Also skip if we can't determine uptime (process might have just died)
            uptime = get_process_uptime(pid)
            if uptime is None or uptime < 10.0:
                continue

            pids_to_reassign.append(pid)

        return pids_to_reassign
    except Exception as e:
        logging.debug(f"Failed to get processes to reassign: {e}")
        return []


def get_process_cmdline(pid):
    """Get full command line for a process."""
    try:
        with open(f"/proc/{pid}/cmdline") as f:
            cmdline = f.read().replace('\0', ' ').strip()
            return cmdline if cmdline else f"<PID {pid}>"
    except Exception:
        return f"<PID {pid}>"


def get_process_affinity(pid):
    """Get current CPU affinity for a process."""
    try:
        result = subprocess.run(
            ["taskset", "-cp", pid],
            capture_output=True,
            text=True,
            timeout=2
        )
        if result.returncode == 0:
            # Parse output like "pid 600's current affinity list: 2-4,34,35"
            for line in result.stdout.splitlines():
                if "affinity list:" in line:
                    affinity_str = line.split("affinity list:")[-1].strip()
                    return set(expand_ranges(affinity_str))
        return None
    except Exception:
        return None


async def manage_cpu_affinities():
    """Manage CPU affinities for non-wekanode processes.

    This function:
    1. Calculates remaining cores (excluding data path cores and their siblings)
    2. Finds all processes that should be reassigned
    3. Sets their CPU affinity to remaining cores

    Failures are non-fatal and only logged.
    """
    try:
        # Calculate core allocation
        available_cores = parse_cpu_allowed_list()
        data_path_cores = get_data_path_cores()
        reserved_cores = get_all_reserved_cores()
        remaining_cores = get_remaining_cores()

        if not remaining_cores:
            logging.warning("No remaining cores available for CPU affinity management. "
                          "All cores are reserved for data path processes.")
            return

        target_cores_set = set(remaining_cores)
        cores_str = ",".join(map(str, remaining_cores))

        pids = get_processes_to_reassign()

        # First pass: check if any changes are needed
        pids_needing_changes = []
        for pid in pids:
            try:
                current_affinity = get_process_affinity(pid)
                # Skip if we can't get affinity (process dead/unreadable)
                if current_affinity is None:
                    continue
                # Skip if already set correctly
                if current_affinity == target_cores_set:
                    continue
                pids_needing_changes.append(pid)
            except Exception:
                # Process might have exited, skip it
                continue

        # If no changes needed, return silently
        if not pids_needing_changes:
            return

        # Log only when we have changes to make
        logging.debug(f"CPU affinity calculation: available={available_cores}, "
                     f"data_path={data_path_cores}, reserved={sorted(reserved_cores)}, "
                     f"remaining={remaining_cores}")
        logging.debug(f"Managing CPU affinities: assigning processes to cores {cores_str}")
        logging.debug(f"Found {len(pids_needing_changes)} processes needing affinity changes (out of {len(pids)} checked)")

        changes_made = 0
        for pid in pids_needing_changes:
            try:
                # Get current affinity and command line for logging
                current_affinity = get_process_affinity(pid)

                # Skip if process died between first and second pass
                if current_affinity is None:
                    continue

                cmdline = get_process_cmdline(pid)

                # Set new affinity
                result = subprocess.run(
                    ["taskset", "-cp", cores_str, pid],
                    capture_output=True,
                    text=True,
                    timeout=5
                )

                if result.returncode == 0:
                    current_str = ",".join(map(str, sorted(current_affinity))) if current_affinity else "unknown"
                    logging.info(f"Changed CPU affinity for PID {pid}: {current_str} -> {cores_str} | {cmdline}")
                    changes_made += 1
                else:
                    # Process might have exited - only log at debug level
                    logging.debug(f"Failed to set affinity for PID {pid}: {result.stderr}")
            except subprocess.TimeoutExpired:
                logging.debug(f"Timeout setting affinity for PID {pid}")
            except Exception as e:
                logging.debug(f"Error setting affinity for PID {pid}: {e}")

        if changes_made > 0:
            logging.info(f"CPU affinity management: adjusted {changes_made} processes")
    except Exception as e:
        logging.warning(f"CPU affinity management failed (non-fatal): {e}")


async def periodic_cpu_affinity_management():
    """Periodically manage CPU affinities every 60 seconds.

    This task runs in the background and does not block other operations.
    Failures are logged but do not cause the container to exit.
    """
    # Initial delay to allow container to fully initialize
    await asyncio.sleep(30)

    logging.info("Starting periodic CPU affinity management (every 60 seconds)")

    while not exiting:
        try:
            await manage_cpu_affinities()
        except Exception as e:
            logging.warning(f"Periodic CPU affinity management failed (non-fatal): {e}")

        await asyncio.sleep(60)


async def await_agent():
    start = time.time()
    agent_timeout = 60 if WEKA_PERSISTENCE_MODE != "global" else 1500  # global usually is remote storage and pre-create of logs file might take much longer
    while start + agent_timeout > time.time():
        _, _, ec = await run_command("weka local ps")
        if ec == 0:
            logging.info("Weka-agent started successfully")
            return
        await asyncio.sleep(0.3)
        logging.info("Waiting for weka-agent to start")
    raise Exception(f"Agent did not come up in {agent_timeout} seconds")


processes = {}


class Daemon:
    def __init__(self, cmd, alias):
        self.cmd = cmd
        self.alias = alias
        self.process = None
        self.task = None

    async def start(self):
        logging.info(f"Starting daemon {self.alias} with cmd {self.cmd}")
        self.task = asyncio.create_task(self.monitor())
        return self.task

    async def start_process(self):
        logging.info(f"Starting process {self.cmd} for daemon {self.alias}")
        self.process = await start_process(self.cmd, self.alias)
        logging.info(f"Started process {self.cmd} for daemon {self.alias}")

    async def stop(self):
        logging.info(f"Stopping daemon {self.alias}")
        if self.task:
            self.task.cancel()
            try:
                await self.task
            except asyncio.CancelledError:
                pass
        await self.stop_process()

    async def stop_process(self):
        logging.info(f"Stopping process for daemon {self.alias}")
        if self.process:
            await stop_process(self.process)
            self.process = None
            logging.info(f"Stopped process for daemon {self.alias}")
        logging.info(f"No process found to stop")

    async def monitor(self):
        async def with_pause():
            await asyncio.sleep(3)

        while True:
            if self.process:
                if self.is_running():
                    await with_pause()
                    continue
                else:
                    logging.info(f"Daemon {self.alias} is not running")
                    await self.stop_process()
            await self.start_process()

    def is_running(self):
        if self.process is None:
            return False
        running = self.process.returncode is None
        return running


async def start_process(command, alias=""):
    """Start a daemon process."""
    # TODO: Check if already exists, not really needed unless actually adding recovery flow
    # TODO: Logs are basically thrown away into stdout . wrap agent logs as debug on logging level
    process = await asyncio.create_subprocess_shell(command, preexec_fn=os.setpgrp)
    # stdout=asyncio.subprocess.PIPE,
    # stderr=asyncio.subprocess.PIPE)
    logging.info(f"Daemon {alias or command} started with PID {process.pid}")
    processes[alias or command] = process
    logging.info(f"Daemon started with PID {process.pid} for command {command}")
    return process


async def run_command(command, capture_stdout=True, log_execution=True, env: dict = None, log_output=True):
    # TODO: Wrap stdout of commands via INFO via logging
    # Logging is controlled by log_execution and log_output parameters
    # Callers can disable logging for sensitive commands
    if log_execution:
        logging.info("Running command: " + command)
    if capture_stdout:
        pipe = asyncio.subprocess.PIPE
    else:
        pipe = None
    process = await asyncio.create_subprocess_shell("set -e\n" + command,
                                                    stdout=pipe,
                                                    stderr=pipe, env=env)
    stdout, stderr = await process.communicate()
    if log_execution:
        logging.info(f"Command {command} finished with code {process.returncode}")
    if stdout and log_output:
        logging.info(f"Command {command} stdout: {stdout.decode('utf-8')}")
    if stderr and log_output:
        logging.info(f"Command {command} stderr: {stderr.decode('utf-8')}")
    return stdout, stderr, process.returncode


async def run_logrotate():
    stdout, stderr, ec = await run_command("logrotate /etc/logrotate.conf", log_execution=False)
    if ec != 0:
        raise Exception(f"Failed to run logrotate: {stderr}")


async def write_logrotate_config():
    with open("/etc/logrotate.conf", "w") as f:
        f.write(dedent("""
            /var/log/syslog /var/log/errors {
                size 1M
                rotate 10
                missingok
                notifempty
                compress
                delaycompress
                postrotate
                  if [ -f /var/run/syslog-ng.pid ]; then
                    kill -HUP $(cat /var/run/syslog-ng.pid)
                  else
                    echo "syslog-ng.pid not found, skipping reload" >&2
                  fi
                endscript
            }
"""))


async def periodic_logrotate():
    while not exiting:
        await write_logrotate_config()
        await run_logrotate()
        await asyncio.sleep(60)


async def autodiscover_network_devices(subnet_str) -> List[str]:
    """Returns comma-separated list of network devices
    that belong to the given subnet.
    """
    subnet = ipaddress.ip_network(subnet_str, strict=False)
    cmd = f"ip -o addr"
    stdout, stderr, ec = await run_command(cmd)
    if ec != 0:
        raise Exception(f"Failed to discover network devices: {stderr}")
    lines = stdout.decode('utf-8').strip().split("\n")
    devices = []
    for line in lines:
        parts = line.split()
        if len(parts) < 4:
            continue

        device_name = parts[1]
        family = parts[2]
        ip_with_cidr = parts[3]

        # Only match address families relevant to the subnet version
        if (subnet.version == 4 and family != "inet") or (subnet.version == 6 and family != "inet6"):
            continue

        # Strip interface zone ID (e.g., fe80::1%eth0)
        ip_str = ip_with_cidr.split("/")[0].split("%")[0]

        try:
            ip = ipaddress.ip_address(ip_str)
            if ip in subnet:
                devices.append(device_name)
        except ValueError:
            continue  # skip invalid IPs

    if not devices:
        logging.error(f"No network devices found for subnet {subnet}")
    else:
        logging.info(f"Discovered network devices for subnet {subnet}: {devices}")
    return devices


async def resolve_dhcp_net(device):
    def subnet_mask_to_prefix_length(subnet_mask):
        # Convert subnet mask to binary representation
        binary_mask = ''.join([bin(int(octet) + 256)[3:] for octet in subnet_mask.split('.')])
        # Count the number of 1s in the binary representation
        prefix_length = binary_mask.count('1')
        return prefix_length

    def get_netdev_info(device):
        # Create a socket to communicate with the network interface
        s = None
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

            # Get the IP address
            ip_address = socket.inet_ntoa(fcntl.ioctl(
                s.fileno(),
                0x8915,  # SIOCGIFADDR
                struct.pack('256s', bytes(device[:15], 'utf-8'))
            )[20:24])

            # Get the netmask
            netmask = socket.inet_ntoa(fcntl.ioctl(
                s.fileno(),
                0x891b,  # SIOCGIFNETMASK
                struct.pack('256s', bytes(device[:15], 'utf-8'))
            )[20:24])
            cidr = subnet_mask_to_prefix_length(netmask)

            # Get the MAC address
            info = fcntl.ioctl(s.fileno(), 0x8927,  # SIOCGIFHWADDR
                               struct.pack('256s', bytes(device[:15], 'utf-8')))
            mac_address = ':'.join('%02x' % b for b in info[18:24])
        finally:
            if s:
                s.close()

        return mac_address, ip_address, cidr

    try:
        mac_address, ip_address, cidr = get_netdev_info(device)
    except OSError:
        raise Exception(f"Failed to get network info for device {device}, no IP address found")

    return f"'{mac_address}/{ip_address}/{cidr}'"


def should_allocate_vf_per_ionode(network_device=None):
    if network_device is None:
        network_device = NETWORK_DEVICE

    return "vf_" in network_device


async def create_container():
    if MODE not in ["compute", "drive", "client", "s3", "nfs", "smbw", "data-services"]:
        raise NotImplementedError(f"Unsupported mode: {MODE}")

    full_cores = find_full_cores(NUM_CORES)
    mode_part = MODE_CORES_FLAG.get(MODE, "")

    core_str = ",".join(map(str, full_cores))
    logging.info(f"Creating container with cores: {core_str}")

    # read join secret from if file exists /var/run/secrets/weka-operator/operator-user/password
    join_secret_cmd = ""
    join_secret_flag = ""
    if os.path.exists("/var/run/secrets/weka-operator/operator-user/join-secret"):
        join_secret_flag = "--join-secret"
        if MODE == "client":
            join_secret_flag = "--join-token"
        join_secret_cmd = "$(cat /var/run/secrets/weka-operator/operator-user/join-secret)"

    global NETWORK_DEVICE
    devices_info = None
    if not NETWORK_DEVICE and NETWORK_SELECTORS:
        devices_info = await get_devices_by_selectors(NETWORK_SELECTORS)
        NETWORK_DEVICE = ",".join(d['device'] for d in devices_info)

    if not NETWORK_DEVICE and SUBNETS:
        devices = await get_devices_by_subnets(SUBNETS)
        NETWORK_DEVICE = ",".join(devices)

    if should_allocate_vf_per_ionode():
        devices = [dev.replace("vf_", "") for dev in NETWORK_DEVICE.split(",")]
        net_str = " ".join([f"--net {d}" for d in devices]) + " --management-ips " + ",".join(MANAGEMENT_IPS)
    elif is_udp():
        net_str = "--net udp"
    else:
        # Bare-metal: create without --net, reconcile adds devices after
        net_str = "--net udp" # setting udp first, then adding nics during reconfigure

    failure_domain = FAILURE_DOMAIN

    # NOTE: client containers are set up in restricted mode by default
    # (even if you login as administrator from a restricted client, your permissions will be limited to RegularUser level⁠⁠)
    command = dedent(f"""
        weka local setup container --name {NAME} --no-start --disable\
        --core-ids {core_str} --cores {NUM_CORES} {mode_part} \
        {net_str}  --base-port {PORT} \
        {f"{join_secret_flag} {join_secret_cmd}" if join_secret_cmd else ""} \
        {f"--join-ips {JOIN_IPS}" if JOIN_IPS else ""} \
        {f"--client" if MODE == 'client' else ""} \
        {f"--restricted" if MODE == 'client' and "4.2.7.64" not in IMAGE_NAME else ""} \
        {f"--failure-domain {failure_domain}" if failure_domain else ""} \
        {f"--allow-mix-setting" if MODE == 'data-services' else ""}
    """)
    # join_secret_cmd is a shell command substitution "$(cat /path/to/secret)", not the secret value itself
    # The actual secret is read by the shell at runtime and never appears in this logged string
    # lgtm[py/clear-text-logging-sensitive-data]
    logging.info(f"Creating container with command: {command}")
    # lgtm[py/clear-text-logging-sensitive-data]
    stdout, stderr, ec = await run_command(command)
    if ec != 0:
        raise Exception(f"Failed to create container: {stderr}")
    logging.info("Container created successfully")

    if not should_allocate_vf_per_ionode() and not is_udp():
        await reconcile_net_devices()


async def configure_traces():
    # {
    #   "enabled": true,
    #   "ensure_free_space_bytes": 3221225472,
    #   "freeze_period": {
    #     "end_time": "0001-01-01T00:00:00+00:00",
    #     "retention": 0,
    #     "start_time": "0001-01-01T00:00:00+00:00"
    #   },
    #   "retention_type": "DEFAULT",
    #   "version": 1
    # }
    global DUMPER_CONFIG_MODE
    ff = await get_feature_flags()
    if DUMPER_CONFIG_MODE in ["auto", ""]:
        if ff.traces_override_partial_support:
            DUMPER_CONFIG_MODE = "partial-override"
        else:
            DUMPER_CONFIG_MODE = "cluster"

    data = dict()
    if DUMPER_CONFIG_MODE == "override":
        data = dict(enabled=True, ensure_free_space_bytes=int(ENSURE_FREE_SPACE_GB) * 1024 * 1024 * 1024,
                    retention_bytes=int(MAX_TRACE_CAPACITY_GB) * 1024 * 1024 * 1024, retention_type="BYTES", version=1,
                    freeze_period=dict(start_time="0001-01-01T00:00:00+00:00", end_time="0001-01-01T00:00:00+00:00",
                                       retention=0))
    elif DUMPER_CONFIG_MODE == "partial-override":
        data = dict(
            ensure_free_space_bytes=int(ENSURE_FREE_SPACE_GB) * 1024 * 1024 * 1024,
            retention_bytes=int(MAX_TRACE_CAPACITY_GB) * 1024 * 1024 * 1024,
            retention_type="BYTES"
        )

    data_string = json.dumps(data)

    old_full_location = "/data/reserved_space/dumper_config.json.override"
    legacy_partial_location = "/data/reserved_space/dumper_config_overrides.json"
    new_partial_location = "/traces/config_overrides.json"

    write_location = old_full_location

    if DUMPER_CONFIG_MODE == "partial-override":
        if ff.traces_override_in_slash_traces:
            write_location = new_partial_location
        else:
            write_location = legacy_partial_location

    if DUMPER_CONFIG_MODE in ["override", "partial-override"]:
        command = dedent(f"""
            set -e
            mkdir -p /opt/weka/k8s-scripts
            echo '{data_string}' > /opt/weka/k8s-scripts/dumper_config.json.override
            weka local run --container {NAME} mv /opt/weka/k8s-scripts/dumper_config.json.override {write_location}
            """)
    elif DUMPER_CONFIG_MODE == "cluster":
        command = f"""
        weka local run --container {NAME} rm -f {old_full_location} {legacy_partial_location} {new_partial_location}
        """
    else:
        raise Exception(f"Invalid DUMPER_CONFIG_MODE: {DUMPER_CONFIG_MODE}")

    if command:
        stdout, stderr, ec = await run_command(command)
        if ec != 0:
            raise Exception(f"Failed to configure traces: {stderr}")

    # Generate config.json for ssdproxy mode
    if MODE == "ssdproxy":
        config_data = dict(
            enabled=True,
            ensure_free_space_bytes=data.get("ensure_free_space_bytes", 0),
            freeze_period=dict(
                comment="",
                end_time="1970-01-01T00:00:00Z",
                retention=0,
                start_time="1970-01-01T00:00:00Z"
            ),
            retention_type="DEFAULT",
            version=1,
            weka_iops_rate=dict()
        )
        config_data_string = json.dumps(config_data)
        config_command = dedent(f"""
            set -e
            mkdir -p /opt/weka/k8s-scripts
            echo '{config_data_string}' > /opt/weka/k8s-scripts/config.json
            weka local run --container {NAME} mv /opt/weka/k8s-scripts/config.json /traces/config.json
            """)
        stdout, stderr, ec = await run_command(config_command)
        if ec != 0:
            raise Exception(f"Failed to generate traces config.json: {stderr}")

    logging.info("Traces configured successfully")


async def ensure_nics(num: int):
    command = dedent(f"""
        set -e
        mkdir -p /opt/weka/k8s-scripts
        weka local run --container {NAME} /weka/go-helpers/cloud-helper ensure-nics -n {num}
        """)
    stdout, stderr, ec = await run_command(command)
    if ec != 0:
        raise Exception(f"Failed to ensure NICs: {stderr}")
    logging.info("Ensured NICs successfully")
    write_results(
        dict(err=None, ensured=True, nics=json.loads(stdout.decode('utf-8').strip())['metadata']['vnics'][1:]))


async def get_containers():
    current_containers, stderr, ec = await run_command("weka local ps --json")
    if ec != 0:
        raise Exception(f"Failed to list containers: {stderr}")
    current_containers = json.loads(current_containers)
    return current_containers


async def get_weka_local_resources() -> dict:
    resources, stderr, ec = await run_command(f"weka local resources --container {NAME} --json", log_output=False)
    if ec != 0:
        raise Exception(f"Failed to get resources: {stderr}")
    return json.loads(resources)


def should_recreate_client_container(resources: dict) -> bool:
    if resources["base_port"] != PORT:
        return True
    if resources.get("restricted_client") is not True:
        return True
    return False


def convert_to_bytes(memory: str) -> int:
    size_str = memory.upper()
    match = re.match(r"(\d+)([KMGTPE]I?B)", size_str)
    if not match:
        raise ValueError(f"Invalid size format: {size_str}")

    size = int(match.group(1))
    unit = match.group(2)

    multipliers = {
        'B': 1,
        'KB': 10 ** 3,
        'MB': 10 ** 6,
        'GB': 10 ** 9,
        'TB': 10 ** 12,
        'PB': 10 ** 15,
        'EB': 10 ** 18,
        'KIB': 2 ** 10,
        'MIB': 2 ** 20,
        'GIB': 2 ** 30,
        'TIB': 2 ** 40,
        'PIB': 2 ** 50,
        'EIB': 2 ** 60
    }
    return size * multipliers[unit]


async def check_resources_json(resources_dir: str):
    # Check current container status and if "runStatus" is "Unknown", look for empty resources file in
    #   resources_dir ("/opt/weka/data/{NAME}/container/")
    # If resources.json.stable pointing to an empty file:
    #   look for older weka-resources*.json files in the same directory
    #   - if found, link resources.json, resources.json.stable and resources.json.staging to the latest non-empty file
    #   - if not found, remove and recreate container
    resources_file = os.path.join(resources_dir, "resources.json")
    if not os.path.exists(resources_file):
        raise Exception(f"Resources file {resources_file} does not exist")

    if os.path.getsize(resources_file) > 0:
        logging.info(f"Resources file {resources_file} is not empty, nothing to do")
        return

    logging.info(f"Resources file {resources_file} is empty, looking for older resources files")
    files = os.listdir(resources_dir)
    resource_files = [f for f in files if f.startswith("weka-resources.") and f.endswith(".json")]
    resource_files = [f for f in resource_files if os.path.getsize(os.path.join(resources_dir, f)) > 0]
    if not resource_files:
        # delete and recreate container
        logging.info(f"No older non-empty resources files found, removing and recreating container")
        await run_command("weka local stop --force", capture_stdout=False)
        await run_command(f"weka local rm --all --force", capture_stdout=False)
        await create_container()
        return

    resource_files.sort(key=lambda f: os.path.getmtime(os.path.join(resources_dir, f)), reverse=True)
    latest_file = resource_files[0]
    logging.info(f"Linking resources.json, resources.json.stable and resources.json.staging to {latest_file}")
    await link_resources_file(latest_file, resources_dir)


async def handle_existing_container(container: Dict[str, Any], resources_dir: str):
    if container.get('isRunning', False):
        logging.info("Container is already running, nothing to do")
        return

    if container.get('runStatus', '') == "Unknown":
        logging.info("Container is in Unknown state, checking resources file")
        await check_resources_json(resources_dir)


async def link_resources_file(file_name, resources_dir: str):
     # reconfigure containers
    _, stderr, ec = await run_command(f"""
        ln -sf {file_name} {resources_dir}/resources.json
        ln -sf {file_name} {resources_dir}/resources.json.stable
        ln -sf {file_name} {resources_dir}/resources.json.staging
        # at some point weka creates such, basically expecting relative path: 'resources.json.stable -> weka-resources.35fda56d-2ce3-4f98-b77c-a399df0940af.json'
        # stable flow might not even be used, and should be fixed on wekapp side
    """)
    if ec != 0:
        raise Exception(f"Failed to link resources file: {stderr}")


async def reconcile_net_devices() -> bool:
    """Reconcile network devices to match desired state. Used for both initial setup and reconfiguration."""
    if should_allocate_vf_per_ionode() or is_udp():
        return False

    target_devices = set(NETWORK_DEVICE.split(","))
    device_flags = {}

    if NETWORK_SELECTORS:
        devices_info = await get_devices_by_selectors(NETWORK_SELECTORS)
        target_devices = set(d['device'] for d in devices_info)
        device_flags = {d['device']: d for d in devices_info}
    if SUBNETS:
        target_devices = set(await get_devices_by_subnets(SUBNETS))

    resources = await get_weka_local_resources()
    net_device_names = set(dev['device'] for dev in resources['net_devices'])
    rdma_devs = resources.get('rdma_devices', {})
    rdma_device_names = set(dev['name'] for dev in rdma_devs.get('devices', []))
    current_devices = net_device_names | rdma_device_names

    to_remove = current_devices - target_devices
    to_add = target_devices - current_devices

    # Detect devices that exist but need --rdma-off: device is in rdma_devices
    # but selector says disable_rdma. Remove and re-add with correct flag.
    to_readd = set()
    for device in (target_devices & current_devices):
        if device in device_flags and device_flags[device].get('disable_rdma'):
            if device in rdma_device_names:
                to_readd.add(device)

    for device in to_remove | to_readd:
        stdout, stderr, ec = await run_command(f"weka local resources net -C {NAME} remove {device}")
        if ec != 0:
            raise Exception(f"Failed to remove net device {device}: {stderr}")
    for device in to_add | to_readd:
        flags = ""
        if device in device_flags:
            if device_flags[device].get('rdma_only'):
                flags += " --rdma-only"
            if device_flags[device].get('disable_rdma'):
                flags += " --rdma-off"
        stdout, stderr, ec = await run_command(f"weka local resources net -C {NAME} add {device}{flags}")
        if ec != 0:
            raise Exception(f"Failed to add net device {device}: {stderr}")

    return len(to_add) > 0 or len(to_remove) > 0 or len(to_readd) > 0


async def ensure_weka_container():
    resources_dir = f"/opt/weka/data/{NAME}/container"
    os.makedirs(resources_dir, exist_ok=True)

    current_containers = await get_containers()

    if len(current_containers) == 0:
        logging.info("no pre-existing containers, creating")
        await create_container()
    else:
        logging.info(f"Found {len(current_containers)} existing containers")
        container = None
        for c in current_containers:
            if c['name'] == NAME:
                container = c
                break

        if not container:
            raise Exception(f"Container with name {NAME} already exists but with different name(s): {[c['name'] for c in current_containers]}")

        await handle_existing_container(container, resources_dir)

    full_cores = find_full_cores(NUM_CORES)

    # reconfigure containers
    logging.info("Container already exists, reconfiguring")
    try:
        resources = await get_weka_local_resources()
    except Exception as e:
        if MODE == "client" and "resources.json.staging: No such file or directory" in str(e):
            logging.warning(f"Client container has corrupted state (staging file missing), removing and recreating: {e}")
            await run_command("weka local stop --force", capture_stdout=False)
            await run_command(f"weka local rm {NAME} --force", capture_stdout=False)
            await create_container()
            resources = await get_weka_local_resources()
        else:
            raise

    if MODE == "client" and should_recreate_client_container(resources):
        logging.info("Recreating client container")
        await run_command("weka local stop --force", capture_stdout=False)
        await run_command(f"weka local rm {NAME} --force", capture_stdout=False)
        await create_container()
        resources = await get_weka_local_resources()

    if MODE in MODE_CORES_FLAG and len(resources['nodes']) != (NUM_CORES + 1):
        cores_flag = MODE_CORES_FLAG[MODE]
        stdout, stderr, ec = await run_command(
            f"weka local resources cores {NUM_CORES} -C {NAME} {cores_flag} --core-ids {','.join(map(str, full_cores[:NUM_CORES]))}")
        if ec != 0:
            raise Exception(f"Failed to reconfigure cores: {stderr}")

    # TODO: unite with above block as single getter
    resources = await get_weka_local_resources()

    if MODE in ["s3", "nfs", "smbw"]:
        resources['allow_protocols'] = True
    resources['reserve_1g_hugepages'] = False
    resources['excluded_drivers'] = ["igb_uio"]
    resources['memory'] = convert_to_bytes(MEMORY)
    resources['auto_discovery_enabled'] = False
    resources["ips"] = MANAGEMENT_IPS
    resources['dpdk_base_memory_mb'] = int(os.environ.get("DPDK_BASE_MEMORY_MB", "64"))
    # update join ips
    if JOIN_IPS:
        # update backend_endpoints
        backend_endpoints = []
        for join_ip in JOIN_IPS.split(','):
            ip, port = join_ip.split(':')
            backend_endpoints.append({
                "ip": ip,
                "port": int(port),
            })
        resources['backend_endpoints'] = backend_endpoints
    ff = await get_feature_flags()
    if ff.supports_binding_to_not_all_interfaces:
        if os.environ.get("BIND_MANAGEMENT_ALL", "false").lower() == "false":
            resources["restrict_listen"] = True
        else:
            resources["restrict_listen"] = False

    nvidia_vf_single_ip = os.environ.get("NVIDIA_VF_SINGLE_IP")
    if nvidia_vf_single_ip is not None:
        resources["nvidia_vf_single_ip"] = nvidia_vf_single_ip.lower() == "true"

    # resources["mask_interrupts"] = True

    resources['auto_remove_timeout'] = AUTO_REMOVE_TIMEOUT

    cores_cursor = 0
    for node_id, node in resources['nodes'].items():
        if "MANAGEMENT" in node['roles']:
            continue
        if CPU_POLICY == "shared":
            node['dedicate_core'] = False
            node['dedicated_mode'] = "NONE"
        else:
            node['dedicate_core'] = True
        node['core_id'] = full_cores[cores_cursor]
        cores_cursor += 1

    # fix/add gateway
    if NET_GATEWAY:
        if not is_udp():
            # TODO: Multi-nic support with custom gateways
            # figure out what is meant here ^
            if len(resources['net_devices']) != 1:
                raise Exception("Gateway configuration is not supported with multiple or zero NICs")
            resources['net_devices'][0]['gateway'] = NET_GATEWAY

    # save resources
    resource_gen = str(uuid.uuid4())
    file_name = f"weka-resources.{resource_gen}.json"
    resource_file = os.path.join(resources_dir, file_name)
    with open(resource_file, "w") as f:
        json.dump(resources, f)

    await link_resources_file(file_name, resources_dir)

    # cli-based changes
    cli_changes = await reconcile_net_devices()

    # applying cli-based changes
    if cli_changes:
        stdout, stderr, ec = await run_command(f"""
            ln -sf `readlink /opt/weka/data/{NAME}/container/resources.json.staging` /opt/weka/data/{NAME}/container/resources.json.stable
            ln -sf `readlink /opt/weka/data/{NAME}/container/resources.json.staging` /opt/weka/data/{NAME}/container/resources.json
        """)
        if ec != 0:
            raise Exception(f"Failed to import resources: {stderr} \n {stdout}")


def get_boot_id():
    with open("/proc/sys/kernel/random/boot_id", "r") as file:
        boot_id = file.read().strip()
    return boot_id


def get_instructions_dir():
    # /host-binds/shared path comes from weka-container-shared-dir volume mount
    # NOTE: hostpath for this volume includes container uid subdir
    return f"/host-binds/shared/instructions/{POD_ID}/{get_boot_id()}"


@dataclass
class ShutdownInstructions:
    allow_force_stop: bool = False
    allow_stop: bool = False


async def get_shutdown_instructions() -> ShutdownInstructions:
    if not POD_ID:  ## back compat mode for when pod was scheduled without downward api
        return ShutdownInstructions()

    try:
        instructions_dir = get_instructions_dir()
        instructions_file = os.path.join(instructions_dir, "shutdown_instructions.json")

        if not os.path.exists(instructions_file):
            ret = ShutdownInstructions()
            logging.debug(f"No shutdown instructions file found at {instructions_file}")
        else:
            try:
                with open(instructions_file, "r") as file:
                    data = json.load(file)
                    ret = ShutdownInstructions(**data)
                    logging.debug(f"Loaded shutdown instructions from file: {data}")
            except (json.JSONDecodeError, OSError) as e:
                logging.warning(f"Failed to read/parse shutdown instructions file: {e}, using defaults")
                ret = ShutdownInstructions()

        if exists("/tmp/.allow-force-stop"):
            ret.allow_force_stop = True
            logging.debug("Found /tmp/.allow-force-stop file")
        if exists("/tmp/.allow-stop"):
            ret.allow_stop = True
            logging.debug("Found /tmp/.allow-stop file")
        return ret
    except Exception as e:
        logging.exception(f"Unexpected error in get_shutdown_instructions: {e}")
        return ShutdownInstructions()


async def start_weka_container():
    stdout, stderr, ec = await run_command("weka local start")
    if ec != 0:
        raise Exception(f"Failed to start container: {stderr}")
    logging.info("finished applying new config")
    logging.info(f"Container reconfigured successfully: {stdout.decode('utf-8')}")


async def configure_persistency():
    # Conditional persistent storage setup
    # External mounts (ssdproxy, shared, etc.) should work even without persistent storage
    command = dedent(f"""
        # Main persistent storage setup (only if /host-binds/opt-weka exists)
        if [ -d /host-binds/opt-weka ]; then
            mkdir -p /opt/weka-preinstalled
            # --- save weka image data separately
            mount -o bind /opt/weka /opt/weka-preinstalled
            # --- WEKA_PERSISTENCE_DIR - is HostPath (persistent volume)
            # --- put existing drivers from persistent dir to weka-preinstalled
            mkdir -p {WEKA_PERSISTENCE_DIR}/dist/drivers
            mount -o bind {WEKA_PERSISTENCE_DIR}/dist/drivers /opt/weka-preinstalled/dist/drivers
            mount -o bind {WEKA_PERSISTENCE_DIR} /opt/weka
            mkdir -p /opt/weka/dist
            # --- put weka dist back on top
            mount -o bind /opt/weka-preinstalled/dist /opt/weka/dist
            # --- make drivers dir persistent
            mount -o bind {WEKA_PERSISTENCE_DIR}/dist/drivers /opt/weka/dist/drivers
        fi

        # External mounts - always check and mount if they exist
        if [ -d /host-binds/boot-level ]; then
            BOOT_DIR=/host-binds/boot-level/$(cat /proc/sys/kernel/random/boot_id)/cleanup
            mkdir -p $BOOT_DIR
            mkdir -p /opt/weka/external-mounts/cleanup
            mount -o bind $BOOT_DIR /opt/weka/external-mounts/cleanup
        fi

        # SSD proxy mount (for proxy containers and drive containers with sharing)
        if [ -d /host-binds/ssdproxy ]; then
            mkdir -p /opt/weka/external-mounts/ssdproxy
            mount -o bind /host-binds/ssdproxy /opt/weka/external-mounts/ssdproxy
        fi

        if [ -d /host-binds/shared ]; then
            mkdir -p /host-binds/shared/local-sockets
            mkdir -p /opt/weka/external-mounts/local-sockets
            mount -o bind /host-binds/shared/local-sockets /opt/weka/external-mounts/local-sockets
        fi

        if [ -f /var/run/secrets/weka-operator/wekahome-cacert/cert.pem ]; then
            rm -rf /opt/weka/k8s-runtime/vars/wh-cacert
            mkdir -p /opt/weka/k8s-runtime/vars/wh-cacert/
            cp /var/run/secrets/weka-operator/wekahome-cacert/cert.pem /opt/weka/k8s-runtime/vars/wh-cacert/cert.pem
            chmod 400 /opt/weka/k8s-runtime/vars/wh-cacert/cert.pem
        fi

        if [ -d /host-binds/shared-configs ]; then
            # Generic, all uses should migrate to this variant
            mkdir -p /opt/weka/external-mounts/shared_boot_level
            mount -o bind /host-binds/shared-configs /opt/weka/external-mounts/shared_boot_level
        
            # Envoy-specific due to lack of generic support
            ENVOY_DIR=/opt/weka/envoy
            EXT_ENVOY_DIR=/host-binds/shared-configs/envoy
            mkdir -p $ENVOY_DIR
            mkdir -p $EXT_ENVOY_DIR
            mount -o bind $EXT_ENVOY_DIR $ENVOY_DIR
            
            # Audit-traces specific due to lack of generic support
            mkdir -p /opt/weka/wtracer
            mkdir -p /host-binds/shared-configs/audit-traces
            mount -o bind /host-binds/shared-configs/audit-traces /opt/weka/wtracer
        fi

        mkdir -p {WEKA_K8S_RUNTIME_DIR}

        touch {PERSISTENCY_CONFIGURED}
    """)

    stdout, stderr, ec = await run_command(command)
    if ec != 0:
        raise Exception(f"Failed to configure persistency: {stdout} {stderr}")

    logging.info("Persistency configured successfully")


async def ensure_weka_version(force_set=False):
    if force_set:
        cmd = "weka version set $(weka version -J | jq -r '.[0]')"
    else:
        cmd = "weka version | grep '*' || weka version set $(weka version)"
    stdout, stderr, ec = await run_command(cmd)
    if ec != 0:
        raise Exception(f"Failed to set weka version: {stderr}")
    logging.info("Weka version set successfully")


async def configure_agent(agent_handle_drivers=False):
    logging.info(f"reconfiguring agent with handle_drivers={agent_handle_drivers}")
    ignore_driver_flag = "false" if agent_handle_drivers else "true"

    env_vars = dict()

    skip_envoy_setup = ""
    if MODE == "s3":
        skip_envoy_setup = "sed -i 's/skip_envoy_setup=.*/skip_envoy_setup=true/g' /etc/wekaio/service.conf || true"

    if MODE == "envoy":
        env_vars['RESTART_EPOCH_WANTED'] = str(int(os.environ.get("envoy_restart_epoch", time.time())))
        env_vars['BASE_ID'] = PORT

    expand_condition_mounts = ""
    if MODE in ['envoy', 's3']:
        expand_condition_mounts = ",envoy-data"

    drivers_handling_cmd = f"""
    # Check if the last line contains the pattern
    CONFFILE="/etc/wekaio/service.conf"
    PATTERN="skip_driver_install"
    if tail -n 1 "$CONFFILE" | grep -q "$PATTERN"; then
        sed -i '$d' "$CONFFILE"
    fi


    #TODO: once moving to 4.3+ only switch to ignore_driver_spec. Problem that 4.2 had it in different category
    # and check by skip_driver_install is sort of abuse of not anymore existing flag to have something to validate by
    if ! grep -q "skip_driver_install" /etc/wekaio/service.conf; then
        sed -i "/\\[os\\]/a skip_driver_install={ignore_driver_flag}" /etc/wekaio/service.conf
        sed -i "/\\[os\\]/a ignore_driver_spec={ignore_driver_flag}" /etc/wekaio/service.conf
    else
        sed -i "s/skip_driver_install=.*/skip_driver_install={ignore_driver_flag}/g" /etc/wekaio/service.conf
    fi
    sed -i "s/ignore_driver_spec=.*/ignore_driver_spec={ignore_driver_flag}/g" /etc/wekaio/service.conf || true

    sed -i "s@external_mounts=.*@external_mounts=/opt/weka/external-mounts@g" /etc/wekaio/service.conf || true
    sed -i "s@conditional_mounts_ids=.*@conditional_mounts_ids=kube-serviceaccount,etc-hosts,etc-resolv{expand_condition_mounts}@g" /etc/wekaio/service.conf || true
    {skip_envoy_setup}
    """

    cmd = dedent(f"""
        {drivers_handling_cmd}
        sed -i 's/cgroups_mode=auto/cgroups_mode=none/g' /etc/wekaio/service.conf || true
        sed -i 's/override_core_pattern=true/override_core_pattern=false/g' /etc/wekaio/service.conf || true
        sed -i "s/port=14100/port={AGENT_PORT}/g" /etc/wekaio/service.conf || true
        # sed -i "s/serve_static=false/serve_static=true/g" /etc/wekaio/service.conf || true
        echo '{{"agent": {{"port": \'{AGENT_PORT}\'}}}}' > /etc/wekaio/service.json
    """)
    stdout, stderr, ec = await run_command(cmd, env=env_vars)
    if ec != 0:
        raise Exception(f"Failed to configure agent: {stderr}")

    if MACHINE_IDENTIFIER is not None:
        logging.info(f"Setting machine-id {MACHINE_IDENTIFIER}")
        os.makedirs("/opt/weka/data/agent", exist_ok=True)
        cmd = f"echo '{MACHINE_IDENTIFIER}' > /opt/weka/data/agent/machine-identifier"
        stdout, stderr, ec = await run_command(cmd)
        if ec != 0:
            raise Exception(f"Failed to set machine-id: {stderr}")
    logging.info("Agent configured successfully")


async def override_dependencies_flag():
    """Hard-code the success marker so that the dist container can start

    Equivalent to:
        ```sh
        HARDCODED=1.0.0-024f0fdaa33ec66087bc6c5631b85819
        mkdir -p /opt/weka/data/dependencies/HARDCODED/$(uname -r)/
        touch /opt/weka/data/dependencies/HARDCODED/$(uname -r)/successful
        ```
    """
    logging.info("overriding dependencies flag")
    dep_version = version_params.get('dependencies', DEFAULT_DEPENDENCY_VERSION)

    if WEKA_DRIVERS_HANDLING:
        cmd = dedent("""
        mkdir -p /opt/weka/data/dependencies
        touch /opt/weka/data/dependencies/skip
        """)
    else:
        cmd = dedent(
            f"""
            mkdir -p /opt/weka/data/dependencies/{dep_version}/$(uname -r)/
            touch /opt/weka/data/dependencies/{dep_version}/$(uname -r)/successful
            """
        )
    stdout, stderr, ec = await run_command(cmd)
    if ec != 0:
        raise Exception(f"Failed to override dependencies flag: {stderr}")
    logging.info("dependencies flag overridden successfully")


async def ensure_stem_container(name="dist"):
    logging.info("ensuring dist container")

    cmd = dedent(f"""
        if [ -d /driver-toolkit-shared ]; then
            # Mounting kernel modules from driver-toolkit-shared to dist container
            mkdir -p /lib/modules
            mkdir -p /usr/src
            mount -o bind /driver-toolkit-shared/lib/modules /lib/modules
            mount -o bind /driver-toolkit-shared/usr/src /usr/src
        fi

        weka local ps | grep {name} || weka local setup container --name {name} --net udp --base-port {PORT} --no-start --disable
        """)
    stdout, stderr, ec = await run_command(cmd)
    if ec != 0:
        raise Exception(f"Failed to create dist container: {stderr}")

    logging.info("dist container created successfully")
    # wait for container to become running


async def start_stem_container():
    logging.info("starting dist container")
    # stdout, stderr, ec = await run_command(cmd)
    # if ec != 0:
    #     raise Exception(f"Failed to start dist container: {stderr}")
    # ! start_process is deprecated and this is the only place that uses it
    # TODO: Revalidate if it needed or can be simple run_command(As it should be)
    # TODO: Still broken! hangs if running "weka local start" directly via run_command. zombie process
    await start_process(
        "weka local start")  # weka local start is not returning, so we need to daemonize it, this is a hack that needs to go away
    # reason of being stuck: agent tries to authenticate using admin:admin into this stem container, for not known reason
    logging.info("stem container started")


async def ensure_container_exec():
    logging.info("ensuring container exec")
    start = time.time()
    while True:
        stdout, stderr, ec = await run_command(f"weka local exec --container {NAME} -- ls")
        if ec == 0:
            break
        await asyncio.sleep(1)
        if time.time() - start > 300:
            raise Exception(f"Failed to exec into container in 5 minutes: {stderr}")
    logging.info("container exec ensured")


def write_results(results):
    logging.info("Writing result into /weka-runtime/results.json, results: \n%s", results)
    os.makedirs("/weka-runtime", exist_ok=True)
    with open("/weka-runtime/results.json.tmp", "w") as f:
        json.dump(results, f)
    os.rename("/weka-runtime/results.json.tmp", "/weka-runtime/results.json")


async def discovery():
    # TODO: We should move here everything else we need to discover per node
    # This might be a good place to discover drives as well, as long we have some selector to discover by
    host_info = get_host_info()

    is_ht = False
    try:
        siblings = read_siblings_list(0)
        logging.info(f"[discovery] cpu0 thread_siblings_list = {siblings}")
        if len(siblings) > 1:
            is_ht = True
    except OSError as e:
        logging.info(f"[discovery] cpu0 sibling read failed: {e}")
    logging.info(f"[discovery] is_ht={is_ht}")

    data = dict(
        is_ht=is_ht,
        kubernetes_distro=host_info.kubernetes_distro,
        os=host_info.os,
        os_build_id=host_info.os_build_id,
        schema=DISCOVERY_SCHEMA,
    )
    write_results(data)


async def install_gsutil():
    logging.info("Installing gsutil")
    await run_command("curl https://sdk.cloud.google.com | bash -s -- --disable-prompts")
    os.environ["PATH"] += ":/root/google-cloud-sdk/bin"
    await run_command("gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS")


async def cleanup_traces_and_stop_dumper():
    while True:
        cmd = "weka local exec supervisorctl status | grep RUNNING"
        stdout, stderr, ec = await run_command(cmd)
        if ec != 0:
            logging.info(f"Failed to get supervisorctl status: {stderr}")
            await asyncio.sleep(3)
            continue
        break

    stdout, stderr, ec = await run_command("""
    weka local exec supervisorctl stop weka-trace-dumper
    rm -f /opt/weka/traces/*.shard
    """)
    if ec != 0:
        logging.error(f"Failed to cleanup traces: {stderr}")


def get_agent_cmd():
    return f"exec /usr/bin/weka --agent --socket-name weka_agent_ud_socket_{AGENT_PORT}"


daemons = {

}


# k8s lifecycle/local leadership election


def cos_reboot_machine():
    logging.warning("Rebooting the host")
    os.sync()
    time.sleep(3)  # give some time to log the message and sync
    os.system("echo b > /hostside/proc/sysrq-trigger")


async def is_secure_boot_enabled():
    stdout, stderr, ec = await run_command("dmesg")
    return "Secure boot enabled" in stdout.decode('utf-8')


async def cos_disable_driver_signing_verification():
    logging.info("Checking if driver signing is disabled")
    esp_partition = "/dev/disk/by-partlabel/EFI-SYSTEM"
    mount_path = "/tmp/esp"
    grub_cfg = "efi/boot/grub.cfg"
    sed_cmds = []
    reboot_required = False

    with open("/hostside/proc/cmdline", 'r') as file:
        for line in file.readlines():
            logging.info(f"cmdline: {line}")
            if "module.sig_enforce" in line:
                if "module.sig_enforce=1" in line:
                    sed_cmds.append(('module.sig_enforce=1', 'module.sig_enforce=0'))
            else:
                sed_cmds.append(('cros_efi', 'cros_efi module.sig_enforce=0'))
            if "loadpin.enabled" in line:
                if "loadpin.enabled=1" in line:
                    sed_cmds.append(('loadpin.enabled=1', 'loadpin.enabled=0'))
            else:
                sed_cmds.append(('cros_efi', 'cros_efi loadpin.enabled=0'))
            if "loadpin.enforce" in line:
                if "loadpin.enforce=1" in line:
                    sed_cmds.append(('loadpin.enforce=1', 'loadpin.enforce=0'))
            else:
                sed_cmds.append(('cros_efi', 'cros_efi loadpin.enforce=0'))
    if sed_cmds:
        logging.warning("Must modify kernel parameters")
        if WEKA_COS_ALLOW_DISABLE_DRIVER_SIGNING:
            logging.warning("Node driver signing configuration has changed, NODE WILL REBOOT NOW!")
        else:
            raise Exception(
                "Node driver signing configuration must be changed, but WEKA_COS_ALLOW_DISABLE_DRIVER_SIGNING is not set to True. Exiting.")

        await run_command(f"mkdir -p {mount_path}")
        await run_command(f"mount {esp_partition} {mount_path}")
        current_path = os.curdir
        try:
            os.chdir(mount_path)
            for sed_cmd in sed_cmds:
                await run_command(f"sed -i 's/{sed_cmd[0]}/{sed_cmd[1]}/g' {grub_cfg}")
            reboot_required = True
        except Exception as e:
            logging.error(f"Failed to modify kernel cmdline: {e}")
            raise
        finally:
            os.chdir(current_path)
            await run_command(f"umount {mount_path}")
            if reboot_required:
                cos_reboot_machine()
    else:
        logging.info("Driver signing is already disabled")


async def cos_configure_hugepages():
    if not is_google_cos():
        logging.debug("Skipping hugepages configuration")
        return

    with open("/proc/meminfo", 'r') as meminfo:
        for line in meminfo.readlines():
            if "HugePages_Total" in line:
                hugepage_count = int(line.split()[1])
                if hugepage_count > 0:
                    logging.info(f"Node already has {hugepage_count} hugepages configured, skipping")
                    return

    logging.info("Checking if hugepages are set")
    esp_partition = "/dev/disk/by-partlabel/EFI-SYSTEM"
    mount_path = "/tmp/esp"
    grub_cfg = "efi/boot/grub.cfg"
    sed_cmds = []
    reboot_required = False

    current_path = os.curdir
    with open("/hostside/proc/cmdline", 'r') as file:
        for line in file.readlines():
            logging.info(f"cmdline: {line}")
            if "hugepagesz=" in line:
                if "hugepagesz=1g" in line.lower() and WEKA_COS_GLOBAL_HUGEPAGE_SIZE == "2m":
                    sed_cmds.append(('hugepagesz=1g', 'hugepagesz=2m'))
                elif "hugepagesz=2m" in line.lower() and WEKA_COS_GLOBAL_HUGEPAGE_SIZE == "1g":
                    sed_cmds.append(('hugepagesz=2m', 'hugepagesz=1g'))
            if "hugepages=" not in line:
                # hugepages= is not set at all
                sed_cmds.append(('cros_efi', f'cros_efi hugepages={WEKA_COS_GLOBAL_HUGEPAGE_COUNT}'))
            elif f"hugepages={WEKA_COS_GLOBAL_HUGEPAGE_COUNT}" not in line and WEKA_COS_ALLOW_HUGEPAGE_CONFIG:
                # hugepages= is set but not to the desired value, and we are allowed to change it
                sed_cmds.append(('hugepages=[0-9]+', f'hugepages={WEKA_COS_GLOBAL_HUGEPAGE_COUNT}'))
            elif f"hugepages={WEKA_COS_GLOBAL_HUGEPAGE_COUNT}" not in line and not WEKA_COS_ALLOW_HUGEPAGE_CONFIG:
                logging.info(f"Node hugepages configuration is managed externally, skipping")
    if sed_cmds:
        logging.warning("Must modify kernel HUGEPAGES parameters")
        if WEKA_COS_ALLOW_HUGEPAGE_CONFIG:
            logging.warning("Node hugepage configuration has changed, NODE WILL REBOOT NOW!")
        else:
            raise Exception(
                "Node hugepage configuration must be changed, but WEKA_COS_ALLOW_HUGEPAGE_CONFIG is not set to True. Exiting.")

        await run_command(f"mkdir -p {mount_path}")
        await run_command(f"mount {esp_partition} {mount_path}")
        try:
            os.chdir(mount_path)
            for sed_cmd in sed_cmds:
                await run_command(f"sed -i 's/{sed_cmd[0]}/{sed_cmd[1]}/g' {grub_cfg}")
            reboot_required = True
        except Exception as e:
            logging.error(f"Failed to modify kernel cmdline: {e}")
            raise
        finally:
            os.chdir(current_path)
            os.sync()
            await run_command(f"umount {mount_path}")
            if reboot_required:
                cos_reboot_machine()
    else:
        logging.info(f"Hugepages are already configured to {WEKA_COS_GLOBAL_HUGEPAGE_COUNT}x2m pages")


async def disable_driver_signing():
    if not is_google_cos():
        return
    logging.info("Ensuring driver signing is disabled")
    await cos_disable_driver_signing_verification()


SOCKET_NAME = '\0weka_runtime_' + NAME  # Abstract namespace socket
WEKA_K8S_RUNTIME_DIR = '/opt/weka/k8s-runtime'
GENERATION_PATH = f'{WEKA_K8S_RUNTIME_DIR}/runtime-generation'
CURRENT_GENERATION = str(time.time())
PERSISTENCY_CONFIGURED = f'{WEKA_K8S_RUNTIME_DIR}/persistency-configured'

_last_wrong_generation_log: float = 0.0
_WRONG_GENERATION_LOG_INTERVAL = 30  # seconds


def is_udp():
    return NETWORK_DEVICE.lower() == "udp" or UDP_MODE


async def write_generation():
    while os.path.exists("/host-binds/opt-weka") and not os.path.exists(PERSISTENCY_CONFIGURED):
        logging.info("Waiting for persistency to be configured")
        await asyncio.sleep(1)

    logging.info("Writing generation %s", CURRENT_GENERATION)
    os.makedirs(WEKA_K8S_RUNTIME_DIR, exist_ok=True)
    with open(GENERATION_PATH, 'w') as f:
        f.write(CURRENT_GENERATION)
    logging.info("current generation: %s", read_generation())


def read_generation():
    try:
        with open(GENERATION_PATH, 'r') as f:
            ret = f.read().strip()
    except Exception as e:
        logging.debug("Failed to read generation: %s", e)
        ret = ""
    return ret


async def obtain_lock():
    server = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
    server.setblocking(False)
    server.bind(SOCKET_NAME)
    return server


_server = None


async def ensure_envoy_container():
    logging.info("ensuring envoy container")
    cmd = dedent(f"""
        weka local ps | grep envoy || weka local setup envoy
    """)
    _, _, ec = await run_command(cmd)
    if ec != 0:
        raise Exception(f"Failed to ensure envoy container")
    pass


async def ensure_telemetry_container():
    logging.info("ensuring telemetry container")
    cmd = dedent(f"""
        weka local ps | grep telemetry || weka local setup telemetry --not-dependent
    """)
    _, _, ec = await run_command(cmd)
    if ec != 0:
        raise Exception(f"Failed to ensure telemetry container")
    pass


def write_telemetry_config_override():
    """Write config override for telemetry container audit traces.

    Sets tracesRetentionSize to 10GiB and minimumFreeSpace to 80% of total capacity.
    Only writes if file doesn't exist or content differs. Uses atomic write pattern.
    """
    config_path = "/opt/weka/external-mounts/shared_boot_level/audit-traces/override.config.json"
    audit_traces_dir = "/opt/weka/external-mounts/shared_boot_level/audit-traces"

    if not os.path.isdir(audit_traces_dir):
        logging.info(f"Audit traces directory {audit_traces_dir} does not exist, skipping config override")
        return

    # Calculate minimumFreeSpace as 80% of total capacity
    try:
        stat = os.statvfs(audit_traces_dir)
        total_capacity = stat.f_blocks * stat.f_frsize
        minimum_free_space = int(total_capacity * 0.2)
    except Exception as e:
        logging.warning(f"Failed to get filesystem stats for {audit_traces_dir}: {e}, using default minimumFreeSpace")
        minimum_free_space = 5368709120  # fallback to ~5GiB

    # 10GiB in bytes
    traces_retention_size = 10 * 1024 * 1024 * 1024  # 10737418240

    config_override = {
        "global": {
            "dumping": {
                "histogramRetentionSize": 134217728,
                "maxHistograms": 30000,
                "minimumFreeSpace": minimum_free_space,
                "tracesRetentionSize": traces_retention_size
            }
        }
    }

    new_content = json.dumps(config_override)

    # Check if file exists and content matches
    if os.path.exists(config_path):
        try:
            with open(config_path, 'r') as f:
                existing_content = f.read()
            if existing_content == new_content:
                logging.info(f"Telemetry config override already up to date at {config_path}")
                return
        except Exception as e:
            logging.warning(f"Failed to read existing config at {config_path}: {e}")

    # Atomic write: write to temp file then move
    temp_path = os.path.join(audit_traces_dir, f".config.json.tmp.{os.getpid()}")
    logging.info(f"Writing telemetry config override: tracesRetentionSize={traces_retention_size}, minimumFreeSpace={minimum_free_space}")
    try:
        with open(temp_path, 'w') as f:
            f.write(new_content)
        os.rename(temp_path, config_path)
        logging.info(f"Telemetry config override written to {config_path}")
    except Exception as e:
        logging.error(f"Failed to write telemetry config override: {e}")
        if os.path.exists(temp_path):
            try:
                os.remove(temp_path)
            except Exception:
                pass
        raise


async def ensure_ssdproxy_container():
    logging.info("ensuring ssdproxy container")
    proxy_memory = os.getenv("MEMORY")
    if not proxy_memory:
        raise Exception("MEMORY environment variable must be set for ssdproxy")
    cmd = dedent(f"""
        weka local ps | grep ssdproxy || weka local setup ssdproxy --memory={proxy_memory} --base-port 13000 --enable-ssdproxy-nginx
    """)
    _, _, ec = await run_command(cmd)
    if ec != 0:
        raise Exception(f"Failed to ensure ssdproxy container")

    if not os.path.exists("/usr/bin/weka-sign-drive"):
        os.symlink("/opt/weka/dist/extracted/weka-sign-drive", "/usr/bin/weka-sign-drive")
        logging.info("Created symlink /usr/bin/weka-sign-drive -> /opt/weka/dist/extracted/weka-sign-drive")


def write_file(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        f.write(content)


def is_port_free(port: int) -> bool:
    proc_files = [
        "/proc/net/tcp",
        "/proc/net/tcp6",
        "/proc/net/udp",
        "/proc/net/udp6",
    ]

    for path in proc_files:
        if not os.path.exists(path):
            continue

        with open(path, "r") as f:
            next(f)  # skip header
            for line in f:
                cols = line.split()
                if len(cols) < 10:
                    continue
                local_addr = cols[1]         # e.g. "0100007F:0016"

                try:
                    ip_hex, port_hex = local_addr.split(':')
                    used_port = int(port_hex, 16)
                except (ValueError, IndexError):
                    continue

                if used_port == 0:
                    continue

                # Check if the local port is in use (any TCP/UDP state)
                if used_port == port:
                    logging.debug(f"Port {port} is already in use")
                    return False

    return True

async def get_free_subrange_in_port_range(
        base_port: int,
        max_port: int,
        subrange_size: int,
        exclude_ports: Optional[List[int]] = None
) -> Tuple[int, int]:
    """Get a subrange of free ports of size subrange_size in the specified port range."""
    exclude_ports = sorted(exclude_ports or [])
    free_ports = set()
    not_free_ports = set()

    port = base_port
    while port <= max_port - subrange_size:
        # Skip any subranges that intersect with exclude_ports
        for exclude_port in exclude_ports:
            if port <= exclude_port < port + subrange_size:
                port = exclude_port + 1
                break
        else:
            subrange_start = port
            consecutive_free_count = 0

            for check_port in range(port, port + subrange_size):
                if check_port in free_ports:
                    consecutive_free_count += 1
                elif check_port in not_free_ports:
                    break
                else:
                    if is_port_free(check_port):
                        free_ports.add(check_port)
                        consecutive_free_count += 1
                    else:
                        not_free_ports.add(check_port)
                        break

            if consecutive_free_count == subrange_size:
                logging.info(f"Found free subrange: {subrange_start}-{subrange_start + subrange_size - 1}")
                return subrange_start, subrange_start + subrange_size - 1

            # If not all ports in the subrange were free, move to the next port
            port += 1

    raise RuntimeError(f"Could not find a subrange of {subrange_size} free ports in the specified range.")


def get_free_port(base_port: int, max_port: int, exclude_ports: Optional[List[int]] = None) -> int:
    for port in range(base_port, max_port):
        if exclude_ports and port in exclude_ports:
            continue

        if is_port_free(port):
            logging.info(f"Found free port: {port}")
            return port

    raise RuntimeError(f"Failed to find free port in range {base_port}-{max_port}")


async def ensure_client_ports():
    global PORT, AGENT_PORT
    logging.info("Ensuring client ports")

    if parse_port(PORT) > 0 and parse_port(AGENT_PORT) > 0:  # we got resources via env, so no need to wait here
        await save_weka_ports_data()
        return

    base_port = parse_port(BASE_PORT)
    port_range = parse_port(PORT_RANGE)
    assert base_port > 0, "BASE_PORT is not set"
    max_port = base_port + port_range if port_range > 0 else MAX_PORT

    try:
        if not parse_port(AGENT_PORT):
            p = get_free_port(base_port, max_port)
            AGENT_PORT = f'{p}'
        if not parse_port(PORT):
            p1, _ = await get_free_subrange_in_port_range(base_port, max_port, WEKA_CONTAINER_PORT_SUBRANGE,
                                                          exclude_ports=[int(AGENT_PORT)])
            PORT = f'{p1}'
    except RuntimeError as e:
        raise Exception(f"Failed to find free ports: {e}")
    else:
        await save_weka_ports_data()


async def save_weka_ports_data():
    write_file("/opt/weka/k8s-runtime/vars/port", str(PORT))
    write_file("/opt/weka/k8s-runtime/vars/agent_port", str(AGENT_PORT))
    logging.info(f"PORT={PORT}, AGENT_PORT={AGENT_PORT}")


def parse_port(port_str: str) -> int:
    try:
        return int(port_str)
    except ValueError:
        return 0


async def get_requested_drives():
    if not os.path.exists("/opt/weka/k8s-runtime/resources.json"):
        return []
    with open("/opt/weka/k8s-runtime/resources.json", "r") as f:
        data = json.load(f)
    return data.get("drives", [])


async def wait_for_resources():
    global PORT, AGENT_PORT, RESOURCES, FAILURE_DOMAIN, NETWORK_DEVICE

    if MODE == 'client':
        await ensure_client_ports()

    if MODE not in ['drive', 's3', 'compute', 'nfs', 'smbw', 'envoy', 'client', 'telemetry', 'data-services']:
        return

    logging.info("waiting for controller to set resources")

    while not os.path.exists("/opt/weka/k8s-runtime/resources.json"):
        logging.info("waiting for /opt/weka/k8s-runtime/resources.json")
        await asyncio.sleep(3)
        if (await get_shutdown_instructions()).allow_stop:
            raise Exception("Shutdown requested")
        continue

    # Read and validate the JSON file
    data = None
    max_retries = 10
    retry_count = 0

    while data is None and retry_count < max_retries:
        try:
            with open("/opt/weka/k8s-runtime/resources.json", "r") as f:
                content = f.read().strip()
                if not content:
                    logging.warning("resources.json is empty, waiting for content...")
                    await asyncio.sleep(3)
                    retry_count += 1
                    continue

                data = json.loads(content)
                break
        except json.JSONDecodeError as e:
            logging.warning(f"Invalid JSON in resources.json (attempt {retry_count + 1}/{max_retries}): {e}")
            logging.debug("Content of resources.json:", content)
            await asyncio.sleep(3)
            retry_count += 1
        except Exception as e:
            logging.error(f"Error reading resources.json: {e}")
            await asyncio.sleep(3)
            retry_count += 1

    if data is None:
        raise Exception(f"Failed to read valid JSON from resources.json after {max_retries} attempts")

    logging.info("found resources.json: %s", data)
    net_devices = ",".join(data.get("netDevices", []))
    if net_devices and should_allocate_vf_per_ionode(net_devices):
        NETWORK_DEVICE = net_devices

    if data.get("machineIdentifier"):
        logging.info("found machineIdentifier override, applying")
        global MACHINE_IDENTIFIER
        MACHINE_IDENTIFIER = data.get("machineIdentifier")
    if MODE == "client":
        return

    RESOURCES = data
    if "failureDomain" in data:
        FAILURE_DOMAIN = data["failureDomain"]
        logging.info("Failure Domain: %s", FAILURE_DOMAIN)
    if parse_port(PORT) == 0 and MODE not in ['envoy', 'telemetry']:
        PORT = data["wekaPort"]
    if parse_port(AGENT_PORT) == 0 and MODE != 'telemetry':
        AGENT_PORT = data["agentPort"]

    await save_weka_ports_data()


async def get_single_device_ip(device_name: str = "default") -> str:
    if device_name == "default":
        if IS_IPV6:
            cmd = "ip -6 addr show $(ip -6 route show default | awk '{print $5}' | head -n1) | grep 'inet6 ' | grep global | awk '{print $2}' | cut -d/ -f1"
        else:
            cmd = "ip route show default | grep src | awk '/default/ {print $9}' | head -n1"
    else:
        if IS_IPV6:
            # use ULA/GUA address for ipv6 (WEKA does not support link-local addresses)
            cmd = f"ip -6 addr show dev {device_name} | grep -E 'inet6 (fd|2)' | head -n1 | awk '{{print $2}}' | cut -d/ -f1"
        else:
            cmd = f"ip addr show dev {device_name} | grep 'inet ' | head -n1 | awk '{{print $2}}' | cut -d/ -f1"

    stdout, stderr, ec = await run_command(cmd)
    if ec != 0:
        raise Exception(f"Failed to get ip address for device {device_name}: {stderr}")
    ip = stdout.decode('utf-8').strip()

    # try again with a different command for default
    if not ip and device_name == "default":
        # TODO: support ipv6 in this case
        if not IS_IPV6:
            cmd = "ip -4 addr show dev $(ip route show default | awk '{print $5}') | grep inet | awk '{print $2}' | cut -d/ -f1"
            stdout, stderr, ec = await run_command(cmd)
            if ec != 0:
                raise Exception(f"Failed to get ip address for device {device_name}: {stderr}")
            ip = stdout.decode('utf-8').strip()

    if not ip:
        raise Exception(f"Failed to get ip address for device {device_name}")
    return ip


async def get_devices_waiting_for_all_subnets_to_have_device(subnets: List[str], timeout: int = 300) -> List[str]:
    """Waits for all subnets to have at least one device.
    Returns a list of devices found in all subnets.
    Raises an exception if any subnet does not have a device after the timeout.
    """
    start_time = time.time()
    while True:
        all_devices_found = True
        devices = []
        for subnet in subnets:
            devices_for_subnet = await autodiscover_network_devices(subnet)
            if not devices_for_subnet:
                all_devices_found = False
                logging.info(f"No devices found for subnet {subnet}, waiting...")
                break
            else:
                devices.extend(devices_for_subnet)

        if all_devices_found:
            logging.info("All subnets have devices. Subnets: %s, Devices: %s", subnets, devices)
            return devices

        if time.time() - start_time > timeout:
            raise Exception(f"Timeout: Not all subnets have devices after {timeout} seconds.")

        await asyncio.sleep(5)  # Wait before checking again


async def device_interface_exists(device_name: str) -> bool:
    """Check if a network interface exists by running 'ip link show dev {device_name}'."""
    proc = await asyncio.create_subprocess_exec(
        "ip", "link", "show", "dev", device_name,
        stdout=asyncio.subprocess.DEVNULL,
        stderr=asyncio.subprocess.DEVNULL,
    )
    await proc.wait()
    return proc.returncode == 0



async def filter_out_missing_devices(device_names: List[str], rdma_only: bool = False) -> List[str]:
    """Filter out devices that are not available in the system."""
    available_devices = []
    for device_name in device_names:
        try:
            if rdma_only:
                exists = await device_interface_exists(device_name)
                if exists:
                    available_devices.append(device_name)
                else:
                    logging.warning(f"Device {device_name} is not available: interface not found")
            else:
                ip = await get_single_device_ip(device_name)
                if ip:
                    available_devices.append(device_name)
                else:
                    logging.warning(f"Device {device_name} is not available: no IP address found")
        except Exception as e:
            logging.warning(f"Device {device_name} is not available: {e}")
    return available_devices


async def get_devices_by_subnets(subnets_str: str) -> List[str]:
    subnets = subnets_str.split(",")
    if not subnets:
        raise ValueError("No subnets provided or format is incorrect. Expected comma-separated list of subnets.")

    return await get_devices_waiting_for_all_subnets_to_have_device(subnets)


async def get_devices_by_selectors(selectors_str: str) -> List[dict]:
    devices = []
    seen_devices = set()
    selectors = json.loads(selectors_str)
    for selector in selectors:
        min_devices = selector.get("min", 0)
        max_devices = selector.get("max", 0)
        device_names = selector.get("deviceNames")
        subnet = selector.get("subnet")
        rdma_only = selector.get("rdmaOnly", False)
        disable_rdma = selector.get("disableRdma", False)

        if device_names:
            device_names = await filter_out_missing_devices(device_names, rdma_only=rdma_only)
            if len(device_names) < min_devices:
                raise Exception(f"Not enough devices found by deviceNames selector. Expected at least {min_devices}, found {len(device_names)}.")

            if max_devices > 0:
                device_names = device_names[:max_devices]

            for device_name in device_names:
                if device_name not in seen_devices:
                    seen_devices.add(device_name)
                    devices.append({"device": device_name, "rdma_only": rdma_only, "disable_rdma": disable_rdma})

            continue

        if not subnet:
            raise Exception("Either 'deviceNames' or 'subnet' must be provided in the selector.")

        subnet_devices = await get_devices_waiting_for_all_subnets_to_have_device([subnet])
        if len(subnet_devices) < min_devices:
            raise Exception(f"Not enough devices found in subnet {subnet}. Expected at least {min_devices}, found {len(subnet_devices)}.")

        if max_devices > 0:
            subnet_devices = subnet_devices[:max_devices]

        for device in subnet_devices:
            if device not in seen_devices:
                seen_devices.add(device)
                devices.append({"device": device, "rdma_only": rdma_only, "disable_rdma": disable_rdma})

    logging.info(f"Devices found by selectors: {devices}")

    return devices


async def write_management_ips():
    """Auto-discover management IPs and write them to a file"""
    if MODE not in ['drive', 'compute', 's3', 'nfs', 'smbw', 'client', 'data-services']:
        return

    ipAddresses = []

    if os.environ.get("MANAGEMENT_IP") and should_allocate_vf_per_ionode():
        ipAddresses.append(os.environ.get("MANAGEMENT_IP"))
    elif MANAGEMENT_IPS_SELECTORS:
        devices_info = await get_devices_by_selectors(MANAGEMENT_IPS_SELECTORS)
        for d in devices_info:
            ip = await get_single_device_ip(d['device'])
            ipAddresses.append(ip)
    elif not NETWORK_DEVICE and NETWORK_SELECTORS:
        all_devices = await get_devices_by_selectors(NETWORK_SELECTORS)
        devices = [d['device'] for d in all_devices if not d.get('rdma_only')]
        if not devices:
            raise Exception("No non-rdma-only devices available for management IPs; "
                            "configure managementIpsSelectors separately")
        for device in devices:
            ip = await get_single_device_ip(device)
            ipAddresses.append(ip)
    elif not NETWORK_DEVICE and SUBNETS:
        devices = await get_devices_by_subnets(SUBNETS)
        for device in devices:
            ip = await get_single_device_ip(device)
            ipAddresses.append(ip)
    # default udp mode (if network device is not set explicitly)
    elif is_udp():
        if NETWORK_DEVICE != 'udp':
            ip = await get_single_device_ip(NETWORK_DEVICE)
        else:
            ip = await get_single_device_ip()
        ipAddresses.append(ip)
    # if single nic is used
    elif ',' not in NETWORK_DEVICE:
        ip = await get_single_device_ip(NETWORK_DEVICE)
        ipAddresses.append(ip)
    # if multiple nics are used
    else:
        devices = NETWORK_DEVICE.split(",")
        for device in devices:
            ip = await get_single_device_ip(device)
            ipAddresses.append(ip)

    if not ipAddresses:
        raise Exception("Failed to discover management IPs")

    with open("/opt/weka/k8s-runtime/management_ips.tmp", "w") as f:
        f.write("\n".join(ipAddresses))
    os.rename("/opt/weka/k8s-runtime/management_ips.tmp", "/opt/weka/k8s-runtime/management_ips")

    logging.info(f"Management IPs: {ipAddresses}")
    global MANAGEMENT_IPS
    MANAGEMENT_IPS = ipAddresses


async def has_iommu_groups() -> bool:
    """Check if the system has IOMMU groups present."""
    iommu_check_cmd = 'ls -A /sys/kernel/iommu_groups/ 2>/dev/null'
    stdout, _, _ = await run_command(iommu_check_cmd)
    return bool(stdout.decode().strip())


async def assert_ssdproxy_iommu_supported():
    """Fail early if ssdproxy runs on an IOMMU system without feature flag support."""
    if await has_iommu_groups():
        ff = await get_feature_flags()
        if not ff.ssd_proxy_iommu_support:
            raise Exception(
                "SSD proxy mode is not supported on IOMMU-enabled systems with this Weka version. "
                "Please upgrade to a version that supports IOMMU for SSD proxy."
            )
        logging.info("IOMMU system detected, ssd_proxy_iommu_support feature flag is set")


async def assert_vfio_pci_loaded_if_required():
    """Check if vfio-pci is loaded when iommu groups are present (required for drives).

    For drives, we must ensure vfio-pci is loaded when iommu is enabled.
    Unlike clients where we just log an error, drives must fail if vfio-pci is required but not loaded.
    """
    # On Google COS, always check vfio-pci regardless of iommu groups
    if is_google_cos() or await has_iommu_groups():
        vfio_check_cmd = 'lsmod | grep -w vfio_pci'
        _, _, ec = await run_command(vfio_check_cmd)
        if ec != 0:
            raise Exception("vfio-pci module is required for drives but is not loaded. "
                          "Ensure vfio-pci module is available and can be loaded on this system.")
        logging.info("vfio-pci module is loaded (required for drives with iommu)")


async def ensure_drives():
    await assert_vfio_pci_loaded_if_required()
    sys_drives = await find_weka_drives()
    requested_drives = RESOURCES.get("drives", [])
    drives_to_setup = []
    for drive in requested_drives:
        for sd in sys_drives:
            if sd["serial_id"] == drive:
                drives_to_setup.append(sd["block_device"])
                break
        # else:
        #     raise Exception(f"Drive {drive['serial_id']} not found")

    # write discovered drives into runtime dir
    os.makedirs("/opt/weka/k8s-runtime", exist_ok=True)
    with open("/opt/weka/k8s-runtime/drives.json", "w") as f:
        json.dump([d for d in sys_drives if d['serial_id'] in requested_drives], f)
    logging.info(f"sys_drives: {sys_drives}")
    logging.info(f"requested_drives: {requested_drives}")
    logging.info(f"in-kernel drives are: {drives_to_setup}")


is_legacy_driver_command = None


async def is_legacy_driver_cmd() -> bool:
    global is_legacy_driver_command
    if is_legacy_driver_command is not None:
        return is_legacy_driver_command
    cmd = "weka driver --help | grep pack"
    stdout, stderr, ec = await run_command(cmd)
    if ec == 0:
        logging.info("Driver pack command is available, new dist mode")
        is_legacy_driver_command = False
        return False
    logging.info("Driver pack command is not available, legacy dist mode")
    is_legacy_driver_command = True
    return True


async def pack_drivers():
    logging.info("Packing drivers")
    cmd = "weka driver pack"
    stdout, stderr, ec = await run_command(cmd)
    if ec != 0:
        raise Exception(f"Failed to pack drivers: {stderr}")
    logging.info("Drivers packed successfully")


async def run_prerun_script():
    pre_run_script = os.environ.get("PRE_RUN_SCRIPT")
    if not pre_run_script:
        return
    # decode base64
    pre_run_script = base64.b64decode(pre_run_script).decode('utf-8')
    logging.info(f"Running pre-run script: {pre_run_script}")
    # save script into tmp script file
    with open("/tmp/pre-run-script.sh", "w") as f:
        f.write(pre_run_script)
    # run script
    cmd = "bash /tmp/pre-run-script.sh"
    stdout, stderr, ec = await run_command(cmd, capture_stdout=False)
    if ec != 0:
        raise Exception(f"Failed to run pre-run script: {stderr}")


async def umount_drivers():
    # TODO: Should support specific container id
    logging.info("Umounting driver")
    find_mounts_cmd = "nsenter --mount --pid --target 1 -- mount -t wekafs | awk '{print $3}'"
    stdout, stderr, ec = await run_command(find_mounts_cmd)
    if ec != 0:
        logging.info(f"Failed to find weka mounts: {stderr} {stdout}")

    errs = []
    umounted_paths = []

    for mount in stdout.decode('utf-8').split("\n"):
        if not mount:
            continue
        umount_cmd = f"nsenter --mount --pid --target 1 -- umount {mount}"
        stdout, stderr, ec = await run_command(umount_cmd)
        errs.append(stderr)
        if ec != 0:
            continue
        umounted_paths.append(mount)

    # after umounts without errors we should succeed to rmmod, be that true or not - attempting
    if len(errs) == 0:
        stdout, stderr, ec = await run_command("""
        if lsmod | grep wekafsio; then
            rmmod wekafsio
        fi
        """
                                               )
        if ec != 0:
            errs.append(stderr)

    logging.info("weka mounts umounted successfully")
    write_results(dict(
        error=errs,
        umounted_paths=umounted_paths,
    ))


async def start_syslog():
    if use_go_syslog():
        syslog = Daemon("/usr/sbin/go-syslog", "go-syslog")
    else:
        syslog = Daemon("/usr/sbin/syslog-ng -F -f /etc/syslog-ng/syslog-ng.conf --pidfile /var/run/syslog-ng.pid",
                        "syslog")

    return await syslog.start()


async def main():
    host_info = get_host_info()
    global OS_DISTRO, OS_BUILD_ID, NAME
    OS_DISTRO = host_info.os
    logging.info(f'OS_DISTRO={OS_DISTRO}')

    OS_BUILD_ID = host_info.os_build_id

    if not OS_BUILD_ID and is_google_cos():
        raise Exception("OS_BUILD_ID is not set")
    if is_google_cos():
        logging.info(f'OS_BUILD_ID={OS_BUILD_ID}')

    if MODE == "discovery":
        # self signal to exit
        logging.info("discovery mode")
        await cos_configure_hugepages()
        await discovery()
        return

    if MODE in ["drivers-builder"]:
        await run_prerun_script()
        # Default version from IMAGE_NAME
        version = await get_weka_version()
        logging.info(f"Building drivers for version: {version}")
        stdout, stderr, ec = await run_command(f"weka version get --driver-only --without-agent --no-progress-bar --from file://shared-weka-version/opt-weka {version}")
        if ec != 0:
            logging.error(f"Failed to get weka version {version}: {stderr}")
            raise Exception(f"Failed to get weka version {version}: {stderr}")
        logging.info(f"Successfully got weka version {version}")

        kernel_build_id = ""
        kernel_arg = ""
        if is_ubuntu_24():
            kernel_build_id = UBUNTU24_BUILD_ID
            kernel_arg = f"--kernel-build-id {kernel_build_id}"
        stdout, stderr, ec = await run_command(f"weka driver pack --without-agent --version {version} {kernel_arg}")
        if ec != 0:
            logging.error(f"Failed to build weka version {version}: {stderr}")
            raise Exception(f"Failed to build weka version {version}: {stderr}")
        logging.info(f"Successfully built weka version {version}")

        # Create symlink so /dist/v1/drivers/ URLs work
        stdout, stderr, ec = await run_command("mkdir -p /opt/weka/dist && ln -sf /opt/weka/dist /opt/weka/dist/v1")
        if ec != 0:
            logging.error(f"Failed to create symlink: {stderr}")
            raise Exception(f"Failed to create symlink: {stderr}")
        # Write results so operator knows build is complete
        kernel_signature = get_kernel_signature()
        if not kernel_signature:
            raise Exception("Failed to get kernel signature from built drivers")
        write_results({
            "driver_built": True,
            "err": "",
            "weka_version": version,
            "kernel_build_id": kernel_build_id,
            "kernel_signature": kernel_signature,
            "weka_pack_not_supported": False,
            "no_weka_drivers_handling": not WEKA_DRIVERS_HANDLING,
        })
        logging.info(f"Build results written for version {version}")

        # Start HTTP server to serve built drivers for operator to download
        import http.server
        import socketserver
        import threading

        serve_dir = "/opt/weka"  # Serves from /opt/weka so requests to /dist/v1/drivers/ work
        serve_port = int(PORT) if PORT else 60002

        class Handler(http.server.SimpleHTTPRequestHandler):
            def __init__(self, *args, **kwargs):
                super().__init__(*args, directory=serve_dir, **kwargs)

            def log_message(self, format, *args):
                logging.info(f"HTTP: {format % args}")

        def run_http_server():
            with socketserver.TCPServer(("", serve_port), Handler) as httpd:
                logging.info(f"Serving drivers from {serve_dir} on port {serve_port}")
                httpd.serve_forever()

        # Start server in background thread
        server_thread = threading.Thread(target=run_http_server, daemon=True)
        server_thread.start()
        logging.info(f"HTTP server started on port {serve_port}, serving /opt/weka/dist/")

        # Keep the container running to serve files
        while not exiting:
            await asyncio.sleep(10)
        return


    if MODE == "drivers-loader":
        # self signal to exit
        await override_dependencies_flag()
        # 2 minutes timeout for driver loading
        end_time = time.time() + 120
        await disable_driver_signing()

        # Set up overlayfs for /lib/modules to allow writes on readonly host mount
        try:
            await setup_overlayfs_for_lib_modules()
        except Exception as e:
            logging.error(f"Failed to set up overlayfs: {e}")
            write_results(dict(
                err=f"Failed to set up overlayfs: {str(e)}",
                drivers_loaded=False,
            ))
            return

        loaded = False
        while time.time() < end_time:
            try:
                await load_drivers()
                write_results(dict(
                    err=None,
                    drivers_loaded=True
                ))
                logging.info("Drivers loaded successfully")
                loaded = True
                return
            except Exception as e:
                await asyncio.sleep(5)
                if time.time() > end_time:
                    write_results(dict(
                        err=getattr(e, 'message', repr(e)),
                        drivers_loaded=False,
                    ))
                    # return (not raise) to avoid infinite container restarts in the pod
                    return
                logging.exception("Failed to load drivers, retrying...", exc_info=e)
                logging.info("retrying drivers download... will reach timeout in %d seconds", end_time - time.time())
        if not loaded:
            raise Exception("Failed to load drivers")
        return

    await configure_persistency()
    await wait_for_resources()
    await write_generation()  # write own generation to kill other processes
    await write_management_ips()
    global _server
    _server = await obtain_lock()  # then waiting for lock with short timeout

    # for client-mode containers, check first if there is already a frontend with the same name
    # connected to the driver (in /proc/wekafs/interface)
    # NOTE: This check is needed for integration with "External" weka client - when customer had weka client
    # on the host but outside of k8s cluster and wants to move it to k8s cluster.
    # We must wait for the external frontend to disconnect before setting up the new k8s-managed container.
    if MODE == "client":
        await wait_for_existing_frontend_disconnect(NAME)

    if MODE != "adhoc-op":  # this can be specialized container that should not have agent
        await configure_agent()
        await start_syslog()

    await override_dependencies_flag()
    if MODE not in ["drivers-dist", "drivers-loader", "drivers-builder", "adhoc-op-with-container", "envoy",
                    "adhoc-op", "telemetry"]:
        await ensure_drivers()

    if MODE != "adhoc-op":
        agent_cmd = get_agent_cmd()
        agent = Daemon(agent_cmd, "agent")
        await agent.start()
        await await_agent()
        await ensure_weka_version()

    if MODE == "drivers-dist":
        # Dist is only serving, we will invoke downloads on it, probably in stand-alone ad-hoc container, but never actually build
        # if DIST_LEGACY_MODE:
        logging.info("dist-service flow")
        await ensure_stem_container("dist")
        await configure_traces()
        await start_stem_container()
        await cleanup_traces_and_stop_dumper()
        return

    if MODE == "adhoc-op-with-container":
        NAME = "adhoc"
        await ensure_stem_container(NAME)
        await configure_traces()
        await start_stem_container()
        await ensure_container_exec()
        instruction = json.loads(INSTRUCTIONS)
        logging.info(f"adhoc-op-with-container instruction: {instruction}")
        if instruction.get('type') == 'ensure-nics':
            payload = json.loads(instruction['payload'])
            if payload.get('type') in ["aws", "oci"]:
                await ensure_nics(payload['dataNICsNumber'])
                return
            else:
                raise ValueError(f"Ensure NICs instruction type not supported: {payload.get('type')}")
        elif instruction.get('type') == 'feature-flags-update':
            ff = await get_feature_flags()
            write_results({
                "feature_flags": ff.get_feature_map(),
            })
            return
        else:
            raise ValueError(f"unsupported instruction: {instruction.get('type')}")

    if MODE == "adhoc-op":
        instruction = json.loads(INSTRUCTIONS)
        if instruction.get('type') and instruction['type'] == "discover-drives":
            await discover_drives()
        elif instruction.get('type') and instruction['type'] == 'force-resign-drives':
            logging.info(f"force-resign-drives instruction: {instruction}")
            payload = json.loads(instruction['payload'])
            device_paths = payload.get('devicePaths', [])
            device_serials = payload.get('deviceSerials', [])
            if device_paths:
                await force_resign_drives_by_paths(device_paths)
            elif device_serials:
                await force_resign_drives_by_serials(device_serials)
        elif instruction.get('type') and instruction['type'] == 'sign-drives':
            logging.info(f"sign-drives instruction: {instruction}")
            payload = json.loads(instruction['payload'])
            for_proxy = payload.get('shared', False)
            signed_drives = await sign_drives(payload)
            logging.info(f"signed_drives: {signed_drives}")
            await asyncio.sleep(3)  # a hack to give kernel a chance to update paths, as it's not instant

            if for_proxy:
                await discover_ssdproxy_drives()
            else:
                # Regular mode: discover drives and write annotation
                await discover_drives()
        elif instruction.get('type') and instruction['type'] == 'debug':
            # TODO: Wrap this as conditional based on payload, as might fail in some cases
            raw_disks = await find_disks()
            logging.info(f"Raw disks: {raw_disks}")
        # TODO: Should we support generic command proxy? security concern?
        elif instruction.get('type') and instruction['type'] == 'umount':
            logging.info(f"umounting wekafs mounts")
            await umount_drivers()
        else:
            raise ValueError(f"Unsupported instruction: {INSTRUCTIONS}")
        return

    if MODE == "envoy":
        await ensure_envoy_container()
        return

    if MODE == "ssdproxy":
        await assert_ssdproxy_iommu_supported()
        await ensure_ssdproxy_container()
        await ensure_weka_version(force_set=True)
        await configure_traces() # TODO: fragile code, we are entering configure_traces into multiple places, re-write in go and using our API will be more suitable
        return

    if MODE == "telemetry":
        await ensure_telemetry_container()
        write_telemetry_config_override()
        return

    await ensure_weka_container()
    await configure_traces()
    if MODE == "compute":
        write_telemetry_config_override()
    await start_weka_container()
    await ensure_container_exec()
    await write_feature_flags_json()
    logging.info("Container is UP and running")

    # Start periodic CPU affinity management for drive, compute, and client containers
    if MODE in ["drive", "compute", "client"]:
        asyncio.create_task(periodic_cpu_affinity_management())

    if MODE == "drive":
        await ensure_drives()


def get_kernel_signature(drivers_dir="/opt/weka/dist/drivers"):
    """
    Parse kernel signature from weka-driver zip filename in the drivers directory.
    Filename follows pattern: weka-driver-<hash>-<kernel_signature>.zip
    """

    if not os.path.isdir(drivers_dir):
        logging.warning(f"Drivers directory {drivers_dir} does not exist")
        return None

    # Look for weka-driver-*.zip file
    pattern = r'^weka-driver-[a-f0-9]+-([a-f0-9]+)\.zip$'
    for filename in os.listdir(drivers_dir):
        match = re.match(pattern, filename)
        if match:
            kernel_sig = match.group(1)
            logging.info(f"Parsed kernel signature '{kernel_sig}' from: {filename}")
            return kernel_sig

    logging.warning(f"No weka-driver zip file found in {drivers_dir}")
    return None



async def stop_process(process):
    logging.info(f"stopping daemon with pid {process.pid} (via process group), {process}")

    async def cleanup_process():
        for k, v in list(processes.items()):
            if v == process:
                logging.info(f"removing process {k}")
                del processes[k]
        logging.info(f"waiting for process {process.pid} to exit")
        await process.wait()
        logging.info(f"process {process.pid} exited")

    if process.returncode is not None:
        await cleanup_process()
        return

    pgid = os.getpgid(process.pid)
    logging.info(f"stopping process group {pgid}")
    os.killpg(pgid, signal.SIGTERM)
    logging.info(f"process group {pgid} stopped")
    await cleanup_process()


def is_wrong_generation():
    global _last_wrong_generation_log
    # These modes have no persistent storage — /host-binds/opt-weka is not mounted,
    # so GENERATION_PATH is container-local. A new pod cannot write a generation visible
    # to the old pod, meaning the mechanism cannot work. Skip the check to avoid
    # misleading log noise.
    if MODE in ['drivers-loader', 'discovery', 'drivers-builder']:
        return False

    current_generation = read_generation()
    if current_generation == "":
        return False

    if current_generation != CURRENT_GENERATION:
        now = time.time()
        if now - _last_wrong_generation_log >= _WRONG_GENERATION_LOG_INTERVAL:
            logging.error("Wrong generation detected, exiting, current:%s, read: %s", CURRENT_GENERATION, current_generation)
            _last_wrong_generation_log = now
        return True
    return False


async def takeover_shutdown():
    while not is_wrong_generation():
        await asyncio.sleep(1)

    logging.info("takeover_shutdown called")
    await run_command("weka local stop --force", capture_stdout=False)


DRIVER_INTERFACE_PATH = "/proc/wekafs/interface"


def get_active_mounts(file_path="/proc/wekafs/interface") -> int:
    """Get the number of active mounts from the specified file.
    Return -1 if the number of active mounts cannot be determined.
    """
    try:
        with open(file_path, "r") as file:
            for line in file:
                if line.startswith("Active mounts:"):
                    # Extract the number after "Active mounts:"
                    return int(line.split(":")[1].strip())
    except FileNotFoundError:
        logging.error(f"File '{file_path}' not found.")
    except ValueError:
        logging.error(f"Failed to parse the number of active mounts.")
    except Exception as e:
        logging.error(f"Failed to get the number of active mounts: {e}")
    return -1

async def read_file(path: str) -> str:
    loop = asyncio.get_running_loop()
    return await loop.run_in_executor(
        None,
        lambda: open(path, "rt").read()
    )


async def read_file_shell(path: str) -> str:
    """Read a file using cat via shell.

    This is useful for special files (like /proc files) where direct file open has issues.

    Args:
        path: The path to the file to read

    Returns:
        The contents of the file as a string

    Raises:
        FileNotFoundError: If the file does not exist
        Exception: If the file cannot be read for other reasons
    """
    stdout, stderr, returncode = await run_command(
        f"cat {path}", log_execution=False, log_output=False
    )
    if returncode != 0:
        stderr_text = stderr.decode('utf-8') if stderr else ''
        if "No such file" in stderr_text:
            raise FileNotFoundError(f"File not found: {path}")
        raise Exception(f"Failed to read {path}: {stderr_text or 'unknown error'}")
    return stdout.decode('utf-8') if stdout else ""


async def is_frontend_connected(container_name: str) -> bool:
    """Check if a frontend container with the given name is connected to the driver.

    Args:
        container_name: The name of the container to check for

    Returns:
        True if a connected frontend with the given container name exists, False otherwise

    Raises:
        Exception: If the driver interface file cannot be read (except FileNotFoundError)
    """
    try:
        data = await read_file_shell(DRIVER_INTERFACE_PATH)
        for line in data.splitlines():
            # Look for lines like: Container=150136828323client FE 0: Connected frontend pid 1226063
            if line.startswith(f"Container={container_name}") and "Connected frontend" in line:
                return True
        return False
    except FileNotFoundError:
        # File doesn't exist on new hosts - no frontends connected, safe to proceed
        logging.debug(f"Driver interface file '{DRIVER_INTERFACE_PATH}' not found - no existing frontends")
        return False
    except Exception as e:
        raise Exception(f"Failed to read driver interface file '{DRIVER_INTERFACE_PATH}': {e}")


async def wait_for_existing_frontend_disconnect(container_name: str, timeout_seconds: int = 120):
    """Wait for any existing connected frontend with the given container name to disconnect.

    This function checks /proc/wekafs/interface for existing connected frontends with the same
    container name. If found, it waits up to timeout_seconds for the frontend to disconnect.

    Args:
        container_name: The name of the container to check for
        timeout_seconds: Maximum time to wait in seconds (default: 120 = 2 minutes)

    Raises:
        Exception: If a connected frontend with the same name still exists after timeout
        Exception: If the driver interface file cannot be read
    """
    start_time = time.time()
    check_interval = 5  # Check every 5 seconds

    while await is_frontend_connected(container_name):
        elapsed = time.time() - start_time
        remaining = timeout_seconds - elapsed

        if elapsed >= timeout_seconds:
            raise TimeoutError(
                f"Timeout waiting for existing frontend container '{container_name}' to disconnect. "
                f"A frontend with this name is still connected after {timeout_seconds} seconds. "
                f"Cannot setup new weka local container while an existing one with the same name is connected."
            )

        logging.info(
            f"Frontend container '{container_name}' is still connected. "
            f"Waiting for it to disconnect... (timeout in {remaining:.0f} seconds)"
        )
        await asyncio.sleep(check_interval)

    logging.info(f"No connected frontend with name '{container_name}' found - safe to proceed")


async def wait_for_shutdown_instruction():
    logging.info("Entered wait_for_shutdown_instruction() - waiting for shutdown approval from controller")
    iteration = 0
    while True:
        iteration += 1
        try:
            shutdown_instructions = await get_shutdown_instructions()

            if shutdown_instructions.allow_force_stop:
                logging.info("Received 'allow-force-stop' instruction - proceeding with force shutdown")
                return
            if shutdown_instructions.allow_stop:
                logging.info("Received 'allow-stop' instruction - proceeding with graceful shutdown")
                return

            if iteration % 6 == 1:  # Log every 30 seconds (every 6th iteration)
                logging.info(f"Waiting for shutdown instruction... (iteration {iteration}, elapsed ~{iteration * 5}s)")
            await asyncio.sleep(5)
        except Exception as e:
            logging.exception(f"Error in wait_for_shutdown_instruction loop (iteration {iteration}): {e}")
            await asyncio.sleep(5)


async def watch_for_force_shutdown():
    while True:
        if (await get_shutdown_instructions()).allow_force_stop:
            logging.info("Received 'allow-force-stop' instruction")
            await run_command("weka local stop --force", capture_stdout=False)
            return
        await asyncio.sleep(5)


async def is_container_running(no_agent_as_not_running=False):
    try:
        containers = await get_containers()
    except Exception as e:
        if no_agent_as_not_running:
            logging.exception("agent error, due to force stop - assuming container is not running")
            return False
        else:
            logging.exception("agent error, since no force stop - assuming container is running")
            return True
    for container in containers:
        if container['name'] == NAME:
            if container['runStatus'] == "Stopped":
                return False
            return True
    return False


async def shutdown():
    global exiting
    while not (exiting or is_wrong_generation()):
        await asyncio.sleep(1)
        continue

    logging.warning("Received signal, stopping all processes")
    exiting = True  # multiple entry points of shutdown, exiting is global check for various conditions

    if MODE not in ["drivers-loader", "discovery", "ensure-nics"]:
        logging.info(f"Shutdown for MODE={MODE}: checking if shutdown instruction is needed")
        if MODE in ["client", "s3", "nfs", "smbw", "drive", "compute"]:
            logging.info(f"MODE={MODE} requires shutdown instruction approval - calling wait_for_shutdown_instruction()")
            try:
                await wait_for_shutdown_instruction()
                logging.info("wait_for_shutdown_instruction() completed successfully")
            except Exception as e:
                logging.exception(f"CRITICAL: wait_for_shutdown_instruction() failed with exception: {e}")
                raise

        force_stop = False
        if (await get_shutdown_instructions()).allow_force_stop:
            force_stop = True
        if is_wrong_generation():
            force_stop = True
        if MODE not in ["s3", "drive", "compute", "nfs", "smbw", "data-services"]:
            force_stop = True
        stop_flag = "--force" if force_stop else "-g"

        force_shutdown_task = None
        if "--force" not in stop_flag:
            force_shutdown_task = asyncio.create_task(watch_for_force_shutdown())

        while await is_container_running(no_agent_as_not_running=force_stop):
            await run_command(f"timeout 180 weka local stop {stop_flag}", capture_stdout=False)
            await asyncio.sleep(3)

        if force_shutdown_task is not None:
            force_shutdown_task.cancel()
        logging.info("finished stopping weka container")

    if MODE == "drive":
        timeout = 60
        # print out in-kernel devices for up to 60 seconds every 0.3 seconds
        requested_drives = await get_requested_drives()
        requested_drives_returned = True
        logging.info(f"Waiting for {len(requested_drives)} requested drives to return to kernel: {requested_drives}")

        for _ in range(int(timeout / 0.3)):
            drives = await find_weka_drives()
            logging.info(f"Found {len(drives)}: {drives}")
            in_kernel_drives_serials = [d['serial_id'] for d in drives]

            requested_drives_returned = True
            for requested_serial in requested_drives:
                if requested_serial not in in_kernel_drives_serials:
                    logging.info(f"Requested drive {requested_serial} not found in kernel drives")
                    requested_drives_returned = False

            if requested_drives_returned:
                logging.info("All requested drives returned to kernel")
                break

            await asyncio.sleep(0.3)

        if not requested_drives_returned:
            logging.error("Not all requested drives returned to kernel after waiting")

    for key, process in dict(processes.items()).items():
        logging.info(f"stopping process {process.pid}, {key}")
        await stop_process(process)
        logging.info(f"process {process.pid} stopped")

    tasks = [t for t in asyncio.all_tasks(loop) if t is not asyncio.current_task(loop)]
    [task.cancel() for task in tasks]

    logging.info("All processes stopped, stopping main loop")
    loop.stop()
    logging.info("Main loop stopped")


exiting = False


def signal_handler(sig):
    global exiting
    logging.info(f"Received signal {sig}")
    exiting = True


def reap_zombies():
    # agent leaves zombies behind on weka local start
    while True:
        time.sleep(1)
        try:
            # Wait for any child process, do not block
            pid, _ = os.waitpid(-1, os.WNOHANG)
            if pid == 0:  # No zombie to reap
                continue
        except ChildProcessError:
            # No child processes
            continue


zombie_collector = threading.Thread(target=reap_zombies, daemon=True)
zombie_collector.start()

# Setup signal handler for graceful shutdown
loop.add_signal_handler(signal.SIGINT, partial(signal_handler, "SIGINT"))
loop.add_signal_handler(signal.SIGTERM, partial(signal_handler, "SIGTERM"))

shutdown_task = loop.create_task(shutdown())
takeover_shutdown_task = loop.create_task(takeover_shutdown())

main_loop = loop.create_task(main())
if MODE not in ["adhoc-op"] and not use_go_syslog():
    logrotate_task = loop.create_task(periodic_logrotate())


try:
    try:
        loop.run_until_complete(main_loop)
        loop.run_forever()
    except RuntimeError:
        if exiting:
            logging.info("Cancelled")
        else:
            raise
finally:
    if _server is not None:
        _server.close()
    debug_sleep = int(os.environ.get("WEKA_OPERATOR_DEBUG_SLEEP", 3))
    logging.info(f"{debug_sleep} seconds exit-sleep to allow for debugging and ensure proper sync")
    start = time.time()
    while time.time() - start < debug_sleep:
        if os.path.exists("/tmp/.cancel-debug-sleep"):
            break
        time.sleep(1)
