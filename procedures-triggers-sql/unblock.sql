DELIMITER &&
CREATE PROCEDURE unblock(IN unblock_user VARCHAR(20))
BEGIN
	CALL get_last_username(@user);
    DELETE FROM `block` 
	WHERE blocking_user=@user and blocked_user=unblock_user;
END &&
DELIMITER ;