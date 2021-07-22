DELIMITER &&
CREATE TRIGGER hashtag 
AFTER INSERT ON `tweet` FOR EACH ROW
BEGIN
	DECLARE i INT DEFAULT 0;
    DECLARE n INT DEFAULT 0;
    SELECT COUNT(*) FROM `text_split` INTO n;
    SET i = 0;
    WHILE i < n DO
        CALL `add_hashtag`(NEW.id, (SELECT `text_split`.`part` FROM `text_split` LIMIT i,1));
        SET i = i + 1;
    END WHILE;
END &&
DELIMITER ;