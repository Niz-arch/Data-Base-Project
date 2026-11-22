USE DBPROJECT;

-- Part 4, task 2(a): reject adding a unit to an approved reservation when
DELIMITER //
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

-- Part 4, task 2(b): when an approved reservation is approved or rescheduled,
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

-- Valid insert
INSERT INTO Reserves VALUES (3, 'U7');

-- Valid update
UPDATE Reservation
SET plannedStart = (SELECT dates.plannedStart FROM
                       (SELECT plannedStart FROM Reservation WHERE resId = 4) dates),
    plannedEnd = (SELECT dates.plannedEnd FROM
                     (SELECT plannedEnd FROM Reservation WHERE resId = 4) dates)
WHERE resId = 1;

-- Rejected INSERT
INSERT INTO Reserves VALUES (1, 'U3');

-- Rejected UPDATE
UPDATE Reservation
SET plannedStart = (SELECT dates.plannedStart FROM
                       (SELECT plannedStart FROM Reservation WHERE resId = 4) dates),
    plannedEnd = (SELECT dates.plannedEnd FROM
                     (SELECT plannedEnd FROM Reservation WHERE resId = 4) dates)
WHERE resId = 2;
