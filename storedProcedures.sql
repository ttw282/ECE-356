/**************************************************
 * Stored Procedures for Presentation Application *
 **************************************************/
DROP PROCEDURE IF EXISTS PatientSearch;
DELIMITER @@
CREATE PROCEDURE PatientSearch(IN callerAlias VARCHAR(20), IN alias VARCHAR(20), IN province VARCHAR(100), IN city VARCHAR(100))
BEGIN
    SELECT P.*, COUNT(DISTINCT(R.reviewId)) AS "numReviews", MAX(submitDate) AS "lastestReviewDate", COUNT(S.patAlias) AS FriendStatus
    FROM Patient P
    LEFT JOIN Review R ON P.patAlias = R.patAlias
    LEFT JOIN (
        -- Parameter required: person we're in relation to
        SELECT patAlias, friendAlias
        from SocialNetwork
    ) AS S
    ON (S.patAlias = callerAlias AND S.friendAlias = P.patAlias) OR (S.patAlias = P.patAlias and S.friendAlias = callerAlias)
    WHERE P.patAlias LIKE Concat('%', alias, '%') AND P.province LIKE Concat('%', province, '%')
    AND P.city LIKE Concat('%', city, '%')
    AND P.patAlias != callerAlias
    GROUP BY P.patAlias;
END @@
DELIMITER ;

DROP PROCEDURE IF EXISTS AddFriend;
DELIMITER @@
CREATE PROCEDURE AddFriend(IN adder VARCHAR(20), IN addee VARCHAR(20), OUT retVal TINYINT)
proc: BEGIN
    DECLARE adderExists INT DEFAULT 0;
    DECLARE addeeExists INT DEFAULT 0;

    START TRANSACTION;

    SELECT 1 INTO adderExists FROM Patient WHERE patAlias = adder;
    SELECT 1 INTO addeeExists FROM Patient WHERE patAlias = addee;

    IF adderExists = 0 THEN
        SET retVal = -1;
        ROLLBACK;
        LEAVE proc;
    END IF;

    IF addeeExists = 0 THEN
        SET retVal = -2;
        ROLLBACK;
        LEAVE proc;
    END IF;

    INSERT IGNORE INTO SocialNetwork(patAlias, friendAlias) VALUES (adder, addee);

    -- Returns 2 if relationship formed, 1 if friend request is pending, 0 if not friends
    SELECT COUNT(*) INTO retVal FROM SocialNetwork
    WHERE (patAlias = adder AND friendAlias = addee)
    OR    (patAlias = addee AND friendAlias = adder);

    COMMIT;

END @@
DELIMITER ;

DROP PROCEDURE IF EXISTS GetUserType;
DELIMITER @@
CREATE PROCEDURE GetUserType(IN userAlias VARCHAR(20), OUT retVal TINYINT)
BEGIN
    DECLARE isPatient INT DEFAULT 0;
    DECLARE isDoctor  INT DEFAULT 0;

    SELECT 1 INTO isPatient FROM Patient WHERE patAlias = userAlias;
    SELECT 1 INTO isDoctor  FROM Doctor  WHERE docAlias = userAlias;

    IF isPatient = 1 THEN
        SET retVal = 1;
    ELSEIF isDoctor = 1 THEN
        SET retVal = 2;
    ELSE
        SET retVal = 0;
    END IF;
END @@
DELIMITER ;


DROP PROCEDURE IF EXISTS DoctorSearch;
DELIMITER @@
CREATE PROCEDURE DoctorSearch(
    IN currentuser VARCHAR(100),
    IN firstName   VARCHAR(100),
    IN lastName    VARCHAR(100),
    IN spec        VARCHAR(100),
    IN gender      VARCHAR(20),
    IN address     VARCHAR(100),
    IN city        VARCHAR(100),
    IN province    VARCHAR(100),
    IN years       INT,
    IN rating      INT,
    IN rbf         INT,
    IN keyword     VARCHAR(100))
BEGIN
    SELECT D.docAlias, A.address, A.city, A.province, A.postalCode, S.field, D.firstName, D.lastName, D.docEmail, D.gender, D.yearLicensed, AVG(R.rating) AS 'avgRating', COUNT(DISTINCT(R.reviewId)) AS 'numReviews'
    FROM Doctor D
    LEFT JOIN Review R         ON R.docAlias = D.docAlias
    INNER JOIN Address A        ON A.docAlias = D.docAlias
    INNER JOIN DoctorSpec DS    ON DS.docAlias = D.docAlias
    INNER JOIN Specialization S ON S.specId = DS.specId

    WHERE S.field    LIKE spec
    AND A.address    LIKE address
    AND A.city       LIKE city
    AND A.province   LIKE province
    AND (
        rbf = 0 OR
        (EXISTS (
            SELECT 1 FROM SocialNetwork
            WHERE
                SocialNetwork.patAlias = currentuser
                AND SocialNetwork.friendAlias = R.patAlias
            )
            AND EXISTS (
                SELECT 1 FROM SocialNetwork
                WHERE
                    SocialNetwork.patAlias = R.patAlias
                    AND SocialNetwork.friendAlias = currentuser
                ))
    )
    AND D.lastName      LIKE lastName
    AND D.firstName     LIKE firstName
    AND LOWER(D.gender) LIKE LOWER(gender)
    AND YEAR(CURDATE()) - D.yearLicensed >= years
    AND LOWER(IFNULL(R.comments, '')) LIKE keyword
    GROUP BY D.docAlias
    HAVING AVG(IFNULL(R.rating, 0))  >= rating;

END @@
DELIMITER ;


DROP PROCEDURE IF EXISTS WriteDoctorReview;
DELIMITER @@
CREATE PROCEDURE WriteDoctorReview(
    IN currentuser VARCHAR(100),
    IN docAlias    VARCHAR(100),
    IN rating      FLOAT,
    IN comments    VARCHAR(1000))
BEGIN
    INSERT INTO Review (submitDate, patAlias, docAlias, rating, comments)
    VALUES (Now(), currentuser, docAlias, rating, comments);

END @@
DELIMITER ;

/**************************************************
 * Testing Stored Procedures for Presentation     *
 **************************************************/
DROP PROCEDURE IF EXISTS Test_ResetDB;
DELIMITER @@
CREATE PROCEDURE Test_ResetDB()
BEGIN
    /* Reset state of database as described in lab manual */
    DELETE FROM Address;
    DELETE FROM DoctorSpec;
    DELETE FROM Review;
    DELETE FROM SocialNetwork;
    DELETE FROM Specialization;
    DELETE FROM Doctor;
    DELETE FROM Patient;
    DELETE FROM User;

    -- Bootstrap Specializations
    INSERT INTO Specialization SET specId = 1, field = "allergologist";
    INSERT INTO Specialization SET specId = 2, field = "naturopath";
    INSERT INTO Specialization SET specId = 3, field = "obstetrician";
    INSERT INTO Specialization SET specId = 4, field = "gynecologist";
    INSERT INTO Specialization SET specId = 5, field = "cardiologist";
    INSERT INTO Specialization SET specId = 6, field = "surgeon";
    INSERT INTO Specialization SET specId = 7, field = "psychiatrist";

    -- Bootstrap Doctors
    call createUser("doc_aiken", "doc_aiken", "7ae6b4b82c7174cf05ff85868d4d9d6857cba798094b9ab40870afb87bb2aa1c", 1);
    call createUser("doc_amnio", "doc_amnio", "19e694a0d6512b00d93bece6380b2c4a760ddc7b914df6c37a4df1ded0ece223", 1);
    call createUser("doc_umbilical", "doc_umbilical", "08c42aa04961553d881be3b26b5537af12164b5f0a4f3139a137f85a1802a503", 1);
    call createUser("doc_heart", "doc_heart", "686cfddb6c3e9613ea42afa822f0a20759f4364948e6243231bfdc988b77a21c", 1);
    call createUser("doc_cutter", "doc_cutter", "0263cec7a5ef07ce5ccaf73a2ec9a81557e84a5062176bfa6533ba847b8cbce1", 1);

    INSERT INTO Doctor SET docAlias='doc_aiken', firstName='John', lastName='Aikenhead', gender='male', docEmail='aiken@head.com', yearLicensed='1990';
    INSERT INTO Address SET docAlias = "doc_aiken", address = "1 Elizabeth Street", city = "Waterloo", province = "Ontario", postalCode = "N2L 2W8";
    INSERT INTO Address SET docAlias = "doc_aiken", address = "2 Aikenhead Street", city = "Kitchener", province = "Ontario", postalCode = "N2P 1K2";
    INSERT INTO DoctorSpec SET docAlias="doc_aiken", specId = 1;
    INSERT INTO DoctorSpec SET docAlias="doc_aiken", specId = 2;

    INSERT INTO Doctor SET docAlias='doc_amnio', firstName='Jane', lastName='Amniotic', gender='female', docEmail='obgyn_clinic@rogers.com', yearLicensed='2005';
    INSERT INTO Address SET docAlias = "doc_amnio", address = "1 Jane Street", city = "Waterloo", province = "Ontario", postalCode = "N2L 2W8";
    INSERT INTO Address SET docAlias = "doc_amnio", address = "2 Amniotic Street", city = "Kitchener", province = "Ontario", postalCode = "N2P 2K5";
    INSERT INTO DoctorSpec SET docAlias="doc_amnio", specId = 3;
    INSERT INTO DoctorSpec SET docAlias="doc_amnio", specId = 4;

    INSERT INTO Doctor SET docAlias='doc_umbilical', firstName='Mary', lastName='Umbilical', gender='female', docEmail='obgyn_clinic@rogers.com', yearLicensed='2006';
    INSERT INTO Address SET docAlias = "doc_umbilical", address = "1 Mary Street", city = "Cambridge", province = "Ontario", postalCode = "N2L 1A2";
    INSERT INTO Address SET docAlias = "doc_umbilical", address = "2 Amniotic Street", city = "Kitchener", province = "Ontario", postalCode = "N2P 2K5";
    INSERT INTO DoctorSpec SET docAlias="doc_umbilical", specId = 3;
    INSERT INTO DoctorSpec SET docAlias="doc_umbilical", specId = 2;

    INSERT INTO Doctor SET docAlias='doc_heart', firstName='Jack', lastName='Hearty', gender='male', docEmail='jack@healthyheart.com', yearLicensed='1980';
    INSERT INTO Address SET docAlias = "doc_heart", address = "1 Jack Street", city = "Guelph", province = "Ontario", postalCode = "N2L 1G2";
    INSERT INTO Address SET docAlias = "doc_heart", address = "2 Heart Street", city = "Waterloo", province = "Ontario", postalCode = "N2P 2W5";
    INSERT INTO DoctorSpec SET docAlias="doc_heart", specId = 5;
    INSERT INTO DoctorSpec SET docAlias="doc_heart", specId = 6;

    INSERT INTO Doctor SET docAlias='doc_cutter', firstName='Beth', lastName='Cutter', gender='female', docEmail='beth@tummytuck.com', yearLicensed='2014';
    INSERT INTO Address SET docAlias = "doc_cutter", address = "1 Beth Street", city = "Cambridge", province = "Ontario", postalCode = "N2L 1C2";
    INSERT INTO Address SET docAlias = "doc_cutter", address = "2 Cutter Street", city = "Kitchener", province = "Ontario", postalCode = "N2P 2K5";
    INSERT INTO DoctorSpec SET docAlias="doc_cutter", specId = 6;
    INSERT INTO DoctorSpec SET docAlias="doc_cutter", specId = 7;

    -- Bootstrap Patients
    call createUser("pat_bob", "pat_bob", "4ceea6872923257198c2928a46dedfc360402b5d2ff232e747ee6ee0944d9846", 0);
    call createUser("pat_peggy", "pat_peggy", "ddb3135911db273c41cad09a08cab1a9e80df77938650f77911bb17ec2eb4410", 0);
    call createUser("pat_homer", "pat_homer", "1259469280315460bbdd4b9a0a71adaef2b2ebea616958ef613ceef511ee21f2", 0);
    call createUser("pat_kate", "pat_kate", "3f78766abda7aa4867b54344511e78bb3ab1c4c664fb79da9be03ce609dc19a2", 0);
    call createUser("pat_anne", "pat_anne", "d292a2cca8abc42d813f3ee47aa521bc06b4862391b886ec5618d86d0940152c", 0);

    INSERT INTO Patient SET patAlias='pat_bob', firstName='Bob', lastName='Bobberson', province='Ontario', city='Waterloo', patEmail='thebobbersons@sympatico.ca';
    INSERT INTO Patient SET patAlias='pat_peggy', firstName='Peggy', lastName='Bobberson', province='Ontario', city='Waterloo', patEmail='thebobbersons@sympatico.ca';
    INSERT INTO Patient SET patAlias='pat_homer', firstName='Homer', lastName='Homerson', province='Ontario', city='Kitchener', patEmail='homer@rogers.com';
    INSERT INTO Patient SET patAlias='pat_kate', firstName='Kate', lastName=' Katemyer', province='Ontario', city='Cambridge', patEmail='kate@hello.com';
    INSERT INTO Patient SET patAlias='pat_anne', firstName='Anne', lastName='MacDonald', province='Ontario', city='Guelph', patEmail='anne@gmail.com';
END @
DELIMITER ;

DROP PROCEDURE IF EXISTS Test_PatientSearch;
DELIMITER @@
CREATE PROCEDURE Test_PatientSearch(IN province VARCHAR(20), IN city VARCHAR(20), OUT num_matches INT)
BEGIN
    /* Returns in num_matches the total number of patients in the given province and city */
    SELECT COUNT(*) INTO num_matches
    FROM Patient P
    WHERE P.province LIKE Concat("%", province, "%") AND P.city LIKE Concat("%", city, "%");
END @@
DELIMITER ;

DROP PROCEDURE IF EXISTS Test_DoctorSearch;
DELIMITER @@
CREATE PROCEDURE Test_DoctorSearch(IN gender VARCHAR(20), IN city VARCHAR(20), IN specialization VARCHAR(20), IN num_years_licensed INT, OUT num_matches INT)
BEGIN
    /* Returns in num_matches the total number of doctors that match exactly on all the given criteria
     *   gender('male' or 'female')
     *   city
     *   specialization
     *   number of years licensed
     */
     SELECT COUNT(*) INTO num_matches
     FROM Doctor D
     INNER JOIN Address A        ON A.docAlias = D.docAlias
     INNER JOIN DoctorSpec DS    ON DS.docAlias = D.docAlias
     INNER JOIN Specialization S ON S.specId = DS.specId

     WHERE D.gender = gender
     AND   A.city = city
     AND   S.field = specialization
     AND   YEAR(CURDATE()) - D.yearLicensed = num_years_licensed;

END @@
DELIMITER ;

DROP PROCEDURE IF EXISTS Test_DoctorSearchStarRating;
DELIMITER @@
CREATE PROCEDURE Test_DoctorSearchStarRating(IN avg_star_rating FLOAT, OUT num_matches INT)
BEGIN
    /* returns in num_matches the total number of doctors whose average star rating is equal to or greater than the given threshold */
    SELECT COUNT(*) INTO num_matches
    FROM
    (
        SELECT D.docAlias
        FROM Doctor D
        LEFT JOIN Review R ON R.docAlias = D.docAlias
        GROUP BY D.docAlias
        HAVING AVG(IFNULL(R.rating, 0))  >= avg_star_rating
    ) AS X;
END @@
DELIMITER ;

DROP PROCEDURE IF EXISTS Test_DoctorSearchFriendReview;
DELIMITER @@
CREATE PROCEDURE Test_DoctorSearchFriendReview
(IN patient_alias VARCHAR(20), IN review_keyword VARCHAR(20), OUT num_matches INT)
BEGIN
    /* returns in num_matches the total number of doctors who have been reviewed by friends of
    the given patient, and where at least one of the reviews for that doctor (not necessarily
    written by a friend) contains the given keyword (case-sensitive) */
    SELECT COUNT(*) INTO num_matches
    FROM (
        SELECT D.docAlias
        FROM Doctor D
        LEFT JOIN Review R         ON R.docAlias = D.docAlias
        WHERE (
            (EXISTS (
                SELECT 1 FROM SocialNetwork
                WHERE
                    SocialNetwork.patAlias = patient_alias
                    AND SocialNetwork.friendAlias = R.patAlias
                )
                AND EXISTS (
                    SELECT 1 FROM SocialNetwork
                    WHERE
                        SocialNetwork.patAlias = R.patAlias
                        AND SocialNetwork.friendAlias = patient_alias
                    ))
        )
        AND IFNULL(R.comments, '') LIKE CONCAT('%', review_keyword,'%')
        GROUP BY D.docAlias
    ) AS X;

END @@
DELIMITER;

DROP PROCEDURE IF EXISTS Test_RequestFriend;
DELIMITER @@
CREATE PROCEDURE Test_RequestFriend
(IN requestor_alias VARCHAR(20), IN requestee_alias VARCHAR(20))
BEGIN
    /* add friendship request from requestor_alias to requestee_alias */
    INSERT IGNORE INTO SocialNetwork(patAlias, friendAlias) VALUES (requestor_alias, requestee_alias);
END @@
DELIMITER;

DROP PROCEDURE IF EXISTS Test_ConfirmFriendRequest;
DELIMITER @@
CREATE PROCEDURE Test_ConfirmFriendRequest
(IN requestor_alias VARCHAR(20), IN requestee_alias VARCHAR(20))
BEGIN
    /* add friendship between requestor_alias and requestee_alias, assuming that friendship was requested previously */
    INSERT IGNORE INTO SocialNetwork(patAlias, friendAlias) VALUES (requestee_alias, requestor_alias);
END @@
DELIMITER;

DROP PROCEDURE IF EXISTS Test_AreFriends;
DELIMITER @@
CREATE PROCEDURE Test_AreFriends
(IN patient_alias_1 VARCHAR(20), IN patient_alias_2 VARCHAR(20), OUT are_friends INT)
BEGIN
    /* returns 1 in are_friends if patient_alias_1 and patient_alias_2 are friends, 0 otherwise */
    DECLARE friendStatus INT default 0;

    SELECT COUNT(*) INTO friendStatus
    FROM SocialNetwork
    WHERE (patAlias = patient_alias_1 AND friendAlias = patient_alias_2)
    OR    (patAlias = patient_alias_2 AND friendAlias = patient_alias_1);

    IF friendStatus = 2 THEN
        SET are_friends = 1;
    ELSE
        SET are_friends = 0;
    END IF;
END @@
DELIMITER;

DROP PROCEDURE IF EXISTS Test_AddReview;
DELIMITER @@
CREATE PROCEDURE Test_AddReview
(IN patient_alias VARCHAR(20), IN doctor_alias VARCHAR(20), IN star_rating FLOAT,
IN comments VARCHAR(256))
BEGIN
    /* add review by patient_alias for doctor_alias with the given star_rating and comments
       fields, assign the current date to the review automatically, assume that star_rating is an
       integer multiple of 0.5 (e.g., 1.5, 2.0, 2.5, etc.) */
    INSERT INTO Review (submitDate, patAlias, docAlias, rating, comments)
    VALUES (Now(), patient_alias, doctor_alias, star_rating, comments);
END @@
DELIMITER;

DROP PROCEDURE IF EXISTS Test_CheckReviews;
DELIMITER @@
CREATE PROCEDURE Test_CheckReviews
(IN doctor_alias VARCHAR(20), OUT avg_star FLOAT, OUT num_reviews INT)
BEGIN
    /* returns the average star rating and total number of reviews for the given doctor alias */
    SELECT COUNT(*), AVG(R.rating) INTO num_reviews, avg_star
    FROM Doctor D
    JOIN Review R on R.docAlias = D.docAlias
    WHERE D.docAlias = doctor_alias;
END @@
DELIMITER;
