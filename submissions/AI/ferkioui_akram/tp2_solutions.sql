-- ============================================
-- TP2: Hospital Management System
-- Student: FERKIOUI Akram (Group AI_2)
-- ============================================

-- ============================================
-- 1. Database Creation
-- ============================================
DROP DATABASE IF EXISTS hospital_db;
CREATE DATABASE hospital_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hospital_db;

-- ============================================
-- 2. Table Creation
-- ============================================

-- Table: specialties
CREATE TABLE specialties (
    specialty_id INT AUTO_INCREMENT PRIMARY KEY,
    specialty_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    consultation_fee DECIMAL(10, 2) NOT NULL
);

-- Table: doctors
CREATE TABLE doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    specialty_id INT NOT NULL,
    license_number VARCHAR(20) UNIQUE NOT NULL,
    hire_date DATE,
    office VARCHAR(100),
    active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (specialty_id) REFERENCES specialties(specialty_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Table: patients
CREATE TABLE patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    file_number VARCHAR(20) UNIQUE NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('M', 'F') NOT NULL,
    blood_type VARCHAR(5),
    email VARCHAR(100),
    phone VARCHAR(20) NOT NULL,
    address TEXT,
    city VARCHAR(50),
    province VARCHAR(50),
    registration_date DATE DEFAULT (CURRENT_DATE),
    insurance VARCHAR(100),
    insurance_number VARCHAR(50),
    allergies TEXT,
    medical_history TEXT
);

-- Table: consultations
CREATE TABLE consultations (
    consultation_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    consultation_date DATETIME NOT NULL,
    reason TEXT NOT NULL,
    diagnosis TEXT,
    observations TEXT,
    blood_pressure VARCHAR(20),
    temperature DECIMAL(4, 2),
    weight DECIMAL(5, 2),
    height DECIMAL(5, 2),
    status ENUM('Scheduled', 'In Progress', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
    amount DECIMAL(10, 2),
    paid BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Table: medications
CREATE TABLE medications (
    medication_id INT AUTO_INCREMENT PRIMARY KEY,
    medication_code VARCHAR(20) UNIQUE NOT NULL,
    commercial_name VARCHAR(150) NOT NULL,
    generic_name VARCHAR(150),
    form VARCHAR(50),
    dosage VARCHAR(50),
    manufacturer VARCHAR(100),
    unit_price DECIMAL(10, 2) NOT NULL,
    available_stock INT DEFAULT 0,
    minimum_stock INT DEFAULT 10,
    expiration_date DATE,
    prescription_required BOOLEAN DEFAULT TRUE,
    reimbursable BOOLEAN DEFAULT FALSE
);

-- Table: prescriptions
CREATE TABLE prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    consultation_id INT NOT NULL,
    prescription_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    treatment_duration INT, -- in days
    general_instructions TEXT,
    FOREIGN KEY (consultation_id) REFERENCES consultations(consultation_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table: prescription_details
CREATE TABLE prescription_details (
    detail_id INT AUTO_INCREMENT PRIMARY KEY,
    prescription_id INT NOT NULL,
    medication_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    dosage_instructions VARCHAR(200) NOT NULL,
    duration INT NOT NULL,
    total_price DECIMAL(10, 2),
    FOREIGN KEY (prescription_id) REFERENCES prescriptions(prescription_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (medication_id) REFERENCES medications(medication_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================
-- 3. Required Indexes
-- ============================================
CREATE INDEX idx_patient_name ON patients(last_name, first_name);
CREATE INDEX idx_consultation_date ON consultations(consultation_date);
CREATE INDEX idx_consultation_patient ON consultations(patient_id);
CREATE INDEX idx_consultation_doctor ON consultations(doctor_id);
CREATE INDEX idx_medication_name ON medications(commercial_name);
CREATE INDEX idx_prescription_consultation ON prescriptions(consultation_id);

-- ============================================
-- 4. Inserting Test Data
-- ============================================

-- Specialties
INSERT INTO specialties (specialty_name, description, consultation_fee) VALUES
('General Medicine', 'Primary care medicine', 2000.00),
('Cardiology', 'Heart and blood vessels', 4000.00),
('Pediatrics', 'Medical care of infants, children, and adolescents', 2500.00),
('Dermatology', 'Skin, nails, and hair diseases', 3000.00),
('Orthopedics', 'Musculoskeletal system', 3500.00),
('Gynecology', 'Female reproductive system', 3000.00);

-- Doctors
INSERT INTO doctors (last_name, first_name, email, phone, specialty_id, license_number, hire_date, office) VALUES
('House', 'Gregory', 'greg.house@hospital.com', '0555123456', 1, 'LIC001', '2015-05-10', 'Room 101'),
('Strange', 'Stephen', 'dr.strange@hospital.com', '0555123457', 2, 'LIC002', '2018-03-15', 'Room 202'),
('Quinn', 'Harley', 'h.quinn@hospital.com', '0555123458', 3, 'LIC003', '2020-01-20', 'Room 303'),
('Jekyll', 'Henry', 'h.jekyll@hospital.com', '0555123459', 4, 'LIC004', '2016-11-05', 'Room 404'),
('McCoy', 'Leonard', 'bones@hospital.com', '0555123460', 5, 'LIC005', '2010-09-01', 'Room 505'),
('Grey', 'Meredith', 'm.grey@hospital.com', '0555123461', 6, 'LIC006', '2021-07-12', 'Room 606');

-- Patients
INSERT INTO patients (file_number, last_name, first_name, date_of_birth, gender, blood_type, phone, city, allergies, insurance) VALUES
('P001', 'Doe', 'John', '1985-06-15', 'M', 'O+', '0666111222', 'Algiers', 'Penicillin', 'CNAS'),
('P002', 'Smith', 'Jane', '1990-12-05', 'F', 'A-', '0666333444', 'Oran', NULL, 'CASNOS'),
('P003', 'Wayne', 'Bruce', '1980-02-19', 'M', 'AB+', '0666555666', 'Constantine', 'Bat bites', 'Private'),
('P004', 'Kent', 'Clark', '1988-04-18', 'M', 'O+', '0666777888', 'Algiers', 'Kryptonite', 'CNAS'),
('P005', 'Prince', 'Diana', '1995-03-22', 'F', 'B+', '0666999000', 'Annaba', NULL, 'Private'),
('P006', 'Parker', 'Peter', '2005-08-10', 'M', 'A+', '0666123123', 'Algiers', 'Spider venom', 'CNAS'),
('P007', 'Stacy', 'Gwen', '2006-11-14', 'F', 'O-', '0666321321', 'Blida', NULL, NULL),
('P008', 'Odinson', 'Thor', '1975-01-01', 'M', 'AB-', '0666987654', 'Oran', 'None', 'CASNOS');

-- Consultations
-- Make sure some are in Jan 2025 for Q4
INSERT INTO consultations (patient_id, doctor_id, consultation_date, reason, status, amount, paid, diagnosis) VALUES
(1, 1, '2025-01-10 09:00:00', 'Fever and cough', 'Completed', 2000.00, TRUE, 'Flu'),
(2, 2, '2025-01-12 10:30:00', 'Chest pain', 'Completed', 4000.00, TRUE, 'Angina'),
(3, 3, '2025-01-15 14:00:00', 'Routine checkup', 'Completed', 2500.00, TRUE, 'Healthy'),
(4, 4, '2025-02-01 11:00:00', 'Skin rash', 'Scheduled', 3000.00, FALSE, NULL),
(5, 5, '2024-12-20 15:30:00', 'Knee pain', 'Completed', 3500.00, TRUE, 'Sprain'),
(6, 1, '2025-01-20 08:30:00', 'Headache', 'Completed', 2000.00, FALSE, 'Migraine'),
(1, 2, '2025-02-05 09:15:00', 'Follow up', 'Scheduled', 4000.00, FALSE, NULL),
(7, 6, '2025-01-25 10:00:00', 'Pregnancy check', 'Completed', 3000.00, TRUE, 'Normal progression');

-- Medications
INSERT INTO medications (medication_code, commercial_name, unit_price, available_stock, minimum_stock, expiration_date) VALUES
('MED001', 'Paracetamol 500mg', 100.00, 500, 50, '2026-12-31'),
('MED002', 'Amoxicillin 1g', 850.00, 200, 30, '2025-10-15'),
('MED003', 'Ibuprofen 400mg', 450.00, 300, 40, '2026-06-20'),
('MED004', 'Loratadine 10mg', 350.00, 150, 20, '2025-08-01'),
('MED005', 'Vitamin C 1000mg', 250.00, 400, 50, '2027-01-01'),
('MED006', 'Metformin 500mg', 600.00, 100, 20, '2025-05-30'), -- Expiring soon (Q20)
('MED007', 'Atorvastatin 20mg', 1200.00, 80, 15, '2026-03-15'),
('MED008', 'Omeprazole 20mg', 550.00, 120, 25, '2026-11-30'),
('MED009', 'Aspirin 100mg', 150.00, 600, 100, '2028-01-01'),
('MED010', 'Insulin Glargine', 2500.00, 40, 10, '2025-04-20'); -- Expiring soon (Q20)

-- Prescriptions
INSERT INTO prescriptions (consultation_id, prescription_date, treatment_duration) VALUES
(1, '2025-01-10 09:30:00', 7),
(2, '2025-01-12 11:00:00', 30),
(5, '2024-12-20 16:00:00', 5),
(6, '2025-01-20 09:00:00', 3),
(7, '2025-01-25 10:30:00', 90),
(3, '2025-01-15 14:30:00', 10),
(8, '2025-01-25 10:30:00', 180);

-- Prescription Details
INSERT INTO prescription_details (prescription_id, medication_id, quantity, dosage_instructions, duration, total_price) VALUES
(1, 1, 2, '1 tablet every 8 hours', 5, 200.00), -- Paracetamol
(1, 5, 1, '1 effervescent tablet daily', 7, 250.00), -- Vit C
(2, 9, 1, '1 tablet daily', 30, 150.00), -- Aspirin
(3, 3, 1, '1 tablet every 8 hours after food', 5, 450.00), -- Ibuprofen
(4, 1, 1, '1 tablet if needed', 3, 100.00), -- Paracetamol
(5, 5, 3, '1 tablet daily', 90, 750.00), -- Vit C
(6, 5, 1, '1 tablet daily', 10, 250.00), -- Vit C
(7, 5, 6, '1 tablet daily', 180, 1500.00), -- Vit C for pregnancy
(2, 7, 1, '1 tablet at night', 30, 1200.00), -- Atorvastatin
(3, 1, 1, '1 tablet for pain', 5, 100.00),
(1, 2, 1, '1 sachet every 12 hours', 7, 850.00), -- Amoxicillin
(4, 3, 1, '1 tablet for pain', 3, 450.00);


-- ============================================
-- 5. SQL Queries (30 Queries)
-- ============================================

-- ========== PART 1: BASIC QUERIES (Q1-Q5) ==========

-- Q1. List all patients with their main information
SELECT file_number, CONCAT(last_name, ' ', first_name) AS full_name, date_of_birth, phone, city 
FROM patients;

-- Q2. Display all doctors with their specialty
SELECT CONCAT(d.last_name, ' ', d.first_name) AS doctor_name, s.specialty_name, d.office, d.active
FROM doctors d
JOIN specialties s ON d.specialty_id = s.specialty_id;

-- Q3. Find all medications with price less than 500 DA
SELECT medication_code, commercial_name, unit_price, available_stock 
FROM medications 
WHERE unit_price < 500;

-- Q4. List consultations from January 2025
SELECT consultation_date, CONCAT(p.last_name, ' ', p.first_name) AS patient_name, 
       CONCAT(d.last_name, ' ', d.first_name) AS doctor_name, status
FROM consultations c
JOIN patients p ON c.patient_id = p.patient_id
JOIN doctors d ON c.doctor_id = d.doctor_id
WHERE consultation_date BETWEEN '2025-01-01' AND '2025-01-31';

-- Q5. Display medications where stock is below minimum stock
SELECT commercial_name, available_stock, minimum_stock, (minimum_stock - available_stock) AS difference
FROM medications
WHERE available_stock < minimum_stock;

-- ========== PART 2: QUERIES WITH JOINS (Q6-Q10) ==========

-- Q6. Display all consultations with patient and doctor names
SELECT c.consultation_date, CONCAT(p.last_name, ' ', p.first_name) AS patient_name, 
       CONCAT(d.last_name, ' ', d.first_name) AS doctor_name, c.diagnosis, c.amount
FROM consultations c
JOIN patients p ON c.patient_id = p.patient_id
JOIN doctors d ON c.doctor_id = d.doctor_id;

-- Q7. List all prescriptions with medication details
SELECT pr.prescription_date, CONCAT(p.last_name, ' ', p.first_name) AS patient_name, 
       m.commercial_name AS medication_name, pd.quantity, pd.dosage_instructions
FROM prescription_details pd
JOIN prescriptions pr ON pd.prescription_id = pr.prescription_id
JOIN consultations c ON pr.consultation_id = c.consultation_id
JOIN patients p ON c.patient_id = p.patient_id
JOIN medications m ON pd.medication_id = m.medication_id;

-- Q8. Display patients with their last consultation date
SELECT CONCAT(p.last_name, ' ', p.first_name) AS patient_name, MAX(c.consultation_date) AS last_consultation_date,
       (SELECT CONCAT(d.last_name, ' ', d.first_name) FROM doctors d WHERE d.doctor_id = 
           (SELECT doctor_id FROM consultations c2 WHERE c2.patient_id = p.patient_id ORDER BY consultation_date DESC LIMIT 1)
       ) AS doctor_name
FROM patients p
LEFT JOIN consultations c ON p.patient_id = c.patient_id
GROUP BY p.patient_id;

-- Q9. List doctors and the number of consultations performed
SELECT CONCAT(d.last_name, ' ', d.first_name) AS doctor_name, COUNT(c.consultation_id) AS consultation_count
FROM doctors d
LEFT JOIN consultations c ON d.doctor_id = c.doctor_id
GROUP BY d.doctor_id;

-- Q10. Display revenue by medical specialty
SELECT s.specialty_name, SUM(c.amount) AS total_revenue, COUNT(c.consultation_id) AS consultation_count
FROM specialties s
LEFT JOIN doctors d ON s.specialty_id = d.specialty_id
LEFT JOIN consultations c ON d.doctor_id = c.doctor_id
GROUP BY s.specialty_id;

-- ========== PART 3: AGGREGATE FUNCTIONS (Q11-Q15) ==========

-- Q11. Calculate total prescription amount per patient
SELECT CONCAT(p.last_name, ' ', p.first_name) AS patient_name, SUM(pd.total_price) AS total_prescription_cost
FROM patients p
JOIN consultations c ON p.patient_id = c.patient_id
JOIN prescriptions pr ON c.consultation_id = pr.consultation_id
JOIN prescription_details pd ON pr.prescription_id = pd.prescription_id
GROUP BY p.patient_id;

-- Q12. Count the number of consultations per doctor
-- (Duplicate of Q9, but standard phrasing)
SELECT CONCAT(d.last_name, ' ', d.first_name) AS doctor_name, COUNT(c.consultation_id) AS consultation_count
FROM doctors d
LEFT JOIN consultations c ON d.doctor_id = c.doctor_id
GROUP BY d.doctor_id;

-- Q13. Calculate total stock value of pharmacy
SELECT COUNT(*) AS total_medications, SUM(available_stock * unit_price) AS total_stock_value
FROM medications;

-- Q14. Find average consultation price per specialty
SELECT s.specialty_name, AVG(c.amount) AS average_price
FROM specialties s
JOIN doctors d ON s.specialty_id = d.specialty_id
JOIN consultations c ON d.doctor_id = c.doctor_id
GROUP BY s.specialty_id;

-- Q15. Count number of patients by blood type
SELECT blood_type, COUNT(*) AS patient_count
FROM patients
GROUP BY blood_type;

-- ========== PART 4: ADVANCED QUERIES (Q16-Q20) ==========

-- Q16. Find the top 5 most prescribed medications
SELECT m.commercial_name AS medication_name, COUNT(pd.detail_id) AS times_prescribed, SUM(pd.quantity) AS total_quantity
FROM medications m
JOIN prescription_details pd ON m.medication_id = pd.medication_id
GROUP BY m.medication_id
ORDER BY times_prescribed DESC
LIMIT 5;

-- Q17. List patients who have never had a consultation
SELECT CONCAT(p.last_name, ' ', p.first_name) AS patient_name, p.registration_date
FROM patients p
LEFT JOIN consultations c ON p.patient_id = c.patient_id
WHERE c.consultation_id IS NULL;

-- Q18. Display doctors who performed more than 2 consultations
SELECT CONCAT(d.last_name, ' ', d.first_name) AS doctor_name, s.specialty_name, COUNT(c.consultation_id) AS consultation_count
FROM doctors d
JOIN specialties s ON d.specialty_id = s.specialty_id
JOIN consultations c ON d.doctor_id = c.doctor_id
GROUP BY d.doctor_id
HAVING consultation_count > 2;

-- Q19. Find unpaid consultations with total amount
SELECT CONCAT(p.last_name, ' ', p.first_name) AS patient_name, c.consultation_date, c.amount, 
       CONCAT(d.last_name, ' ', d.first_name) AS doctor_name
FROM consultations c
JOIN patients p ON c.patient_id = p.patient_id
JOIN doctors d ON c.doctor_id = d.doctor_id
WHERE c.paid = FALSE;

-- Q20. List medications expiring in less than 6 months from today
-- Assuming today is fixed for reproducibility or using CURRENT_DATE
SELECT commercial_name AS medication_name, expiration_date, DATEDIFF(expiration_date, CURRENT_DATE) AS days_until_expiration
FROM medications
WHERE expiration_date BETWEEN CURRENT_DATE AND DATE_ADD(CURRENT_DATE, INTERVAL 6 MONTH);

-- ========== PART 5: SUBQUERIES (Q21-Q25) ==========

-- Q21. Find patients who consulted more than the average
SELECT CONCAT(p.last_name, ' ', p.first_name) AS patient_name, COUNT(c.consultation_id) AS consultation_count,
       (SELECT COUNT(*) / COUNT(DISTINCT patient_id) FROM consultations) AS average_count
FROM patients p
JOIN consultations c ON p.patient_id = c.patient_id
GROUP BY p.patient_id
HAVING consultation_count > (SELECT COUNT(*) / COUNT(DISTINCT patient_id) FROM consultations);

-- Q22. List medications more expensive than average price
SELECT commercial_name AS medication_name, unit_price, (SELECT AVG(unit_price) FROM medications) AS average_price
FROM medications
WHERE unit_price > (SELECT AVG(unit_price) FROM medications);

-- Q23. Display doctors from the most requested specialty
SELECT CONCAT(d.last_name, ' ', d.first_name) AS doctor_name, s.specialty_name, 
       (SELECT COUNT(*) FROM consultations c2 JOIN doctors d2 ON c2.doctor_id = d2.doctor_id WHERE d2.specialty_id = s.specialty_id) AS specialty_consultation_count
FROM doctors d
JOIN specialties s ON d.specialty_id = s.specialty_id
WHERE s.specialty_id = (
    SELECT d3.specialty_id
    FROM consultations c3
    JOIN doctors d3 ON c3.doctor_id = d3.doctor_id
    GROUP BY d3.specialty_id
    ORDER BY COUNT(*) DESC
    LIMIT 1
);

-- Q24. Find consultations with amount higher than average
SELECT c.consultation_date, CONCAT(p.last_name, ' ', p.first_name) AS patient_name, c.amount, 
       (SELECT AVG(amount) FROM consultations) AS average_amount
FROM consultations c
JOIN patients p ON c.patient_id = p.patient_id
WHERE c.amount > (SELECT AVG(amount) FROM consultations);

-- Q25. List allergic patients who received a prescription
SELECT DISTINCT CONCAT(p.last_name, ' ', p.first_name) AS patient_name, p.allergies, COUNT(pr.prescription_id) AS prescription_count
FROM patients p
JOIN consultations c ON p.patient_id = c.patient_id
JOIN prescriptions pr ON c.consultation_id = pr.consultation_id
WHERE p.allergies IS NOT NULL AND p.allergies != ''
GROUP BY p.patient_id;

-- ========== PART 6: BUSINESS ANALYSIS (Q26-Q30) ==========

-- Q26. Calculate total revenue per doctor (paid consultations only)
SELECT CONCAT(d.last_name, ' ', d.first_name) AS doctor_name, COUNT(c.consultation_id) AS total_consultations, SUM(c.amount) AS total_revenue
FROM doctors d
JOIN consultations c ON d.doctor_id = c.doctor_id
WHERE c.paid = TRUE
GROUP BY d.doctor_id;

-- Q27. Display top 3 most profitable specialties
SELECT DENSE_RANK() OVER (ORDER BY SUM(c.amount) DESC) AS rank_pos, s.specialty_name, SUM(c.amount) AS total_revenue
FROM specialties s
JOIN doctors d ON s.specialty_id = d.specialty_id
JOIN consultations c ON d.doctor_id = c.doctor_id
GROUP BY s.specialty_id
LIMIT 3;

-- Q28. List medications to restock (stock < minimum)
SELECT commercial_name AS medication_name, available_stock AS current_stock, minimum_stock, (minimum_stock - available_stock) AS quantity_needed
FROM medications
WHERE available_stock < minimum_stock;

-- Q29. Calculate average number of medications per prescription
SELECT AVG(med_count) AS average_medications_per_prescription
FROM (
    SELECT prescription_id, COUNT(medication_id) AS med_count
    FROM prescription_details
    GROUP BY prescription_id
) AS sub;

-- Q30. Generate patient demographics report by age group
SELECT 
    CASE 
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURRENT_DATE) BETWEEN 0 AND 18 THEN '0-18'
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURRENT_DATE) BETWEEN 19 AND 40 THEN '19-40'
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURRENT_DATE) BETWEEN 41 AND 60 THEN '41-60'
        ELSE '60+' 
    END AS age_group,
    COUNT(*) AS patient_count,
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM patients) AS percentage
FROM patients
GROUP BY age_group;
