#!/usr/bin/env python3
"""Validate the local PlayOS supervised knowledge base without dependencies."""

from __future__ import annotations

import csv
import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / "supervised_learning"
SOURCE_ID = re.compile(r"^SRC-[A-Z0-9-]+$")
QA_ID = re.compile(r"^QA-[A-Z0-9-]+$")
KB_ID = re.compile(r"^KB-[A-Z0-9-]+$")
BEHAVIORS = {
    "answer",
    "compare",
    "correct-premise",
    "refuse-unsupported",
    "state-unknown",
}


class Report:
    def __init__(self) -> None:
        self.errors: list[str] = []
        self.warnings: list[str] = []
        self.counts: dict[str, int] = {}

    def error(self, message: str) -> None:
        self.errors.append(message)

    def warning(self, message: str) -> None:
        self.warnings.append(message)


def read_tsv(path: Path, report: Report) -> list[dict[str, str]]:
    try:
        with path.open(encoding="utf-8", newline="") as stream:
            return list(csv.DictReader(stream, delimiter="\t"))
    except (OSError, csv.Error) as exc:
        report.error(f"cannot read TSV {path.relative_to(ROOT)}: {exc}")
        return []


def validate_sources(report: Report) -> set[str]:
    path = BASE / "catalog/sources.tsv"
    rows = read_tsv(path, report)
    required = {"source_id", "type", "system", "version", "path", "status", "priority", "description"}
    source_ids: set[str] = set()
    for line, row in enumerate(rows, 2):
        if not required.issubset(row):
            report.error(f"{path.relative_to(ROOT)}:{line}: missing columns")
            continue
        source_id = row["source_id"]
        if not SOURCE_ID.fullmatch(source_id):
            report.error(f"{path.relative_to(ROOT)}:{line}: invalid source ID {source_id!r}")
        if source_id in source_ids:
            report.error(f"{path.relative_to(ROOT)}:{line}: duplicate source ID {source_id}")
        source_ids.add(source_id)
        target = Path(row["path"])
        if not target.is_absolute():
            target = ROOT / target
        if not target.exists():
            report.error(f"{path.relative_to(ROOT)}:{line}: missing source path {row['path']}")
    report.counts["sources"] = len(rows)
    return source_ids


def check_source_list(raw: str, location: str, source_ids: set[str], report: Report) -> None:
    for source_id in filter(None, (item.strip() for item in raw.split(","))):
        if source_id not in source_ids:
            report.error(f"{location}: unknown source ID {source_id}")


def validate_catalogs(source_ids: set[str], report: Report) -> None:
    specs = {
        "topics.tsv": ("topic_id", "source_ids"),
        "decisions.tsv": ("decision_id", "source_ids"),
        "implementations.tsv": ("implementation_id", "source_ids"),
    }
    for filename, (id_column, source_column) in specs.items():
        path = BASE / "catalog" / filename
        rows = read_tsv(path, report)
        seen: set[str] = set()
        for line, row in enumerate(rows, 2):
            record_id = row.get(id_column, "")
            if not record_id:
                report.error(f"{path.relative_to(ROOT)}:{line}: missing {id_column}")
            elif record_id in seen:
                report.error(f"{path.relative_to(ROOT)}:{line}: duplicate {record_id}")
            seen.add(record_id)
            check_source_list(row.get(source_column, ""), f"{path.relative_to(ROOT)}:{line}", source_ids, report)
            if filename == "topics.tsv":
                entry = row.get("primary_entry", "")
                root_entry = ROOT / entry
                base_entry = BASE / entry
                if entry and not root_entry.exists() and not base_entry.exists():
                    report.error(f"{path.relative_to(ROOT)}:{line}: missing primary entry {entry}")
            if filename == "implementations.tsv":
                target = row.get("path", "")
                if target and not (ROOT / target).exists():
                    report.error(f"{path.relative_to(ROOT)}:{line}: missing implementation path {target}")
        report.counts[filename.removesuffix(".tsv")] = len(rows)

    inventory_path = BASE / "catalog/document_inventory.tsv"
    inventory = read_tsv(inventory_path, report)
    document_ids: set[str] = set()
    for line, row in enumerate(inventory, 2):
        document_id = row.get("document_id", "")
        if not re.fullmatch(r"DOC-[0-9]{3}", document_id):
            report.error(f"{inventory_path.relative_to(ROOT)}:{line}: invalid document ID {document_id!r}")
        if document_id in document_ids:
            report.error(f"{inventory_path.relative_to(ROOT)}:{line}: duplicate document ID {document_id}")
        document_ids.add(document_id)
        target = ROOT / row.get("path", "")
        if not target.exists():
            report.error(f"{inventory_path.relative_to(ROOT)}:{line}: missing document {row.get('path', '')}")
    report.counts["document_inventory"] = len(inventory)


def validate_knowledge(source_ids: set[str], report: Report) -> None:
    seen: set[str] = set()
    files = sorted((BASE / "knowledge").rglob("*.md"))
    for path in files:
        text = path.read_text(encoding="utf-8")
        kb_match = re.search(r"^ID: `([^`]+)`$", text, re.MULTILINE)
        if not kb_match or not KB_ID.fullmatch(kb_match.group(1)):
            report.error(f"{path.relative_to(ROOT)}: missing or invalid KB ID")
        elif kb_match.group(1) in seen:
            report.error(f"{path.relative_to(ROOT)}: duplicate KB ID {kb_match.group(1)}")
        else:
            seen.add(kb_match.group(1))
        source_match = re.search(r"^- fontes: (.+)$", text, re.MULTILINE)
        if not source_match:
            report.error(f"{path.relative_to(ROOT)}: missing source metadata")
        else:
            cited = ",".join(re.findall(r"SRC-[A-Z0-9-]+", source_match.group(1)))
            check_source_list(cited, str(path.relative_to(ROOT)), source_ids, report)
        if "verificado em:" not in text:
            report.error(f"{path.relative_to(ROOT)}: missing verification date")
    report.counts["knowledge_entries"] = len(files)


def validate_jsonl(source_ids: set[str], report: Report) -> None:
    seen: set[str] = set()
    total = 0
    files = sorted((BASE / "datasets").glob("*.jsonl")) + sorted((BASE / "evaluations").glob("*.jsonl"))
    for path in files:
        count = 0
        with path.open(encoding="utf-8") as stream:
            for line_number, raw in enumerate(stream, 1):
                if not raw.strip():
                    continue
                try:
                    row = json.loads(raw)
                except json.JSONDecodeError as exc:
                    report.error(f"{path.relative_to(ROOT)}:{line_number}: invalid JSON: {exc}")
                    continue
                location = f"{path.relative_to(ROOT)}:{line_number}"
                required = {"id", "question", "answer", "source_ids", "expected_behavior", "split", "tags"}
                missing = required - row.keys()
                if missing:
                    report.error(f"{location}: missing fields {sorted(missing)}")
                    continue
                qa_id = row["id"]
                if not QA_ID.fullmatch(qa_id):
                    report.error(f"{location}: invalid QA ID {qa_id!r}")
                if qa_id in seen:
                    report.error(f"{location}: duplicate QA ID {qa_id}")
                seen.add(qa_id)
                if row["expected_behavior"] not in BEHAVIORS:
                    report.error(f"{location}: invalid behavior {row['expected_behavior']!r}")
                if not row["source_ids"]:
                    report.error(f"{location}: QA example has no sources")
                for source_id in row["source_ids"]:
                    if source_id not in source_ids:
                        report.error(f"{location}: unknown source ID {source_id}")
                if len(row["question"].strip()) < 8 or len(row["answer"].strip()) < 10:
                    report.error(f"{location}: question or answer is too short")
                count += 1
                total += 1
        report.counts[path.name] = count
    report.counts["qa_total"] = total


def main() -> int:
    report = Report()
    source_ids = validate_sources(report)
    validate_catalogs(source_ids, report)
    validate_knowledge(source_ids, report)
    validate_jsonl(source_ids, report)

    print("PlayOS supervised knowledge validation")
    for name, count in sorted(report.counts.items()):
        print(f"  {name}: {count}")
    for warning in report.warnings:
        print(f"WARNING: {warning}")
    for error in report.errors:
        print(f"ERROR: {error}")
    if report.errors:
        print(f"FAIL: {len(report.errors)} error(s)")
        return 1
    print("PASS: structure, IDs, references and local paths are consistent")
    return 0


if __name__ == "__main__":
    sys.exit(main())
