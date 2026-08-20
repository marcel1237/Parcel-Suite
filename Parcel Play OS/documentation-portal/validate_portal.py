#!/usr/bin/env python3
"""Validate generated portal data and static local references."""

from __future__ import annotations

import json
import re
from html.parser import HTMLParser
from pathlib import Path


PORTAL = Path(__file__).resolve().parent


class AssetParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.paths: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        data = dict(attrs)
        value = data.get("href") if tag in {"a", "link"} else data.get("src") if tag == "script" else None
        if value and not value.startswith(("#", "http://", "https://")):
            self.paths.append(value.split("#", 1)[0])


def main() -> None:
    parser = AssetParser()
    parser.feed((PORTAL / "index.html").read_text(encoding="utf-8"))
    missing = [path for path in parser.paths if not (PORTAL / path).resolve().exists()]
    generated = (PORTAL / "generated-data.js").read_text(encoding="utf-8")
    match = re.search(r"window\.PLAYOS_PORTAL\s*=\s*(\{.*\});\s*$", generated, re.DOTALL)
    if not match:
        raise SystemExit("generated-data.js has no valid PLAYOS_PORTAL payload")
    payload = json.loads(match.group(1))
    ids: set[str] = set()
    for document in payload["documents"]:
        if document["id"] in ids:
            raise SystemExit(f"duplicate portal document ID: {document['id']}")
        ids.add(document["id"])
        if not (PORTAL / document["href"]).resolve().exists():
            missing.append(document["href"])
    if payload["stats"]["documents"] != len(payload["documents"]):
        raise SystemExit("portal document statistic differs from generated catalog")
    if missing:
        raise SystemExit("missing portal paths:\n" + "\n".join(sorted(set(missing))))
    print(f"PASS: portal has {len(payload['documents'])} generated documents, {len(parser.paths)} static references and no missing paths")


if __name__ == "__main__":
    main()
