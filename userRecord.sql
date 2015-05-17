DROP PROCEDURE IF EXISTS createUser;

-- Creates a User entry with a provided password and hash.
DELIMITER @@
CREATE PROCEDURE createUser(
    IN _username varchar(100),
    IN _password varchar(100),
    IN _salt varchar(64),
    IN _role CHAR(1))
BEGIN
    INSERT INTO User (username, salt, hash, role)
    VALUES (_username, _salt, SHA2(CONCAT(_password, _salt), 256), _role);
END @@
DELIMITER ;

DROP PROCEDURE IF EXISTS authenticate;

-- Authenticates a login attemp with a given username and password.
-- If the username/password combo matches, valid is set to 1. Otherwise, 0.
DELIMITER @@
CREATE PROCEDURE authenticate(
    IN _username varchar(100),
    IN _password varchar(100),
    OUT valid BOOLEAN)
BEGIN
    -- Generate salted hash from attempted password
    DECLARE userSalt varchar(64) DEFAULT null;
    DECLARE testHash varchar(64) DEFAULT null;

    -- If the salt doesn't exist, it's not a big deal, since
    -- we'll end up just hashing with null. The validity check below
    -- will handle the fact that the user doesn't exist for us.
    SELECT Salt INTO userSalt FROM User WHERE username = _username;

    SET testHash = SHA2(CONCAT(_password, userSalt), 256);

    IF EXISTS(SELECT 1 FROM User WHERE username = _username AND hash = testHash) THEN
        SET valid = 1;
    ELSE
        SET valid = 0;
    END IF;
END @@
DELIMITER ;


DROP PROCEDURE IF EXISTS changePassword;

-- Attempts to change the password of a user.
-- If the user's old password matches, success
-- is set to 1, otherwise 0.
DELIMITER @@
CREATE PROCEDURE changePassword(
    IN _username    varchar(100),
    IN _oldPassword varchar(100),
    IN _newPassword varchar(100),
    IN _salt        varchar(64),
    OUT success BOOLEAN)
BEGIN
    -- Generate salted hash from old password
    DECLARE userSalt varchar(64) DEFAULT null;
    DECLARE testHash varchar(64) DEFAULT null;

    -- If the salt doesn't exist, it's not a big deal, since
    -- we'll end up just hashing with null. The validity check below
    -- will handle the fact that the user doesn't exist for us.
    SELECT Salt INTO userSalt FROM User WHERE username = _username;

    SET testHash = SHA2(CONCAT(_oldPassword, userSalt), 256);

    IF EXISTS(SELECT 1 FROM User WHERE username = _username AND hash = testHash) THEN
        UPDATE User SET salt = _salt, hash = SHA2(CONCAT(_newPassword, _salt), 256) WHERE username = _username;
        SET success = 1;
    ELSE
        SET success = 0;
    END IF;
END @@
DELIMITER ;
