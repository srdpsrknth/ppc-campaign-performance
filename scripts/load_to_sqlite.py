import os
import sqlite3
from pathlib import Path

import pandas as pd

RAW_PATH = Path("data/raw/ppc_campaign_performance.csv")
DB_PATH = Path("ppc.db")
TABLE_NAME = "raw_ppc_campaign_performance"

def main():
    print("CWD:", os.getcwd())
    print("RAW:", RAW_PATH.resolve())
    print("RAW exists?:", RAW_PATH.exists())
    print("DB target:", DB_PATH.resolve())

    if not RAW_PATH.exists():
        # show what's actually in data/raw to make debugging obvious
        raw_dir = RAW_PATH.parent
        files = [p.name for p in raw_dir.glob("*")] if raw_dir.exists() else []
        raise FileNotFoundError(
            f"Could not find {RAW_PATH}. Found in {raw_dir}: {files}"
        )

    df = pd.read_csv(RAW_PATH)
    df.columns = [c.strip().lower().replace(" ", "_") for c in df.columns]

    conn = sqlite3.connect(DB_PATH)  # creates ppc.db in CWD
    df.to_sql(TABLE_NAME, conn, if_exists="replace", index=False)
    conn.close()

    print("Loaded rows:", len(df))
    print("Columns:", list(df.columns))
    print("Created DB:", DB_PATH.resolve())
    print("Created table:", TABLE_NAME)

if __name__ == "__main__":
    main()
