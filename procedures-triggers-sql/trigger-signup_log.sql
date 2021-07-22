DELIMITER &&
CREATE TRIGGER signup_log 
AFTER INSERT ON `user` FOR EACH ROW
BEGIN
	INSERT INTO `signup_log`(`username`) VALUES (NEW.`username`);
END &&
DELIMITER ;