DELIMITER &&
CREATE PROCEDURE direct_text(IN receiving VARCHAR(20), IN txt VARCHAR(20))
BEGIN
	CALL get_last_username(@user);
    INSERT INTO `direct`(`sending_username`, `receiving_username`, `text`) 
	SELECT @user, receiving, txt
	WHERE EXISTS(SELECT * 
                 FROM `block`
                 WHERE receiving=block.blocking_user and @user=block.blocked_user)=0;		 
END &&
DELIMITER ;