/*
Background:
	Fact.Sale => 12.2M rows, Clustered Columnstore Index
	Dimension Tables: Clustered Index on key columns
*/

/*
	STEP 1
	=============
	- Set Compatibility to SQL Server 2017 (without Scalar UDF Inlining)
*/

ALTER DATABASE WideWorldImportersDW
SET COMPATIBILITY_LEVEL = 140 /* SQL Server Version 2017 */

/*
	STEP 2
	======
	- 2.1 Query without UDF
	- 2.2 Query with MAXDOP 1
*/
SELECT c.Customer
	, si.[Stock Item]
	, e.Employee
	/** Inlining **/
	, CONVERT(NVARCHAR(50),HASHBYTES('SHA2_256', e.Employee),2) AS EmployeeHash
	/** -------- **/	
	, ci.City
	, d.[Calendar Year]
	, d.[Month]
	, SUM(s.Quantity) AS Quantity
FROM Fact.Sale AS s
LEFT OUTER JOIN Dimension.Customer AS c
	ON c.[Customer Key] = s.[Customer Key]
LEFT OUTER JOIN Dimension.[Stock Item] AS si
	ON si.[Stock Item Key] = s.[Stock Item Key]
LEFT OUTER JOIN Dimension.Employee AS e
	ON e.[Employee Key] = s.[Salesperson Key]
LEFT OUTER JOIN Dimension.City AS ci
	ON ci.[City Key] = s.[City Key]
LEFT OUTER JOIN Dimension.[Date] AS d
	ON d.Date = s.[Invoice Date Key]
GROUP BY c.Customer
	, si.[Stock Item]
	, e.Employee
	, ci.City
	, d.[Calendar Year]
	, d.[Month]
	, d.[Calendar Month Number]
-- OPTION (MAXDOP 1)
-- Parallel Execution Plan: 00:20 (DOP = 2)
-- Serial Execution Plan: 01:35 Min

/*
	STEP 3
	======
	- Add UDF
*/

SELECT c.Customer
	, si.[Stock Item]
	, e.Employee

	/** UDF: **/
	, dbo.GetHashID(e.Employee) AS EmployeeHash
	
	, ci.City
	, d.[Calendar Year]
	, d.[Month]
	, SUM(s.Quantity) AS Quantity
FROM Fact.Sale AS s
LEFT OUTER JOIN Dimension.Customer AS c
	ON c.[Customer Key] = s.[Customer Key]
LEFT OUTER JOIN Dimension.[Stock Item] AS si
	ON si.[Stock Item Key] = s.[Stock Item Key]
LEFT OUTER JOIN Dimension.Employee AS e
	ON e.[Employee Key] = s.[Salesperson Key]
LEFT OUTER JOIN Dimension.City AS ci
	ON ci.[City Key] = s.[City Key]
LEFT OUTER JOIN Dimension.[Date] AS d
	ON d.Date = s.[Invoice Date Key]
GROUP BY c.Customer
	, si.[Stock Item]
	, e.Employee
	, ci.City
	, d.[Calendar Year]
	, d.[Month]
	, d.[Calendar Month Number]
-- With UDF (not parallel): 01:45 Min

/*
	STEP 4
	======
	- Use CLR
*/
SELECT c.Customer
	, si.[Stock Item]
	, e.Employee
	
	/** CLR: **/
	, dbo.GetHashID_CLR(e.Employee) AS EmployeeHash
	
	, ci.City
	, d.[Calendar Year]
	, d.[Month]
	, SUM(s.Quantity) AS Quantity
FROM Fact.Sale AS s
LEFT OUTER JOIN Dimension.Customer AS c
	ON c.[Customer Key] = s.[Customer Key]
LEFT OUTER JOIN Dimension.[Stock Item] AS si
	ON si.[Stock Item Key] = s.[Stock Item Key]
LEFT OUTER JOIN Dimension.Employee AS e
	ON e.[Employee Key] = s.[Salesperson Key]
LEFT OUTER JOIN Dimension.City AS ci
	ON ci.[City Key] = s.[City Key]
LEFT OUTER JOIN Dimension.[Date] AS d
	ON d.Date = s.[Invoice Date Key]
GROUP BY c.Customer
	, si.[Stock Item]
	, e.Employee
	, ci.City
	, d.[Calendar Year]
	, d.[Month]
	, d.[Calendar Month Number]
-- CLR & Parallel: 00:31 Min (+11 seconds)

/*
	STEP 5
	======
	- Change Compatibility Level to 150 (SQL Server 2019) with Scalar UDF Inlining
*/
ALTER DATABASE WideWorldImportersDW
SET COMPATIBILITY_LEVEL = 150 /* SQL Server Version 2019 */

/*
	STEP 6
	======
	- Same Query with UDF as in Step 
*/

SELECT c.Customer
	, si.[Stock Item]
	, e.Employee

	/** UDF: **/
	, dbo.GetHashID(e.Employee) AS EmployeeHash

	, ci.City
	, d.[Calendar Year]
	, d.[Month]
	, SUM(s.Quantity) AS Quantity
FROM Fact.Sale AS s
LEFT OUTER JOIN Dimension.Customer AS c
	ON c.[Customer Key] = s.[Customer Key]
LEFT OUTER JOIN Dimension.[Stock Item] AS si
	ON si.[Stock Item Key] = s.[Stock Item Key]
LEFT OUTER JOIN Dimension.Employee AS e
	ON e.[Employee Key] = s.[Salesperson Key]
LEFT OUTER JOIN Dimension.City AS ci
	ON ci.[City Key] = s.[City Key]
LEFT OUTER JOIN Dimension.[Date] AS d
	ON d.Date = s.[Invoice Date Key]
GROUP BY c.Customer
	, si.[Stock Item]
	, e.Employee
	, ci.City
	, d.[Calendar Year]
	, d.[Month]
	, d.[Calendar Month Number]
-- With UDF (parallel): 0:21