#!/usr/bin/env python3
import csv
import io
import re
import sys

SELF_URL = "https://raw.githubusercontent.com/jkyotnfjfbjnknh/macos-build-pipeline/main/sr-tailscale/sr_tailscale_list.module"


def convert_rule_line(line):
    buf = io.StringIO(line)
    try:
        fields = next(csv.reader(buf))
    except Exception:
        return line, False
    for i in range(2, len(fields)):
        if fields[i].strip() == "PROXY":
            fields[i] = "TAILSCALE"
            head, _, rest = line.partition(",")
            was_quoted = rest.startswith('"')
            parts = []
            for j, field in enumerate(fields):
                if j == 1 and (was_quoted or "," in field or '"' in field):
                    parts.append('"' + field.replace('"', '""') + '"')
                else:
                    parts.append(field)
            return ",".join(parts), True
    return line, False


def main(src_path, dst_path):
    with open(src_path, "r", encoding="utf-8") as f:
        text = f.read()

    lines = text.split("\n")
    out = []
    in_rule = False
    total_rules = 0
    converted = 0
    created = ""

    for line in lines:
        stripped = line.strip()
        if stripped.startswith("#!desc"):
            m = re.search(r"Created:([0-9\-]+ [0-9:]+)", line)
            if m:
                created = m.group(1)
            continue
        if stripped.startswith("#!name="):
            out.append("#!url=" + SELF_URL)
            out.append("#!name=tailscale_list")
            continue
        if stripped == "[Rule]":
            in_rule = True
            if created:
                out.append("#!desc=Rules:PENDING Created:%s Publisher:GMOogway (PROXY converted to TAILSCALE)" % created)
            else:
                out.append("#!desc=Rules:PENDING Publisher:GMOogway (PROXY converted to TAILSCALE)")
            out.append(line)
            continue
        if in_rule and stripped and not stripped.startswith("#") and not stripped.startswith(";"):
            total_rules += 1
            new_line, ok = convert_rule_line(line)
            if ok:
                converted += 1
                out.append(new_line)
            else:
                out.append(line)
                print("no PROXY policy field found: %s" % line, file=sys.stderr)
            continue
        out.append(line)

    result = "\n".join(out)
    result = result.replace("Rules:PENDING", "Rules:%d" % total_rules)

    if converted == 0:
        print("FAIL: no PROXY rules converted", file=sys.stderr)
        return 1
    if converted != total_rules:
        print("FAIL: converted %d of %d rules" % (converted, total_rules), file=sys.stderr)
        return 1

    with open(dst_path, "w", encoding="utf-8") as f:
        f.write(result)

    print("rules=%d converted=%d" % (total_rules, converted))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1], sys.argv[2]))
