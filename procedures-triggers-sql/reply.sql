DELIMITER &&
CREATE PROCEDURE reply(IN tid INT, IN txt VARCHAR(256))
BEGIN
	CALL get_last_username(@user);
    INSERT INTO `tweet`(`username`, `text`) 
    SELECT @user,txt
    WHERE EXISTS(SELECT * 
                 FROM `block` 
                 WHERE (SELECT `username` FROM `tweet` WHERE `id`=tid)=block.blocking_user and block.blocked_user=@user)=0;
    
    INSERT INTO `reply`(`reply_id`, `tweet_id`) 
    SELECT (SELECT last_insert_id()),tid
    WHERE EXISTS(SELECT * 
                 FROM `block` 
                 WHERE (SELECT `username` FROM `tweet` WHERE `id`=tid)=block.blocking_user and block.blocked_user=@user)=0;
END &&
DELIMITER ;