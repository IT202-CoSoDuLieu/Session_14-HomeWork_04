DROP DATABASE IF EXISTS RikkeiClinicDB;
CREATE DATABASE RikkeiClinicDB;
USE RikkeiClinicDB;

-- =========================================================
-- PHẦN 1: KHỞI TẠO CẤU TRÚC DATABASE
-- =========================================================

-- 1. Bảng Bệnh nhân
CREATE TABLE Patients (
    patient_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    date_of_birth DATE
);

-- 2. Bảng Nhân viên / Bác sĩ
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    position VARCHAR(50) NOT NULL,
    salary DECIMAL(18,2) NOT NULL
);

-- 3. Bảng Khoa
CREATE TABLE Departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL
);

-- 4. Bảng Giường bệnh
CREATE TABLE Beds (
    bed_id INT PRIMARY KEY,
    dept_id INT NOT NULL,
    patient_id INT DEFAULT NULL,
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);

-- 5. Bảng Lịch khám
CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Employees(employee_id)
);

-- 6. Bảng Kho vật tư
CREATE TABLE Inventory (
    item_id INT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0
);

-- 7. Bảng Thuốc
CREATE TABLE Medicines (
    medicine_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(18,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0
);

-- 8. Bảng Công nợ bệnh nhân
CREATE TABLE Patient_Invoices (
    patient_id INT PRIMARY KEY,
    total_due DECIMAL(18,2) NOT NULL DEFAULT 0,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);

-- 9. Bảng Sản phẩm
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    price DECIMAL(18,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0
);

-- 10. Bảng Dịch vụ
CREATE TABLE Services (
    service_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(18,2) NOT NULL
);

-- 11. Bảng Ví điện tử
CREATE TABLE Wallets (
    patient_id INT PRIMARY KEY,
    balance DECIMAL(18,2) NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'Active',
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);

-- 12. Bảng Lịch sử sử dụng dịch vụ
CREATE TABLE Service_Usages (
    usage_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    service_id INT NOT NULL,
    actual_price DECIMAL(18,2) DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (service_id) REFERENCES Services(service_id)
);

-- =========================================================
-- PHẦN 2: CHÈN DỮ LIỆU MẪU
-- =========================================================

-- Bệnh nhân
INSERT INTO Patients VALUES
(1, 'Nguyen Van An', '0901111222', '1990-05-15'),
(2, 'Tran Thi Binh', '0912222333', '1985-08-20'),
(3, 'Le Hoang Cuong', '0923333444', '2000-12-01');

-- Nhân viên
INSERT INTO Employees VALUES
(101, 'Dr. Hoang Minh', 'Doctor', 20000),
(102, 'Dr. Lan Anh', 'Doctor', 25000),
(103, 'Nurse Thu Ha', 'Nurse', 12000);

-- Khoa
INSERT INTO Departments VALUES
(1, 'Khoa Ngoai'),
(2, 'Khoa Noi'),
(3, 'Khoa ICU');

-- Giường bệnh
INSERT INTO Beds VALUES
(101, 1, 1),
(201, 2, NULL),
(301, 3, 2);

-- Lịch khám
INSERT INTO Appointments VALUES
(104, 1, 101, '2026-06-10 08:30:00', 'Pending'),
(105, 2, 102, '2026-05-01 09:00:00', 'Completed'),
(106, 3, 101, '2026-05-02 10:00:00', 'Cancelled');

-- Vật tư
INSERT INTO Inventory VALUES
(10, 'Khau trang y te N95', 1000),
(11, 'Gang tay vo trung', 500),
(12, 'Dung dich sat khuan', 200);

-- Thuốc
INSERT INTO Medicines VALUES
(1, 'Amoxicillin 500mg', 15000, 100),
(2, 'Panadol Extra', 5000, 5);

-- Công nợ bệnh nhân
INSERT INTO Patient_Invoices(patient_id, total_due) VALUES
(1, 1500000),
(2, 100000),
(3, 0);

-- Sản phẩm
INSERT INTO Products(name, price, stock) VALUES
('May do huyet ap Omron', 850000, 20),
('May do duong huyet', 450000, 15);

-- Dịch vụ
INSERT INTO Services VALUES
(1, 'Sieu am o bung', 200000),
(2, 'Xet nghiem mau', 150000),
(3, 'Chup X-Quang', 250000);

-- Ví điện tử
INSERT INTO Wallets VALUES
(1, 500000, 'Active'),
(2, 50000, 'Active'),
(3, 1000000, 'Inactive');

-- =========================================================
-- PHẦN 3: PHÂN TÍCH GIẢI PHÁP
-- =========================================================

/*

===========================
1. ĐỊNH NGHĨA INPUT / OUTPUT
===========================

Đầu vào:
- p_patient_id INT
  -> Mã bệnh nhân thực hiện thanh toán.

- p_amount DECIMAL(18,2)
  -> Số tiền cần thanh toán.

Đầu ra:
- p_status_message VARCHAR(255)
  -> Thông báo trạng thái giao dịch.


===========================
2. ĐỀ XUẤT GIẢI PHÁP
===========================

CHIẾN LƯỢC 1:
- Thực hiện UPDATE trực tiếp.
- Chỉ dựa vào Exception của DBMS để rollback.

Ưu điểm:
- Code ngắn.
- Triển khai nhanh.

Nhược điểm:
- Không kiểm tra trước dữ liệu.
- Dễ phát sinh lỗi nghiệp vụ.
- Thông báo lỗi khó hiểu.


CHIẾN LƯỢC 2:
- Kiểm tra dữ liệu trước khi UPDATE.
- Dùng TRANSACTION + COMMIT + ROLLBACK.
- Chủ động rollback nếu vi phạm điều kiện.

Ưu điểm:
- An toàn dữ liệu.
- Tránh ví âm tiền.
- Đúng nguyên tắc ACID.
- Dễ kiểm soát nghiệp vụ.

Nhược điểm:
- Code dài hơn.
- Thiết kế phức tạp hơn.


===========================
3. LỰA CHỌN GIẢI PHÁP
===========================

Chọn CHIẾN LƯỢC 2 vì:
- Đảm bảo tính toàn vẹn dữ liệu.
- Không thất thoát tiền.
- Phù hợp hệ thống thanh toán thực tế.

*/

-- =========================================================
-- PHẦN 4: THIẾT KẾ LUỒNG XỬ LÝ
-- =========================================================

/*

BƯỚC 1:
Kiểm tra số tiền thanh toán phải > 0.

BƯỚC 2:
START TRANSACTION.

BƯỚC 3:
Đọc và khóa dữ liệu ví bằng FOR UPDATE.

BƯỚC 4:
Kiểm tra:
- Ví tồn tại.
- Ví Active.
- Số dư đủ.

BƯỚC 5:
Đọc và khóa dữ liệu công nợ.

BƯỚC 6:
Kiểm tra:
- Công nợ tồn tại.
- Không thanh toán vượt công nợ.

BƯỚC 7:
Cập nhật:
- Trừ tiền ví.
- Giảm công nợ.

BƯỚC 8:
COMMIT transaction.

BƯỚC 9:
Nếu lỗi hệ thống:
ROLLBACK toàn bộ dữ liệu.

*/

-- =========================================================
-- PHẦN 5: TRIỂN KHAI PROCEDURE
-- =========================================================

DROP PROCEDURE IF EXISTS ProcessPayment;

DELIMITER //

CREATE PROCEDURE ProcessPayment(
    IN p_patient_id INT,
    IN p_amount DECIMAL(18,2),
    OUT p_status_message VARCHAR(255)
)

proc_main: BEGIN

    DECLARE v_balance DECIMAL(18,2);
    DECLARE v_status VARCHAR(20);
    DECLARE v_total_due DECIMAL(18,2);

    -- =====================================================
    -- HANDLER: rollback nếu có lỗi hệ thống
    -- =====================================================

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;

        SET p_status_message =
        'Lỗi hệ thống: Giao dịch đã được hoàn tác.';
    END;

    -- =====================================================
    -- KIỂM TRA DỮ LIỆU ĐẦU VÀO
    -- =====================================================

    IF p_amount <= 0 THEN

        SET p_status_message =
        'Lỗi: Số tiền thanh toán phải lớn hơn 0.';

        LEAVE proc_main;

    END IF;

    -- =====================================================
    -- BẮT ĐẦU TRANSACTION
    -- =====================================================

    START TRANSACTION;

    -- =====================================================
    -- KHÓA DỮ LIỆU VÍ
    -- =====================================================

    SELECT balance, status
    INTO v_balance, v_status
    FROM Wallets
    WHERE patient_id = p_patient_id
    FOR UPDATE;

    -- =====================================================
    -- KIỂM TRA VÍ
    -- =====================================================

    IF v_balance IS NULL THEN

        ROLLBACK;

        SET p_status_message =
        'Lỗi: Không tìm thấy ví điện tử.';

        LEAVE proc_main;

    END IF;

    IF v_status <> 'Active' THEN

        ROLLBACK;

        SET p_status_message =
        'Lỗi: Ví điện tử đang bị khóa.';

        LEAVE proc_main;

    END IF;

    IF v_balance < p_amount THEN

        ROLLBACK;

        SET p_status_message =
        'Lỗi: Số dư ví không đủ để thanh toán.';

        LEAVE proc_main;

    END IF;

    -- =====================================================
    -- KHÓA DỮ LIỆU CÔNG NỢ
    -- =====================================================

    SELECT total_due
    INTO v_total_due
    FROM Patient_Invoices
    WHERE patient_id = p_patient_id
    FOR UPDATE;

    -- =====================================================
    -- KIỂM TRA CÔNG NỢ
    -- =====================================================

    IF v_total_due IS NULL THEN

        ROLLBACK;

        SET p_status_message =
        'Lỗi: Không tìm thấy công nợ bệnh nhân.';

        LEAVE proc_main;

    END IF;

    IF p_amount > v_total_due THEN

        ROLLBACK;

        SET p_status_message =
        'Lỗi: Số tiền thanh toán vượt quá công nợ hiện tại.';

        LEAVE proc_main;

    END IF;

    -- =====================================================
    -- THỰC HIỆN THANH TOÁN
    -- =====================================================

    UPDATE Wallets
    SET balance = balance - p_amount
    WHERE patient_id = p_patient_id;

    UPDATE Patient_Invoices
    SET total_due = total_due - p_amount,
        last_updated = CURRENT_TIMESTAMP
    WHERE patient_id = p_patient_id;

    -- =====================================================
    -- COMMIT GIAO DỊCH
    -- =====================================================

    COMMIT;

    SET p_status_message =
    'Thanh toán thành công.';

END //

DELIMITER ;

-- =========================================================
-- PHẦN 6: KIỂM THỬ HỆ THỐNG
-- =========================================================

-- =====================================================
-- TEST 1: GIAO DỊCH HỢP LỆ
-- =====================================================

CALL ProcessPayment(1, 200000, @msg);

SELECT @msg AS 'Ket qua';

SELECT * FROM Wallets
WHERE patient_id = 1;

SELECT * FROM Patient_Invoices
WHERE patient_id = 1;

-- Kỳ vọng:
-- Wallet: 500000 -> 300000
-- total_due: 1500000 -> 1300000


-- =====================================================
-- TEST 2: KHÔNG ĐỦ TIỀN
-- =====================================================

CALL ProcessPayment(2, 400000, @msg);

SELECT @msg AS 'Ket qua';

SELECT * FROM Wallets
WHERE patient_id = 2;

-- Kỳ vọng:
-- Báo lỗi không đủ tiền
-- Wallet vẫn giữ nguyên 50000


-- =====================================================
-- TEST 3: SỐ TIỀN ÂM
-- =====================================================

CALL ProcessPayment(1, -50000, @msg);

SELECT @msg AS 'Ket qua';

-- Kỳ vọng:
-- Báo lỗi số tiền phải > 0


-- =====================================================
-- TEST 4: VÍ BỊ KHÓA
-- =====================================================

CALL ProcessPayment(3, 50000, @msg);

SELECT @msg AS 'Ket qua';

-- Kỳ vọng:
-- Báo lỗi ví bị khóa


-- =====================================================
-- TEST 5: THANH TOÁN VƯỢT CÔNG NỢ
-- =====================================================

CALL ProcessPayment(2, 200000, @msg);

SELECT @msg AS 'Ket qua';

-- Kỳ vọng:
-- Báo lỗi vượt công nợ