DELIMITER &&
CREATE PROCEDURE block(IN blocked VARCHAR(20))
BEGIN
	CALL get_last_username(@user);
    INSERT IGNORE INTO `block`(`blocking_user`, `blocked_user`)
	SELECT @user, blocked
	WHERE @user != blocked;
END &&
DELIMITER ;