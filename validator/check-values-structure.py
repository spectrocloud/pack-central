#!/usr/bin/env python3
"""
Structural + duplicate check for a chart-based pack's values.yaml.

Given pack_values.yaml, chart_values.yaml (from the chart tarball), and the
chart's Chart.yaml name, verifies:

  1. Structural subset: every key path present under charts.<chart_name> in
     pack_values.yaml also exists as a key path in chart_values.yaml. Values
     may differ. Exception: if the corresponding node in chart_values.yaml is
     an empty sequence ([]), the pack may define anything under it.

  2. No duplicate keys within any mapping under charts.<chart_name>.

  3. No duplicate items within any sequence under charts.<chart_name>.

Exit 0 on success, 1 on findings, 2 on usage/parse errors.
"""

import sys
from collections import defaultdict

import yaml


def load_root(path):
    with open(path) as f:
        return yaml.compose(f)


def get_child(map_node, key):
    if not isinstance(map_node, yaml.MappingNode):
        return None
    for k_node, v_node in map_node.value:
        if isinstance(k_node, yaml.ScalarNode) and k_node.value == key:
            return v_node
    return None


def is_empty_seq(node):
    return isinstance(node, yaml.SequenceNode) and len(node.value) == 0


def is_empty_map(node):
    return isinstance(node, yaml.MappingNode) and len(node.value) == 0


def check_subset(pack, chart, path, errs):
    """Structural subset: every path in pack must exist in chart. Exception:
    when the chart node at any level is an empty sequence or an empty mapping
    (a Helm user-extension point like podLabels: {}, tolerations: [], etc.),
    everything under the corresponding pack path is accepted."""
    if chart is None:
        errs.append(f"path '{path}' present in pack values.yaml but not in chart's values.yaml")
        return
    if is_empty_seq(chart) or is_empty_map(chart):
        return
    if isinstance(pack, yaml.MappingNode):
        if not isinstance(chart, yaml.MappingNode):
            errs.append(
                f"structural mismatch at '{path}': pack has a mapping, chart has "
                f"{chart.tag}"
            )
            return
        for k_node, v_node in pack.value:
            if not isinstance(k_node, yaml.ScalarNode):
                continue
            key = k_node.value
            child_path = f"{path}.{key}" if path else key
            check_subset(v_node, get_child(chart, key), child_path, errs)
    elif isinstance(pack, yaml.SequenceNode):
        if not isinstance(chart, yaml.SequenceNode):
            errs.append(
                f"structural mismatch at '{path}': pack has a sequence, chart has "
                f"{chart.tag}"
            )
        # Sequence items are not recursed - item shape can legitimately differ.


def find_dups(node, path, errs):
    if isinstance(node, yaml.MappingNode):
        key_to_lines = defaultdict(list)
        for k_node, _ in node.value:
            if isinstance(k_node, yaml.ScalarNode):
                key_to_lines[k_node.value].append(k_node.start_mark.line + 1)
        for key, lines in key_to_lines.items():
            if len(lines) > 1:
                errs.append(
                    f"duplicate key '{key}' under '{path or '<root>'}' at lines {lines}"
                )
        for k_node, v_node in node.value:
            if isinstance(k_node, yaml.ScalarNode):
                child_path = f"{path}.{k_node.value}" if path else k_node.value
                find_dups(v_node, child_path, errs)
    elif isinstance(node, yaml.SequenceNode):
        repr_to_entries = defaultdict(list)
        for idx, item in enumerate(node.value):
            canonical = yaml.serialize(item)
            repr_to_entries[canonical].append((idx, item.start_mark.line + 1))
        for entries in repr_to_entries.values():
            if len(entries) > 1:
                indices = [e[0] for e in entries]
                lines = [e[1] for e in entries]
                errs.append(
                    f"duplicate item(s) under '{path or '<root>'}' at indices {indices} "
                    f"(lines {lines})"
                )
        for idx, item in enumerate(node.value):
            find_dups(item, f"{path}[{idx}]", errs)


def main():
    if len(sys.argv) != 4:
        print(
            "usage: check-values-structure.py <pack_values.yaml> "
            "<chart_values.yaml> <chart_name>",
            file=sys.stderr,
        )
        sys.exit(2)

    pack_path, chart_path, chart_name = sys.argv[1:4]

    try:
        pack_root = load_root(pack_path)
    except Exception as e:
        print(f"parse error in pack values.yaml: {e}", file=sys.stderr)
        sys.exit(2)

    #A "-" means the chart tarball has no default values.yaml (templates-only
    #chart). Skip the subset check; still run duplicate detection.
    chart_root = None
    if chart_path and chart_path != "-":
        try:
            chart_root = load_root(chart_path)
        except Exception as e:
            print(f"parse error in chart values.yaml: {e}", file=sys.stderr)
            sys.exit(2)

    charts_node = get_child(pack_root, "charts")
    pack_chart = get_child(charts_node, chart_name)

    if pack_chart is None:
        print(
            f"ERROR: 'charts.{chart_name}' node missing in pack values.yaml",
            file=sys.stderr,
        )
        sys.exit(1)
    if not isinstance(pack_chart, yaml.MappingNode):
        print(
            f"ERROR: 'charts.{chart_name}' must be a mapping",
            file=sys.stderr,
        )
        sys.exit(1)

    errs = []
    if chart_root is not None:
        check_subset(pack_chart, chart_root, "", errs)
    else:
        print(
            f"NOTE: chart '{chart_name}' has no default values.yaml; "
            "skipping subset check, running duplicate detection only",
            file=sys.stderr,
        )
    find_dups(pack_chart, "", errs)

    if errs:
        for msg in errs:
            print(f"ERROR: {msg}", file=sys.stderr)
        sys.exit(1)

    print(f"OK: 'charts.{chart_name}' structure is a subset of chart values, no duplicates")


if __name__ == "__main__":
    main()
