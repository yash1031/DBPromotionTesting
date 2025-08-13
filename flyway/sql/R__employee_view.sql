CREATE OR ALTER VIEW vw_UsersWithFullName AS
SELECT 
    UserID,
    FirstName,
    LastName,
    Email,
    HireDate
FROM Users;