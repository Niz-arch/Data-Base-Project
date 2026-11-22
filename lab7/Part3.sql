USE DBPROJECT;

-- Part 3: CHECK constraints. Values are the domains used by the RLMS lab data.
ALTER TABLE Student ADD CONSTRAINT chk_student_program
  CHECK (program IN ('BSc', 'BEng', 'MSc', 'PhD'));
ALTER TABLE Employee ADD CONSTRAINT chk_employee_position
  CHECK (position IN ('dean', 'faculty', 'postdoc', 'secretary', 'technician', 'lab manager'));
ALTER TABLE ResearchProject ADD CONSTRAINT chk_project_status
  CHECK (status IN ('Proposed', 'Active', 'Completed', 'Cancelled'));
ALTER TABLE Participates ADD CONSTRAINT chk_participation_role
  CHECK (role IN ('PI', 'Co-PI', 'Collaborator'));
ALTER TABLE EquipmentUnit ADD CONSTRAINT chk_equipment_status
  CHECK (status IN ('InService', 'UnderMaintenance'));
ALTER TABLE Reservation ADD CONSTRAINT chk_reservation_status
  CHECK (status IN ('Pending', 'Approved', 'Rejected', 'Cancelled', 'Completed'));
ALTER TABLE Maintenance ADD CONSTRAINT chk_maintenance_type
  CHECK (type IN ('Preventive', 'Corrective'));
ALTER TABLE Maintenance ADD CONSTRAINT chk_maintenance_outcome
  CHECK (outcome IN ('Resolved', 'FollowUpRequired'));
ALTER TABLE CalibrationRecord ADD CONSTRAINT chk_calibration_result
  CHECK (result IN ('Pass', 'Fail', 'Adjusted'));

ALTER TABLE Budget ADD CONSTRAINT chk_budget_amounts
  CHECK (amountGranted >= 0 AND amountDisbursed >= 0);
ALTER TABLE EquipmentUnit ADD CONSTRAINT chk_equipment_purchase_cost
  CHECK (purchaseCost >= 0);
ALTER TABLE Maintenance ADD CONSTRAINT chk_maintenance_cost
  CHECK (cost >= 0);
ALTER TABLE Supplies ADD CONSTRAINT chk_supply_unit_price
  CHECK (unitPrice >= 0);
ALTER TABLE Consumable ADD CONSTRAINT chk_reorder_threshold
  CHECK (reorderThreshold >= 0);
ALTER TABLE Stocks ADD CONSTRAINT chk_stock_quantity
  CHECK (quantityOnHand >= 0);
ALTER TABLE Consumes ADD CONSTRAINT chk_quantity_used
  CHECK (quantityUsed > 0);

ALTER TABLE Reservation ADD CONSTRAINT chk_reservation_period
  CHECK (plannedEnd > plannedStart);
ALTER TABLE Maintenance ADD CONSTRAINT chk_maintenance_period
  CHECK (endTS >= startTS);

-- Rejected examples.
UPDATE Student SET program = 'Kindergarten' WHERE pid = 8;
UPDATE Employee SET position = 'visitor' WHERE pid = 2;
UPDATE ResearchProject SET status = 'Paused' WHERE code = 'P1';
UPDATE Participates SET role = 'Observer' WHERE pid = 8 AND projectCode = 'P1';
UPDATE EquipmentUnit SET status = 'Broken' WHERE serialNo = 'U1';
UPDATE Reservation SET status = 'Waiting' WHERE resId = 1;
UPDATE Maintenance SET type = 'Inspection' WHERE serialNo = 'U6';
UPDATE Maintenance SET outcome = 'Open' WHERE serialNo = 'U6';
UPDATE CalibrationRecord SET result = 'Unknown' WHERE serialNo = 'U3';
UPDATE Budget SET amountGranted = -1 WHERE budgetLine = 'B1';
UPDATE EquipmentUnit SET purchaseCost = -1 WHERE serialNo = 'U1';
UPDATE Maintenance SET cost = -1 WHERE serialNo = 'U6';
UPDATE Supplies SET unitPrice = -1 WHERE suppId = 1 AND consId = 1 AND labId = 1;
UPDATE Consumable SET reorderThreshold = -1 WHERE consId = 1;
UPDATE Stocks SET quantityOnHand = -1 WHERE labId = 1 AND consId = 1;
INSERT INTO Consumes VALUES (1, 1, 1, 0);
UPDATE Reservation SET plannedEnd = plannedStart WHERE resId = 1;
UPDATE Maintenance SET endTS = startTS - INTERVAL 1 SECOND WHERE serialNo = 'U6';

