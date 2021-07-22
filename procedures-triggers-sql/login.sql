DELIMITER &&
CREATE PROCEDURE login(IN login_user VARCHAR(20), IN pass VARCHAR(128))
BEGIN
    INSERT INTO `login`(`username`) 
    SELECT login_user 
    WHERE (SELECT `password` FROM `user` WHERE `username` = login_user) = sha1(pass);
END &&
DELIMITER ;