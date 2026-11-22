USE DBPROJECT

-- PART 4, TASK 1 

DELIMITER //

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

-- valid
INSERT INTO Participates (pid, projectCode, role) VALUES (4, 'P1', 'Collaborator');
UPDATE Participates SET role = 'PI' WHERE pid = 2 AND projectCode = 'P1';

-- rejected
INSERT INTO Participates (pid, projectCode, role) VALUES (5, 'P1', 'Collaborator');   -- administrative
INSERT INTO Participates (pid, projectCode, role) VALUES (10, 'P2', 'Co-PI');         -- Co-PI but not Academic
INSERT INTO Participates (pid, projectCode, role) VALUES (4, 'P2', 'PI');             -- second PI (P2 has one)
UPDATE Participates SET role = 'PI' WHERE pid = 4 AND projectCode = 'P1';             -- second PI by update

