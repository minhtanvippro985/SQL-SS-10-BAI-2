CREATE DATABASE HospitalManagement;
USE HospitalManagement;

CREATE TABLE Patients (
    PatientID INT AUTO_INCREMENT PRIMARY KEY,
    Full_Name VARCHAR(100),
    Phone VARCHAR(20),
    Age INT,
    Address VARCHAR(255)
);

-- 2. Tạo Procedure để chèn 500.000 dòng
DELIMITER //
CREATE PROCEDURE SeedPatients()
BEGIN
    DECLARE i INT DEFAULT 1;
    -- Tắt autocommit để tăng tốc độ chèn ban đầu
    SET autocommit = 0;
    WHILE i <= 500000 DO
        INSERT INTO Patients (Full_Name, Phone, Age, Address)
        VALUES (CONCAT('Patient ', i), CONCAT('090', i), FLOOR(RAND()*100), 'Ho Chi Minh City');
        
        -- Commit mỗi 10.000 dòng để tránh tràn bộ nhớ
        IF MOD(i, 10000) = 0 THEN
            COMMIT;
        END IF;
        SET i = i + 1;
    END WHILE;
    COMMIT;
    SET autocommit = 1;
END //
DELIMITER ;

CALL SeedPatients();




SELECT * FROM Patients WHERE Phone = '090456789';
-- thường > 0.3s - 1s 

EXPLAIN SELECT * FROM Patients WHERE Phone = '090456789';
-- Full Table Scan rows = ~500.000



DELIMITER //
CREATE PROCEDURE TestInsertPerformance()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE start_time TIMESTAMP;
    DECLARE end_time TIMESTAMP;
    
    SET start_time = CURRENT_TIMESTAMP(6);
    
    WHILE i <= 1000 DO
        INSERT INTO Patients (Full_Name, Phone, Age, Address)
        VALUES ('New Patient', CONCAT('080', i), 30, 'Hanoi');
        SET i = i + 1;
    END WHILE;
    
    SET end_time = CURRENT_TIMESTAMP(6);
    SELECT TIMEDIFF(end_time, start_time) AS Execution_Time;
END //
DELIMITER ;

CALL TestInsertPerformance();

DROP INDEX idx_phone ON Patients;
CALL TestInsertPerformance();


-- Truy vấn select	Rất chậm   Cải thiện ~100-500 lần
-- Ghi mới insert	Nhanh	Chậm hơn một chút	Giảm nhẹ (do phải cập nhật B-Tree)