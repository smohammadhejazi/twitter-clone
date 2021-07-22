-- phpMyAdmin SQL Dump
-- version 5.1.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 13, 2021 at 03:00 PM
-- Server version: 10.4.18-MariaDB
-- PHP Version: 8.0.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `twitter-clone`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_hashtag` (IN `tid` INT, IN `tag` VARCHAR(6))  BEGIN

	INSERT IGNORE INTO `hashtag`(`name`)
    SELECT tag
    HAVING (CHAR_LENGTH(tag)=6) AND (tag LIKE '#%') AND (tag REGEXP '[0-9]')=0;

    INSERT INTO `tweet_direct_hashtag`(`tweet_id`,`hashtag_id`)
    SELECT tid, (SELECT `id` FROM `hashtag` WHERE `name`=tag) AS tag_id
    HAVING NOT EXISTS (SELECT * FROM `tweet_direct_hashtag` 
                      WHERE `tweet_id`=tid AND `hashtag_id`=tag_id LIMIT 1); 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `block` (IN `blocked` VARCHAR(20))  BEGIN
	CALL get_last_username(@user);
    INSERT IGNORE INTO `block`(`blocking_user`, `blocked_user`)
	SELECT @user, blocked
	WHERE @user != blocked;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `direct_text` (IN `receiving` VARCHAR(20), IN `txt` VARCHAR(20))  BEGIN
	CALL get_last_username(@user);
    INSERT INTO `direct`(`sending_username`, `receiving_username`, `text`) 
	SELECT @user, receiving, txt
	WHERE EXISTS(SELECT * 
                 FROM `block`
                 WHERE receiving=block.blocking_user and @user=block.blocked_user)=0;		 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `direct_tweet` (IN `receiving` VARCHAR(20), IN `tid` INT)  BEGIN
	CALL get_last_username(@user);
    INSERT INTO `direct`(`sending_username`, `receiving_username`, `tweet_id`) 
    SELECT @user ,receiving ,tid
    HAVING EXISTS(SELECT * 
                  FROM `block`
                  WHERE receiving=block.blocking_user AND @user=block.blocked_user)=0 
    AND EXISTS(SELECT * FROM `block` WHERE (SELECT `username` 
                                            FROM `tweet` 
                                            WHERE id=tid)=block.blocking_user AND receiving=block.blocked_user)=0;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `follow` (IN `receiving` VARCHAR(20))  BEGIN 
	CALL get_last_username(@user);
    INSERT IGNORE INTO `follow`(`following_user`, `followed_user`) 
    SELECT @user, receiving
    WHERE @user != receiving;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_directs` (IN `sending` VARCHAR(20))  BEGIN
	CALL get_last_username(@user);
    SELECT `sending_username`, `text`, `sent_date`, "text" AS `text/tweet`
    FROM `direct`
    WHERE `receiving_username`=@user AND `sending_username`=sending AND `tweet_id` IS NULL
    UNION
    SELECT `username`, tweet.text, direct.sent_date, "tweet" AS `text/tweet`
    FROM `tweet`,`direct`
    WHERE tweet.id=direct.tweet_id 
    AND `receiving_username`=@user 
	AND `sending_username`=sending
    AND EXISTS(SELECT * 
               FROM `block` 
               WHERE tweet.username=block.blocking_user and @user=block.blocked_user)=0
    ORDER BY sent_date DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_direct_list` ()  BEGIN
	CALL get_last_username(@user);
    SELECT `sending_username`, MAX(`sent_date`) AS `last_date`
    FROM `direct`
    WHERE `receiving_username`=@user
    GROUP BY `sending_username`
    ORDER BY `sent_date` DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_followed_tweets` ()  BEGIN
	CALL get_last_username(@user);
    SELECT tweet.username, tweet.text, tweet.sent_date 
    FROM `follow`,`tweet`
    WHERE follow.following_user=@user and follow.followed_user=tweet.username and EXISTS(
        SELECT * 
        FROM `block` 
        WHERE tweet.username=block.blocking_user and follow.following_user=block.blocked_user)=0
    ORDER BY `sent_date` DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_hashtag_tweets` (IN `tag` VARCHAR(6))  BEGIN
	CALL get_last_username(@user);
    SELECT tweet.username, tweet.text, tweet.sent_date 
    FROM `tweet`, (SELECT `tweet_id` 
                   FROM `tweet_direct_hashtag` 
                   WHERE `hashtag_id`=(SELECT `id` 
                                       FROM `hashtag` 
                                       WHERE `name`=tag)) AS hashtag_tweets
    WHERE `id`=hashtag_tweets.tweet_id
    AND EXISTS(
        SELECT * 
        FROM `block` 
        WHERE tweet.username=block.blocking_user and @user=block.blocked_user)=0;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_last_username` (OUT `last_username` VARCHAR(20))  BEGIN 
    SELECT username INTO last_username FROM login ORDER BY id DESC LIMIT 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_logins` ()  BEGIN
	CALL get_last_username(@user);
    SELECT `login_date` 
    FROM `login`
    WHERE (username=@user) 
    ORDER BY `login_date` DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_own_tweets` ()  BEGIN
	CALL get_last_username(@user);
    SELECT `text`,`sent_date` 
    FROM `tweet` 
    WHERE (`username` = @user)
    ORDER BY `sent_date` DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_popular_tweets` ()  BEGIN
	CALL get_last_username(@user);
    SELECT tweet.username, tweet.text, tweet.sent_date, IFNULL(popular.likes, 0) AS likes
    FROM `tweet` LEFT OUTER JOIN (SELECT `tweet_id`,COUNT(`tweet_id`) AS likes
                   FROM `like_tweet` 
                   GROUP BY `tweet_id`) AS popular
    ON tweet.id=popular.tweet_id
    AND EXISTS(SELECT * 
               FROM `block` 
               WHERE (SELECT `username` 
                      FROM `tweet` 
                      WHERE tweet.id=popular.tweet_id)=block.blocking_user and block.blocked_user=@user)=0
    ORDER BY popular.likes DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_replys` (IN `tid` INT)  BEGIN
	CALL get_last_username(@user);
    SELECT tweet.username, tweet.text, tweet.sent_date  
    FROM `tweet`,(SELECT `reply_id`
                  FROM `reply`
                  WHERE `tweet_id`=tid) AS replys
    WHERE tweet.id=replys.reply_id AND EXISTS(SELECT * 
                                       FROM `block`
                                       WHERE (SELECT `username` FROM `tweet` WHERE `id`=tid)=block.blocking_user and block.blocked_user=@user)=0
                                   AND EXISTS(SELECT * 
                                       FROM `block`
                                       WHERE tweet.username=block.blocking_user and block.blocked_user=@user)=0
    ORDER BY `sent_date` DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_tweet_likes` (IN `tid` INT)  BEGIN
	CALL get_last_username(@user);
    SELECT COUNT(`tweet_id`) AS likes 
    FROM `like_tweet` 
    WHERE `tweet_id`=tid AND EXISTS(SELECT * 
                                      FROM `block` 
                                      WHERE (SELECT `username` 
                                             FROM `tweet` 
                                             WHERE tweet.id=like_tweet.tweet_id)=block.blocking_user and block.blocked_user=@user)=0;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_user_tweets` (IN `tweeter` VARCHAR(20))  BEGIN
	CALL get_last_username(@user);
    SELECT tweet.username, tweet.text, tweet.sent_date 
    FROM `tweet`
    WHERE tweet.username=tweeter and EXISTS(
        SELECT * 
        FROM `block` 
        WHERE tweeter=block.blocking_user and block.blocked_user=@user)=0
    ORDER BY `sent_date` DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `like_tweet` (IN `tid` INT)  BEGIN
	CALL get_last_username(@user);
    INSERT INTO `like_tweet`(`liking_user`, `tweet_id`) 
    SELECT @user, tid
    HAVING EXISTS(SELECT * 
                  FROM `block` 
                  WHERE (SELECT `username` 
                         FROM `tweet` WHERE 
                         `id`=tid)=block.blocking_user and @user=block.blocked_user)=0;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `login` (IN `login_user` VARCHAR(20), IN `pass` VARCHAR(128))  BEGIN
    INSERT INTO `login`(`username`) 
    SELECT login_user 
    WHERE (SELECT `password` FROM `user` WHERE `username` = login_user) = sha1(pass);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reply` (IN `tid` INT, IN `txt` VARCHAR(256))  BEGIN
	CALL get_last_username(@user);
    INSERT INTO `tweet`(`username`, `text`) 
    SELECT @user,txt
    WHERE EXISTS(SELECT * 
                 FROM `block` 
                 WHERE (SELECT `username` FROM `tweet` WHERE `id`=`tid`)=block.blocking_user and block.blocked_user=@user)=0;
    
    INSERT INTO `reply`(`reply_id`, `tweet_id`) 
    SELECT (SELECT last_insert_id()),tid
    WHERE EXISTS(SELECT * 
                 FROM `block` 
                 WHERE (SELECT `username` FROM `tweet` WHERE `id`=`tid`)=block.blocking_user and block.blocked_user=@user)=0;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sign_in` (IN `username` VARCHAR(20), IN `pass` VARCHAR(128), IN `first_name` VARCHAR(20), IN `last_name` VARCHAR(20), IN `birthday` DATE, IN `biography` VARCHAR(64))  BEGIN 
    INSERT INTO `user`(`username`, `password`, `first_name`, `last_name`, `birthday`, `biography`) 
    VALUES (username, sha1(pass), first_name, last_name, birthday, biography);
    SELECT * FROM `user`;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `split` (`_list` VARCHAR(256))  BEGIN
	DECLARE _next TEXT DEFAULT NULL;
    DECLARE _nextlen INT DEFAULT NULL;
    DECLARE _value TEXT DEFAULT NULL;
    
    DROP TEMPORARY TABLE IF EXISTS `text_split`;
    CREATE TEMPORARY TABLE `text_split` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `part` varchar(256) NOT NULL,
      PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
	-- https://stackoverflow.com/questions/37213789/split-a-string-and-loop-through-values-in-mysql-procedure

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
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `tweet` (IN `txt` VARCHAR(256))  BEGIN    
	CALL `split`(txt);
    
    DELETE FROM `text_split`
    WHERE `text_split`.`part` NOT LIKE '#%';
    
	IF EXISTS(SELECT * FROM text_split WHERE (CHAR_LENGTH(text_split.part)!=6) OR (text_split.part NOT LIKE '#%') OR ((text_split.part REGEXP '[0-9]')!=0)) THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Hashtag is not valid.";
  	END IF;
    
	CALL get_last_username(@user);    
    INSERT INTO `tweet`(`username`, `text`) 
	VALUES (@user,txt);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `unblock` (IN `unblock_user` VARCHAR(20))  BEGIN
	CALL get_last_username(@user);
    DELETE FROM `block` 
	WHERE blocking_user=@user and blocked_user=unblock_user;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `unfollow` (IN `unfollow_user` VARCHAR(20))  BEGIN
	CALL get_last_username(@user);
    DELETE FROM `follow` 
    WHERE following_user=@user and followed_user=unfollow_user;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `username` varchar(20) NOT NULL,
  `password` varchar(128) NOT NULL,
  `first_name` varchar(20) NOT NULL,
  `last_name` varchar(20) NOT NULL,
  `birthday` date NOT NULL,
  `sign_in_date` datetime DEFAULT current_timestamp(),
  `biography` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


--
-- Triggers `user`
--
DELIMITER $$
CREATE TRIGGER `signup_log` AFTER INSERT ON `user` FOR EACH ROW BEGIN
	INSERT INTO `signup_log`(`username`) VALUES (NEW.`username`);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tweet`
--

CREATE TABLE `tweet` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(20) NOT NULL,
  `text` varchar(256) NOT NULL,
  `sent_date` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  FOREIGN KEY (`username`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `tweet`
--
DELIMITER $$
CREATE TRIGGER `hashtag` AFTER INSERT ON `tweet` FOR EACH ROW BEGIN
	DECLARE i INT DEFAULT 0;
    DECLARE n INT DEFAULT 0;
    SELECT COUNT(*) FROM `text_split` INTO n;
    SET i = 0;
    WHILE i < n DO
        CALL `add_hashtag`(NEW.id, (SELECT `text_split`.`part` FROM `text_split` LIMIT i,1));
        SET i = i + 1;
    END WHILE;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tweet_log` AFTER INSERT ON `tweet` FOR EACH ROW BEGIN
	INSERT INTO `tweet_log`(`username`, `tweet_id`) VALUES (NEW.`username`,NEW.`id`);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `block`
--

CREATE TABLE `block` (
  `blocking_user` varchar(20) NOT NULL,
  `blocked_user` varchar(20) NOT NULL,
  PRIMARY KEY (`blocking_user`,`blocked_user`),
  FOREIGN KEY (`blocking_user`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`blocked_user`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `direct`
--

CREATE TABLE `direct` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sending_username` varchar(20) NOT NULL,
  `receiving_username` varchar(20) NOT NULL,
  `text` varchar(256) DEFAULT NULL,
  `tweet_id` int(11) DEFAULT NULL,
  `sent_date` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  FOREIGN KEY (`sending_username`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`receiving_username`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`tweet_id`) REFERENCES `tweet` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `follow`
--

CREATE TABLE `follow` (
  `following_user` varchar(20) NOT NULL,
  `followed_user` varchar(20) NOT NULL,
  PRIMARY KEY (`following_user`,`followed_user`),
  FOREIGN KEY (`following_user`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`followed_user`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `hashtag`
--

CREATE TABLE `hashtag` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `like_tweet`
--

CREATE TABLE `like_tweet` (
  `liking_user` varchar(20) NOT NULL,
  `tweet_id` int(11) NOT NULL,
  PRIMARY KEY (`liking_user`,`tweet_id`),
  FOREIGN KEY (`liking_user`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`tweet_id`) REFERENCES `tweet` (`id`) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `login`
--

CREATE TABLE `login` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(20) NOT NULL,
  `login_date` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  FOREIGN KEY (`username`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `reply`
--

CREATE TABLE `reply` (
  `reply_id` int(11) NOT NULL,
  `tweet_id` int(11) NOT NULL,
  PRIMARY KEY (`reply_id`,`tweet_id`),
  FOREIGN KEY (`reply_id`) REFERENCES `tweet` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`tweet_id`) REFERENCES `tweet` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `signup_log`
--

CREATE TABLE `signup_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(20) NOT NULL,
  `signup_date` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY (`username`), 
  FOREIGN KEY (`username`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `tweet_direct_hashtag`
--

CREATE TABLE `tweet_direct_hashtag` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tweet_id` int(11) DEFAULT NULL,
  `direct_id` int(11) DEFAULT NULL,
  `hashtag_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`tweet_id`) REFERENCES `tweet` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`direct_id`) REFERENCES `direct` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`hashtag_id`) REFERENCES `hashtag` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `tweet_log`
--

CREATE TABLE `tweet_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(20) NOT NULL,
  `tweet_id` int(11) NOT NULL,
  `sent_date` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  FOREIGN KEY (`username`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`tweet_id`) REFERENCES `tweet` (`id`) ON DELETE CASCADE ON UPDATE CASCADE 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
