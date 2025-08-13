USE [MyTestDB]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[sp_user_crud]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_user_crud];
GO

CREATE PROCEDURE [dbo].[sp_user_crud]
    @action           VARCHAR(50),          -- 'get_all', 'get_by_id', 'create', 'update', 'delete'
    @EmployeeID          UNIQUEIDENTIFIER , -- Target user
    @FirstName             NVARCHAR(50),
    @LastName   NVARCHAR(50),
    @email            NVARCHAR(100),
    @HireDate           DATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @action = 'get_all'
        BEGIN
            SELECT EmployeeID, FirstName, LastName, email, HireDate
            FROM [dbo].[Employees]
        END

        ELSE IF @action = 'get_by_id'
        BEGIN
            IF @EmployeeID IS NULL
                THROW 50001, 'Parameter @user_id is required for get_by_id.', 1;

            SELECT EmployeeID, FirstName, LastName, email, HireDate
            FROM [dbo].[Employees]
        END

        ELSE
        BEGIN
            THROW 50005, 'Invalid @action parameter.', 1;
        END
    END TRY

    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000),
                @ErrorSeverity INT,
                @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO
