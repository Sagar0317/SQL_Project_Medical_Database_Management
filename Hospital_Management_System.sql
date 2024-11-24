-- 1. List Patients and Their Doctors Using JOIN
	
Select * from Patients;
Select * from Doctors;
Select * from Appointments;

Select
    P.FirstName AS PatientName,
    P.LastName AS PatientLastName,
    D.FirstName AS DoctorName,
    D.LastName AS DoctorLastName,
    D.Specialty as Specialty
From 
	Patients p join
	Appointments a on p.PatientID = a.PatientID join
	Doctors d on a.DoctorID = d.DoctorID

-- 2. Find Doctors with More than 5 Appointments Using JOIN and GROUP BY

SELECT 
    D.FirstName AS DoctorFirstName,
    D.LastName AS DoctorLastName,
    COUNT(A.AppointmentID) AS TotalAppointments
FROM Doctors D
JOIN Appointments A ON D.DoctorID = A.DoctorID
GROUP BY D.FirstName, LastName
HAVING COUNT(A.AppointmentID) > 5;

-- 3. Find Upcoming Appointments Using CTE

WITH UpcomingAppointments AS (
    SELECT 
        AppointmentID,
        PatientID,
        DoctorID,
        AppointmentDate
    FROM Appointments
    WHERE AppointmentDate > SYSDATETIME()	
)
SELECT 
    U.AppointmentID,
    P.FirstName AS PatientName,
    D.FirstName AS DoctorName,
    U.AppointmentDate
FROM UpcomingAppointments U JOIN 
	Patients P ON U.PatientID = P.PatientID JOIN 
	Doctors D ON U.DoctorID = D.DoctorID;

-- 4. Calculate Total Revenue per Patient Using CTE

WITH PatientBilling AS (
    SELECT 
        PatientID,
        SUM(TotalAmount) AS TotalRevenue
    FROM Billing
    GROUP BY PatientID
)
SELECT 
    P.FirstName AS PatientName,
    P.LastName AS PatientLastName,
    PB.TotalRevenue
FROM PatientBilling PB
JOIN Patients P ON PB.PatientID = P.PatientID;

-- 5. Find Top 3 Doctors with the Most Appointments Using Window Functions

SELECT top 3
    D.FirstName AS DoctorName,
    D.Specialty,
    COUNT(A.AppointmentID) AS TotalAppointments,
    RANK() OVER (ORDER BY COUNT(A.AppointmentID) DESC) AS rn
FROM Doctors D
JOIN Appointments A ON D.DoctorID = A.DoctorID
GROUP BY D.FirstName, D.Specialty
ORDER BY rn

-- 6. Identify Drugs Running Low in Stock Using JOIN

SELECT 
    DI.DrugName,
    DI.Quantity,
    B.BillID,
    SUM(DI.Quantity) OVER (PARTITION BY DI.DrugID) AS TotalStockUsed
FROM DrugInventory DI
LEFT JOIN Billing B ON DI.DrugID = B.BillID
WHERE DI.Quantity < 50;

-- 7. Monthly Revenue Breakdown Using CTE

WITH MonthlyRevenue AS (
    SELECT 
        FORMAT(PaymentDate, 'yyyy-MM') AS Month, -- Format date to 'YYYY-MM'
        SUM(TotalAmount) AS Revenue
    FROM Billing
    GROUP BY FORMAT(PaymentDate, 'yyyy-MM')
)
SELECT * FROM MonthlyRevenue;

-- 8. Calculate Patient Appointment Frequency Using Window Functions

WITH RankedAppointments AS (
    SELECT 
        P.PatientID,
        P.FirstName AS PatientName,
        P.LastName AS PatientLastName,
        A.AppointmentID,
        A.AppointmentDate,
        ROW_NUMBER() OVER (PARTITION BY P.PatientID ORDER BY A.AppointmentDate DESC) AS VisitRank
    FROM Patients P
    JOIN Appointments A ON P.PatientID = A.PatientID
),
AppointmentCounts AS (
    SELECT 
        P.PatientID,
        COUNT(A.AppointmentID) AS AppointmentCount
    FROM Patients P
    JOIN Appointments A ON P.PatientID = A.PatientID
    GROUP BY P.PatientID
)
SELECT 
    R.PatientName,
    R.PatientLastName,
    C.AppointmentCount,
    R.VisitRank
FROM RankedAppointments R
JOIN AppointmentCounts C ON R.PatientID = C.PatientID
ORDER BY R.PatientID, R.VisitRank;

-- 9. Find Appointments with Patients Having No Insurance

SELECT 
    P.FirstName AS PatientName,
    P.LastName AS PatientLastName,
    A.AppointmentID,
    A.AppointmentDate,
    D.FirstName AS DoctorName,
    D.Specialty
FROM Patients P
JOIN Appointments A ON P.PatientID = A.PatientID
JOIN Doctors D ON A.DoctorID = D.DoctorID
WHERE P.InsuranceProvider IS NULL;

-- 10. Analyze Average Bill Payment Using Window Functions

SELECT 
    PatientID,
    AVG(TotalAmount) OVER (PARTITION BY PatientID) AS AverageBill,
    MAX(TotalAmount) OVER (PARTITION BY PatientID) AS MaxBill,
    MIN(TotalAmount) OVER (PARTITION BY PatientID) AS MinBill
FROM Billing;






