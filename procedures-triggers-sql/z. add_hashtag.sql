DELIMITER &&
CREATE PROCEDURE add_hashtag(IN tid INT, IN tag VARCHAR(6))
BEGIN

	INSERT IGNORE INTO `hashtag`(`name`)
    SELECT tag
    HAVING (CHAR_LENGTH(tag)=6) AND (tag LIKE '#%') AND (tag REGEXP '[0-9]')=0;

    INSERT INTO `tweet_direct_hashtag`(`tweet_id`,`hashtag_id`)
    SELECT tid, (SELECT `id` FROM `hashtag` WHERE `name`=tag) AS tag_id
    HAVING NOT EXISTS (SELECT * FROM `tweet_direct_hashtag` 
                      WHERE `tweet_id`=tid AND `hashtag_id`=tag_id LIMIT 1); 
END &&
DELIMITER ;