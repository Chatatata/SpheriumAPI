SELECT exists(
	SELECT 1
	FROM users AS u
	INNER JOIN permission_sets AS ps ON u.permission_set_id = ps.id
	INNER JOIN permission_set_permissions AS psp ON psp.permission_set_id = ps.id
	INNER JOIN controller_access_permissions AS cap ON cap.permission_id = psp.permission_id
	WHERE  u.id = 5 AND
		   cap.controller_name = 'SpheriumWebService.UserController' AND
		   cap.controller_action = 'index' AND
		   (cap.type = 'one' OR cap.type = 'all')
) AS "result";
