DELIMITER &&
CREATE PROCEDURE get_tweet_likes(IN tid INT)
BEGIN
	CALL get_last_username(@user);
    SELECT COUNT(`tweet_id`) AS likes 
    FROM `like_tweet` 
    WHERE `tweet_id`=tid AND EXISTS(SELECT * 
                                      FROM `block` 
                                      WHERE (SELECT `username` 
                                             FROM `tweet` 
                                             WHERE tweet.id=like_tweet.tweet_id)=block.blocking_user and block.blocked_user=@user)=0;
END &&
DELIMITER ;