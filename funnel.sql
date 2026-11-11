WITH eligible AS (
    SELECT user_id, channel, signup_date, date(signup_date, '+6 days') AS deadline
    FROM users
    WHERE date(signup_date, '+6 days') <= :observed_through
),
onboarding AS (
    SELECT u.user_id, MIN(e.event_date) AS onboarding_date
    FROM eligible AS u
    JOIN events AS e ON e.user_id = u.user_id
        AND e.event_type = 'onboarding_completed'
        AND e.event_date BETWEEN u.signup_date AND u.deadline
    GROUP BY u.user_id
),
activation AS (
    SELECT DISTINCT u.user_id
    FROM eligible AS u
    JOIN onboarding AS o ON o.user_id = u.user_id
    JOIN events AS e ON e.user_id = u.user_id
        AND e.event_type = 'first_project_created'
        AND e.event_date BETWEEN o.onboarding_date AND u.deadline
)
SELECT
    u.channel,
    COUNT(*) AS signups,
    COUNT(o.user_id) AS onboarded,
    COUNT(a.user_id) AS activated,
    ROUND(100.0 * COUNT(o.user_id) / COUNT(*), 1) AS onboarding_pct,
    ROUND(100.0 * COUNT(a.user_id) / NULLIF(COUNT(o.user_id), 0), 1) AS activation_after_onboarding_pct,
    ROUND(100.0 * COUNT(a.user_id) / COUNT(*), 1) AS signup_to_activation_pct
FROM eligible AS u
LEFT JOIN onboarding AS o ON o.user_id = u.user_id
LEFT JOIN activation AS a ON a.user_id = u.user_id
GROUP BY u.channel
ORDER BY signup_to_activation_pct DESC, u.channel;
