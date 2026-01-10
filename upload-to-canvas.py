#!/usr/bin/env python3
"""
Upload the contents of set01.html into the Canvas assignment description (HTML) field,
using ONLY the Python standard library.

Usage:
  export CANVAS_ACCESS_TOKEN="..."
  python upload_assignment_html_stdlib.py set01.html \
    https://osu.instructure.com/courses/205092/assignments/5236217/

Notes:
- This REPLACES the assignment description with the file contents.
"""

import argparse
import json
import os
import sys
from urllib.parse import urlparse, urlencode
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError


def parse_assignment_url(url: str):
    p = urlparse(url)
    if not p.scheme or not p.netloc:
        raise ValueError(f"Not a valid URL: {url}")

    parts = [x for x in p.path.split("/") if x]
    # Expect: /courses/{course_id}/assignments/{assignment_id}
    try:
        i = parts.index("courses")
        course_id = parts[i + 1]
        j = parts.index("assignments")
        assignment_id = parts[j + 1]
    except (ValueError, IndexError) as e:
        raise ValueError(
            f"URL path must look like /courses/<course_id>/assignments/<assignment_id>, got: {p.path}"
        ) from e

    base = f"{p.scheme}://{p.netloc}"
    return base, course_id, assignment_id


def http_json(method: str, url: str, token: str, data_dict=None, timeout=60):
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/json",
    }

    data_bytes = None
    if data_dict is not None:
        # Canvas accepts x-www-form-urlencoded for updates
        body = urlencode(data_dict).encode("utf-8")
        data_bytes = body
        headers["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8"

    req = Request(url, method=method, headers=headers, data=data_bytes)

    try:
        with urlopen(req, timeout=timeout) as resp:
            raw = resp.read().decode("utf-8", errors="replace")
            if raw.strip() == "":
                return {}
            return json.loads(raw)
    except HTTPError as e:
        err_body = e.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"{method} {url} -> HTTP {e.code}\n{err_body}") from e
    except URLError as e:
        raise RuntimeError(f"{method} {url} -> Network error: {e}") from e
    except json.JSONDecodeError as e:
        raise RuntimeError(f"{method} {url} -> Could not parse JSON response") from e


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("html_file", help="Path to HTML file (e.g., set01.html)")
    ap.add_argument("assignment_url", help="Canvas assignment URL")
    ap.add_argument("--dry-run", action="store_true",
                    help="Show what would happen, but don't update")
    args = ap.parse_args()

    token = os.environ.get("CANVAS_ACCESS_TOKEN")
    if not token:
        print("ERROR: CANVAS_ACCESS_TOKEN is not set in the environment.", file=sys.stderr)
        sys.exit(2)

    base_url, course_id, assignment_id = parse_assignment_url(args.assignment_url)
    api = f"{base_url}/api/v1/courses/{course_id}/assignments/{assignment_id}"

    # Read HTML file
    try:
        with open(args.html_file, "r", encoding="utf-8") as f:
            new_html = f.read()
    except OSError as e:
        print(f"ERROR: Could not read {args.html_file}: {e}", file=sys.stderr)
        sys.exit(2)

    # Fetch current assignment (useful sanity check)
    assignment = http_json("GET", api, token, timeout=30)
    title = assignment.get("name", "(no name)")
    print(f"Assignment: {title}")
    print(f"Replacing description with {len(new_html)} characters from {args.html_file}")

    if args.dry_run:
        print("Dry run: not updating.")
        return

    updated = http_json(
        "PUT",
        api,
        token,
        data_dict={"assignment[description]": new_html},
        timeout=60,
    )

    print("Update successful.")
    print(f"Updated description length: {len(updated.get('description') or '')}")


if __name__ == "__main__":
    main()

