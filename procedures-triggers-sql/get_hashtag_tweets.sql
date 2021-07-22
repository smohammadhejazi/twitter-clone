DELIMITER &&
CREATE PROCEDURE get_hashtag_tweets(IN tag varchar(6))
BEGIN
	CALL get_last_username(@user);
    SELECT tweet.username, tweet.text, tweet.sent_date 
    FROM `tweet`, (SELECT `tweet_id` 
                   FROM `tweet_direct_hashtag` 
                   WHERE `hashtag_id`=(SELECT `id` 
                                       FROM `hashtag` 
                                       WHERE `name`=tag)) AS hashtag_tweets
    WHERE `id`=hashtag_tweets.tweet_id
    AND EXISTS(
        SELECT * 
        FROM `block` 
        WHERE tweet.username=block.blocking_user and @user=block.blocked_user)=0;
END &&
DELIMITER ;