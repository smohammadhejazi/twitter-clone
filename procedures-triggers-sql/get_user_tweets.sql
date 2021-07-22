DELIMITER &&
CREATE PROCEDURE get_user_tweets(IN tweeter VARCHAR(20))
BEGIN
	CALL get_last_username(@user);
    SELECT tweet.username, tweet.text, tweet.sent_date 
    FROM `tweet`
    WHERE tweet.username=tweeter and EXISTS(
        SELECT * 
        FROM `block` 
        WHERE tweeter=block.blocking_user and block.blocked_user=@user)=0
    ORDER BY `sent_date` DESC;
END &&
DELIMITER ;