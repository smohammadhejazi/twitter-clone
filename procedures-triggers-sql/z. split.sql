DELIMITER $$
CREATE PROCEDURE `split`(_list VARCHAR(256))
-- src: https://stackoverflow.com/questions/37213789/split-a-string-and-loop-through-values-in-mysql-procedure
-- with a little change
BEGIN
	DECLARE _next TEXT DEFAULT NULL;
    DECLARE _nextlen INT DEFAULT NULL;
    DECLARE _value TEXT DEFAULT NULL;
    
    DROP TEMPORARY TABLE IF EXISTS `text_split`;
    CREATE TEMPORARY TABLE `text_split` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `part` varchar(256) NOT NULL,
      PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

    iterator:
    LOOP
      -- exit the loop if the list seems empty or was null;
      -- this extra caution is necessary to avoid an endless loop in the proc.
      IF CHAR_LENGTH(TRIM(_list)) = 0 OR _list IS NULL THEN
        LEAVE iterator;
      END IF;

      -- capture the next value from the list
      SET _next = SUBSTRING_INDEX(_list,' ',1);

      -- save the length of the captured value; we will need to remove this
      -- many characters + 1 from the beginning of the string 
      -- before the next iteration
      SET _nextlen = CHAR_LENGTH(_next);

      -- trim the value of leading and trailing spaces, in case of sloppy CSV strings
      SET _value = TRIM(_next);

      -- insert the extracted value into the target table
      INSERT INTO `text_split` (part) VALUES (_value);

      -- rewrite the original string using the `INSERT()` string function,
      -- args are original string, start position, how many characters to remove, 
      -- and what to "insert" in their place (in this case, we "insert"
      -- an empty string, which removes _nextlen + 1 characters)
      SET _list = INSERT(_list,1,_nextlen + 1,'');
    END LOOP;
END $$
DELIMITER ;