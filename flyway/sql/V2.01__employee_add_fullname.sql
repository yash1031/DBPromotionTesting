ALTER TABLE Users
ADD FullName AS (FirstName + ' ' + LastName);