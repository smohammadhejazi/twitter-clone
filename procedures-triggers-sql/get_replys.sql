DELIMITER &&
CREATE PROCEDURE get_replys(IN tid INT)
BEGIN
	CALL get_last_username(@user);
    SELECT tweet.username, tweet.text, tweet.sent_date  
    FROM `tweet`,(SELECT `reply_id`
                  FROM `reply`
                  WHERE `tweet_id`=tid) AS replys
    WHERE tweet.id=replys.reply_id AND EXISTS(SELECT * 
                                       FROM `block`
                                       WHERE (SELECT `username` FROM `tweet` WHERE `id`=tid)=block.blocking_user and block.blocked_user=@user)=0
                                   AND EXISTS(SELECT * 
                                       FROM `block`
                                       WHERE tweet.username=block.blocking_user and block.blocked_user=@user)=0
    ORDER BY `sent_date` DESC;
END &&
DELIMITER ;