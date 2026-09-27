CREATE DATABASE project;

USE project;

CREATE TABLE Persons (
	pid INT PRIMARY KEY,
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL,
    affiliation VARCHAR(50) NOT NULL,
    startDate VARCHAR(50) NOT NULL,
    endDate VARCHAR(50)
);

CREATE TABLE Student (
	studentId INT PRIMARY KEY,
	program VARCHAR(50) NOT NULL,
    FOREIGN KEY (studentId) REFERENCES Persons(id)
);

CREATE TABLE Employee (
	employeeId INT PRIMARY KEY,
    phone VARCHAR(50) NOT NULL,
    office VARCHAR(50) NOT NULL,
    supervisorId INT,
	FOREIGN KEY (supervisorId) REFERENCES Employee(pid),
    FOREIGN KEY (employeeId) REFERENCES Persons(pid)
);

CREATE TABLE Academic (
	academicId INT PRIMARY KEY,
    FOREIGN KEY (academicId) REFERENCES Employee(employeeId)
);

CREATE TABLE Faculty (
	facultyId INT PRIMARY KEY,
    FOREIGN KEY (facultyId) REFERENCES Academic(academicId)
);

CREATE TABLE Administrative (
	adminId INT PRIMARY KEY,
    FOREIGN KEY (adminId) REFERENCES Employee(employeeId)
);

CREATE TABLE Technical (
	technicalId INT PRIMARY KEY,
    FOREIGN KEY (technicalId) REFERENCES Employee(employeeId)
);

CREATE TABLE StudentAdvisors (
	studentId INT NOT NULL,
    FOREIGN KEY (studentId) REFERENCES Student(studentId),
    advisorId INT NOT NULL,
    FOREIGN KEY (advisorId) REFERENCES Academic(academicId)
);

CREATE TABLE Laboratory (
    labId INT PRIMARY KEY,
    name_ VARCHAR(50) NOT NULL,
    building VARCHAR(50) NOT NULL,
    roomNumber VARCHAR(50) NOT NULL,
    discipline VARCHAR(50) NOT NULL,
    supervisorId INT NOT NULL,
    FOREIGN KEY (supervisorId) REFERENCES Faculty(facultyId)
)

CREATE TABLE LabAttatchedTo (
    labId INT PRIMARY KEY,
    FOREIGN KEY (labId) REFERENCES Laboratory(labId),
    personId INT PRIMARY KEY,
    FOREIGN KEY (personId) REFERENCES Persons(pid),
)

-- Jbari part

CREATE TABLE ResearchProject (
	projectCode INT PRIMARY KEY,
    title VARCHAR(50) NOT NULL,
    status_ VARCHAR(50) NOT NULL,
    startDate VARCHAR(50) NOT NULL,
    endDate VARCHAR(50)
);

CREATE TABLE Budget (
	budgetaryLine INT PRIMARY KEY,
    grantedAmount INT NOT NULL,
    disbursedAmount INT(50) NOT NULL,
    startDate VARCHAR(50) NOT NULL,
    endDate VARCHAR(50)
);

CREATE TABLE EquipmentModel (
	modelIndentifier INT PRIMARY KEY,
    commercialName VARCHAR(50) NOT NULL,
    manufacturer VARCHAR(50) NOT NULL,
    category VARCHAR(50) NOT NULL,
    requiredEnvironment VARCHAR(50),
    specialTraining VARCHAR(50) NOT NULL
);

CREATE TABLE EquipmentUnit (
	serialNumber INT PRIMARY KEY,
    acquisitionDate VARCHAR(50) NOT NULL,
    purchaseCost INT NOT NULL,
    operationalStatus VARCHAR(50) NOT NULL,
    laboratoryLocation VARCHAR(50) NOT NULL
);

CREATE TABLE funds_lab (
	labID INT NOT NULL,
	budgetID INT NOT NULL,
	PRIMARY KEY (labID , budgetID),
    FOREIGN KEY (labID) REFERENCES Laboratory(labId),
    FOREIGN KEY (budgetID) REFERENCES Budget(budgetaryLine)
);
    
CREATE TABLE funds_project (
	projectID INT NOT NULL,
	budgetID INT NOT NULL,
	PRIMARY KEY (projectID , budgetID),
    FOREIGN KEY (projetcID) REFERENCES ResearchProject(projectCode),
    FOREIGN KEY (budgetID) REFERENCES Budget(budgetaryLine)
);

ALTER TABLE Budget ADD academicId INT NOT NULL, ADD FOREIGN KEY (academicId) REFERENCES Academic(academicId);

CREATE TABLE participates (
	personID INT NOT NULL,
	projectID INT NOT NULL,
	PRIMARY KEY (projectID , personID),
    FOREIGN KEY (projetcID) REFERENCES ResearchProject(projectCode),
    FOREIGN KEY (personID) REFERENCES Persons(pid)
);

CREATE TABLE requires (
	certification_code INT NOT NULL,
	modelID INT NOT NULL,
	PRIMARY KEY (modelID , certification_code),
    FOREIGN KEY (certification_code) REFERENCES Certification(code_), -- RIYAD hna khssk tsmii attribute dialk b7ali
    FOREIGN KEY (modelID) REFERENCES EquipmentModel(modelIndentifier)
);

ALTER TABLE EquipmentUnit ADD modelID INT, ADD FOREIGN KEY (modelID) REFERENCES EquipmentModel(modelIndentifier);

ALTER TABLE EquipmentUnit ADD labID INT, ADD FOREIGN KEY (labID) REFERENCES laboratory(labId);

-- Chaimae Part

create table HasCalib 
(
	calibDate DATE  NOT NULL,
    serialNo varchar(50) NOT NULL,
    next_due_date DATE,
    calibration_type varchar(50),
    result ENUM ('Pass', 'Fail', 'Adjusted'),
    remarks varchar(50),
    PRIMARY KEY (calibDate,serialNo),
	FOREIGN KEY (serialNo)
	REFERENCES EquipmentUnit(serialNo)
	ON DELETE CASCADE
);

create table consumable
(
	consId varchar(50),
    cname varchar(50),
    cmeasure_unit varchar(50),
    treshold_reorder int,
    hazard_lev varchar(50),
    PRIMARY KEY (consId)
);

create table supplier
(
	suppId varchar(50),
    sname varchar(50),
    phone_num varchar(50),
    email varchar(50),
    PRIMARY KEY (suppId)
);

create table supplies
(
unitPrice varchar(50),
suppId varchar(50),
consId varchar(50),
labId varchar(50),
PRIMARY KEY (suppId , consId,labId),
FOREIGN KEY (suppId) REFERENCES supplier(suppId),
FOREIGN KEY (consId) REFERENCES consumable(consId),
FOREIGN KEY (labId) REFERENCES Laboratory(labId)
);



create table labo_stock
(
quantityOnHand  varchar(50),
lastRestockDate varchar(50),
storageCondition varchar(50),
technicalId INT ,
labId varchar(50),
consId varchar(50),
PRIMARY KEY (labId , consid),
FOREIGN KEY (labId) REFERENCES Laboratory(labId),
FOREIGN KEY (consId) REFERENCES consumable(consId),
FOREIGN KEY (technicalId) REFERENCES Employee(employeeId)
);

create table stock_conusmed
(
quantityUsed varchar(50),
resId varchar(50),
labId varchar(50),
consId varchar(50),
PRIMARY KEY(labId,consId,resId),
FOREIGN KEY (labId, consId) REFERENCES labo_stock(labId, consId),
FOREIGN KEY (resId) REFERENCES Reservation(resId)
);

-- Riyad Part

CREATE TABLE certifications(
	cert_code INT,
    PRIMARY KEY (cert_code)
);

CREATE TABLE requires(
	cert_code INT,
    modelId int,
    PRIMARY KEY (cert_code, modelID),
    
    FOREIGN KEY (modelId) REFERENCES Equipmentmodel(modelIdentifier),
    FOREIGN KEY (cert_code) REFERENCES certifications(cert_code)

);

CREATE TABLE holds(
	grade INT,
    issueDate DATE,
    expirationDate DATE,
    cert_code INT,
    person_id INT,
    PRIMARY KEY (person_id, cert_code),
    
    FOREIGN KEY (cert_code) REFERENCES certifications(cert_code),
    FOREIGN KEY (person_id) REFERENCES Persons(pid)

);

CREATE TABLE reservations(
	resID INT,
    approverID INT,
    madeBy INT NOT NULL,
    forProj INT NOT NULL,
    PRIMARY KEY (resID),
    
	FOREIGN KEY (approverID) REFERENCES Persons(pid) ON DELETE NO ACTION,
    FOREIGN KEY (madeBy) REFERENCES Persons(pid) ON DELETE NO ACTION,
    FOREIGN KEY (forProj) REFERENCES ResearchProject(projectCode) ON DELETE NO ACTION
);

CREATE TABLE reserves(
	resID INT,
    serialNo INT NOT NULL,
    PRIMARY KEY (resID, serialNo),
    FOREIGN KEY (resID) REFERENCES reservations(resID),
    FOREIGN KEY (serialNo) REFERENCES EquipmentUnit(serialNumber)

);

CREATE TABLE maintenance(
	startTS DATE NOT NULL,
    DoneBy INT NOT NULL,
    serialNo INT NOT NULL,
    PRIMARY KEY (serialNo, startTS),
    
    FOREIGN KEY (DoneBy) REFERENCES Persons(pid) ON DELETE NO ACTION,
    FOREIGN KEY (serialNo) REFERENCES EquipmentUnit(serialNumber) ON DELETE CASCADE
    
);
