DELIMITER &&
CREATE PROCEDURE get_last_username()
BEGIN 
    SELECT username INTO last_username FROM login ORDER BY id DESC LIMIT 1;
END &&
DELIMITER ;