/** Enable CLR functionality **/
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'clr enabled', 1;
GO
RECONFIGURE;
GO
sp_configure 'show advanced options', 0;
GO
RECONFIGURE;
GO


/*****
Import DLL Certificate to SQL server
*****/
USE [Master]
GO

CREATE ASYMMETRIC KEY CLR_SP_Key
FROM EXECUTABLE FILE = 'C:\Users\cwolf\source\repos\sqlclr\sqlclr\obj\Debug\sqlclr.dll'
GO

/*****
Create Login for Asymmetric Key
and grant UNSAFE permissioni
******/

CREATE LOGIN CLR_Login FROM ASYMMETRIC KEY CLR_SP_Key
GO
 
GRANT UNSAFE ASSEMBLY TO CLR_Login
GO
 
USE WideWorldImportersDW
GO
 
CREATE USER CLR_Login FOR LOGIN CLR_Login
GO

/*** Load Assembly from DLL **/
IF EXISTS (SELECT * FROM sys.assemblies WHERE name = 'sqlclr') DROP ASSEMBLY Solisyon
CREATE ASSEMBLY Solisyon FROM 'C:\Users\cwolf\source\repos\sqlclr\sqlclr\obj\Debug\sqlclr.dll'  WITH PERMISSION_SET = EXTERNAL_ACCESS
GO