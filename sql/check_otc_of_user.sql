SELECT otc.*
FROM users u
INNER JOIN one_time_codes otc ON u.id = otc.user_id
LEFT OUTER JOIN one_time_code_invalidations otci ON otci.one_time_code_id = otc.id
WHERE u.id = 3 AND
      otc.code = 482693 AND
      otci.inserted_at IS NULL AND
      otc.inserted_at > all(SELECT otc.inserted_at
       	                    FROM one_time_codes otc2
                            WHERE otc2.user_id = 3) AND
      otc.inserted_at > (now() - '180 seconds'::interval);


-- QUERY PLAN
-- Nested Loop Left Join  (cost=26.38..180.38 rows=1 width=20) (actual time=0.024..0.024 rows=0 loops=1)
--   Output: otc.id, otc.user_id, otc.code, otc.inserted_at
--   Filter: (otci.inserted_at IS NULL)
--   ->  Nested Loop  (cost=4.35..147.72 rows=1 width=20) (actual time=0.023..0.023 rows=0 loops=1)
--         Output: otc.id, otc.user_id, otc.code, otc.inserted_at
--         ->  Index Only Scan using users_pkey on public.users u  (cost=0.14..8.16 rows=1 width=4) (actual time=0.010..0.011 rows=1 loops=1)
--               Output: u.id
--               Index Cond: (u.id = 3)
--               Heap Fetches: 1
--         ->  Bitmap Heap Scan on public.one_time_codes otc  (cost=4.21..139.55 rows=1 width=20) (actual time=0.010..0.010 rows=0 loops=1)
--               Output: otc.id, otc.user_id, otc.code, otc.inserted_at
--               Recheck Cond: (otc.code = 482693)
--               Filter: ((otc.user_id = 3) AND (otc.inserted_at > (now() - '00:03:00'::interval)) AND (SubPlan 1))
--               Rows Removed by Filter: 1
--               Heap Blocks: exact=1
--               ->  Bitmap Index Scan on one_time_codes_code_index  (cost=0.00..4.21 rows=8 width=0) (actual time=0.003..0.003 rows=1 loops=1)
--                     Index Cond: (otc.code = 482693)
--               SubPlan 1
--                 ->  Seq Scan on public.one_time_codes otc2  (cost=0.00..31.25 rows=8 width=8) (never executed)
--                       Output: otc.inserted_at
--                       Filter: (otc2.user_id = 3)
--   ->  Bitmap Heap Scan on public.one_time_code_invalidations otci  (cost=22.03..32.57 rows=9 width=12) (never executed)
--         Output: otci.id, otci.one_time_code_id, otci.inserted_at
--         Recheck Cond: (otci.one_time_code_id = otc.id)
--         ->  Bitmap Index Scan on one_time_code_invalidations_pkey  (cost=0.00..22.03 rows=9 width=0) (never executed)
--               Index Cond: (otci.one_time_code_id = otc.id)
-- Planning time: 0.373 ms
-- Execution time: 0.138 ms
