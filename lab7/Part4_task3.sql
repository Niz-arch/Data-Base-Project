USE DBPROJECT;

-- Part 4, task 3: certification eligibility (CE5-CE6).
DELIMITER //
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

-- Valid
INSERT INTO Reserves VALUES (2, 'U1');
DELETE FROM Reserves WHERE resId = 2 AND serialNo = 'U1';

-- Rejected
INSERT INTO Reserves VALUES (1, 'U3');
