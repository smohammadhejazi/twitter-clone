DELIMITER &&
CREATE PROCEDURE follow(IN receiving VARCHAR(20))
BEGIN 
	CALL get_last_username(@user);
    INSERT IGNORE INTO `follow`(`following_user`, `followed_user`) 
    SELECT @user, receiving
    WHERE @user != receiving;
END &&
DELIMITER ;