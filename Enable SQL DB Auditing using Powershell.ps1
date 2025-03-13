
Get-AzSqlDatabaseAudit -ResourceGroupName "RG1" -ServerName "azsql5" -DatabaseName "BLN"

# I build this query
Set-AzSqlDatabaseAudit -ResourceGroupName "RG1" -ServerName "azsql5" -DatabaseName "BLN" `
-BlobStorageTargetState Enabled  `
-StorageAccountResourceId "/subscriptions/f8e09f37-d4cd-429e-bb19-a33cde7a7ca5/resourceGroups/Dev-RG/providers/Microsoft.Storage/storageAccounts/devstgacc101" `
-RetentionInDay 10 -PredicateExpression "statement like 'INSERT%' or statement like 'select%' or statement like 'Drop%'" 



# Remove  AuditActionGroup, AuditAction and PredicateExpression
Set-AzSqlDatabaseAudit `
-ResourceGroupName "RG1" `
-ServerName "azsql5" `
-DatabaseName "BLN" `
-AuditActionGroup @() `
-AuditAction @() `
-PredicateExpression {}


#Sql script  # only run in SSMS or Azure Portal Query Editor
##  create table TestTable (id int) 
##  insert into TestTable values (1) 
##  select * from TestTable 
##  drop table TestTable

#---------------------------------------------------------------------------------------------------------

# Microsoft engineer gave this query
# Azure Storage accoutn still need to be connected with Azure SQL DB in Auditing section

Set-AzSqlDatabaseAudit -ResourceGroupName "RG1" -ServerName "azsql5" -DatabaseName "BLN" `
-AuditActionGroup "DATABASE_OBJECT_CHANGE_GROUP"  `
-BlobStorageTargetState Enabled `
-StorageAccountResourceId "/subscriptions/f8e09f37-d4cd-429e-bb19-a33cde7a7ca5/resourceGroups/Dev-RG/providers/Microsoft.Storage/storageAccounts/devstgacc101" `
-AuditAction "INSERT, UPDATE, DELETE ON dbo.Employees BY public", "EXECUTE ON InsertEmployees_SP BY public"


<# Run below query in SSMS or Azure Portal SQL DB query Editor

CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100),
    Position NVARCHAR(100),
    Salary DECIMAL(10,2)
);


CREATE PROCEDURE InsertEmployees_SP
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Employees (Name, Position, Salary)
    VALUES
        ('Alice Johnson', 'Software Engineer', 75000),
        ('Bob Smith', 'Database Administrator', 80000),
        ('Charlie Brown', 'Cloud Engineer', 90000);
END;

Exec InsertEmployees_SP

Select * from Employees
truncate table Employees

#>


# SQL qeury to check logs in SSMS or Azure Portal SQL DB query Editor
#change the date in the path

# SELECT TOP 100 event_time, server_instance_name, database_name, server_principal_name, client_ip, statement, succeeded, action_id, class_type, additional_information
# FROM sys.fn_get_audit_file('https://devstgacc101.blob.core.windows.net/sqldbauditlogs/azsql5/BLN/SqlDbAuditing_Audit/2025-03-09', default, default)
# /* additional WHERE clause conditions/filters can be added here */
# ORDER BY event_time DESC