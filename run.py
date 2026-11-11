from datetime import date, timedelta
from pathlib import Path
import csv
import random
import sqlite3

ROOT = Path(__file__).resolve().parent
START = date(2025, 1, 6)
OBSERVED_THROUGH = date(2025, 3, 9)
CHANNELS = {
    "organic": (0.76, 0.73, 0.58),
    "referral": (0.85, 0.82, 0.67),
    "paid_search": (0.67, 0.58, 0.44),
}


def populate(connection):
    rng = random.Random(42)
    users = []
    events = []
    for week in range(8):
        cohort = START + timedelta(weeks=week)
        for channel, (onboarding_rate, activation_rate, return_rate) in CHANNELS.items():
            for _ in range(100):
                user_id = len(users) + 1
                signup = cohort + timedelta(days=rng.randrange(7))
                users.append((user_id, channel, signup.isoformat()))
                if rng.random() >= onboarding_rate:
                    continue
                onboarding = signup + timedelta(days=rng.randint(0, 3))
                events.append((user_id, "onboarding_completed", onboarding))
                if rng.random() >= activation_rate:
                    continue
                activation = onboarding + timedelta(days=rng.randint(1, 5))
                events.append((user_id, "first_project_created", activation))
                for age_week in range(1, 5):
                    activity = cohort + timedelta(weeks=age_week, days=rng.randrange(7))
                    if rng.random() < return_rate * 0.78 ** (age_week - 1) and activity > activation:
                        events.append((user_id, "project_used", activity))

    connection.executemany("INSERT INTO users VALUES (?, ?, ?)", users)
    connection.executemany(
        "INSERT INTO events VALUES (?, ?, ?)",
        ((user, kind, day.isoformat()) for user, kind, day in events if day <= OBSERVED_THROUGH),
    )


def main():
    output = ROOT / "results"
    output.mkdir(exist_ok=True)
    with sqlite3.connect(":memory:") as connection:
        connection.executescript((ROOT / "schema.sql").read_text(encoding="utf-8"))
        populate(connection)
        for report in ("funnel", "retention"):
            query = (ROOT / f"{report}.sql").read_text(encoding="utf-8")
            rows = connection.execute(query, {"observed_through": OBSERVED_THROUGH.isoformat()})
            with (output / f"{report}.csv").open("w", encoding="utf-8", newline="") as file:
                writer = csv.writer(file, lineterminator="\n")
                writer.writerow(column[0] for column in rows.description)
                writer.writerows(rows)


if __name__ == "__main__":
    main()
