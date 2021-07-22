DELIMITER &&
CREATE PROCEDURE get_own_tweets()
BEGIN
	CALL get_last_username(@user);
    SELECT `text`,`sent_date` 
    FROM `tweet` 
    WHERE (`username` = @user)
    ORDER BY `sent_date` DESC;
END &&
DELIMITER ;