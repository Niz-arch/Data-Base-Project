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

