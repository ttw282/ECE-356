-- CREATING TABLES

-- Foreign key dependant tables here
DROP TABLE IF EXISTS Address;
DROP TABLE IF EXISTS DoctorSpec;
DROP TABLE IF EXISTS Review;
DROP TABLE IF EXISTS SocialNetwork;
DROP TABLE IF EXISTS Specialization;
DROP TABLE IF EXISTS Doctor;
DROP TABLE IF EXISTS Patient;
DROP TABLE IF EXISTS User;

CREATE TABLE User(
    username VARCHAR(100),   -- user alias, either docAlias or patAlias
    salt     VARCHAR(64),
    hash     VARCHAR(64),
    role     CHAR(1),        -- 0 for doctor, 1 for patient
    PRIMARY KEY(username)
);

CREATE TABLE Doctor(
    docAlias        VARCHAR(100),
    firstName       VARCHAR(100),
    lastName        VARCHAR(100),
    gender          VARCHAR(20),
    docEmail        VARCHAR(100),
    yearLicensed    INTEGER,
    PRIMARY KEY(docAlias),
    FOREIGN KEY(docAlias) REFERENCES User(username)
);

CREATE TABLE Address(
    id         INTEGER NOT NULL AUTO_INCREMENT,
    docAlias   VARCHAR(100),
    address    VARCHAR(100),
    city       VARCHAR(100),
    province   VARCHAR(100),
    postalCode VARCHAR(100),

    PRIMARY KEY(id),
    FOREIGN KEY(docAlias) REFERENCES Doctor(docAlias)
);

CREATE TABLE Specialization(
    specId  INTEGER NOT NULL AUTO_INCREMENT,
    field   VARCHAR(100),
    PRIMARY KEY(specId)
);

CREATE TABLE DoctorSpec(
    docAlias    VARCHAR(100),
    specId      INTEGER,
    PRIMARY KEY (docAlias, specId),
    FOREIGN KEY (docAlias) REFERENCES Doctor(docAlias),
    FOREIGN KEY (specId) REFERENCES Specialization(specId)
);

CREATE TABLE Patient(
    patAlias  VARCHAR(100),
    firstName VARCHAR(100),
    lastName  VARCHAR(100),
    city      VARCHAR(100),
    province  VARCHAR(100),
    patEmail  VARCHAR(100),
    PRIMARY KEY(patAlias),
    FOREIGN KEY(patAlias) REFERENCES User(username)
);

CREATE TABLE Review(
    reviewId   INTEGER NOT NULL AUTO_INCREMENT,
    submitDate DATETIME,
    patAlias   VARCHAR(100),
    docAlias   VARCHAR(100),
    rating     FLOAT NOT NULL,
    comments   VARCHAR(1000),
    PRIMARY KEY (reviewId),
    FOREIGN KEY (patAlias) REFERENCES Patient(patAlias),
    FOREIGN KEY (docAlias) REFERENCES Doctor(docAlias)
);

CREATE TABLE SocialNetwork(
    patAlias VARCHAR(100),
    friendAlias VARCHAR(100),
    PRIMARY KEY(patAlias, friendAlias),
    FOREIGN KEY (patAlias) REFERENCES Patient(patAlias),
    FOREIGN KEY (friendAlias) REFERENCES Patient(patAlias)
);
