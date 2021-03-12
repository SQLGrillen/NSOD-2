USE [WideWorldImportersDW]
GO

/****** Object:  UserDefinedFunction [dbo].[GetCustomerProfit]    Script Date: 3/10/2021 10:51:12 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[GetCustomerProfit](@Customer INT, @Year INT, @Month INT)
RETURNS FLOAT AS
BEGIN
	DECLARE @Profit FLOAT

	SELECT @Profit = SUM(Profit)
	FROM Fact.Sale AS a
	WHERE YEAR([Invoice Date Key]) = @Year
		AND MONTH([Invoice Date Key]) = @Month
		AND [Customer Key] = @Customer

	RETURN @Profit

END
GO

