USE DBPROJECT;

-- Canonical Lab 7 trigger definitions (all six tasks).
-- Safe to rerun: existing triggers are dropped before replacement.

DELIMITER //

DROP TRIGGER IF EXISTS trg_participates_bi//
CREATE TRIGGER trg_participates_bi
BEFORE INSERT ON Participates
FOR EACH ROW
BEGIN
  IF EXISTS (SELECT * FROM Administrative A WHERE A.pid = NEW.pid) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Administrative staff cannot participate';
  END IF;
  IF NEW.role IN ('PI', 'Co-PI')
     AND NOT EXISTS (SELECT * FROM Academic A WHERE A.pid = NEW.pid) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'PI and Co-PI must be Academic';
  END IF;
  IF NEW.role IN ('PI', 'Co-PI')
     AND EXISTS (SELECT * FROM Participates P
                 WHERE P.projectCode = NEW.projectCode AND P.role = NEW.role) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Project already has this PI / Co-PI';
  END IF;
END//

DROP TRIGGER IF EXISTS trg_participates_bu//
CREATE TRIGGER trg_participates_bu
BEFORE UPDATE ON Participates
FOR EACH ROW
BEGIN
  IF EXISTS (SELECT * FROM Administrative A WHERE A.pid = NEW.pid) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Administrative staff cannot participate';
  END IF;
  IF NEW.role IN ('PI', 'Co-PI')
     AND NOT EXISTS (SELECT * FROM Academic A WHERE A.pid = NEW.pid) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'PI and Co-PI must be Academic';
  END IF;
  IF NEW.role IN ('PI', 'Co-PI')
     AND EXISTS (SELECT * FROM Participates P
                 WHERE P.projectCode = NEW.projectCode AND P.role = NEW.role
                   AND NOT (P.pid = OLD.pid AND P.projectCode = OLD.projectCode)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Project already has this PI / Co-PI';
  END IF;
END//

DELIMITER ;

-- Part 4, task 2: prevent double booking.
DELIMITER //
DROP TRIGGER IF EXISTS trg_reserves_double_booking_bi//
CREATE TRIGGER trg_reserves_double_booking_bi
BEFORE INSERT ON Reserves
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT *
    FROM Reservation NewR
    JOIN Reservation OtherR ON OtherR.status = 'Approved'
    JOIN Reserves OtherRS ON OtherRS.resId = OtherR.resId
    WHERE NewR.resId = NEW.resId
      AND NewR.status = 'Approved'
      AND OtherRS.serialNo = NEW.serialNo
      AND OtherR.resId <> NewR.resId
      AND NewR.plannedStart < OtherR.plannedEnd
      AND NewR.plannedEnd > OtherR.plannedStart
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Equipment unit is already booked during this interval';
  END IF;
END//

DROP TRIGGER IF EXISTS trg_reservation_double_booking_bu//
CREATE TRIGGER trg_reservation_double_booking_bu
BEFORE UPDATE ON Reservation
FOR EACH ROW
BEGIN
  IF NEW.status = 'Approved' AND EXISTS (
    SELECT *
    FROM Reserves NewRS
    JOIN Reservation OtherR ON OtherR.status = 'Approved'
    JOIN Reserves OtherRS ON OtherRS.resId = OtherR.resId
    WHERE NewRS.resId = NEW.resId
      AND OtherRS.serialNo = NewRS.serialNo
      AND OtherR.resId <> NEW.resId
      AND NEW.plannedStart < OtherR.plannedEnd
      AND NEW.plannedEnd > OtherR.plannedStart
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Reservation conflicts with another approved equipment booking';
  END IF;
END//
DELIMITER ;

-- Part 4, task 3: enforce certification eligibility.
DELIMITER //
DROP TRIGGER IF EXISTS trg_reserves_certification_bi//
CREATE TRIGGER trg_reserves_certification_bi
BEFORE INSERT ON Reserves
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT *
    FROM Reservation R
    JOIN EquipmentUnit U ON U.serialNo = NEW.serialNo
    JOIN Requires Q ON Q.modelId = U.modelId
    WHERE R.resId = NEW.resId
      AND NOT EXISTS (
        SELECT *
        FROM Holds H
        WHERE H.pid = R.madeByPid
          AND H.certCode = Q.certCode
          AND H.expirationDate >= DATE(R.plannedStart)
      )
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Reservation maker lacks a required valid certification';
  END IF;
END//
DELIMITER ;

-- Part 4, task 4: validate consumption and decrement stock.
DELIMITER //
DROP TRIGGER IF EXISTS OnConsumpInsert//
CREATE TRIGGER OnConsumpInsert
BEFORE INSERT ON Consumes
FOR EACH ROW
BEGIN
  IF NEW.quantityUsed <= 0 OR NEW.quantityUsed IS NULL
     OR (NEW.labId, NEW.consId) NOT IN (SELECT S.labId, S.consId FROM Stocks S)
     OR NEW.quantityUsed > ALL (
       SELECT S.quantityOnHand
       FROM Stocks S
       WHERE S.labId = NEW.labId AND S.consId = NEW.consId
     ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid consumption info !';
  END IF;
END//

DROP TRIGGER IF EXISTS StockUpdate//
CREATE TRIGGER StockUpdate
AFTER INSERT ON Consumes
FOR EACH ROW
BEGIN
  UPDATE Stocks
  SET quantityOnHand = quantityOnHand - NEW.quantityUsed
  WHERE labId = NEW.labId AND consId = NEW.consId;
END//

-- Part 4, task 5: synchronize maintenance and equipment status.
DROP TRIGGER IF EXISTS AfterMaint//
CREATE TRIGGER AfterMaint
AFTER INSERT ON Maintenance
FOR EACH ROW
BEGIN
  UPDATE EquipmentUnit
  SET status = 'UnderMaintenance'
  WHERE serialNo = NEW.serialNo;
END//

DROP TRIGGER IF EXISTS OnMaintResolved//
CREATE TRIGGER OnMaintResolved
AFTER UPDATE ON Maintenance
FOR EACH ROW
BEGIN
  IF OLD.outcome <> 'Resolved' AND NEW.outcome = 'Resolved' THEN
    UPDATE EquipmentUnit
    SET status = 'InService'
    WHERE serialNo = NEW.serialNo;
  END IF;
END//

-- Part 4, task 6: enforce people hierarchy rules.
DROP TRIGGER IF EXISTS OnStudentInsert//
CREATE TRIGGER OnStudentInsert
BEFORE INSERT ON Student
FOR EACH ROW
BEGIN
  IF NEW.pid IN (SELECT E.pid FROM Employee E) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee cannot be a student!';
  END IF;
END//

DROP TRIGGER IF EXISTS OnEmployeeInsert//
CREATE TRIGGER OnEmployeeInsert
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
  IF NEW.pid IN (SELECT S.pid FROM Student S) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student cannot be an employee!';
  END IF;
END//

DROP TRIGGER IF EXISTS OnFacultyInsert//
CREATE TRIGGER OnFacultyInsert
BEFORE INSERT ON Faculty
FOR EACH ROW
BEGIN
  IF 'dean' NOT IN (
    SELECT S.position
    FROM Employee E JOIN Employee S ON E.supervisorPid = S.pid
    WHERE E.pid = NEW.pid
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Invalid faculty id, is not supervised by dean!';
  END IF;
END//

DROP TRIGGER IF EXISTS OnAdminInsert//
CREATE TRIGGER OnAdminInsert
BEFORE INSERT ON Administrative
FOR EACH ROW
BEGIN
  IF 'dean' NOT IN (
    SELECT S.position
    FROM Employee E JOIN Employee S ON E.supervisorPid = S.pid
    WHERE E.pid = NEW.pid
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Invalid admin id, is not supervised by dean!';
  END IF;
END//

DROP TRIGGER IF EXISTS OnEmployeeUpdate//
CREATE TRIGGER OnEmployeeUpdate
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
  IF NEW.pid IN (SELECT A.pid FROM Administrative A)
     OR NEW.pid IN (SELECT F.pid FROM Faculty F) THEN
    IF 'dean' NOT IN (
      SELECT S.position FROM Employee S WHERE S.pid = NEW.supervisorPid
    ) THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot have supervisor other than dean !';
    END IF;
  END IF;
END//

DROP TRIGGER IF EXISTS OnDeanInsert//
CREATE TRIGGER OnDeanInsert
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
  IF NEW.position = 'dean' AND NEW.supervisorPid IS NOT NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dean cannot have a supervisor !';
  END IF;
END//

DROP TRIGGER IF EXISTS OnDeanUpdate//
CREATE TRIGGER OnDeanUpdate
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
  IF NEW.position = 'dean' AND NEW.supervisorPid IS NOT NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dean cannot have a supervisor !';
  END IF;
END//
DELIMITER ;

-- DEMONSTRATIONS FOR ALL SIX TASKS
-- Run statements individually after the definitions above. Rejected examples
-- intentionally raise errors, so do not execute this section as one batch.
-- These examples assume the official lab7_base.sql data plus Parts 2 and 3.

-- TASK 1: project participation.
-- Valid insert and update.
INSERT INTO Participates (pid, projectCode, role)
VALUES (4, 'P1', 'Collaborator');
UPDATE Participates SET role = 'PI'
WHERE pid = 2 AND projectCode = 'P1';
-- Rejected: administrative participant.
INSERT INTO Participates (pid, projectCode, role)
VALUES (5, 'P1', 'Collaborator');
-- Rejected: PI/Co-PI must be Academic.
INSERT INTO Participates (pid, projectCode, role)
VALUES (10, 'P2', 'Co-PI');
-- Rejected: duplicate PI.
INSERT INTO Participates (pid, projectCode, role)
VALUES (4, 'P2', 'PI');
-- Rejected: duplicate Co-PI.
INSERT INTO Participates (pid, projectCode, role)
VALUES (4, 'P1', 'Co-PI');
-- Rejected: duplicate PI through UPDATE.
UPDATE Participates SET role = 'PI'
WHERE pid = 4 AND projectCode = 'P1';

-- TASK 2: double booking.
-- Valid INSERT; delete the test row after capturing the successful insert.
INSERT INTO Reserves (resId, serialNo) VALUES (2, 'U8');
DELETE FROM Reserves WHERE resId = 2 AND serialNo = 'U8';
-- Valid UPDATE; this also makes the following insert conflict test overlap.
UPDATE Reservation
SET plannedStart = (SELECT d.plannedStart FROM
                    (SELECT plannedStart FROM Reservation WHERE resId = 4) d),
    plannedEnd = (SELECT d.plannedEnd FROM
                  (SELECT plannedEnd FROM Reservation WHERE resId = 4) d)
WHERE resId = 1;
-- Rejected INSERT: reservation 1 now overlaps reservation 4 on U3.
INSERT INTO Reserves (resId, serialNo) VALUES (1, 'U3');
-- Rejected UPDATE: reservation 2's U3 booking would overlap reservation 4.
UPDATE Reservation
SET plannedStart = (SELECT d.plannedStart FROM
                    (SELECT plannedStart FROM Reservation WHERE resId = 4) d),
    plannedEnd = (SELECT d.plannedEnd FROM
                  (SELECT plannedEnd FROM Reservation WHERE resId = 4) d)
WHERE resId = 2;

-- TASK 3: certification eligibility. Reservation 5 is Rejected, avoiding the
-- separate double-booking rule while still checking certification eligibility.
-- U1's model requires no certifications: valid.
INSERT INTO Reserves (resId, serialNo) VALUES (5, 'U1');
DELETE FROM Reserves WHERE resId = 5 AND serialNo = 'U1';
-- U3's model requires C1 and C2; reservation maker 8 lacks C2: rejected.
INSERT INTO Reserves (resId, serialNo) VALUES (5, 'U3');

-- TASK 4: consumable stock consistency.
SELECT quantityOnHand FROM Stocks WHERE labId = 1 AND consId = 1;
INSERT INTO Consumes (resId, labId, consId, quantityUsed)
VALUES (7, 1, 1, 1.00);
SELECT quantityOnHand FROM Stocks WHERE labId = 1 AND consId = 1;
-- Rejected: non-positive quantity.
INSERT INTO Consumes (resId, labId, consId, quantityUsed)
VALUES (7, 1, 2, 0.00);
-- Rejected: no stock occurrence exists for lab 3 and consumable 2.
INSERT INTO Consumes (resId, labId, consId, quantityUsed)
VALUES (7, 3, 2, 1.00);
-- Rejected: consumption exceeds available stock.
INSERT INTO Consumes (resId, labId, consId, quantityUsed)
VALUES (7, 1, 2, 9999.00);

-- TASK 5: maintenance/equipment status synchronization.
INSERT INTO Maintenance
VALUES ('U7', '2026-11-23 09:00:00', '2026-11-23 12:00:00',
        'Corrective', 'Trigger evidence test', 0.00, 'FollowUpRequired', 6);
SELECT serialNo, status FROM EquipmentUnit WHERE serialNo = 'U7';
UPDATE Maintenance SET outcome = 'Resolved'
WHERE serialNo = 'U7' AND startTS = '2026-11-23 09:00:00';
SELECT serialNo, status FROM EquipmentUnit WHERE serialNo = 'U7';

-- TASK 6(a): Student/Employee disjointness.
-- Rejected: pid 1 is already an Employee.
INSERT INTO Student (pid, program) VALUES (1, 'MSc');
-- Rejected: pid 8 is already a Student.
INSERT INTO Employee (pid, phone, office, position, supervisorPid)
VALUES (8, '0608', 'B-220', 'postdoc', 2);

-- TASK 6(b): Faculty/Administrative must report to the dean.
-- Valid Faculty setup. Execute each prerequisite before the Faculty insert.
INSERT INTO Person VALUES
(20, 'Test', 'Faculty', 'test.faculty20@example.com', 'UM6P', '2026-09-01', NULL);
INSERT INTO Employee VALUES (20, '0620', 'B-240', 'faculty', 1);
INSERT INTO Academic (pid) VALUES (20);
INSERT INTO Faculty (pid) VALUES (20);
-- Rejected: a faculty member cannot report to a non-dean supervisor.
UPDATE Employee SET supervisorPid = 2 WHERE pid = 20;
-- Rejected Faculty INSERT with an existing employee supervised by a non-dean.
INSERT INTO Person VALUES
(22, 'Test', 'FacultyBad', 'test.faculty22@example.com', 'UM6P', '2026-09-01', NULL);
INSERT INTO Employee VALUES (22, '0622', 'B-242', 'faculty', 2);
INSERT INTO Academic (pid) VALUES (22);
INSERT INTO Faculty (pid) VALUES (22);
-- Valid Administrative setup.
INSERT INTO Person VALUES
(21, 'Test', 'Admin', 'test.admin21@example.com', 'UM6P', '2026-09-01', NULL);
INSERT INTO Employee VALUES (21, '0621', 'A-120', 'secretary', 1);
INSERT INTO Administrative (pid) VALUES (21);
-- Rejected Administrative INSERT with a non-dean supervisor.
INSERT INTO Person VALUES
(23, 'Test', 'AdminBad', 'test.admin23@example.com', 'UM6P', '2026-09-01', NULL);
INSERT INTO Employee VALUES (23, '0623', 'A-122', 'secretary', 2);
INSERT INTO Administrative (pid) VALUES (23);

-- TASK 6(c): the dean has no supervisor.
-- Rejected INSERT.
INSERT INTO Person VALUES
(24, 'Test', 'DeanBad', 'test.dean24@example.com', 'UM6P', '2026-09-01', NULL);
INSERT INTO Employee VALUES (24, '0624', 'A-124', 'dean', 2);
-- Rejected UPDATE of the existing dean.
UPDATE Employee SET supervisorPid = 2 WHERE pid = 1;
