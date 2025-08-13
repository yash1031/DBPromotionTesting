CREATE OR ALTER VIEW vw_EmployeesWithFullName AS
SELECT 
    EmployeeID,
    FirstName,
    LastName,
    Email,
    HireDate
FROM Employees;