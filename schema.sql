PRAGMA foreign_keys = ON;

CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    channel TEXT NOT NULL,
    signup_date TEXT NOT NULL
);

CREATE TABLE events (
    user_id INTEGER NOT NULL REFERENCES users(user_id),
    event_type TEXT NOT NULL,
    event_date TEXT NOT NULL,
    PRIMARY KEY (user_id, event_type, event_date)
);
