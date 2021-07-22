DELIMITER &&
CREATE PROCEDURE get_directs(IN sending VARCHAR(20))
BEGIN
	CALL get_last_username(@user);
    SELECT `sending_username`, `text`, `sent_date`, "text" AS `text/tweet`
    FROM `direct`
    WHERE `receiving_username`=@user AND `sending_username`=sending AND `tweet_id` IS NULL
    UNION
    SELECT `username`, tweet.text, direct.sent_date, "tweet" AS `text/tweet`
    FROM `tweet`,`direct`
    WHERE tweet.id=direct.tweet_id 
    AND `receiving_username`=@user 
	AND `sending_username`=sending
    AND EXISTS(SELECT * 
               FROM `block` 
               WHERE tweet.username=block.blocking_user and @user=block.blocked_user)=0
    ORDER BY sent_date DESC;
END &&
DELIMITER ;