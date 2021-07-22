DELIMITER &&
CREATE PROCEDURE get_logins()
BEGIN
	CALL get_last_username(@user);
    SELECT `login_date` 
    FROM `login`
    WHERE (username=@user) 
    ORDER BY `login_date` DESC;
END &&
DELIMITER ;