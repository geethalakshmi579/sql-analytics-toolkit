#!/usr/bin/env python3
"""Generate a small synthetic e-commerce dataset and load it into SQLite.

Deterministic (seed=42). All data is fictional and for portfolio/demo use.
"""
import csv
import random
import sqlite3
from datetime import date, timedelta
from pathlib import Path

SEED = 42
BASE = Path(__file__).resolve().parent.parent
DATA = BASE / "data"
DB = BASE / "analytics.db"

random.seed(SEED)

FIRST = ["Ava", "Liam", "Maya", "Noah", "Zoe", "Ethan", "Priya", "Arjun",
         "Sofia", "Lucas", "Emma", "Mason", "Isha", "Ravi", "Nina", "Omar"]
LAST = ["Sharma", "Patel", "Garcia", "Kim", "Nguyen", "Smith", "Khan",
        "Lopez", "Chen", "Das", "Ali", "Brown"]
PRODUCTS = [
    ("P01", "Aurora Wireless Headphones", "Electronics", 129.99),
    ("P02", "Terra Ceramic Mug Set", "Home", 34.50),
    ("P03", "Pulse Fitness Band", "Electronics", 79.00),
    ("P04", "Drift Canvas Backpack", "Apparel", 59.99),
    ("P05", "Lumen Desk Lamp", "Home", 45.00),
    ("P06", "Stride Running Shoes", "Apparel", 89.95),
    ("P07", "Nimbus Air Purifier", "Home", 149.00),
    ("P08", "Volt Power Bank", "Electronics", 39.99),
]
CHANNELS = ["organic", "paid_search", "social", "email", "referral"]
STATUSES = ["completed", "completed", "completed", "completed", "refunded", "cancelled"]


def main(n_customers=400, n_orders=2500):
    DATA.mkdir(exist_ok=True)
    start = date(2025, 1, 1)

    customers = []
    for i in range(1, n_customers + 1):
        customers.append({
            "customer_id": f"C{i:04d}",
            "name": f"{random.choice(FIRST)} {random.choice(LAST)}",
            "signup_date": str(start + timedelta(days=random.randint(0, 300))),
            "channel": random.choice(CHANNELS),
            "country": random.choice(["US", "US", "US", "IN", "UK", "CA"]),
        })

    orders = []
    for i in range(1, n_orders + 1):
        c = random.choice(customers)
        p = random.choice(PRODUCTS)
        qty = random.randint(1, 3)
        order_date = start + timedelta(days=random.randint(0, 349))
        # keep order dates on/after signup
        if order_date < date.fromisoformat(c["signup_date"]):
            order_date = date.fromisoformat(c["signup_date"])
        orders.append({
            "order_id": f"O{i:05d}",
            "customer_id": c["customer_id"],
            "product_id": p[0],
            "quantity": qty,
            "unit_price": p[3],
            "order_date": str(order_date),
            "status": random.choice(STATUSES),
        })

    for name, rows in [("customers.csv", customers), ("orders.csv", orders),
                       ("products.csv", [dict(zip(["product_id", "product_name", "category", "list_price"], p)) for p in PRODUCTS])]:
        with open(DATA / name, "w", newline="") as f:
            w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
            w.writeheader()
            w.writerows(rows)

    if DB.exists():
        DB.unlink()
    con = sqlite3.connect(DB)
    cur = con.cursor()
    cur.executescript((BASE / "sql" / "01_schema.sql").read_text())
    for table, rows in [("customers", customers), ("products", [dict(zip(["product_id", "product_name", "category", "list_price"], p)) for p in PRODUCTS]), ("orders", orders)]:
        cols = list(rows[0].keys())
        cur.executemany(
            f"INSERT INTO {table} ({', '.join(cols)}) VALUES ({', '.join('?' * len(cols))})",
            [[r[c] for c in cols] for r in rows],
        )
    con.commit()
    print(f"customers={cur.execute('SELECT COUNT(*) FROM customers').fetchone()[0]} "
          f"orders={cur.execute('SELECT COUNT(*) FROM orders').fetchone()[0]} "
          f"products={cur.execute('SELECT COUNT(*) FROM products').fetchone()[0]}")
    con.close()
    print(f"wrote {DB}")


if __name__ == "__main__":
    main()
