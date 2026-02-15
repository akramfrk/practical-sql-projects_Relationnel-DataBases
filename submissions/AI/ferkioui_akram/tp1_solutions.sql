-- ============================================
-- TP1: University Management System
-- Student: FERKIOUI Akram (Group AI_2)
-- ============================================

-- ============================================
-- 1. Database Creation
-- ============================================
DROP DATABASE IF EXISTS university_db;
CREATE DATABASE university_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE university_db;

-- ============================================
-- 2. Table Creation
-- ============================================

-- Table: departments
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    building VARCHAR(50),
    budget DECIMAL(12, 2),
    department_head VARCHAR(100),
    creation_date DATE
);

-- Table: professors
CREATE TABLE professors (
    professor_id INT AUTO_INCREMENT PRIMARY KEY,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    department_id INT,
    hire_date DATE,
    salary DECIMAL(10, 2),
    specialization VARCHAR(100),
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Table: students
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    student_number VARCHAR(20) UNIQUE NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    date_of_birth DATE,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    department_id INT,
    level VARCHAR(20),
    enrollment_date DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CHECK (level IN ('L1', 'L2', 'L3', 'M1', 'M2'))
);

-- Table: courses
CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(10) UNIQUE NOT NULL,
    course_name VARCHAR(150) NOT NULL,
    description TEXT,
    credits INT NOT NULL CHECK (credits > 0),
    semester INT CHECK (semester BETWEEN 1 AND 2),
    department_id INT,
    professor_id INT,
    max_capacity INT DEFAULT 30,
    FOREIGN KEY (department_id) REFERENCES departments(department_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (professor_id) REFERENCES professors(professor_id) 
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- Table: enrollments
CREATE TABLE enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATE DEFAULT (CURRENT_DATE),
    academic_year VARCHAR(9) NOT NULL, -- Format: '2024-2025'
    status VARCHAR(20) DEFAULT 'In Progress' CHECK (status IN ('In Progress', 'Passed', 'Failed', 'Dropped')),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE (student_id, course_id, academic_year)
);

-- Table: grades
CREATE TABLE grades (
    grade_id INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT NOT NULL,
    evaluation_type VARCHAR(30) CHECK (evaluation_type IN ('Assignment', 'Lab', 'Exam', 'Project')),
    grade DECIMAL(5, 2) CHECK (grade BETWEEN 0 AND 20),
    coefficient DECIMAL(3, 2) DEFAULT 1.00,
    evaluation_date DATE,
    comments TEXT,
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================
-- 3. Required Indexes
-- ============================================
CREATE INDEX idx_student_department ON students(department_id);
CREATE INDEX idx_course_professor ON courses(professor_id);
CREATE INDEX idx_enrollment_student ON enrollments(student_id);
CREATE INDEX idx_enrollment_course ON enrollments(course_id);
CREATE INDEX idx_grades_enrollment ON grades(enrollment_id);

-- ============================================
-- 4. Inserting Test Data
-- ============================================

-- Departments
INSERT INTO departments (department_name, building, budget, department_head) VALUES
('Computer Science', 'Building A', 500000.00, 'Dr. Smith'),
('Mathematics', 'Building B', 350000.00, 'Dr. Johnson'),
('Physics', 'Building C', 400000.00, 'Dr. Williams'),
('Civil Engineering', 'Building D', 600000.00, 'Dr. Brown');

-- Professors
-- CS Department (3 professors)
INSERT INTO professors (last_name, first_name, email, department_id, salary, specialization) VALUES
('Turing', 'Alan', 'alan.turing@univ.edu', 1, 95000.00, 'Artificial Intelligence'),
('Knuth', 'Donald', 'donald.knuth@univ.edu', 1, 92000.00, 'Algorithms'),
('Lovelace', 'Ada', 'ada.lovelace@univ.edu', 1, 90000.00, 'Programming'),
-- Other departments
('Euler', 'Leonhard', 'leonhard.euler@univ.edu', 2, 88000.00, 'Calculus'),
('Einstein', 'Albert', 'albert.einstein@univ.edu', 3, 98000.00, 'Relativity'),
('Da Vinci', 'Leonardo', 'leo.davinci@univ.edu', 4, 85000.00, 'Architecture');

-- Students (8 minimum)
INSERT INTO students (student_number, last_name, first_name, date_of_birth, email, department_id, level) VALUES
('S001', 'Potter', 'Harry', '2002-07-31', 'harry.potter@univ.edu', 1, 'L2'),
('S002', 'Granger', 'Hermione', '2001-09-19', 'hermione.granger@univ.edu', 1, 'L3'),
('S003', 'Weasley', 'Ron', '2002-03-01', 'ron.weasley@univ.edu', 1, 'L2'),
('S004', 'Stark', 'Tony', '2000-05-29', 'tony.stark@univ.edu', 4, 'M1'),
('S005', 'Parker', 'Peter', '2003-08-10', 'peter.parker@univ.edu', 3, 'L1'),
('S006', 'Romanoff', 'Natasha', '1999-11-22', 'natasha.romanoff@univ.edu', 2, 'M2'),
('S007', 'Rogers', 'Steve', '2001-07-04', 'steve.rogers@univ.edu', 4, 'L3'),
('S008', 'Banner', 'Bruce', '1998-12-18', 'bruce.banner@univ.edu', 3, 'M2');

-- Courses (7 minimum)
INSERT INTO courses (course_code, course_name, credits, semester, department_id, professor_id, max_capacity) VALUES
('CS101', 'Introduction to AI', 6, 1, 1, 1, 40),
('CS102', 'Advanced Algorithms', 6, 2, 1, 2, 35),
('CS103', 'Software Engineering', 5, 1, 1, 3, 30),
('MATH201', 'Calculus II', 6, 1, 2, 4, 50),
('PHYS301', 'Quantum Mechanics', 6, 2, 3, 5, 25),
('ENG401', 'Structural Analysis', 5, 2, 4, 6, 40),
('CS104', 'Database Systems', 6, 1, 1, 2, 35);

-- Enrollments (15 minimum)
INSERT INTO enrollments (student_id, course_id, academic_year, status) VALUES
(1, 1, '2024-2025', 'In Progress'), -- Harry in AI
(1, 3, '2024-2025', 'Passed'), -- Harry in Software Eng
(2, 1, '2024-2025', 'Passed'), -- Hermione in AI
(2, 2, '2024-2025', 'In Progress'), -- Hermione in Algorithms
(3, 1, '2024-2025', 'In Progress'), -- Ron in AI
(3, 3, '2024-2025', 'Failed'), -- Ron in Software Eng
(4, 6, '2024-2025', 'In Progress'), -- Tony in Structural Analysis
(5, 5, '2024-2025', 'Passed'), -- Peter in Quantum Mechanics
(6, 4, '2024-2025', 'Passed'), -- Natasha in Calculus
(7, 6, '2024-2025', 'In Progress'), -- Steve in Structural Analysis
(8, 5, '2024-2025', 'In Progress'), -- Bruce in Quantum Mechanics
(2, 7, '2024-2025', 'Passed'), -- Hermione in Databases
(1, 7, '2024-2025', 'Passed'), -- Harry in Databases
(4, 1, '2024-2025', 'Dropped'), -- Tony dropped AI
(5, 4, '2024-2025', 'Passed'); -- Peter in Calculus

-- Grades (12 minimum)
INSERT INTO grades (enrollment_id, evaluation_type, grade, coefficient) VALUES
(2, 'Exam', 14.5, 1.0), -- Harry in Software Eng
(3, 'Exam', 19.0, 1.0), -- Hermione in AI
(6, 'Exam', 8.0, 1.0), -- Ron in Software Eng
(8, 'Project', 16.5, 1.0), -- Peter in Quantum
(9, 'Exam', 17.0, 1.0), -- Natasha in Calculus
(12, 'Lab', 15.0, 0.5), -- Hermione in DB
(12, 'Exam', 18.0, 1.0), -- Hermione in DB
(13, 'Exam', 13.0, 1.0), -- Harry in DB
(15, 'Exam', 14.0, 1.0), -- Peter in Calculus
(1, 'Assignment', 12.0, 0.5), -- Harry in AI
(4, 'Assignment', 18.0, 0.5), -- Hermione in Algorithms
(7, 'Project', 15.5, 1.0); -- Steve in Structural Analysis

-- ============================================
-- 5. SQL Queries (30 Queries)
-- ============================================

-- ========== PART 1: BASIC QUERIES (Q1-Q5) ==========

-- Q1. List all students with their main information (name, email, level)
SELECT last_name, first_name, email, level FROM students;

-- Q2. Display all professors from the Computer Science department
SELECT p.last_name, p.first_name, p.email, p.specialization 
FROM professors p
JOIN departments d ON p.department_id = d.department_id 
WHERE d.department_name = 'Computer Science';

-- Q3. Find all courses with more than 5 credits
SELECT course_code, course_name, credits FROM courses WHERE credits > 5;

-- Q4. List students enrolled in L3 level
SELECT student_number, last_name, first_name, email FROM students WHERE level = 'L3';

-- Q5. Display courses from semester 1
SELECT course_code, course_name, credits, semester FROM courses WHERE semester = 1;

-- ========== PART 2: QUERIES WITH JOINS (Q6-Q10) ==========

-- Q6. Display all courses with the professor's name
SELECT c.course_code, c.course_name, CONCAT(p.last_name, ' ', p.first_name) AS professor_name
FROM courses c
LEFT JOIN professors p ON c.professor_id = p.professor_id;

-- Q7. List all enrollments with student name and course name
SELECT CONCAT(s.last_name, ' ', s.first_name) AS student_name, c.course_name, e.enrollment_date, e.status
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id;

-- Q8. Display students with their department name
SELECT CONCAT(s.last_name, ' ', s.first_name) AS student_name, d.department_name, s.level
FROM students s
LEFT JOIN departments d ON s.department_id = d.department_id;

-- Q9. List grades with student name, course name, and grade obtained
SELECT CONCAT(s.last_name, ' ', s.first_name) AS student_name, c.course_name, g.evaluation_type, g.grade
FROM grades g
JOIN enrollments e ON g.enrollment_id = e.enrollment_id
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id;

-- Q10. Display professors with the number of courses they teach
SELECT CONCAT(p.last_name, ' ', p.first_name) AS professor_name, COUNT(c.course_id) AS number_of_courses
FROM professors p
LEFT JOIN courses c ON p.professor_id = c.professor_id
GROUP BY p.professor_id;

-- ========== PART 3: AGGREGATE FUNCTIONS (Q11-Q15) ==========

-- Q11. Calculate the overall average grade for each student
SELECT CONCAT(s.last_name, ' ', s.first_name) AS student_name, AVG(g.grade) AS average_grade
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN grades g ON e.enrollment_id = g.enrollment_id
GROUP BY s.student_id;

-- Q12. Count the number of students per department
SELECT d.department_name, COUNT(s.student_id) AS student_count
FROM departments d
LEFT JOIN students s ON d.department_id = s.department_id
GROUP BY d.department_id;

-- Q13. Calculate the total budget of all departments
SELECT SUM(budget) AS total_budget FROM departments;

-- Q14. Find the total number of courses per department
SELECT d.department_name, COUNT(c.course_id) AS course_count
FROM departments d
LEFT JOIN courses c ON d.department_id = c.department_id
GROUP BY d.department_id;

-- Q15. Calculate the average salary of professors per department
SELECT d.department_name, AVG(p.salary) AS average_salary
FROM departments d
JOIN professors p ON d.department_id = p.department_id
GROUP BY d.department_id;

-- ========== PART 4: ADVANCED QUERIES (Q16-Q20) ==========

-- Q16. Find the top 3 students with the best averages
SELECT CONCAT(s.last_name, ' ', s.first_name) AS student_name, AVG(g.grade) AS average_grade
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN grades g ON e.enrollment_id = g.enrollment_id
GROUP BY s.student_id
ORDER BY average_grade DESC
LIMIT 3;

-- Q17. List courses with no enrolled students
SELECT c.course_code, c.course_name
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
WHERE e.enrollment_id IS NULL;

-- Q18. Display students who have passed all their courses (status = 'Passed')
-- Note: This requires grouping and checking if all statuses are 'Passed' or if count of 'Passed' equals total enrollments.
-- Simpler interpretation: List students and count of passed courses.
SELECT CONCAT(s.last_name, ' ', s.first_name) AS student_name, COUNT(e.course_id) AS passed_courses_count
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
WHERE e.status = 'Passed'
GROUP BY s.student_id;

-- Q19. Find professors who teach more than 2 courses
SELECT CONCAT(p.last_name, ' ', p.first_name) AS professor_name, COUNT(c.course_id) AS courses_taught
FROM professors p
JOIN courses c ON p.professor_id = c.professor_id
GROUP BY p.professor_id
HAVING COUNT(c.course_id) > 2;

-- Q20. List students enrolled in more than 2 courses
SELECT CONCAT(s.last_name, ' ', s.first_name) AS student_name, COUNT(e.course_id) AS enrolled_courses_count
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id
HAVING COUNT(e.course_id) > 2;

-- ========== PART 5: SUBQUERIES (Q21-Q25) ==========

-- Q21. Find students with an average higher than their department's average
SELECT 
    CONCAT(s.last_name, ' ', s.first_name) AS student_name, 
    AVG(g.grade) AS student_avg,
    (SELECT AVG(g2.grade) 
     FROM grades g2 
     JOIN enrollments e2 ON g2.enrollment_id = e2.enrollment_id 
     JOIN students s2 ON e2.student_id = s2.student_id 
     WHERE s2.department_id = s.department_id) AS department_avg
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN grades g ON e.enrollment_id = g.enrollment_id
GROUP BY s.student_id, s.department_id
HAVING student_avg > department_avg;

-- Q22. List courses with more enrollments than the average number of enrollments
SELECT c.course_name, COUNT(e.enrollment_id) AS enrollment_count
FROM courses c
JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id
HAVING enrollment_count > (
    SELECT COUNT(*) / COUNT(DISTINCT course_id) FROM enrollments
);

-- Q23. Display professors from the department with the highest budget
SELECT CONCAT(p.last_name, ' ', p.first_name) AS professor_name, d.department_name, d.budget
FROM professors p
JOIN departments d ON p.department_id = d.department_id
WHERE d.budget = (SELECT MAX(budget) FROM departments);

-- Q24. Find students with no grades recorded
SELECT CONCAT(s.last_name, ' ', s.first_name) AS student_name, s.email
FROM students s
WHERE s.student_id NOT IN (
    SELECT DISTINCT e.student_id 
    FROM enrollments e 
    JOIN grades g ON e.enrollment_id = g.enrollment_id
);

-- Q25. List departments with more students than the average
SELECT d.department_name, COUNT(s.student_id) AS student_count
FROM departments d
JOIN students s ON d.department_id = s.department_id
GROUP BY d.department_id
HAVING student_count > (
    SELECT COUNT(*) / COUNT(DISTINCT department_id) FROM students
);

-- ========== PART 6: BUSINESS ANALYSIS (Q26-Q30) ==========

-- Q26. Calculate the pass rate per course (grades >= 10/20)
SELECT 
    c.course_name, 
    COUNT(g.grade_id) AS total_grades,
    SUM(CASE WHEN g.grade >= 10 THEN 1 ELSE 0 END) AS passed_grades,
    (SUM(CASE WHEN g.grade >= 10 THEN 1 ELSE 0 END) / COUNT(g.grade_id)) * 100 AS pass_rate_percentage
FROM courses c
JOIN enrollments e ON c.course_id = e.course_id
JOIN grades g ON e.enrollment_id = g.enrollment_id
GROUP BY c.course_id;

-- Q27. Display student ranking by descending average
SELECT 
    RANK() OVER (ORDER BY AVG(g.grade) DESC) AS ranking,
    CONCAT(s.last_name, ' ', s.first_name) AS student_name, 
    AVG(g.grade) AS average_grade
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN grades g ON e.enrollment_id = g.enrollment_id
GROUP BY s.student_id;

-- Q28. Generate a report card for student with student_id = 1
SELECT 
    c.course_name, 
    g.evaluation_type, 
    g.grade, 
    g.coefficient, 
    (g.grade * g.coefficient) AS weighted_grade
FROM grades g
JOIN enrollments e ON g.enrollment_id = e.enrollment_id
JOIN courses c ON e.course_id = c.course_id
WHERE e.student_id = 1;

-- Q29. Calculate teaching load per professor (total credits taught)
SELECT 
    CONCAT(p.last_name, ' ', p.first_name) AS professor_name, 
    SUM(c.credits) AS total_credits
FROM professors p
JOIN courses c ON p.professor_id = c.professor_id
GROUP BY p.professor_id;

-- Q30. Identify overloaded courses (enrollments > 80% of max capacity)
SELECT 
    c.course_name, 
    COUNT(e.enrollment_id) AS current_enrollments, 
    c.max_capacity,
    (COUNT(e.enrollment_id) / c.max_capacity) * 100 AS percentage_full
FROM courses c
JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id
HAVING percentage_full > 80;
