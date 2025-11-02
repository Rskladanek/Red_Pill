import sqlite3
from pathlib import Path

DB_PATH = Path(__file__).resolve().parents[1] / "redpill.db"

def column_exists(cur, table, col):
    cur.execute(f"PRAGMA table_info({table})")
    return any(r[1] == col for r in cur.fetchall())

def table_exists(cur, table):
    cur.execute("SELECT name FROM sqlite_master WHERE type='table' AND name=?", (table,))
    return cur.fetchone() is not None

def main():
    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()

    # --- kolumny w users ---
    for col, ddl in [
        ("xp_mind",      "INTEGER NOT NULL DEFAULT 0"),
        ("xp_body",      "INTEGER NOT NULL DEFAULT 0"),
        ("xp_soul",      "INTEGER NOT NULL DEFAULT 0"),
        ("streak_days",  "INTEGER NOT NULL DEFAULT 0"),
        ("last_active",  "DATE")
    ]:
        if not column_exists(cur, "users", col):
            cur.execute(f"ALTER TABLE users ADD COLUMN {col} {ddl}")

    # --- tabela activity_log ---
    if not table_exists(cur, "activity_log"):
        cur.execute("""
        CREATE TABLE activity_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            date TEXT NOT NULL,
            kind TEXT NOT NULL,         -- 'quiz'|'habit'|'task' etc.
            track TEXT,                 -- 'mind'|'body'|'soul'|NULL
            delta_xp INTEGER NOT NULL DEFAULT 0,
            correct INTEGER NOT NULL DEFAULT 0,
            note TEXT,
            FOREIGN KEY(user_id) REFERENCES users(id)
        )
        """)
        cur.execute("CREATE INDEX idx_activity_user_date ON activity_log(user_id, date)")

    con.commit()
    con.close()
    print("OK: migration applied.")

if __name__ == "__main__":
    main()
