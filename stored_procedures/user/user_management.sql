USE [hrhoudini_dev]
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
    @company_id       UNIQUEIDENTIFIER,     -- Always required
    @request_user_id  UNIQUEIDENTIFIER,     -- User making the request (audit/logging)
    @user_id          UNIQUEIDENTIFIER = NULL, -- Target user
    @name             NVARCHAR(100) = NULL,
    @email            NVARCHAR(255) = NULL,
    @phone            NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @action = 'get_all'
        BEGIN
            SELECT user_id, name, email, phone, created_at, updated_at
            FROM [dbo].[user]
            WHERE company_id = @company_id
            ORDER BY created_at DESC;
        END

        ELSE IF @action = 'get_by_id'
        BEGIN
            IF @user_id IS NULL
                THROW 50001, 'Parameter @user_id is required for get_by_id.', 1;

            SELECT user_id, name, email, phone, created_at, updated_at
            FROM [dbo].[user]
            WHERE user_id = @user_id
              AND company_id = @company_id;
        END

        ELSE IF @action = 'create'
        BEGIN
            IF @name IS NULL OR @email IS NULL
                THROW 50002, 'Parameters @name and @email are required for create.', 1;

            INSERT INTO [dbo].[user] (user_id, company_id, name, email, phone, created_at, updated_at, created_by)
            VALUES (NEWID(), @company_id, @name, @email, @phone, GETUTCDATE(), GETUTCDATE(), @request_user_id);
        END

        ELSE IF @action = 'update'
        BEGIN
            IF @user_id IS NULL
                THROW 50003, 'Parameter @user_id is required for update.', 1;

            UPDATE [dbo].[user]
            SET name = COALESCE(@name, name),
                email = COALESCE(@email, email),
                phone = COALESCE(@phone, phone),
                updated_at = GETUTCDATE(),
                updated_by = @request_user_id
            WHERE user_id = @user_id
              AND company_id = @company_id;
        END

        ELSE IF @action = 'delete'
        BEGIN
            IF @user_id IS NULL
                THROW 50004, 'Parameter @user_id is required for delete.', 1;

            DELETE FROM [dbo].[user]
            WHERE user_id = @user_id
              AND company_id = @company_id;
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
