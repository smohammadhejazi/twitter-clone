DELIMITER &&
CREATE PROCEDURE get_followed_tweets()
BEGIN
	CALL get_last_username(@user);
    SELECT tweet.username, tweet.text, tweet.sent_date 
    FROM `follow`,`tweet`
    WHERE follow.following_user=@user and follow.followed_user=tweet.username and EXISTS(
        SELECT * 
        FROM `block` 
        WHERE tweet.username=block.blocking_user and follow.following_user=block.blocked_user)=0
    ORDER BY `sent_date` DESC;
END &&
DELIMITER ;