ALTER DATABASE WideWorldImportersDW
SET COMPATIBILITY_LEVEL = 140 /* SQL Server Version 2017 */

SELECT [Customer Key]
	, Customer
	, dbo.GetCustomerProfit([Customer Key], 2012, 1) AS Profit
FROM Dimension.Customer
-- 24 seconds

ALTER DATABASE WideWorldImportersDW
SET COMPATIBILITY_LEVEL = 150 /* SQL Server Version 2019 */

SELECT [Customer Key]
	, Customer
	, dbo.GetCustomerProfit([Customer Key], 2012, 1) AS Profit
FROM Dimension.Customer

-- 5 seconds

/* Force Parallel Execution */

SELECT [Customer Key]
	, Customer
	, dbo.GetCustomerProfit([Customer Key], 2012, 1) AS Profit
FROM Dimension.Customer
OPTION (RECOMPILE, QUERYTRACEON 8649)

-- 3 seconds