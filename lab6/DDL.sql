-- Active: 1794345192058@@127.0.0.1@3306@test
CREATE DATABASE DBPROJECT;
USE DBPROJECT;

CREATE TABLE Person(
	pid INT,
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL,
    affiliation VARCHAR(50) NOT NULL,
    startDate DATE NOT NULL,
    endDate DATE,
    PRIMARY KEY (pid)
    

);

CREATE TABLE Student(
	pid INT PRIMARY KEY,
    program VARCHAR(50) NOT NULL,
    FOREIGN KEY (pid) REFERENCES Person(pid)


);

CREATE TABLE Employee(
	pid INT PRIMARY KEY,
    phone INT NOT NULL,
    office VARCHAR(50) NOT NULL,
    position VARCHAR(50) NOT NULL,
    supervisorPid INT,
    FOREIGN KEY (pid) REFERENCES Person(pid),
    FOREIGN KEY (supervisorPid) REFERENCES Employee(pid)
    


);

CREATE TABLE Academic(
	pid INT PRIMARY KEY,
    FOREIGN KEY (pid) REFERENCES Person(pid)

);

CREATE TABLE Administrative(
	pid INT PRIMARY KEY,
    FOREIGN KEY (pid) REFERENCES Employee(pid)

);
						
CREATE TABLE Technical(
	pid INT PRIMARY KEY,
    FOREIGN KEY (pid) REFERENCES Employee(pid)

);

CREATE TABLE Faculty(
	pid INT PRIMARY KEY,
    FOREIGN KEY (pid) REFERENCES Academic(pid)

);

CREATE TABLE Advises (
	academicPid INT NOT NULL ,
	studentPid INT NOT NULL ,
	PRIMARY KEY ( academicPid , studentPid ) ,
	FOREIGN KEY ( academicPid )
	REFERENCES Academic ( pid ) ,
	FOREIGN KEY ( studentPid )
	REFERENCES Student ( pid )

);

CREATE TABLE Laboratory (
	labId INT PRIMARY KEY ,
	name VARCHAR (150) NOT NULL ,
	building VARCHAR (100) NOT NULL ,
	roomNumber VARCHAR (50) NOT NULL ,
	discipline VARCHAR (150) NOT NULL ,
	-- Supervises : exactly one Faculty supervisor
	supervisorPid INT NOT NULL ,
	FOREIGN KEY ( supervisorPid ) REFERENCES Faculty ( pid )
    
) ;

CREATE TABLE Attached (
	pid INT NOT NULL ,
	labId INT NOT NULL ,
	PRIMARY KEY ( pid , labId ) ,
	FOREIGN KEY ( pid )
	REFERENCES Person ( pid ) ,
	FOREIGN KEY ( labId )
	REFERENCES Laboratory ( labId )
) ;

CREATE TABLE ResearchProject (
	code VARCHAR (50) PRIMARY KEY ,
	title VARCHAR (200) NOT NULL ,
	startDate DATE NOT NULL ,
	endDate DATE NOT NULL ,
	status VARCHAR (20) NOT NULL
) ;

CREATE TABLE Participates (
	pid INT NOT NULL ,
	projectCode VARCHAR (50) NOT NULL ,
	role VARCHAR (30) NOT NULL ,
	PRIMARY KEY ( pid , projectCode ) ,
	FOREIGN KEY ( pid )
	REFERENCES Person ( pid ),

	FOREIGN KEY ( projectCode )
	REFERENCES ResearchProject ( code )
) ;

CREATE TABLE Budget (
	budgetLine VARCHAR (50) PRIMARY KEY ,
	amountGranted DECIMAL (12 ,2) NOT NULL ,
	amountDisbursed DECIMAL (12 ,2) NOT NULL ,
	startDate DATE NOT NULL ,
	endDate DATE NOT NULL ,
	-- Manages : exactly one Academic manager
	managerPid INT NOT NULL ,
	FOREIGN KEY ( managerPid )
	REFERENCES Academic ( pid )
) ;


CREATE TABLE FundsPrj (
	budgetLine VARCHAR (50) NOT NULL ,
	projectCode VARCHAR (50) NOT NULL ,
	PRIMARY KEY ( budgetLine , projectCode ) ,
	FOREIGN KEY ( budgetLine )
	REFERENCES Budget ( budgetLine ) ,
	FOREIGN KEY ( projectCode )
	REFERENCES ResearchProject ( code )
) ;

CREATE TABLE FundsLab (
	budgetLine VARCHAR (50) NOT NULL ,
	labId INT NOT NULL ,
	PRIMARY KEY ( budgetLine , labId ) ,
	FOREIGN KEY ( budgetLine )
	REFERENCES Budget ( budgetLine ) ,
	FOREIGN KEY ( labId )
	REFERENCES Laboratory ( labId )
) ;

CREATE TABLE EquipmentModel (
	modelId INT PRIMARY KEY ,
	commercialName VARCHAR (150) NOT NULL ,
	manufacturer VARCHAR (150) NOT NULL ,
	category VARCHAR (100) NOT NULL ,
	requiredEnvironment VARCHAR (200) NOT NULL ,
	trainingMandatory BOOLEAN NOT NULL
) ;


CREATE TABLE EquipmentUnit (
	serialNo VARCHAR (100) PRIMARY KEY ,
	acquisitionDate DATE NOT NULL ,
	purchaseCost DECIMAL (12 ,2) NOT NULL ,
	status VARCHAR (30) NOT NULL ,
	portable BOOLEAN NOT NULL ,
	-- InstanceOf : exactly one EquipmentModel
	modelId INT NOT NULL ,
	-- LocatedIn : exactly one Laboratory

	labId INT NOT NULL ,
	FOREIGN KEY ( modelId )
	REFERENCES EquipmentModel ( modelId ) ,
	FOREIGN KEY ( labId )
	REFERENCES Laboratory ( labId )
) ;

CREATE TABLE Certification (
	code VARCHAR (50) PRIMARY KEY ,
	title VARCHAR (150) NOT NULL ,
	issuingAuthority VARCHAR (150) NOT NULL ,
	validityPeriod INT NOT NULL ,
	safetyLevel VARCHAR (100) NOT NULL
) ;

CREATE TABLE Requires (
	modelId INT NOT NULL ,
	certCode VARCHAR (50) NOT NULL ,
	PRIMARY KEY ( modelId , certCode ) ,
	FOREIGN KEY ( modelId )
	REFERENCES EquipmentModel ( modelId ) ,
	FOREIGN KEY ( certCode )
	REFERENCES Certification ( code )
) ;

CREATE TABLE Holds (
	pid INT NOT NULL ,
	certCode VARCHAR (50) NOT NULL ,
	issueDate DATE NOT NULL ,
	expirationDate DATE NOT NULL ,
	grade VARCHAR (50) ,
	PRIMARY KEY ( pid , certCode ) ,
	FOREIGN KEY ( pid )
	REFERENCES Person ( pid ) ,
	FOREIGN KEY ( certCode )
	REFERENCES Certification ( code )

) ;

CREATE TABLE Reservation (
	resId INT PRIMARY KEY ,
	submissionTS TIMESTAMP NOT NULL ,
	plannedStart TIMESTAMP NOT NULL ,
	plannedEnd TIMESTAMP NOT NULL ,
	purpose VARCHAR (255) NOT NULL ,
	status VARCHAR (20) NOT NULL DEFAULT 'pending',
	-- MadeBy : exactly one Person
	madeByPid INT NOT NULL ,
	-- For : exactly one ResearchProject
	projectCode VARCHAR (50) NOT NULL ,
	-- Approves : at most one approver
	approverPid INT ,
	FOREIGN KEY ( madeByPid )
	REFERENCES Person ( pid ) ,
	FOREIGN KEY ( projectCode )
	REFERENCES ResearchProject ( code ) ,
	FOREIGN KEY ( approverPid )
	REFERENCES Person ( pid ) ON DELETE SET NULL
) ;

CREATE TABLE Reserves (
	resId INT NOT NULL ,
	serialNo VARCHAR (100) NOT NULL ,
	PRIMARY KEY ( resId , serialNo ) ,
	FOREIGN KEY ( resId )
	REFERENCES Reservation ( resId ) ON DELETE CASCADE,
	FOREIGN KEY ( serialNo )
	REFERENCES EquipmentUnit ( serialNo )
) ;

CREATE TABLE Maintenance (
	serialNo VARCHAR (100) NOT NULL ,
	startTS TIMESTAMP NOT NULL ,
	endTS TIMESTAMP NOT NULL ,
	type VARCHAR (20) NOT NULL ,
	description VARCHAR (255) NOT NULL ,
	cost DECIMAL (12 ,2) NOT NULL ,
    outcome VARCHAR (30) NOT NULL ,
	-- DoneBy : exactly one Technical staff member
	technicalPid INT NOT NULL ,
	PRIMARY KEY ( serialNo , startTS ) ,
	FOREIGN KEY ( serialNo )
	REFERENCES EquipmentUnit ( serialNo ) ,
	FOREIGN KEY ( technicalPid )
	REFERENCES Technical ( pid )
	ON DELETE CASCADE
) ;

CREATE TABLE CalibrationRecord (
	serialNo VARCHAR (100) NOT NULL ,
	calibDate DATE NOT NULL ,
	calibrationType VARCHAR (100) NOT NULL ,
	result VARCHAR (20) NOT NULL ,
	nextDueDate DATE NOT NULL ,
	remarks VARCHAR (255) NOT NULL ,
	PRIMARY KEY ( serialNo , calibDate ) ,
	FOREIGN KEY ( serialNo )
	REFERENCES EquipmentUnit ( serialNo )
	ON DELETE CASCADE
) ;


CREATE TABLE Consumable (
	consId INT PRIMARY KEY ,
	name VARCHAR (150) NOT NULL ,
	unitOfMeasure VARCHAR (50) NOT NULL ,
	hazardLevel VARCHAR (100) NOT NULL ,
	reorderThreshold DECIMAL (12 ,2) NOT NULL
) ;

CREATE TABLE Supplier (
	suppId INT PRIMARY KEY ,
	name VARCHAR (150) NOT NULL ,
	contactEmail VARCHAR (150) NOT NULL ,
	phone VARCHAR (30) NOT NULL
) ;

CREATE TABLE Supplies (
	suppId INT NOT NULL ,
	consId INT NOT NULL ,
	labId INT NOT NULL ,
	unitPrice DECIMAL (12 ,2) NOT NULL ,
	PRIMARY KEY ( suppId , consId , labId ) ,
	FOREIGN KEY ( suppId )
	REFERENCES Supplier ( suppId ) ,
	FOREIGN KEY ( consId )
	REFERENCES Consumable ( consId ) ,
	FOREIGN KEY ( labId )
	REFERENCES Laboratory ( labId )
) ;

CREATE TABLE Stocks (
	labId INT NOT NULL ,
	consId INT NOT NULL ,
	quantityOnHand DECIMAL (12 ,2) NOT NULL ,
	lastRestockDate DATE NOT NULL ,
	storageCondition VARCHAR (150) ,
	-- Monitors : exactly one Technical member
	-- for each stock occurrence
	technicalPid INT NOT NULL ,
	monitoringSince DATE NOT NULL ,
	PRIMARY KEY ( labId , consId ) ,
	FOREIGN KEY ( labId )
	REFERENCES Laboratory ( labId ) ,
	FOREIGN KEY ( consId )
	REFERENCES Consumable ( consId ) ,
	FOREIGN KEY ( technicalPid )
	REFERENCES Technical ( pid )
) ;

CREATE TABLE Consumes (
resId INT NOT NULL ,
labId INT NOT NULL ,
consId INT NOT NULL ,
quantityUsed DECIMAL (12 ,2) NOT NULL ,
PRIMARY KEY ( resId , labId , consId ) ,
FOREIGN KEY ( resId )
REFERENCES Reservation ( resId ) ,
FOREIGN KEY ( labId , consId )
REFERENCES Stocks ( labId , consId )
) ;
























