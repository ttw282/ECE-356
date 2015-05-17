CREATE VIEW DoctorSummaryView AS
SELECT D.firstName, D.lastName, D.gender, AVG(R.rating) AS "avgRating", COUNT(R.docAlias) AS "numReviews"
FROM Doctor D
LEFT JOIN Review R ON R.docAlias = D.docAlias;

CREATE VIEW PatientSummaryView AS
SELECT P.patAlias, P.province, P.city, COUNT(R.patAlias) AS "numReviews", MAX(submitDate) AS "Latest Review"
FROM Patient P
LEFT JOIN Review R ON P.patAlias = R.patAlias;

CREATE VIEW DoctorReviewView AS
SELECT D.firstName, D.lastName, R.submitDate, R.rating, R.comments
FROM Doctor D
LEFT JOIN Review R ON D.docAlias = R.docAlias;

CREATE VIEW DoctorProfileView AS
SELECT D.firstName, D.lastName, D.gender, A.address, A.city, A.province, A.postalCode, D.yearLicensed, AVG(R.rating) AS "avgRating"
FROM Doctor D
LEFT JOIN Review R ON R.docAlias = D.docAlias
LEFT JOIN Address A ON A.docAlias = D.docAlias;

CREATE VIEW FriendRequestView AS
SELECT P.patAlias, P.patEmail
FROM Patient P
LEFT JOIN SocialNetwork S ON S.friendAlias = P.patAlias;
