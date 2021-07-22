DELIMITER &&
CREATE PROCEDURE unfollow(IN unfollow_user VARCHAR(20))
BEGIN
	CALL get_last_username(@user);
    DELETE FROM `follow` 
    WHERE following_user=@user and followed_user=unfollow_user;
END &&
DELIMITER ;