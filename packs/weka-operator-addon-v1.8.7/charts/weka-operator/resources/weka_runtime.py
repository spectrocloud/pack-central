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


MODE = os.environ.get("MODE")
assert MODE != ""
NUM_CORES = int(os.environ.get("CORES", 0))
CORE_IDS = os.environ.get("CORE_IDS", "auto")
CPU_POLICY = os.environ.get("CPU_POLICY", "auto")
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
OS_DISTRO = ""
OS_BUILD_ID = ""
DISCOVERY_SCHEMA = 1
INSTRUCTIONS = os.environ.get("INSTRUCTIONS", "")
NODE_NAME = os.environ["NODE_NAME"]
POD_ID = os.environ.get("POD_ID", "")
FAILURE_DOMAIN = os.environ.get("FAILURE_DOMAIN", None)
MACHINE_IDENTIFIER = os.environ.get("MACHINE_IDENTIFIER", None)
NET_GATEWAY = os.environ.get("NET_GATEWAY", None)
IS_IPV6 = os.environ.get("IS_IPV6", "false") == "true"
MANAGEMENT_IPS = []  # to be populated at later stage
UDP_MODE = os.environ.get("UDP_MODE", "false") == "true"
DUMPER_CONFIG_MODE = os.environ.get("DUMPER_CONFIG_MODE", "auto")

KUBERNETES_DISTRO_OPENSHIFT = "openshift"
KUBERNETES_DISTRO_GKE = "gke"
OS_NAME_GOOGLE_COS = "cos"
OS_NAME_REDHAT_COREOS = "rhcos"

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

# Define global variables
exiting = 0

# Formatter with channel name
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

# Define handlers for stdout and stderr
stdout_handler = logging.StreamHandler(sys.stdout)
stdout_handler.setLevel(logging.DEBUG)
stderr_handler = logging.StreamHandler(sys.stderr)
stderr_handler.setLevel(logging.WARNING)

# Basic configuration
logging.basicConfig(
    level=logging.DEBUG,  # Global minimum logging level
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',  # Include timestamp
    handlers=[stdout_handler, stderr_handler]
)

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
    supports_binding_to_not_all_interfaces: Union[bool, int] = 1

    def __init__(self, b64_flags: Optional[str]) -> None:
        active: Set[int] = set(parse_feature_bitmap(b64_flags or ""))

        # Walk over class attributes that are ints (flag indices)
        for name, bit in self.__class__.__dict__.items():
            if isinstance(bit, int):  # skip dunders, methods, etc.
                # true  ⇢ flag bit present, false ⇢ absent
                setattr(self, name, bit in active)

        # Store raw list/set if needed elsewhere
        self._active_bits: Set[int] = active


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

async def get_serial_id_fallback(device_path: str) -> Optional[str]:
    """
    Fallback method to get serial ID for a device using udev data.
    This is useful for non-nvme devices where lsblk might not report a serial.
    """
    device_name = os.path.basename(device_path)
    logging.info(f"Attempting fallback to get serial for {device_name}")
    try:
        # Get major:minor device number
        dev_index_out, _, ec = await run_command(f"cat /sys/block/{device_name}/dev")
        if ec != 0:
            logging.warning(f"Fallback failed: could not get dev index for {device_name}")
            return None
        dev_index = dev_index_out.decode().strip()

        # Get serial from udev data
        serial_id_cmd = f"cat /host/run/udev/data/b{dev_index} | grep ID_SERIAL="
        serial_id_out, _, ec = await run_command(serial_id_cmd)
        if ec != 0:
            logging.warning(f"Fallback failed: could not get ID_SERIAL from udev for {device_name}")
            return None

        serial_id = serial_id_out.decode().strip().split("=")[-1]
        logging.info(f"Fallback successful for {device_name}, found serial: {serial_id}")
        return serial_id
    except Exception as e:
        logging.error(f"Exception during serial ID fallback for {device_name}: {e}")
        return None


async def sign_drives_by_pci_info(vendor_id: str, device_id: str, options: dict) -> List[str]:
    logging.info("Signing drives. Vendor ID: %s, Device ID: %s", vendor_id, device_id)

    if not vendor_id or not device_id:
        raise ValueError("Vendor ID and Device ID are required")

    cmd = f"lspci -d {vendor_id}:{device_id}" + " | sort | awk '{print $1}'"
    stdout, stderr, ec = await run_command(cmd)
    if ec != 0:
        return

    signed_drives = []
    pci_devices = stdout.decode().strip().split()
    for pci_device in pci_devices:
        device = f"/dev/disk/by-path/pci-0000:{pci_device}-nvme-1"
        try:
            await sign_device_path(device, options)
            signed_drives.append(device)
        except SignException as e:
            logging.error(str(e))
            continue
    return signed_drives


async def find_disks() -> List[Disk]:
    """
    Find all disk devices and check if they or their partitions are mounted.
    :return: A list of Disk objects.
    """
    logging.info("Finding disks and checking mount status")
    # Use -J for JSON output, -p for full paths, -o to specify columns
    # TODO: We are dependant on lsblk here on host here. Is it a probelm? potentially
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

    for device in data.get("blockdevices", []):
        if device.get("type") == "disk":
            is_mounted = has_mountpoint(device)
            serial_id = device.get("serial")
            device_path = device["name"]
            if not serial_id:
                logging.warning(f"lsblk did not return serial for {device_path}. Using fallback.")
                serial_id = await get_serial_id_fallback(device_path)
            if is_google_cos():
                logging.info(f"Using COS-specific method for {device_path}")
                device_name = os.path.basename(device_path)
                serial_id = await get_serial_id_cos_specific(device_name)

            logging.info(f"Found drive: {device_path}, mounted: {is_mounted}, serial: {serial_id}")
            disks.append(Disk(path=device_path, is_mounted=is_mounted, serial_id=serial_id))

    return disks


async def sign_not_mounted(options: dict) -> List[str]:
    """
    Signs all disk devices that are not mounted and have no mounted partitions.
    :param options:
    :return: list of signed drive paths
    """
    logging.info("Signing drives that are not mounted")
    all_disks = await find_disks()
    signed_drives = []

    unmounted_disks = [disk for disk in all_disks if not disk.is_mounted]
    logging.info(f"Found {len(unmounted_disks)} unmounted disks to sign: {[d.path for d in unmounted_disks]}")

    for disk in unmounted_disks:
        try:
            await sign_device_path(disk.path, options)
            signed_drives.append(disk.path)
        except SignException as e:
            logging.error(str(e))
            continue
    return signed_drives


async def sign_device_paths(devices_paths, options) -> List[str]:
    signed_drives = []
    for device_path in devices_paths:
        try:
            await sign_device_path(device_path, options)
            signed_drives.append(device_path)
        except SignException as e:
            logging.error(str(e))
            continue
    return signed_drives


class SignException(Exception):
    pass


async def sign_device_path(device_path, options: SignOptions):
    logging.info(f"Signing drive {device_path}")
    params = []
    if options.allowEraseWekaPartitions:
        params.append("--allow-erase-weka-partitions")
    if options.allowEraseNonWekaPartitions:
        params.append("--allow-erase-non-weka-partitions")
    if options.allowNonEmptyDevice:
        params.append("--allow-non-empty-device")
    if options.skipTrimFormat:
        params.append("--skip-trim-format")

    stdout, stderr, ec = await run_command(
        f"/weka-sign-drive {' '.join(params)} -- {device_path}")
    if ec != 0:
        err = f"Failed to sign drive {device_path}: {stderr}"
        raise SignException(err)

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

    logging.info(f"Found {len(stdout.decode().strip().split())} drives to sign")
    signed_drives = []
    dev_devices = stdout.decode().strip().split("\n")
    for dev_device in dev_devices:
        device = f"/dev/{dev_device}"
        try:
            await sign_device_path(device, options)
            signed_drives.append(device)

        except SignException as e:
            logging.error(str(e))
            continue
    return signed_drives

async def sign_drives(instruction: dict) -> List[str]:
    type = instruction['type']
    options = SignOptions(**instruction.get('options', {})) if instruction.get('options') else SignOptions()

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
    signed_drives = []
    options = SignOptions(allowEraseWekaPartitions=True)
    for device_path in devices_paths:
        try:
            await sign_device_path(device_path, options)
            signed_drives.append(device_path)
        except SignException as e:
            logging.error(str(e))
            continue
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
        return
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


async def find_weka_drives():
    drives = []
    # ls /dev/disk/by-path/pci-0000\:03\:00.0-scsi-0\:0\:3\:0  | ssd

    devices_by_id = subprocess.check_output("ls /dev/disk/by-id/", shell=True).decode().strip().split()
    if os.path.exists("/dev/disk/by-path"):
        devices_by_path = subprocess.check_output("ls /dev/disk/by-path/", shell=True).decode().strip().split()
    else:
        devices_by_path = []

    part_names = []

    def resolve_to_part_name():
        # TODO: A bit dirty, consolidate paths
        for device in devices_by_path:
            try:
                part_name = subprocess.check_output(f"basename $(readlink -f /dev/disk/by-path/{device})",
                                                    shell=True).decode().strip()
            except subprocess.CalledProcessError:
                logging.error(f"Failed to get part name for {device}")
                continue
            part_names.append(part_name)
        for device in devices_by_id:
            try:
                part_name = subprocess.check_output(f"basename $(readlink -f /dev/disk/by-id/{device})",
                                                    shell=True).decode().strip()
                if part_name in part_names:
                    continue
            except subprocess.CalledProcessError:
                logging.error(f"Failed to get part name for {device}")
                continue
            part_names.append(part_name)

    resolve_to_part_name()

    logging.info(f"All found in kernel block devices: {part_names}")
    for part_name in part_names:
        try:
            type_id = subprocess.check_output(f"blkid -s PART_ENTRY_TYPE -o value -p /dev/{part_name}",
                                              shell=True).decode().strip()
        except subprocess.CalledProcessError:
            logging.error(f"Failed to get PART_ENTRY_TYPE for {part_name}")
            continue

        if type_id == "993ec906-b4e2-11e7-a205-a0a8cd3ea1de":
            # TODO: Read and populate actual weka guid here
            weka_guid = ""
            # resolve block_device to serial id
            pci_device_path = subprocess.check_output(f"readlink -f /sys/class/block/{part_name}",
                                                      shell=True).decode().strip()
            if "nvme" in part_name:
                # 3 directories up is the serial id
                serial_id_path = "/".join(pci_device_path.split("/")[:-2]) + "/serial"
                serial_id = subprocess.check_output(f"cat {serial_id_path}", shell=True).decode().strip()
                device_path = "/dev/" + pci_device_path.split("/")[-2]
                if is_google_cos():
                    serial_id = await get_serial_id_cos_specific(os.path.basename(device_path))
            else:
                device_name = pci_device_path.split("/")[-2]
                device_path = "/dev/" + device_name
                dev_index = subprocess.check_output(f"cat /sys/block/{device_name}/dev", shell=True).decode().strip()
                serial_id_cmd = f"cat /host/run/udev/data/b{dev_index} | grep ID_SERIAL="
                serial_id = subprocess.check_output(serial_id_cmd, shell=True).decode().strip().split("=")[-1]

            drives.append({
                "partition": "/dev/" + part_name,
                "block_device": device_path,
                "serial_id": serial_id,
                "weka_guid": weka_guid
            })

    return drives


def is_google_cos():
    return OS_DISTRO == OS_NAME_GOOGLE_COS


def is_rhcos():
    return OS_DISTRO == OS_NAME_REDHAT_COREOS


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
    files = os.listdir("/opt/weka/dist/release")
    assert len(files) == 1, Exception(f"More then one release found: {files}")
    version = files[0].partition(".spec")[0]
    return version


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

        cluster_image_name = os.environ.get("CLUSTER_IMAGE_NAME")
        if cluster_image_name is not None and cluster_image_name != IMAGE_NAME:
            # when driversLoaderImage is set, we need to detect the cluster version
            # and to get the driver files for that version
            version = cluster_image_name.split(':')[-1]
            logging.info(f"Should get version: {version}")
            version_get_cmds = [
                (f"cp /usr/bin/weka /usr/bin/weka-save && unlink /usr/bin/weka && mv /usr/bin/weka-save /usr/bin/weka", "Use image weka cli"),
                (f"rm -rf /opt/weka/dist && ln -s /shared-weka-version-data/dist /opt/weka/dist", "Use cluster dist files"),
            ]
            for cmd, desc in version_get_cmds:
                logging.info(f"Driver get step: {desc}")
                stdout, stderr, ec = await run_command(cmd)
                if ec != 0:
                    logging.error(f"Failed to get drivers {stderr.decode('utf-8')}: exc={ec}, last command: {cmd}")
                    raise Exception(f"Failed to get drivers: {stderr.decode('utf-8')}")

        if is_google_cos():
            kernelBuildIdArg = f"--kernel-build-id {OS_BUILD_ID}"
        else:
            kernelBuildIdArg = ""

        download_cmds = [
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
    cmd = '[ "$(ls -A /sys/kernel/iommu_groups/)" ] && lsmod | grep -w vfio_pci || modprobe vfio-pci'
    if is_google_cos():
        cmd = 'lsmod | grep -w vfio_pci || modprobe vfio-pci'
    _, stderr, ec = await run_command(cmd)
    if ec != 0:
        logging.error(f"Failed to load vfio-pci {stderr.decode('utf-8')}: exc={ec}, last command: {cmd}")
        raise Exception(f"Failed to load vfio-pci: {stderr}")

    logging.info("Downloading and loading drivers")
    for cmd, desc in download_cmds + load_cmds:
        logging.info(f"Driver loading step: {desc}")
        stdout, stderr, ec = await run_command(cmd)
        if ec != 0:
            logging.error(f"Failed to load drivers {stderr.decode('utf-8')}: exc={ec}, last command: {cmd}")
            raise Exception(f"Failed to load drivers: {stderr.decode('utf-8')}")
    logging.info("All drivers loaded successfully")


async def copy_drivers():
    if WEKA_DRIVERS_HANDLING:
        return

    weka_driver_version = version_params.get('wekafs')
    assert weka_driver_version

    stdout, stderr, ec = await run_command(dedent(f"""
      mkdir -p /opt/weka/dist/drivers
      cp /opt/weka/data/weka_driver/{weka_driver_version}/$(uname -r)/wekafsio.ko /opt/weka/dist/drivers/weka_driver-wekafsio-{weka_driver_version}-$(uname -r).$(uname -m).ko
      cp /opt/weka/data/weka_driver/{weka_driver_version}/$(uname -r)/wekafsgw.ko /opt/weka/dist/drivers/weka_driver-wekafsgw-{weka_driver_version}-$(uname -r).$(uname -m).ko

      cp /opt/weka/data/igb_uio/{IGB_UIO_DRIVER_VERSION}/$(uname -r)/igb_uio.ko /opt/weka/dist/drivers/igb_uio-{IGB_UIO_DRIVER_VERSION}-$(uname -r).$(uname -m).ko
      cp /opt/weka/data/mpin_user/{MPIN_USER_DRIVER_VERSION}/$(uname -r)/mpin_user.ko /opt/weka/dist/drivers/mpin_user-{MPIN_USER_DRIVER_VERSION}-$(uname -r).$(uname -m).ko
      {"" if version_params.get('uio_pci_generic') == False else f"cp /opt/weka/data/uio_generic/{UIO_PCI_GENERIC_DRIVER_VERSION}/$(uname -r)/uio_pci_generic.ko /opt/weka/dist/drivers/uio_pci_generic-{UIO_PCI_GENERIC_DRIVER_VERSION}-$(uname -r).$(uname -m).ko"}
    """))
    if ec != 0:
        logging.info(f"Failed to copy drivers post build {stderr}: exc={ec}")
        raise Exception(f"Failed to copy drivers post build: {stderr}")
    logging.info("done copying drivers")


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
    os_build_id = ''  # this is either COS build ID OR OpenShift version tag, e.g. 415.92.202406111137-0

    def is_rhcos(self):
        return self.os == OS_NAME_REDHAT_COREOS

    def is_cos(self):
        return self.os == OS_NAME_GOOGLE_COS


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
    return ret


@lru_cache
def find_full_cores(n):
    if CORE_IDS != "auto":
        return list(CORE_IDS.split(","))

    selected_siblings = []

    available_cores = parse_cpu_allowed_list()
    zero_siblings = [] if 0 not in available_cores else read_siblings_list(0)

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
            check=True
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
                    check=True
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
            check=True
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


def is_managed_k8s(network_device=None):
    if network_device is None:
        network_device = NETWORK_DEVICE

    return "aws_" in network_device or "oci_" in network_device


async def create_container():
    if MODE not in ["compute", "drive", "client", "s3", "nfs"]:
        raise NotImplementedError(f"Unsupported mode: {MODE}")

    full_cores = find_full_cores(NUM_CORES)
    mode_part = ""
    if MODE == "compute":
        mode_part = "--only-compute-cores"
    elif MODE == "drive":
        mode_part = "--only-drives-cores"
    elif MODE == "client":
        mode_part = "--only-frontend-cores"
    elif MODE == "s3":
        mode_part = "--only-frontend-cores"
    elif MODE == "nfs":
        mode_part = "--only-frontend-cores"

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
    if not NETWORK_DEVICE and NETWORK_SELECTORS:
        devices = await get_devices_by_selectors(NETWORK_SELECTORS)
        NETWORK_DEVICE = ",".join(devices)

    if not NETWORK_DEVICE and SUBNETS:
        devices = await get_devices_by_subnets(SUBNETS)
        NETWORK_DEVICE = ",".join(devices)

    if is_managed_k8s():
        devices = [dev.replace("aws_", "").replace("oci_", "") for dev in NETWORK_DEVICE.split(",")]
        net_str = " ".join([f"--net {d}" for d in devices]) + " --management-ips " + ",".join(MANAGEMENT_IPS)
    elif ',' in NETWORK_DEVICE:
        net_str = " ".join([f"--net {d}" for d in NETWORK_DEVICE.split(",")])
    else:
        if not NETWORK_DEVICE:
            raise Exception("NETWORK_DEVICE not set")

        if is_udp():
            net_str = f"--net udp"
        else:
            net_str = f"--net {NETWORK_DEVICE}"

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
        {f"--failure-domain {failure_domain}" if failure_domain else ""}
    """)
    logging.info(f"Creating container with command: {command}")
    stdout, stderr, ec = await run_command(command)
    if ec != 0:
        raise Exception(f"Failed to create container: {stderr}")
    logging.info("Container created successfully")


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

    if MODE == 'dist':
        data['enabled'] = False
        data['retention_bytes'] = 1 * 1024 * 1024 * 1024 # value should not be in effect due to enabled=False
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
    # Check current container status and if "runStatus" is "Uknown", look for empty resources file in
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
    resources = await get_weka_local_resources()

    if MODE == "client" and should_recreate_client_container(resources):
        logging.info("Recreating client container")
        await run_command("weka local stop --force", capture_stdout=False)
        await run_command(f"weka local rm --all --force", capture_stdout=False)
        await create_container()
        resources = await get_weka_local_resources()

    # TODO: Normalize to have common logic between setup and reconfigure, including between clients and backends
    if MODE == "client" and len(resources['nodes']) != (NUM_CORES + 1):
        stdout, stderr, ec = await run_command(
            f"weka local resources cores -C {NAME} --only-frontend-cores {NUM_CORES} --core-ids {','.join(map(str, full_cores[:NUM_CORES]))}")
        if ec != 0:
            raise Exception(f"Failed to get frontend cores: {stderr}")

    # TODO: unite with above block as single getter
    resources = await get_weka_local_resources()

    if MODE in ["s3", "nfs"]:
        resources['allow_protocols'] = True
    resources['reserve_1g_hugepages'] = False
    resources['excluded_drivers'] = ["igb_uio"]
    resources['memory'] = convert_to_bytes(MEMORY)
    resources['auto_discovery_enabled'] = False
    resources["ips"] = MANAGEMENT_IPS
    ff = await get_feature_flags()
    if ff.supports_binding_to_not_all_interfaces and os.environ.get("BIND_MANAGEMENT_ALL", "false").lower() == "false":
        resources["restrict_listen"] = True

    # resources["mask_interrupts"] = True

    resources['auto_remove_timeout'] = AUTO_REMOVE_TIMEOUT

    cores_cursor = 0
    for node_id, node in resources['nodes'].items():
        if "MANAGEMENT" in node['roles']:
            continue
        if CPU_POLICY == "shared":
            node['dedicate_core'] = False
            node['dedicated_mode'] = "NONE"
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
    cli_changes = False
    if not is_managed_k8s() and not is_udp():
        target_devices = set(NETWORK_DEVICE.split(","))
        if NETWORK_SELECTORS:
            target_devices = set(await get_devices_by_selectors(NETWORK_SELECTORS))
        if SUBNETS:
            target_devices = set(await get_devices_by_subnets(SUBNETS))
        current_devices = set(dev['device'] for dev in resources['net_devices'])
        to_remove = current_devices - target_devices
        to_add = target_devices - current_devices
        for device in to_remove:
            stdout, stderr, ec = await run_command(f"weka local resources net -C {NAME} remove {device}")
            if ec != 0:
                raise Exception(f"Failed to remove net device {device}: {stderr}")
        for device in to_add:
            stdout, stderr, ec = await run_command(f"weka local resources net -C {NAME} add {device}")
            if ec != 0:
                raise Exception(f"Failed to add net device {device}: {stderr}")
        cli_changes = cli_changes or len(target_devices.difference(current_devices))

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
    return f"/host-binds/shared/instructions/{POD_ID}/{get_boot_id()}"


@dataclass
class ShutdownInstructions:
    allow_force_stop: bool = False
    allow_stop: bool = False


async def get_shutdown_instructions() -> ShutdownInstructions:
    if not POD_ID:  ## back compat mode for when pod was scheduled without downward api
        return ShutdownInstructions()
    instructions_dir = get_instructions_dir()
    instructions_file = os.path.join(instructions_dir, "shutdown_instructions.json")

    if not os.path.exists(instructions_file):
        ret = ShutdownInstructions()
    else:
        with open(instructions_file, "r") as file:
            data = json.load(file)
            ret = ShutdownInstructions(**data)

    if exists("/tmp/.allow-force-stop"):
        ret.allow_force_stop = True
    if exists("/tmp/.allow-stop"):
        ret.allow_stop = True
    return ret


async def start_weka_container():
    stdout, stderr, ec = await run_command("weka local start")
    if ec != 0:
        raise Exception(f"Failed to start container: {stderr}")
    logging.info("finished applying new config")
    logging.info(f"Container reconfigured successfully: {stdout.decode('utf-8')}")


async def configure_persistency():
    if not os.path.exists("/host-binds/opt-weka"):
        return

    command = dedent(f"""
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

        if [ -d /host-binds/boot-level ]; then
            BOOT_DIR=/host-binds/boot-level/$(cat /proc/sys/kernel/random/boot_id)/cleanup
            mkdir -p $BOOT_DIR
            mkdir -p /opt/weka/external-mounts/cleanup
            mount -o bind $BOOT_DIR /opt/weka/external-mounts/cleanup
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
            ENVOY_DIR=/opt/weka/envoy
            EXT_ENVOY_DIR=/host-binds/shared-configs/envoy
            mkdir -p $ENVOY_DIR
            mkdir -p $EXT_ENVOY_DIR
            mount -o bind $EXT_ENVOY_DIR $ENVOY_DIR
        fi

        mkdir -p {WEKA_K8S_RUNTIME_DIR}
        touch {PERSISTENCY_CONFIGURED}
    """)

    stdout, stderr, ec = await run_command(command)
    if ec != 0:
        raise Exception(f"Failed to configure persistency: {stdout} {stderr}")

    logging.info("Persistency configured successfully")


async def ensure_weka_version():
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
    data = dict(
        is_ht=len(read_siblings_list(0)) > 1,
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

    if MODE not in ['drive', 's3', 'compute', 'nfs', 'envoy', 'client']:
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
    if net_devices and is_managed_k8s(net_devices):
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
    if parse_port(PORT) == 0 and MODE != 'envoy':
        PORT = data["wekaPort"]
    if parse_port(AGENT_PORT) == 0:
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
            cmd = f"ip addr show dev {device_name} | grep 'inet ' | awk '{{print $2}}' | cut -d/ -f1"

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


async def filter_out_missing_devices(device_names: List[str]) -> List[str]:
    """Filter out devices that are not available in the system."""
    available_devices = []
    for device_name in device_names:
        try:
            ip = await get_single_device_ip(device_name)
            if ip:
                available_devices.append(device_name)
        except Exception as e:
            logging.warning(f"Device {device_name} is not available: {e}")
    return available_devices


async def get_devices_by_subnets(subnets_str: str) -> List[str]:
    subnets = subnets_str.split(",")
    if not subnets:
        raise ValueError("No subnets provided or format is incorrect. Expected comma-separated list of subnets.")

    return await get_devices_waiting_for_all_subnets_to_have_device(subnets)


async def get_devices_by_selectors(selectors_str: str) -> List[str]:
    devices = []
    selectors = json.loads(selectors_str)
    for selector in selectors:
        min_devices = selector.get("min", 0)
        max_devices = selector.get("max", 0)
        device_names = selector.get("deviceNames")
        subnet = selector.get("subnet")

        if device_names:
            device_names = await filter_out_missing_devices(device_names)
            if len(device_names) < min_devices:
                raise Exception(f"Not enough devices found by deviceNames selector. Expected at least {min_devices}, found {len(device_names)}.")

            if max_devices > 0:
                device_names = device_names[:max_devices]

            for device_name in device_names:
                if device_name not in devices:
                    devices.append(device_name)

            continue

        if not subnet:
            raise Exception("Either 'deviceNames' or 'subnet' must be provided in the selector.")

        subnet_devices = await get_devices_waiting_for_all_subnets_to_have_device([subnet])
        if len(subnet_devices) < min_devices:
            raise Exception(f"Not enough devices found in subnet {subnet}. Expected at least {min_devices}, found {len(subnet_devices)}.")

        if max_devices > 0:
            subnet_devices = subnet_devices[:max_devices]

        for device in subnet_devices:
            if device not in devices:
                devices.append(device)

    logging.info(f"Devices found by selectors: {devices}")

    return devices


async def write_management_ips():
    """Auto-discover management IPs and write them to a file"""
    if MODE not in ['drive', 'compute', 's3', 'nfs', 'client']:
        return

    ipAddresses = []

    if os.environ.get("MANAGEMENT_IP") and is_managed_k8s():
        ipAddresses.append(os.environ.get("MANAGEMENT_IP"))
    elif MANAGEMENT_IPS_SELECTORS:
        devices = await get_devices_by_selectors(MANAGEMENT_IPS_SELECTORS)
        for device in devices:
            ip = await get_single_device_ip(device)
            ipAddresses.append(ip)
    elif not NETWORK_DEVICE and NETWORK_SELECTORS:
        devices = await get_devices_by_selectors(NETWORK_SELECTORS)
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


async def ensure_drives():
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
    global OS_DISTRO, OS_BUILD_ID
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

    if MODE == "drivers-loader":
        # self signal to exit
        await override_dependencies_flag()
        # 2 minutes timeout for driver loading
        end_time = time.time() + 120
        await disable_driver_signing()
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

    if MODE != "adhoc-op":  # this can be specialized container that should not have agent
        await configure_agent()
        await start_syslog()

    await override_dependencies_flag()
    if MODE not in ["dist", "drivers-dist", "drivers-loader", "drivers-builder", "adhoc-op-with-container", "envoy",
                    "adhoc-op"]:
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
        global NAME
        NAME = "adhoc"
        await ensure_stem_container(NAME)
        await configure_traces()
        await start_stem_container()
        await ensure_container_exec()
        instruction = json.loads(INSTRUCTIONS)
        logging.info(f"adhoc-op-with-container instruction: {instruction}")
        payload = json.loads(instruction['payload'])
        if instruction.get('type') == 'ensure-nics':
            if payload.get('type') in ["aws", "oci"]:
                await ensure_nics(payload['dataNICsNumber'])
                return
            else:
                raise ValueError(f"Ensure NICs instruction type not supported: {payload.get('type')}")
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
            signed_drives = await sign_drives(payload)
            logging.info(f"signed_drives: {signed_drives}")
            await asyncio.sleep(3)  # a hack to give kernel a chance to update paths, as it's not instant
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

    # de-facto, both drivers-builder and dist right now are doing "build and serve"
    if MODE in ["dist", "drivers-builder"]:
        DIST_LEGACY_MODE = await is_legacy_driver_cmd()
        logging.info("dist-service flow")
        if is_google_cos():
            await install_gsutil()
            await cos_build_drivers()

        elif DIST_LEGACY_MODE:  # default
            await agent.stop()
            await configure_agent(agent_handle_drivers=True)
            await agent.start()  # here the build happens
            await await_agent()

        await ensure_stem_container("dist")
        await configure_traces()
        if not DIST_LEGACY_MODE:
            # there might be a better place for preRunScript, but it is needed just for driver now
            await run_prerun_script()
            await pack_drivers()  # explicit pack of drivers if supported, which is new method, that should become default with rest of code removed eventually
        else:
            await agent.stop()
            await configure_agent(agent_handle_drivers=False)
            await agent.start()
            await await_agent()

        if DIST_LEGACY_MODE:
            await copy_drivers()
        await start_stem_container()
        await cleanup_traces_and_stop_dumper()
        weka_version, _, _ = await run_command("weka version current")
        write_results(
            {
                "driver_built": True,
                "err": "",
                "weka_version": weka_version.decode().strip(),
                "kernel_signature": await get_kernel_signature(weka_pack_supported=not DIST_LEGACY_MODE,
                                                               weka_drivers_handling=WEKA_DRIVERS_HANDLING),
                "weka_pack_not_supported": DIST_LEGACY_MODE,
                "no_weka_drivers_handling": not WEKA_DRIVERS_HANDLING,
            })
        return

    if MODE == "envoy":
        await ensure_envoy_container()
        return

    await ensure_weka_container()
    await configure_traces()
    await start_weka_container()
    await ensure_container_exec()
    logging.info("Container is UP and running")

    # Start periodic CPU affinity management for drive, compute, and client containers
    if MODE in ["drive", "compute", "client"]:
        asyncio.create_task(periodic_cpu_affinity_management())

    if MODE == "drive":
        await ensure_drives()


async def get_kernel_signature(weka_pack_supported=False, weka_drivers_handling=False):
    if not weka_drivers_handling:
        return ""

    cmd = ""
    if weka_pack_supported:
        cmd = "weka driver kernel 2>&1 | awk '{printf \"%s\", $NF}'"
    else:
        # tr -d '\0' is needed to remove null character from the end of output
        cmd = "weka driver kernel-sig 2>&1 | awk '{printf \"%s\", $NF}' | tr -d '\\0'"

    stdout, stderr, ec = await run_command(cmd)
    if ec != 0:
        raise Exception(f"Failed to get kernel signature: {stderr}")

    res = stdout.decode().strip()
    assert res, "Kernel signature not found"
    return res


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
    if MODE in ['drivers-loader', 'discovery']:
        return False

    current_generation = read_generation()
    if current_generation == "":
        return False

    if current_generation != CURRENT_GENERATION:
        logging.error("Wrong generation detected, exiting, current:%s, read: %s", CURRENT_GENERATION, read_generation())
        return True
    return False


async def takeover_shutdown():
    while not is_wrong_generation():
        await asyncio.sleep(1)

    logging.info("takeover_shutdown called")
    await run_command("weka local stop --force", capture_stdout=False)


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


async def wait_for_shutdown_instruction():
    while True:
        shutdown_instructions = await get_shutdown_instructions()

        if shutdown_instructions.allow_force_stop:
            logging.info("Received 'allow-force-stop' instruction")
            return
        if shutdown_instructions.allow_stop:
            logging.info("Received 'allow-stop' instruction")
            return

        logging.info("Waiting for shutdown instruction...")
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
        if MODE in ["client", "s3", "nfs", "drive", "compute"]:
            await wait_for_shutdown_instruction()

        force_stop = False
        if (await get_shutdown_instructions()).allow_force_stop:
            force_stop = True
        if is_wrong_generation():
            force_stop = True
        if MODE not in ["s3", "drive", "compute", "nfs"]:
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
