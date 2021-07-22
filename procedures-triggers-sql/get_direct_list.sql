DELIMITER &&
CREATE PROCEDURE get_direct_list()
BEGIN
	CALL get_last_username(@user);
    SELECT `sending_username`, MAX(`sent_date`) AS `last_date`
    FROM `direct`
    WHERE `receiving_username`=@user
    GROUP BY `sending_username`
    ORDER BY `sent_date` DESC;
END &&
DELIMITER ;