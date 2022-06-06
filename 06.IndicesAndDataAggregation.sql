--1. Records’ Count

USE Gringotts	

GO

SELECT COUNT(*) FROM WizzardDeposits

--02. Longest Magic Wand

SELECT MAX(MagicWandSize) AS LongestMagicWand
	FROM WizzardDeposits

--03. Longest Magic Wand per Deposit Groups

SELECT
	w.[DepositGroup],MAX(MagicWandSize) AS LongestMagicWand
	FROM WizzardDeposits AS	w
	GROUP BY w.[DepositGroup]

--04. Smallest Deposit Group per Magic Wand Size

SELECT TOP (2)
	w.[DepositGroup]
	FROM WizzardDeposits AS	w
	GROUP BY w.[DepositGroup]
	ORDER BY AVG(MagicWandSize) ASC

--05. Deposits Sum

SELECT
	w.[DepositGroup],SUM(DepositAmount) AS TotalSum
	FROM WizzardDeposits AS	w
	GROUP BY w.[DepositGroup]

--06. Deposits Sum for Ollivander Family

SELECT
	w.[DepositGroup],SUM(DepositAmount) AS TotalSum
	FROM WizzardDeposits AS	w
	WHERE [MagicWandCreator]='Ollivander family'
	GROUP BY w.[DepositGroup]
	
--07. Deposits Filter

SELECT
	w.[DepositGroup],SUM(w.DepositAmount) AS TotalSum
	FROM WizzardDeposits AS	w
	WHERE [MagicWandCreator]='Ollivander family'
	GROUP BY w.[DepositGroup]
	HAVING SUM(w.DepositAmount)<150000
	ORDER BY SUM(w.DepositAmount) DESC

--08. Deposit Charge

SELECT
	w.[DepositGroup],w.[MagicWandCreator],MIN(w.[DepositCharge]) AS MinDepositCharge
	FROM WizzardDeposits AS	w
	GROUP BY w.[DepositGroup],w.[MagicWandCreator]
	ORDER BY MagicWandCreator,DepositGroup 

--09. Age Groups

SELECT [AgeGroup], COUNT(*) AS [WizardCount] FROM (SELECT CASE
		WHEN [Age] BETWEEN 0 AND 10 THEN '[0-10]'
		WHEN [Age] BETWEEN 11 AND 20 THEN '[11-20]'
		WHEN [Age] BETWEEN 21 AND 30 THEN '[21-30]'
		WHEN [Age] BETWEEN 31 AND 40 THEN '[31-40]'
		WHEN [Age] BETWEEN 41 AND 50 THEN '[41-50]'
		WHEN [Age] BETWEEN 51 AND 60 THEN '[51-60]'
		ELSE '[61+]'
	END AS [AgeGroup], *
	FROM WizzardDeposits) AS [AgeGroupQuery]
	GROUP BY [AgeGroup]

--10. First Letter

SELECT * FROM
(SELECT LEFT(FirstName, 1) AS FirstLetter
	FROM WizzardDeposits
	WHERE DepositGroup LIKE 'Troll Chest') AS temp
	GROUP BY FirstLetter
	ORDER BY FirstLetter

--11. Average Interest

SELECT
	[DepositGroup],
	IsDepositExpired,
	AVG(DepositInterest) AS [AverageInterest]
	FROM WizzardDeposits
	WHERE [DepositStartDate]>'1985-01-01'
	GROUP BY [DepositGroup],IsDepositExpired
	ORDER BY [DepositGroup] DESC,IsDepositExpired

-- 12. Rich Wizard, Poor Wizard

SELECT SUM([Difference]) AS [SumDifference]
	FROM (SELECT  FirstName AS [Host Wizard],
		DepositAmount AS [Host Wizard Deposit],
		LEAD(FirstName) OVER(ORDER BY Id ASC) AS [Guest Wizard],
		LEAD(DepositAmount) OVER(ORDER BY Id ASC) AS [Guest Wizard Deposit],
		DepositAmount - LEAD(DepositAmount) OVER(ORDER BY Id ASC) AS [Difference]
	FROM WizzardDeposits
	) AS [LeadQuery]
	WHERE [Guest Wizard] IS NOT NULL

--13. Departments Total Salaries

USE SoftUni

GO

SELECT DepartmentID, SUM(Salary) AS [TotalSalary]
	FROM Employees
	GROUP BY DepartmentID
	ORDER BY DepartmentID

--14. Employees Minimum Salaries

SELECT DepartmentID, MIN(Salary) AS MinimumSalary
	FROM Employees
	WHERE HireDate>'2000-01-01'
	GROUP BY DepartmentID
	HAVING DepartmentID IN (2,5,7)
	ORDER BY DepartmentID

--15. Employees Average Salaries

SELECT * INTO NewTable
	FROM Employees
	WHERE Salary>30000 

DELETE FROM NewTable
WHERE ManagerID IN(42)

UPDATE NewTable
SET Salary +=5000
WHERE DepartmentID=1

SELECT DepartmentID,AVG(Salary) AS AverageSalary
	FROM NewTable
	GROUP BY DepartmentID

--16. Employees Maximum Salaries

SELECT DepartmentID, MAX(Salary) AS MaxSalary
	FROM Employees
	GROUP BY DepartmentID
	HAVING MAX(Salary) NOT BETWEEN 30000 AND 70000

--17. Employees Count Salaries

SELECT COUNT(Salary) AS Count
	FROM Employees
	WHERE ManagerID IS NULL

--18. 3rd Highest Salary

SELECT DepartmentID, Salary AS ThirdHighestSalary FROM(
SELECT	DepartmentID,
		Salary,
		DENSE_RANK() OVER(PARTITION BY DepartmentID ORDER BY SALARY DESC) AS [SalaryRank]
	FROM Employees
	GROUP BY DepartmentID, Salary) AS [SalaryRankingQuery]
	WHERE SalaryRank = 3

--19. Salary Challenge

SELECT TOP(10) e1.FirstName, e1.LastName, e1.DepartmentID 
	FROM Employees AS e1
	WHERE e1.Salary >  (
					SELECT AVG(Salary) AS [AverageSalary]
					FROM Employees AS e2
					WHERE e2.DepartmentID = e1.DepartmentID
					GROUP BY DepartmentID
					)
	ORDER BY DepartmentID ASC

