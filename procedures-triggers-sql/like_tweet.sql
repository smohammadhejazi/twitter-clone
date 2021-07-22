DELIMITER &&
CREATE PROCEDURE like_tweet(IN tid INT)
BEGIN
	CALL get_last_username(@user);
    INSERT INTO `like_tweet`(`liking_user`, `tweet_id`) 
    SELECT @user, tid
    HAVING EXISTS(SELECT * 
                  FROM `block` 
                  WHERE (SELECT `username` 
                         FROM `tweet` WHERE 
                         `id`=tid)=block.blocking_user and @user=block.blocked_user)=0;
END &&
DELIMITER ;