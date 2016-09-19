SELECT lrp.subroutine
FROM users AS u
INNER JOIN permission_sets AS ps ON u.permission_set_id = ps.id
INNER JOIN permission_set_permissions AS psp ON psp.permission_set_id = ps.id
INNER JOIN lambda_revoke_permissions AS lrp ON lrp.permission_id = psp.permission_id
WHERE u.id = 5;
