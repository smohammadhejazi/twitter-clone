DELIMITER &&
CREATE PROCEDURE get_popular_tweets()
BEGIN
	CALL get_last_username(@user);
    SELECT tweet.username, tweet.text, tweet.sent_date, IFNULL(popular.likes, 0) AS likes
    FROM `tweet` LEFT OUTER JOIN (SELECT `tweet_id`,COUNT(`tweet_id`) AS likes
                   FROM `like_tweet` 
                   GROUP BY `tweet_id`) AS popular
    ON tweet.id=popular.tweet_id
    AND EXISTS(SELECT * 
               FROM `block` 
               WHERE (SELECT `username` 
                      FROM `tweet` 
                      WHERE tweet.id=popular.tweet_id)=block.blocking_user and block.blocked_user=@user)=0
    ORDER BY popular.likes DESC;
END &&
DELIMITER ;