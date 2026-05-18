DROP DATABASE IF EXISTS RikkeiClinicDB;
CREATE DATABASE RikkeiClinicDB;
USE RikkeiClinicDB;

-- PHẦN 1: KHỞI TẠO CẤU TRÚC BẢNG 

-- 1. Bảng Bệnh nhân (Patients)
CREATE TABLE Patients (
    patient_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    date_of_birth DATE
);

-- 2. Bảng Nhân sự / Bác sĩ (Employees)
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    position VARCHAR(50) NOT NULL,
    salary DECIMAL(18,2) NOT NULL
);

-- 3. Bảng Khoa (Departments)
CREATE TABLE Departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL
);

-- 4. Bảng Giường bệnh (Beds)
CREATE TABLE Beds (
    bed_id INT PRIMARY KEY,
    dept_id INT NOT NULL,
    patient_id INT DEFAULT NULL, -- NULL nghĩa là giường trống
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);

-- 5. Bảng Lịch khám (Appointments)
CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending', -- 'Pending', 'Completed', 'Cancelled'
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Employees(employee_id)
);

-- 6. Bảng Kho Vật tư Y tế (Inventory)
CREATE TABLE Inventory (
    item_id INT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0
);

-- 7. Bảng Kho Thuốc (Medicines)
CREATE TABLE Medicines (
    medicine_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(18,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0
);

-- 8. Bảng Công nợ Bệnh nhân (Patient_Invoices)
CREATE TABLE Patient_Invoices (
    patient_id INT PRIMARY KEY,
    total_due DECIMAL(18,2) NOT NULL DEFAULT 0,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);

-- 9. Bảng Sản phẩm (Products)
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    price DECIMAL(18,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0
);

-- 10. Bảng Dịch vụ khám (Services) 
CREATE TABLE Services (
    service_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(18,2) NOT NULL
);

-- 11. Bảng Ví điện tử (Wallets) 
CREATE TABLE Wallets (
    patient_id INT PRIMARY KEY,
    balance DECIMAL(18,2) NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'Active', -- 'Active', 'Inactive'
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);

-- 12. Bảng Lịch sử sử dụng dịch vụ (Service_Usages) 
CREATE TABLE Service_Usages (
    usage_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    service_id INT NOT NULL,
    actual_price DECIMAL(18,2) DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (service_id) REFERENCES Services(service_id)
);

-- PHẦN 2: CHÈN DỮ LIỆU MẪU (TEST CASES)
-- Chèn Bệnh nhân
INSERT INTO Patients (patient_id, full_name, phone, date_of_birth) VALUES
(1, 'Nguyen Van An', '0901111222', '1990-05-15'),
(2, 'Tran Thi Binh', '0912222333', '1985-08-20'),
(3, 'Le Hoang Cuong', '0923333444', '2000-12-01');

-- Chèn Nhân sự 
INSERT INTO Employees (employee_id, full_name, position, salary) VALUES
(101, 'Dr. Hoang Minh', 'Doctor', 20000.00),
(102, 'Dr. Lan Anh', 'Doctor', 25000.00),
(103, 'Nurse Thu Ha', 'Nurse', 12000.00);

-- Chèn Khoa
INSERT INTO Departments (dept_id, dept_name) VALUES
(1, 'Khoa Ngoai'),
(2, 'Khoa Noi'),
(3, 'Khoa ICU');

-- Chèn Giường bệnh
INSERT INTO Beds (bed_id, dept_id, patient_id) VALUES
(101, 1, 1),    -- Bệnh nhân 1 đang nằm giường 101 Khoa Ngoại
(201, 2, NULL), -- Giường 201 Khoa Nội đang trống
(301, 3, 2);    -- Bệnh nhân 2 đang nằm ICU

-- Chèn Lịch khám 
INSERT INTO Appointments (appointment_id, patient_id, doctor_id, appointment_date, status) VALUES
(104, 1, 101, '2026-06-10 08:30:00', 'Pending'),
(105, 2, 102, '2026-05-01 09:00:00', 'Completed'),
(106, 3, 101, '2026-05-02 10:00:00', 'Cancelled');

-- Chèn Vật tư 
INSERT INTO Inventory (item_id, item_name, stock_quantity) VALUES
(10, 'Khau trang y te N95', 1000),
(11, 'Gang tay vo trung', 500),
(12, 'Dung dich sat khuan', 200);

-- Chèn Thuốc
INSERT INTO Medicines (medicine_id, name, price, stock) VALUES
(1, 'Amoxicillin 500mg', 15000, 100),  -- Tồn kho nhiều
(2, 'Panadol Extra', 5000, 5);         -- Tồn kho ít

-- Chèn Công nợ Bệnh nhân
INSERT INTO Patient_Invoices (patient_id, total_due) VALUES
(1, 1500000.00), -- Đã sửa: Nợ 1.5tr để test bài Giải phóng giường bệnh
(2, 0),
(3, 0);

-- Chèn Sản phẩm E-commerce 
INSERT INTO Products (name, price, stock) VALUES
('May do huyet ap Omron', 850000.00, 20),
('May do duong huyet', 450000.00, 15);

-- Chèn Dịch vụ
INSERT INTO Services (service_id, name, price) VALUES
(1, 'Sieu am o bung', 200000.00),
(2, 'Xet nghiem mau', 150000.00),
(3, 'Chup X-Quang', 250000.00);

-- Chèn Ví điện tử
INSERT INTO Wallets (patient_id, balance, status) VALUES
(1, 500000.00, 'Active'),    -- Test Case 1: Đủ tiền thanh toán
(2, 50000.00, 'Active'),     -- Test Case 3: Cháy ví (Chỉ có 50k, không đủ khám 200k)
(3, 1000000.00, 'Inactive'); -- Test Case 2: Nhiều tiền nhưng thẻ bị khóa

-- Phân tích - Giải pháp

-- 1. Định nghĩa I/O (Input/Output)
-- Để module thanh toán hoạt động linh hoạt và có khả năng tương tác trực tiếp với giao diện người dùng, cấu trúc tham số được xác định như sau:
-- Tham số đầu vào (IN):
-- p_patient_id (INT): Mã định danh bệnh nhân thực hiện thanh toán viện phí.
-- p_amount (DECIMAL(18,2)): Số tiền cần trừ trong ví để thanh toán.
-- Tham số đầu ra (OUT):
-- p_status_message (VARCHAR(255)): Chuỗi thông báo kết quả trả về ứng dụng (ví dụ: thông báo thành công hoặc chi tiết các lỗi nghiệp vụ).

-- 2. Đề xuất chiến lược xử lý
-- Để giải quyết triệt để 2 tình huống lỗi (sự cố mạng giữa chừng và ví bị âm tiền), chúng ta có 2 hướng tiếp cận:

-- Chiến lược 1 - Bẫy ngoại lệ (Exception-driven): Cho hệ thống thực thi lệnh UPDATE ngay lập tức, sau đó dựa vào các ràng buộc dữ liệu 
-- (CHECK constraint) của cơ sở dữ liệu để tự động ném ra ngoại lệ và kích hoạt ROLLBACK nếu số dư bị âm. 
-- Tuy nhiên, cách này phụ thuộc vào cấu hình DB và thông báo trả về thường thô cứng, khó tùy biến cho người dùng.

-- Chiến lược 2 - Kiểm tra trước (Look-before-you-leap): Chủ động dùng lệnh SELECT...INTO để truy vấn số dư và trạng thái ví của bệnh nhân trước.
--  Sử dụng các câu lệnh điều kiện IF để kiểm tra logic nghiệp vụ. Nếu phát hiện vi phạm quy tắc (số tiền âm, ví bị khóa, hoặc không đủ tiền), 
--  hệ thống sẽ chủ động ngắt tiến trình ngay lập tức và trả về thông báo lỗi rõ ràng.

-- Phần B

-- Thiết kế
-- 1. Thiết kế luồng xử lý (Logic Flow)
-- BƯỚC 1 (Khởi tạo bảo vệ): Đăng ký một EXIT HANDLER FOR SQLEXCEPTION nhằm đảm bảo hệ thống tự động hoàn tác (ROLLBACK) 
-- nếu phát sinh sự cố phần cứng hoặc rớt mạng bất ngờ.
-- BƯỚC 2 (Chặn lỗi dữ liệu đầu vào): Kiểm tra nếu số tiền thanh toán nhỏ hơn hoặc bằng 0 (p_amount<=0), 
-- lập tức dừng lại và báo lỗi.
-- BƯỚC 3 (Kiểm tra trạng thái & Số dư): Truy vấn dữ liệu ví của bệnh nhân để kiểm tra hai điều kiện: Ví phải ở trạng thái hoạt động (Active) 
-- và số dư khả dụng phải lớn hơn hoặc bằng số tiền cần thanh toán (balance>=p_amount). Nếu không thỏa mãn, ngắt tiến trình.
-- BƯỚC 4 (Bắt đầu Giao dịch): Gọi lệnh START TRANSACTION để mở một khối giao dịch đồng bộ.
-- BƯỚC 5 (Thực thi đồng bộ): Chạy lệnh cập nhật trừ tiền trong bảng Wallets (Bước 1), sau đó giảm trừ khoản nợ tương ứng trong bảng 
-- Patient_Invoices (Bước 2).
-- BƯỚC 6 (Xác nhận): Gọi lệnh COMMIT để lưu vĩnh viễn các thay đổi vào database và gán thông báo "Thanh toán thành công".

-- Triển khai code 
DROP PROCEDURE IF EXISTS ProcessPayment;

DELIMITER //

CREATE PROCEDURE ProcessPayment(
    IN p_patient_id INT,
    IN p_amount DECIMAL(18,2),
    OUT p_status_message VARCHAR(255)
)
BEGIN
    -- Khai báo các biến cục bộ để đối chiếu dữ liệu trước khi chạy
    DECLARE v_balance DECIMAL(18,2);
    DECLARE v_status VARCHAR(20);
    DECLARE v_invoice_exists INT;

    -- Cơ chế dự phòng: Tự động ROLLBACK khi có lỗi hệ thống bất ngờ xảy ra (Cúp điện, sập nguồn...)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status_message = 'Lỗi: Hệ thống gặp sự cố bất ngờ. Giao dịch đã được hoàn tác an toàn.';
    END;

    -- BẪY LỖI DỮ LIỆU ĐẦU VÀO: Số tiền thanh toán phải lớn hơn 0
    IF p_amount <= 0 THEN
        SET p_status_message = 'Lỗi: Số tiền thanh toán phải lớn hơn 0.';
    ELSE
        -- Lấy thông tin tài khoản ví của bệnh nhân để kiểm tra trước
        SELECT balance, status INTO v_balance, v_status 
        FROM Wallets 
        WHERE patient_id = p_patient_id;

        -- TÌNH HUỐNG 2: Kiểm tra điều kiện ví và số dư khả dụng
        IF v_balance IS NULL THEN
            SET p_status_message = 'Lỗi: Bệnh nhân không có tài khoản ví điện tử.';
        ELSEIF v_status <> 'Active' THEN
            SET p_status_message = 'Lỗi: Ví điện tử của bệnh nhân đang bị khóa.';
        ELSEIF v_balance < p_amount THEN
            SET p_status_message = 'Lỗi: Số dư ví không đủ để thanh toán.';
        ELSE
            -- Kiểm tra xem bệnh nhân có hóa đơn công nợ tồn tại không
            SELECT COUNT(*) INTO v_invoice_exists FROM Patient_Invoices WHERE patient_id = p_patient_id;
            
            IF v_invoice_exists = 0 THEN
                SET p_status_message = 'Lỗi: Không tìm thấy thông tin công nợ của bệnh nhân.';
            ELSE
                -- MỐC KHỞI TẠO GIAO DỊCH AN TOÀN
                START TRANSACTION;

                -- Thao tác 1: Trừ tiền trong Ví điện tử của bệnh nhân
                UPDATE Wallets 
                SET balance = balance - p_amount 
                WHERE patient_id = p_patient_id;

                -- Thao tác 2: Giảm trừ khoản nợ tương ứng trên hóa đơn viện phí
                UPDATE Patient_Invoices 
                SET total_due = total_due - p_amount,
                    last_updated = CURRENT_TIMESTAMP
                WHERE patient_id = p_patient_id;

                -- MỐC XÁC NHẬN GIAO DỊCH THÀNH CÔNG VÀ LƯU DỮ LIỆU
                COMMIT;
                SET p_status_message = 'Thanh toán thành công. Hệ thống đã đồng bộ dữ liệu.';
            END IF;
        END IF;
    END IF;
END //

DELIMITER ;
-- Kiểm thử code 
CALL ProcessPayment(1, 200000.00, @result);
SELECT @result AS 'Trạng thái hệ thống';

-- Kiểm tra tính đồng bộ của dữ liệu trong Database
SELECT * FROM Wallets WHERE patient_id = 1;         -- Số dư phải giảm còn 300,000.00
SELECT * FROM Patient_Invoices WHERE patient_id = 1; -- Công nợ phải giảm còn 1,300,000.00

CALL ProcessPayment(2, 400000.00, @result);
SELECT @result AS 'Trạng thái hệ thống';

-- Kiểm tra xem ví có bị âm hay không
SELECT * FROM Wallets WHERE patient_id = 2; -- Số dư phải giữ nguyên 50,000.00, không bị trừ bừa bãi

CALL ProcessPayment(1, -50000.00, @result);
SELECT @result AS 'Trạng thái hệ thống';