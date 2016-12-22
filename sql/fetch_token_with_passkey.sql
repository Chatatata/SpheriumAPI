DEALLOCATE fetch_token_with_passkey;

PREPARE fetch_token_with_passkey(text) AS (
  SELECT p.*, u.*
	FROM passphrases p
	LEFT OUTER JOIN passphrase_invalidations pi ON pi.target_passphrase_id = p.id
	INNER JOIN users u ON p.user_id = u.id
	WHERE pi.inserted_at IS NULL AND
		  p.passkey = $1 AND
		  p.inserted_at > (
        SELECT (
  			  CASE WHEN max(pr.inserted_at) IS NULL
            THEN
              to_date('01.01.1970', 'DD.MM.YYYY')
			      ELSE
              max(pr.inserted_at)
  		    END
        ) AS result
  		  FROM password_resets pr
  		  WHERE pr.user_id = 1
      )
);

-- should return 1 row.
EXECUTE fetch_token_with_passkey('newer passkey...');

-- should return no rows.
EXECUTE fetch_token_with_passkey('old passkey');
