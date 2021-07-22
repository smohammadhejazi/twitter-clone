DELIMITER &&
CREATE PROCEDURE tweet(IN txt VARCHAR(256))
BEGIN    
	CALL `split`(txt);
    
    DELETE FROM `text_split`
    WHERE `text_split`.`part` NOT LIKE '#%';
    
	IF EXISTS(SELECT * FROM text_split WHERE (CHAR_LENGTH(text_split.part)!=6) OR (text_split.part NOT LIKE '#%') OR ((text_split.part REGEXP '[0-9]')!=0)) THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Hashtag is not valid.";
  	END IF;
    
	CALL get_last_username(@user);    
    INSERT INTO `tweet`(`username`, `text`) 
	VALUES (@user,txt);
END &&
DELIMITER ;