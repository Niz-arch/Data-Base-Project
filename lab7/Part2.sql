USE DBPROJECT;

-- Part 2: Views
UPDATE Reservation
SET plannedStart = CURRENT_DATE + INTERVAL 7 DAY,
    plannedEnd = CURRENT_DATE + INTERVAL 8 DAY
WHERE resId = 2 AND status = 'Approved';

CREATE OR REPLACE VIEW UpcomingApprovedReservationsByLab AS
SELECT L.labId, L.name AS labName, DATE(R.plannedStart) AS reservationDate,
       COUNT(DISTINCT R.resId) AS approvedReservations
FROM Laboratory L
JOIN EquipmentUnit U ON U.labId = L.labId
JOIN Reserves RS ON RS.serialNo = U.serialNo
JOIN Reservation R ON R.resId = RS.resId
WHERE R.status = 'Approved'
  AND R.plannedStart >= CURRENT_DATE
  AND R.plannedStart < DATE_ADD(CURRENT_DATE, INTERVAL 14 DAY)
GROUP BY L.labId, L.name, DATE(R.plannedStart);

SELECT * FROM UpcomingApprovedReservationsByLab;

CREATE OR REPLACE VIEW EquipmentInventoryByLab AS
SELECT L.labId, L.name AS labName, M.modelId, M.commercialName, M.category,
       COUNT(U.serialNo) AS totalUnits,
       SUM(CASE WHEN U.status = 'InService' THEN 1 ELSE 0 END) AS inServiceUnits,
       SUM(CASE WHEN U.status = 'UnderMaintenance' THEN 1 ELSE 0 END) AS unitsUnderMaintenance
FROM Laboratory L
CROSS JOIN EquipmentModel M
LEFT JOIN EquipmentUnit U ON U.labId = L.labId AND U.modelId = M.modelId
GROUP BY L.labId, L.name, M.modelId, M.commercialName, M.category;

SELECT * FROM EquipmentInventoryByLab;

CREATE OR REPLACE VIEW PersonReservationSummary AS
SELECT P.pid, P.firstName, P.lastName,
       COUNT(R.resId) AS totalReservations,
       SUM(CASE WHEN R.status = 'Approved' THEN 1 ELSE 0 END) AS approvedReservations,
       SUM(CASE WHEN R.status = 'Pending' THEN 1 ELSE 0 END) AS pendingReservations,
       SUM(CASE WHEN R.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelledReservations
FROM Person P
LEFT JOIN Reservation R ON R.madeByPid = P.pid
GROUP BY P.pid, P.firstName, P.lastName;

SELECT * FROM PersonReservationSummary;

CREATE OR REPLACE VIEW ProjectReservationSummary AS
SELECT PR.code AS projectCode, PR.title, PR.status,
       COUNT(R.resId) AS totalReservations,
       SUM(CASE WHEN R.status = 'Approved' THEN 1 ELSE 0 END) AS approvedReservations,
       MIN(CASE WHEN R.status = 'Approved' AND R.plannedStart >= CURRENT_TIMESTAMP
                THEN R.plannedStart ELSE NULL END) AS nextApprovedReservation
FROM ResearchProject PR
LEFT JOIN Reservation R ON R.projectCode = PR.code
GROUP BY PR.code, PR.title, PR.status;

SELECT * FROM ProjectReservationSummary;

CREATE OR REPLACE VIEW LaboratoryStockSummary AS
SELECT L.labId, L.name AS labName, C.consId, C.name AS consumableName,
       C.unitOfMeasure, S.quantityOnHand, C.reorderThreshold,
       S.technicalPid, S.monitoringSince,
       CASE WHEN S.quantityOnHand <= C.reorderThreshold THEN 'LOW' ELSE 'OK' END AS stockLevel
FROM Laboratory L
JOIN Stocks S ON S.labId = L.labId
JOIN Consumable C ON C.consId = S.consId;

SELECT * FROM LaboratoryStockSummary;

