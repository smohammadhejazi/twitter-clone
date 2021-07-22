DELIMITER &&
CREATE TRIGGER tweet_log 
AFTER INSERT ON `tweet` FOR EACH ROW
BEGIN
	INSERT INTO `tweet_log`(`username`, `tweet_id`) VALUES (NEW.`username`,NEW.`id`);
END &&
DELIMITER ;