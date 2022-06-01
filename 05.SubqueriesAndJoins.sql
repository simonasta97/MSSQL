-- 1. Employee Address

SELECT TOP (5) e.EmployeeID , e.JobTitle,a.AddressID,a.AddressText
  FROM Employees AS e
	JOIN Addresses AS a ON e.AddressID = a.AddressID
	ORDER BY a.AddressID ASC

--02. Addresses with Towns

SELECT TOP (50) e.FirstName , e.LastName,t.Name AS Town,a.AddressText
  FROM Employees AS e
	JOIN Addresses AS a ON e.AddressID = a.AddressID
	JOIN Towns AS t ON t.TownID=a.TownID
	ORDER BY e.FirstName ASC, e.LastName ASC

--03. Sales Employees

SELECT e.EmployeeID,
	e.FirstName,
	e.LastName,
	d.Name AS DepartmentName

	FROM Employees AS e
	JOIN Departments AS d ON e.DepartmentID=d.DepartmentID
	WHERE d.Name='Sales'
	ORDER BY e.EmployeeID ASC

--04. Employee Departments

SELECT TOP (5)
	e.EmployeeID,
	e.FirstName,
	e.Salary,
	d.Name AS DepartmentName

	FROM Employees AS e
	JOIN Departments AS d ON e.DepartmentID=d.DepartmentID
	WHERE e.Salary > 15000
	ORDER BY d.DepartmentID ASC

--05. Employees Without Projects

SELECT TOP (3)
	e.EmployeeID,
	e.FirstName
	FROM Employees AS e
	LEFT JOIN EmployeesProjects AS p ON e.EmployeeID=p.EmployeeID
	WHERE p.ProjectID IS NULL
	ORDER BY e.EmployeeID ASC

--06. Employees Hired After

SELECT
	e.FirstName,
	e.LastName,
	e.HireDate,
	d.Name AS DeptName
	FROM Employees AS e
	LEFT JOIN Departments AS d ON e.DepartmentID=d.DepartmentID
	WHERE e.HireDate > '01-01-1999'
		AND d.Name IN ('Sales','Finance')
	ORDER BY e.HireDate ASC

--07. Employees With Project

SELECT TOP (5)
	e.EmployeeID,
	e.FirstName,
	p.Name AS ProjectName
	FROM Employees AS e
	JOIN EmployeesProjects AS ep ON e.EmployeeID=ep.EmployeeID
	JOIN Projects AS p ON p.ProjectID=ep.ProjectID
	WHERE p.StartDate > '2002-08-13' AND p.EndDate IS NULL
	ORDER BY e.EmployeeID ASC

--08. Employee 24

SELECT e.EmployeeID, e.FirstName, 
	CASE 
		WHEN DATEPART(YEAR, p.StartDate) >= 2005 THEN NULL
		ELSE p.[Name]
	END AS [ProjectName]
	FROM Employees e
	JOIN EmployeesProjects ep ON ep.EmployeeID = e.EmployeeID
	JOIN Projects p ON p.ProjectID = ep.ProjectID
	WHERE ep.EmployeeID = 24

--09. Employee Manager

SELECT e.EmployeeID, e.FirstName, m.EmployeeID AS ManagerID, m.FirstName AS ManagerName
	FROM Employees e
	JOIN Employees m ON e.ManagerID = m.EmployeeID
	WHERE e.ManagerID IN (3, 7)
	ORDER BY e.EmployeeID ASC

--10. Employees Summary

SELECT TOP (50)
	e.EmployeeID, 
	CONCAT(e.FirstName,' ' ,e.LastName) AS EmployeeName,
	CONCAT(m.FirstName,' ',m.LastName) AS ManagerName,
	d.Name AS DepartmentName
	FROM Employees e
	JOIN Employees m ON e.ManagerID = m.EmployeeID
	JOIN Departments d ON e.DepartmentID = d.DepartmentID
	ORDER BY e.EmployeeID ASC

--11. Min Average Salary

SELECT MIN([Average Salary]) AS MinAverageSalary 
FROM		(
			SELECT DepartmentID, AVG(Salary) AS [Average Salary] 
			FROM Employees
			GROUP BY DepartmentID
			) AS [AverageSalaryQuery]

--12. Highest Peaks in Bulgaria

SELECT mc.CountryCode, m.MountainRange, p.PeakName, p.Elevation
	FROM MountainsCountries mc
	JOIN Mountains m ON m.Id = mc.MountainId AND mc.CountryCode = 'BG'
	JOIN Peaks p ON p.MountainId = m.Id
	WHERE p.Elevation > 2835
	ORDER BY Elevation DESC

--13. Count Mountain Ranges

SELECT CountryCode, COUNT(MountainId) AS [MountainRanges]
	FROM MountainsCountries
	WHERE CountryCode IN ('BG', 'US', 'RU')
	GROUP BY CountryCode

-- 14. Countries with Rivers

SELECT TOP(5) c.CountryName, r.RiverName
	FROM Countries c
	LEFT JOIN CountriesRivers cr ON cr.CountryCode = c.CountryCode
	LEFT JOIN Rivers r ON r.Id = cr.RiverId
	WHERE c.ContinentCode = 'AF'
	ORDER BY c.CountryName


-- 15. *Continents and Currencies

SELECT ContinentCode, CurrencyCode, CurrencyUsage FROM (
SELECT ContinentCode, CurrencyCode, COUNT(CurrencyCode) AS CurrencyUsage,
	DENSE_RANK() OVER (PARTITION BY ContinentCode ORDER BY COUNT(CurrencyCode) DESC) AS [Ranked]
	FROM Countries 
	GROUP BY ContinentCode, CurrencyCode) AS temp
	WHERE Ranked = 1 AND CurrencyUsage > 1
	ORDER BY ContinentCode

-- 16. Countries Without Any Mountains

SELECT COUNT(*)
	FROM Countries c
	LEFT JOIN MountainsCountries mc ON c.CountryCode = mc.CountryCode
	WHERE mc.MountainId IS NULL

-- 17. Highest Peak and Longest River by Country

SELECT TOP (5) c.CountryName, MAX(p.Elevation) AS HighestPeakElevation, MAX(r.[Length]) AS LongestRiverLength
	FROM Countries c
	LEFT JOIN MountainsCountries mc ON mc.CountryCode = c.CountryCode
	LEFT JOIN Mountains m ON m.Id = mc.MountainId
	LEFT JOIN Peaks p ON p.MountainId = m.Id
	LEFT JOIN CountriesRivers cr ON cr.CountryCode = c.CountryCode
	LEFT JOIN Rivers r ON r.Id = cr.RiverId
	GROUP BY c.CountryName
	ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC, c.CountryName


-- 18. Highest Peak Name and Elevation by Country

SELECT TOP(5) CountryName, 
		[Highest Peak Name], 
		[Highest Peak Elevation], 
		[Mountain] FROM (
	SELECT TOP (50) c.CountryName,
		ISNULL(p.PeakName,'(no highest peak)')  AS [Highest Peak Name],
		ISNULL(p.Elevation, 0) AS [Highest Peak Elevation],
		ISNULL(m.MountainRange, '(no mountain)') AS [Mountain],
		DENSE_RANK() OVER (PARTITION BY c.CountryName ORDER BY p.Elevation DESC) AS Ranked
	FROM Countries c
		LEFT JOIN MountainsCountries mc ON mc.CountryCode = c.CountryCode
		LEFT JOIN Mountains m ON m.Id = mc.MountainId
		LEFT JOIN Peaks p ON p.MountainId = m.Id) AS Temp
	WHERE Temp.Ranked = 1
	ORDER BY CountryName ASC, [Highest Peak Name] ASC