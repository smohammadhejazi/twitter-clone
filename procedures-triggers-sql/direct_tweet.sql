DELIMITER &&
CREATE PROCEDURE direct_tweet(IN receiving VARCHAR(20), IN tid INT)
BEGIN
	CALL get_last_username(@user);
    INSERT INTO `direct`(`sending_username`, `receiving_username`, `tweet_id`) 
    SELECT @user ,receiving ,tid
    HAVING EXISTS(SELECT * 
                  FROM `block`
                  WHERE receiving=block.blocking_user AND @user=block.blocked_user)=0 
    AND EXISTS(SELECT * FROM `block` WHERE (SELECT `username` 
                                            FROM `tweet` 
                                            WHERE id=tid)=block.blocking_user AND receiving=block.blocked_user)=0;
END &&
DELIMITER ;