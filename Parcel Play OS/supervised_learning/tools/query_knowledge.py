#!/usr/bin/env python3
"""Small dependency-free lexical search for the PlayOS knowledge collection."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / "supervised_learning"
TOKEN = re.compile(r"[a-zA-ZÀ-ÿ0-9_.+-]+")
STOP = {"a", "as", "com", "como", "da", "das", "de", "do", "dos", "e", "em", "o", "os", "para", "por", "que", "um", "uma"}


def tokens(text: str) -> set[str]:
    return {token.lower() for token in TOKEN.findall(text) if token.lower() not in STOP and len(token) > 1}


def records() -> list[tuple[str, str, str]]:
    result: list[tuple[str, str, str]] = []
    for path in sorted((BASE / "knowledge").rglob("*.md")):
        text = path.read_text(encoding="utf-8")
        result.append((str(path.relative_to(ROOT)), text.splitlines()[0].lstrip("# "), text))
    for path in sorted((BASE / "datasets").glob("*.jsonl")) + sorted((BASE / "evaluations").glob("*.jsonl")):
        with path.open(encoding="utf-8") as stream:
            for raw in stream:
                if not raw.strip():
                    continue
                row = json.loads(raw)
                body = f"{row['question']} {row['answer']} {' '.join(row['tags'])}"
                result.append((f"{path.relative_to(ROOT)}#{row['id']}", row["question"], body))
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description="Search PlayOS supervised knowledge")
    parser.add_argument("query", nargs="+", help="terms to search")
    parser.add_argument("--limit", type=int, default=8)
    args = parser.parse_args()
    query = " ".join(args.query)
    query_tokens = tokens(query)
    ranked: list[tuple[int, str, str]] = []
    for location, title, body in records():
        body_tokens = tokens(body)
        score = sum(3 for token in query_tokens if token in tokens(title))
        score += sum(1 for token in query_tokens if token in body_tokens)
        if score:
            ranked.append((score, location, title))
    ranked.sort(key=lambda item: (-item[0], item[1]))
    for score, location, title in ranked[: max(args.limit, 1)]:
        print(f"{score:02d}\t{location}\t{title}")
    return 0 if ranked else 1


if __name__ == "__main__":
    raise SystemExit(main())
