-- O1
-- [Patient Alias]: Patients Alias to search for
-- [Provice]:       Province to search for
-- [City]:  		City to search for
SELECT P.patAlias, P.province, P.city, COUNT(R.patAlias) AS "numReviews", MAX(submitDate) AS "Latest Review"
FROM Patient P
LEFT JOIN Review R ON P.patAlias = R.patAlias
WHERE P.patAlias LIKE "%[Patient Alias]%" AND P.province LIKE "%[Province]%"
AND P.city LIKE "%[City]%"
GROUP BY P.patAlias;

-- O2: Returns 2 if relationship formed, 1 if friend request is pending, 0 if not friends
-- [Patient A]: First Person Alias in the relationship
-- [Patient B]: Second Person Alias in the relationship
SELECT COUNT(*) FROM SocialNetwork
WHERE (patAlias = [Patient A] AND friendAlias = [Patient B])
OR    (patAlias = [Patient B] AND friendAlias = [Patient A]);

-- O3
-- [Patient Alias]: The person whose friend requests we're finding
SELECT P.patAlias, P.patEmail FROM Patient P
RIGHT JOIN (
    SELECT A.patAlias FROM SocialNetwork AS A
    WHERE A.friendAlias = [Patient Alias]
    AND A.patAlias NOT IN (
        SELECT B.friendAlias FROM SocialNetwork as B
        WHERE B.patAlias = [Patient Alias]
    )
) AS C
ON C.patAlias = P.patAlias;

-- O4:
-- Everything surrounded in [] are search terms.
SELECT D.firstName, D.lastName, D.gender, AVG(R.rating) AS "avgRating", COUNT(R.docAlias)
FROM Doctor D
INNER JOIN Review R         ON R.docAlias = D.docAlias
INNER JOIN Address A        ON A.docAlias = D.docAlias
INNER JOIN DoctorSpec DS    ON DS.docAlias = D.docAlias
INNER JOIN Specialization S ON S.specId = DS.specId
WHERE
	S.specId = [specId]
	AND A.address    LIKE "%[address]%"
	AND A.city       LIKE "%[city]%"
	AND A.postalCode LIKE "%[postalCode]%"
	AND A.province   LIKE "%[province]%"
	AND (
		-- If reviewdByFriend is 0, ignore the rest.
		-- Otherwise, make sure we're friends with the
		-- reviewer
		[reviewedByFriend] = 0 OR
		(EXISTS (
			SELECT 1 FROM SocialNetwork
			WHERE
				SocialNetwork.patAlias = [patient]
				AND SocialNetwork.friendAlias = R.patAlias
		)
		AND EXISTS (
			SELECT 1 FROM SocialNetwork
			WHERE
				SocialNetwork.patAlias = R.patAlias
				AND SocialNetwork.friendAlias = [patient]
		))
	)
	AND D.lastName     LIKE "%[lastName]%"
	AND D.firstName    LIKE "%[firstName]%"
	AND D.gender       = [gender]
	AND D.yearLicensed > [yearLicensed]
	AND LOWER(R.comments) LIKE "%[comments]%";
	HAVING AVG(R.rating)  >= [rating];


-- O5
-- [docAlias]: Doctor's alias who's profile we're looking up
SELECT D.firstName, D.lastName, D.gender, A.address, A.city, A.province, A.postalCode, D.yearLicensed, AVG(R.rating) AS "avgRating"
FROM Doctor D
LEFT JOIN Review R ON R.docAlias = D.docAlias
LEFT JOIN Address A ON A.docAlias = D.docAlias
WHERE D.docAlias = [docAlias];

-- O6
-- [docAlias]: Alias of the doctor we're retrieving the review of
-- [reviewNumber]: The review we want to see, in chronological order.
SELECT D.firstName, D.lastName, R.submitDate, R.rating, R.comments
FROM Doctor D
LEFT JOIN Review R ON D.docAlias = R.docAlias
WHERE D.docAlias = [docAlias]
ORDER BY R.submitDate
LIMIT 1
OFFSET [reviewNumber];

-- O7
INSERT INTO Review (submitDate, patAlias, docAlias, rating, comments)
VALUES (CURRENT_DATE(), [patAlias], [docAlias], [rating], [comments]);

-- O8
-- [docAlias] Doctor's profile we're retrieving
SELECT *
FROM Doctor
WHERE docAlias = [docAlias];

-- O9
--NOT NEEDED
