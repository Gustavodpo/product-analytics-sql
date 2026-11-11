WITH cohort_members AS (
    SELECT user_id, date(signup_date, '-6 days', 'weekday 1') AS cohort_week
    FROM users
),
weeks(age_week) AS (VALUES (1), (2), (3), (4)),
eligible AS (
    SELECT c.user_id, c.cohort_week, w.age_week,
        date(c.cohort_week, printf('+%d days', w.age_week * 7)) AS week_start,
        date(c.cohort_week, printf('+%d days', w.age_week * 7 + 6)) AS week_end
    FROM cohort_members AS c
    CROSS JOIN weeks AS w
    WHERE date(c.cohort_week, printf('+%d days', w.age_week * 7 + 6)) <= :observed_through
),
activity AS (
    SELECT w.*,
        EXISTS (
            SELECT 1
            FROM events AS e
            WHERE e.user_id = w.user_id
                AND e.event_type = 'project_used'
                AND e.event_date BETWEEN w.week_start AND w.week_end
        ) AS returned
    FROM eligible AS w
)
SELECT cohort_week, age_week, COUNT(*) AS signups,
    SUM(returned) AS returning_users,
    ROUND(100.0 * SUM(returned) / COUNT(*), 1) AS retention_pct
FROM activity
GROUP BY cohort_week, age_week
ORDER BY cohort_week, age_week;
