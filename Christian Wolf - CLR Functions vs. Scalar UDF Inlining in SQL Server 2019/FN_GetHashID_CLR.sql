USE [WideWorldImportersDW]
GO

/****** Object:  UserDefinedFunction [dbo].[GetHashID_CLR]    Script Date: 3/10/2021 10:51:33 AM ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE FUNCTION [dbo].[GetHashID_CLR](@String [nvarchar](4000))
RETURNS [nvarchar](255) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [sqlclr].[UserDefinedFunctions].[GetHashID]
GO

