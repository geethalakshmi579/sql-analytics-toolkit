#!/usr/bin/env python3
"""Run every SQL script in sql/ against analytics.db and sanity-check results.

Usage:
    python3 data/generate.py   # build the synthetic dataset first
    python3 run_all.py
"""
import sqlite3
import sys
from pathlib import Path

BASE = Path(__file__).resolve().parent
DB = BASE / "analytics.db"

CHECKS = {
    # file -> (description, assertion on rows returned)
    "02_cohort_retention.sql": ("cohort retention grid", lambda rows: len(rows) > 0),
    "03_funnel_analysis.sql": ("channel funnel", lambda rows: len(rows[0]) == 5),
    "04_window_functions.sql": ("window analytics (3 statements)",
                                lambda rows: True),  # executes only
    "05_data_quality.sql": ("data-quality assertions", lambda rows: rows == []),
}


def run_statements(path):
    con = sqlite3.connect(DB)
    cur = con.cursor()
    results = []
    # strip full-line comments first, then split on ';'
    code = "\n".join(
        l for l in path.read_text().splitlines()
        if not l.strip().startswith("--")
    )
    for stmt in code.split(";"):
        stmt = stmt.strip()
        if not stmt:
            continue
        cur.execute(stmt)
        results.append(cur.fetchall())
    con.close()
    return results


def main():
    if not DB.exists():
        sys.exit("analytics.db not found — run: python3 data/generate.py")
    ok = True
    for fname, (desc, check) in CHECKS.items():
        results = run_statements(BASE / "sql" / fname)
        flat = [r for block in results for r in block] if fname == "05_data_quality.sql" else results
        passed = check(flat)
        ok &= passed
        n_rows = sum(len(b) for b in results)
        print(f"[{'PASS' if passed else 'FAIL'}] {fname} — {desc} ({n_rows} rows)")
        if fname == "03_funnel_analysis.sql":
            for row in results[0]:
                print("      ", row)
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
