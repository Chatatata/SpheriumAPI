SELECT count(*)
FROM one_time_codes otc
INNER JOIN users u ON u.id = otc.user_id
WHERE otc.inserted_at > (now() - '180 seconds'::interval);
