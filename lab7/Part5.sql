USE DBPROJECT;

-- Part 5.1: stored function
DROP FUNCTION IF EXISTS availableUnits;
DELIMITER //
CREATE FUNCTION availableUnits(mId INT) RETURNS INT
READS SQL DATA
BEGIN
  DECLARE unitCount INT;
  SELECT COUNT(*) INTO unitCount
  FROM EquipmentUnit
  WHERE modelId = mId AND status = 'InService';
  RETURN unitCount;
END//
DELIMITER ;

SELECT commercialName, availableUnits(modelId) AS availableUnits
FROM EquipmentModel;

-- Part 5.2: stored procedure with an OUT parameter
DROP PROCEDURE IF EXISTS RestockLab;
DELIMITER //
CREATE PROCEDURE RestockLab(IN inLabId INT, IN inConsId INT,
                            IN qty DECIMAL(12,2), OUT newQuantity DECIMAL(12,2))
BEGIN
  IF qty <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Restock quantity must be positive';
  END IF;
  IF NOT EXISTS (SELECT * FROM Stocks WHERE labId = inLabId AND consId = inConsId) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No stock occurrence for this laboratory and consumable';
  END IF;
  UPDATE Stocks
  SET quantityOnHand = quantityOnHand + qty,
      lastRestockDate = CURRENT_DATE
  WHERE labId = inLabId AND consId = inConsId;
  SELECT quantityOnHand INTO newQuantity
  FROM Stocks WHERE labId = inLabId AND consId = inConsId;
END//
DELIMITER ;

CALL RestockLab(1, 1, 5.00, @newQuantity);
SELECT @newQuantity AS newQuantity;
-- Rejected examples; run separately so the script can continue after each error:
CALL RestockLab(1, 1, 0.00, @newQuantity);
CALL RestockLab(2, 2, 1.00, @newQuantity);

-- Part 5.7(a): run once to rename the base-table column. The unmodified
-- Python query of LaboratoryStockSummary then fails because its view definition
-- uses Consumable.name. The view can no longer resolve that base-table column,
-- so the program's task 4 SELECT reports a database error.
-- ALTER TABLE Consumable RENAME COLUMN name TO designation;

-- Part 5.7(b): with the renamed column, re-create the view while retaining its
-- original output name. The program's query remains unchanged. Its LOW rows
-- are the same as before: only the source column was renamed, not its values or
-- the stock-level calculation.
-- CREATE OR REPLACE VIEW LaboratoryStockSummary AS
-- SELECT L.labId, L.name AS labName, C.consId, C.designation AS consumableName,
--        C.unitOfMeasure, S.quantityOnHand, C.reorderThreshold,
--        S.technicalPid, S.monitoringSince,
--        CASE WHEN S.quantityOnHand <= C.reorderThreshold THEN 'LOW' ELSE 'OK' END AS stockLevel
-- FROM Laboratory L JOIN Stocks S ON S.labId = L.labId
-- JOIN Consumable C ON C.consId = S.consId;

-- Part 5.7(d): restore the schema and original view after the demonstration.
-- ALTER TABLE Consumable RENAME COLUMN designation TO name;
-- Re-run the CREATE OR REPLACE VIEW LaboratoryStockSummary statement in Part2.sql.
-- For (c), this illustrates data independence: the view preserves the logical
-- interface consumed by the program while its underlying base-table column changes.
-- Task 3 directly references Laboratory.name, so that query would fail if that
-- base-table column were renamed without changing the query.
