DELIMITER &&
CREATE PROCEDURE sign_in(IN username VARCHAR(20), IN pass VARCHAR(128), IN first_name VARCHAR(20), IN last_name VARCHAR(20), IN birthday date, IN biography varchar(64))
BEGIN 
    INSERT INTO `user`(`username`, `password`, `first_name`, `last_name`, `birthday`, `biography`) 
    VALUES (username, sha1(pass), first_name, last_name, birthday, biography);
END &&
DELIMITER ;