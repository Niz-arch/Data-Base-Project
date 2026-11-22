USE DBPROJECT;

-- Part 1 

-- Q1
SELECT PE.firstName AS empFirst, PE.lastName AS empLast,
       PS.firstName AS supFirst, PS.lastName AS supLast
FROM Employee E
JOIN Person PE ON PE.pid = E.pid
LEFT OUTER JOIN Person PS ON PS.pid = E.supervisorPid;

-- Q2
SELECT R.resId, R.status, P.firstName, P.lastName
FROM Reservation R
LEFT OUTER JOIN Person P ON P.pid = R.approverPid;

-- Q3
SELECT A.serialNo, B.serialNo, A.modelId, A.labId, B.labId
FROM EquipmentUnit A, EquipmentUnit B
WHERE A.modelId = B.modelId
  AND A.labId <> B.labId
  AND A.serialNo < B.serialNo;

-- Q4
SELECT M.commercialName, COUNT(U.serialNo) AS nbUnits
FROM EquipmentModel M
LEFT OUTER JOIN EquipmentUnit U ON U.modelId = M.modelId
GROUP BY M.modelId, M.commercialName;

-- Q5
SELECT U.labId, U.serialNo
FROM EquipmentUnit U
WHERE U.purchaseCost = (SELECT MAX(U2.purchaseCost)
                        FROM EquipmentUnit U2
                        WHERE U2.labId = U.labId);

-- Q6
SELECT L.labId, COALESCE(SUM(S.quantityOnHand), 0) AS total
FROM Laboratory L
LEFT JOIN Stocks S ON S.labId = L.labId
GROUP BY L.labId
HAVING COALESCE(SUM(S.quantityOnHand), 0) > (
  SELECT AVG(T.total)
  FROM (
    SELECT L2.labId, COALESCE(SUM(S2.quantityOnHand), 0) AS total
    FROM Laboratory L2
    LEFT JOIN Stocks S2 ON S2.labId = L2.labId
    GROUP BY L2.labId
  ) AS T
);

-- Q7
SELECT C.consId, C.name
FROM Consumable C
WHERE NOT EXISTS (SELECT L.labId
                  FROM Laboratory L
                  WHERE NOT EXISTS (SELECT S.labId
                                    FROM Stocks S
                                    WHERE S.labId = L.labId
                                      AND S.consId = C.consId));

