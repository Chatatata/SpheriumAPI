SELECT u.*
FROM one_time_codes otc
INNER JOIN users u ON u.id = otc.user_id
LEFT OUTER JOIN one_time_code_invalidations otci ON otci.one_time_code_id = otc.id
WHERE otc.inserted_at > (now() - '180 seconds'::interval) AND
      otci.inserted_at IS NULL AND
      u.id = 1 AND
      otc.code = 987654;
