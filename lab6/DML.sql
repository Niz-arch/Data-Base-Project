-- part2 

-- population 

-- depends on the project u can remove it or not use it
USE DBPROJECT;

INSERT INTO Person (pid, firstName, lastName, email, affiliation, startDate, endDate)VALUES
    (1, 'Chaimae', 'Iaa', 'chaimae@um6p.ma', 'UM6P', '2025-09-07', NULL),
    (2, 'Imane', 'Gourari', 'imane@gmail.com', 'ENSA', '2026-09-07', NULL),
    (3, 'Zakaria', 'Hittouch', 'zakh@gmail.com', 'UM6P', '2024-10-02', NULL),
    (4, 'Adam', 'aitoudaden', 'adam@ensa.ma', 'ENSA', '2024-09-01', NULL),
    (5, 'Hafsa', 'Sahnoune', 'hafsa@um6p.ma', 'UM6P', '2025-09-01', NULL),
    (6, 'Khadija', 'Kabissa', 'khadija@gmail.com', 'CPGE', '2024-09-15', '2026-06-30');

INSERT INTO Employee (pid, phone, office, position, supervisorPid) VALUES
    (1, 0646345678, 'C-101', 'Professor', NULL),
    (2, 0623456789, 'G-02', 'Technician', 1),
    (3, 0634567890, 'F-11', 'Administrator', 1);

INSERT INTO Academic (pid) VALUES (1);
INSERT INTO Faculty (pid) VALUES (1);
INSERT INTO Technical (pid) VALUES (2);
INSERT INTO Administrative (pid) VALUES (3);

INSERT INTO Student (pid, program) VALUES
    (4, 'Engineering'),
    (5, 'Computer Science');

INSERT INTO Advises (academicPid, studentPid) VALUES (1, 4), (1, 5);


INSERT INTO Laboratory (labId, name, building, roomNumber, discipline, supervisorPid) VALUES
    (1, 'Physics Laboratory', 'Riad5', 'E101', 'Physics', 1),
    (2, 'Computer  Lab', 'College of Computing', 'D101', 'Database', 1),
    (3, 'Chemistry Lab', 'MSN', 'M012', 'Chemistry', 1);

INSERT INTO Attached (pid, labId) VALUES (1,1), (2,1), (3,2), (4,2), (5,3);

INSERT INTO ResearchProject (code, title, startDate, endDate, status) VALUES
    ('PRJ-001', 'Students over-reliance on ai', '2026-01-01', '2027-12-31', 'Active'),
    ('PRJ-002', 'Smart Temperature Sensing', '2026-03-01', '2027-06-30', 'Active'),
    ('PRJ-003', 'Legacy Spectroscopy Study', '2025-01-01', '2026-06-30', 'Cancelled'),
    ('PRJ-004', 'Quantum Sensors Pilot', '2026-09-01', '2028-08-31', 'Active');

INSERT INTO Participates (pid, projectCode, role) VALUES
    (1, 'PRJ-001', 'Principal Investigator'),
    (4, 'PRJ-001', 'Researcher'),
    (2, 'PRJ-002', 'Technician'),
    (5, 'PRJ-002', 'Researcher'),
    (4, 'PRJ-003', 'Researcher'),
    (1, 'PRJ-004', 'Principal Investigator');

INSERT INTO Budget (budgetLine, amountGranted, amountDisbursed, startDate, endDate, managerPid) VALUES
    ('BL-001', 500000.00, 120000.00, '2026-01-01', '2026-12-31', 1),
    ('BL-002', 250000.00, 40000.00, '2026-03-01', '2027-02-28', 1);

INSERT INTO FundsPrj (budgetLine, projectCode) VALUES ('BL-001','PRJ-001'), ('BL-002','PRJ-002'), ('BL-001','PRJ-003');
INSERT INTO FundsLab (budgetLine, labId) VALUES ('BL-001',1), ('BL-002',2), ('BL-002',3);

INSERT INTO EquipmentModel (modelId, commercialName, manufacturer, category, requiredEnvironment, trainingMandatory) VALUES
    (1, 'OptiScope 400', 'Zeiss', 'Optical Microscope', 'Clean room, 20C', TRUE),
    (2, 'ThermoPro T1', 'Fluke', 'Thermometer', 'Room temperature', FALSE),
    (3, 'SpectraMax X', 'Thermo Fisher', 'Spectrometer', 'Dark room', TRUE),
    (4, 'NanoView 9', 'Olympus', 'Optical Microscope', 'Vibration-free table', FALSE);

INSERT INTO EquipmentUnit (serialNo, acquisitionDate, purchaseCost, status, portable, modelId, labId) VALUES
    ('SN-OM-001', '2024-02-10', 45000.00, 'Available', FALSE, 1, 1),
    ('SN-OM-002', '2025-03-20', 47000.00, 'Available', FALSE, 1, 2),
    ('SN-TH-001', '2025-06-01', 1200.00, 'Available', TRUE, 2, 1),
    ('SN-SP-001', '2023-11-15', 80000.00, 'Under Maintenance', FALSE, 3, 3);

INSERT INTO Certification (code, title, issuingAuthority, validityPeriod, safetyLevel) VALUES
    ('CERT-OPT', 'Optical Equipment Safety', 'UM6P Safety Office', 24, 'Medium'),
    ('CERT-LASER', 'Laser Safety', 'National Safety Board', 12, 'High');

INSERT INTO Requires (modelId, certCode) VALUES (1, 'CERT-OPT'), (3, 'CERT-OPT'), (3, 'CERT-LASER');

INSERT INTO Holds (pid, certCode, issueDate, expirationDate, grade) VALUES
    (1, 'CERT-OPT', '2025-01-15', '2027-01-15', 'A'),
    (4, 'CERT-OPT', '2025-10-01', '2027-10-01', 'B'),
    (5, 'CERT-OPT', '2025-11-01', '2027-11-01', NULL),
    (1, 'CERT-LASER', '2026-01-10', '2027-01-10', 'A');

INSERT INTO Reservation (resId, submissionTS, plannedStart, plannedEnd, purpose, status, madeByPid, projectCode, approverPid) VALUES
    (1, '2026-11-01 09:00:00', '2026-11-12 09:00:00', '2026-11-12 12:00:00', 'Thin film imaging', 'Approved', 4, 'PRJ-001', 1),
    (2, '2026-11-05 10:30:00', '2026-11-20 14:00:00', '2026-11-20 16:00:00', 'Temperature calibration test', 'Pending', 5, 'PRJ-002', NULL),
    (3, '2026-10-10 08:00:00', '2026-10-15 09:00:00', '2026-10-15 11:00:00', 'Sample scanning', 'Rejected', 4, 'PRJ-001', NULL),
    (4, '2026-10-20 15:00:00', '2026-10-25 10:00:00', '2026-10-25 12:00:00', 'Backup measurement', 'Cancelled', 5, 'PRJ-002', NULL),
    (5, '2026-09-20 11:00:00', '2026-09-25 09:00:00', '2026-09-25 13:00:00', 'Initial imaging run', 'Completed', 1, 'PRJ-001', 1),
    (6, '2026-11-06 12:00:00', '2026-11-22 09:00:00', '2026-11-22 11:00:00', 'Legacy data re-check', 'Pending', 4, 'PRJ-003', NULL);

INSERT INTO Reserves (resId, serialNo) VALUES
    (1, 'SN-OM-001'), (1, 'SN-TH-001'), (2, 'SN-TH-001'), (3, 'SN-OM-002'),
    (4, 'SN-TH-001'), (5, 'SN-OM-001'), (6, 'SN-OM-002');

INSERT INTO Maintenance (serialNo, startTS, endTS, type, description, cost, outcome, technicalPid) VALUES
    ('SN-SP-001', '2026-10-01 09:00:00', '2026-10-03 17:00:00', 'Corrective', 'Lamp replacement', 1500.00, 'Completed', 2),
    ('SN-OM-001', '2026-06-10 09:00:00', '2026-06-10 12:00:00', 'Preventive', 'Routine cleaning', 200.00, 'Completed', 2);

INSERT INTO CalibrationRecord (serialNo, calibDate, calibrationType, result, nextDueDate, remarks) VALUES
    ('SN-TH-001', '2026-05-01', 'Temperature', 'Pass', '2027-05-01', 'Within tolerance'),
    ('SN-OM-001', '2026-02-15', 'Optical alignment', 'Pass', '2027-02-15', 'No issues'),
    ('SN-OM-002', '2026-03-01', 'Optical alignment', 'Fail', '2026-09-01', 'Needs adjustment');

INSERT INTO Consumable (consId, name, unitOfMeasure, hazardLevel, reorderThreshold) VALUES
    (1, 'Ethanol 99%', 'L', 'Flammable', 5.00),
    (2, 'Immersion Oil', 'mL', 'Low', 100.00),
    (3, 'Liquid Nitrogen', 'L', 'Cryogenic', 20.00);

INSERT INTO Supplier (suppId, name, contactEmail, phone) VALUES
  (1, 'Merck', 'merck@gmail.com', '0522334451'),
  (2, 'Air Liquide Maroc', 'airliquidemaroc@gmail.com', '0522889902');

INSERT INTO Supplies (suppId, consId, labId, unitPrice) VALUES
    (1, 1, 1, 40.00), (1, 2, 1, 15.50), (2, 3, 3, 8.00), (2, 3, 1, 9.00);

INSERT INTO Stocks (labId, consId, quantityOnHand, lastRestockDate, storageCondition, technicalPid, monitoringSince) VALUES
    (1, 2, 150.00, '2026-10-01', 'Room temperature', 2, '2025-01-10'),
    (1, 1, 12.00, '2026-10-05', 'Flammable cabinet', 2, '2025-03-01'),
    (2, 1, 3.00, '2026-09-15', 'Flammable cabinet', 2, '2025-06-01'),
    (3, 3, 50.00, '2026-10-20', 'Cryogenic tank', 2, '2025-09-01');

INSERT INTO Consumes (resId, labId, consId, quantityUsed) VALUES
    (1, 1, 2, 10.00), (5, 1, 1, 2.50);

-- Operations
INSERT INTO Person (pid, firstName, lastName, email, affiliation, startDate, endDate)
VALUES (7, 'Oussama', 'alabtros', 'oussama@um6p.ma', 'UM6P', '2026-11-01', NULL);
INSERT INTO Student (pid, program) VALUES (7, 'Data Science');

INSERT INTO EquipmentUnit (serialNo, acquisitionDate, purchaseCost, status, portable, modelId, labId)
VALUES ('SN-OM-003', '2026-10-30', 46000.00, 'Available', FALSE, 1, 2);

INSERT INTO Reservation (resId, submissionTS, plannedStart, plannedEnd, purpose, status, madeByPid, projectCode, approverPid)
VALUES (7, '2026-11-10 10:30', '2026-11-18 09:00', '2026-11-18 11:00:00', 'Optical measurement', 'Pending', 5, 'PRJ-002', NULL);
INSERT INTO Reserves (resId, serialNo) VALUES (7, 'SN-OM-003');

UPDATE Reservation
SET status = 'Approved', approverPid = 1
WHERE resId = 2 AND status = 'Pending';

UPDATE Stocks SET quantityOnHand = 140 WHERE labId = 1 AND consId = 2;

INSERT INTO Consumes (resId, labId, consId, quantityUsed) VALUES (2, 1, 1, 1.5);

UPDATE Reservation
SET status = 'Cancelled'
WHERE status = 'Pending'
AND projectCode IN (SELECT code FROM ResearchProject WHERE status = 'Cancelled');

INSERT INTO Supplier (suppId, name, contactEmail, phone) VALUES (99, 'Maghreb oxygene', 'maghreboxygene@gmail.com', '0567341298');
DELETE FROM Supplier WHERE suppId = 99;


-- Part3
-- A
SELECT pid, firstName, lastName, email
FROM Person
ORDER BY lastName, firstName;

SELECT DISTINCT discipline
FROM Laboratory;

SELECT *
FROM Person
WHERE email LIKE '%@um6p.ma';

SELECT *
FROM Person
WHERE endDate IS NULL;

SELECT *
FROM Reservation
WHERE plannedStart >= '2026-11-01 00:00:00' AND plannedStart <= '2026-11-30 23:59:59';

-- B

SELECT P.firstName, P.lastName, RP.title, PA.role
FROM Person P
JOIN Participates PA ON P.pid = PA.pid
JOIN ResearchProject RP ON PA.projectCode = RP.code;

SELECT B.*, P.firstName, P.lastName
FROM Budget B
JOIN Academic A ON B.managerPid = A.pid
JOIN Person P ON A.pid = P.pid;

SELECT R.*, P.firstName, P.lastName, RP.title AS projectTitle
FROM Reservation R
JOIN Person P ON R.madeByPid = P.pid
JOIN ResearchProject RP ON R.projectCode = RP.code;

SELECT R.resId, EU.serialNo, EM.commercialName, L.name AS laboratoryName
FROM Reserves R
JOIN EquipmentUnit EU ON R.serialNo = EU.serialNo
JOIN EquipmentModel EM ON EU.modelId = EM.modelId
JOIN Laboratory L ON EU.labId = L.labId;

SELECT R.*, P.firstName, P.lastName
FROM Reservation R
LEFT JOIN Person P ON R.approverPid = P.pid
WHERE R.status = 'Approved';

SELECT L.name AS laboratoryName, C.name AS consumableName,
       S.quantityOnHand, P.firstName, P.lastName
FROM Stocks S
JOIN Laboratory L ON S.labId = L.labId
JOIN Consumable C ON S.consId = C.consId
JOIN Technical T ON S.technicalPid = T.pid
JOIN Person P ON T.pid = P.pid;

-- C

SELECT L.labId, L.name AS laboratoryName, COUNT(EU.serialNo) AS unitCount
FROM Laboratory L
LEFT JOIN EquipmentUnit EU ON L.labId = EU.labId
GROUP BY L.labId, L.name;

SELECT C.consId, C.name AS consumableName, SUM(CO.quantityUsed) AS totalQuantityUsed
FROM Consumable C
LEFT JOIN Consumes CO ON C.consId = CO.consId
GROUP BY C.consId, C.name;

-- D

SELECT L.name AS laboratoryName, COUNT(EU.serialNo) AS unitCount
FROM Laboratory L
JOIN EquipmentUnit EU ON L.labId = EU.labId
GROUP BY L.labId, L.name
HAVING COUNT(EU.serialNo) > 3;

SELECT RP.title AS projectTitle, SUM(B.amountGranted) AS totalAmountGranted
FROM ResearchProject RP
LEFT JOIN FundsPrj FP ON RP.code = FP.projectCode
LEFT JOIN Budget B ON FP.budgetLine = B.budgetLine
GROUP BY RP.code, RP.title;

SELECT L.name AS laboratoryName, EM.category,
       COUNT(EU.serialNo) AS unitCount, AVG(EU.purchaseCost) AS averagePurchaseCost
FROM Laboratory L
JOIN EquipmentUnit EU ON L.labId = EU.labId
JOIN EquipmentModel EM ON EU.modelId = EM.modelId
GROUP BY L.labId, L.name, EM.category;

SELECT S.suppId, COUNT(DISTINCT S.consId)
FROM Supplies S
GROUP BY S.suppId;


SELECT S.labId, S.consId, MIN(S.unitPrice)
FROM Supplies S
GROUP BY S.labId, S.consId;

SELECT R.resId, P.firstName, P.lastName, SUM(C.quantityUsed)
FROM Reservation R, Person P, Consumes C
WHERE R.resId = C.resId AND R.madeByPid = P.pid
GROUP BY R.resId;

-- E

SELECT P.pid, P.firstName, P.lastName
FROM Person P, Laboratory L
WHERE P.pid = L.supervisorPid 
INTERSECT
SELECT P.pid, P.firstName, P.lastName
FROM Person P, Budget B
WHERE P.pid = B.managerPid;

SELECT P.pid
FROM Person P
EXCEPT
SELECT P.pid
FROM Person P, Reservation R
WHERE P.pid = R.madeByPid;

SELECT E.serialNo
FROM EquipmentUnit E
WHERE NOT EXISTS
(
	SELECT R.serialNo
    FROM  Reserves R
    WHERE E.serialNo = R.serialNo
);

SELECT E.serialNo
FROM EquipmentUnit E
WHERE E.purchaseCost >= ALL (
	SELECT E.purchaseCost
    FROM EquipmentUnit E
);

-- F
SELECT DISTINCT R.modelId, H.pid
FROM Requires R, Holds H
WHERE NOT EXISTS (
    SELECT *
    FROM Requires R2
    WHERE R2.modelId = R.modelId
    AND NOT EXISTS (
        SELECT *
        FROM Holds H2
        WHERE H2.pid = H.pid
        AND H2.certCode = R.certCode
    )
);
