--1.   Employees with Salary Above 35000

CREATE PROC dbo.usp_GetEmployeesSalaryAbove35000 
AS
  SELECT FirstName,LastName 
  FROM Employees
  WHERE Salary>35000
GO

EXEC usp_GetEmployeesSalaryAbove35000

--2.	Employees with Salary Above Number

CREATE PROCEDURE usp_GetEmployeesSalaryAboveNumber (@inputSalary  DECIMAL(18,4))
AS
BEGIN
  SELECT FirstName,LastName 
  FROM Employees
  WHERE Salary>=@inputSalary
END


EXEC usp_GetEmployeesSalaryAboveNumber 48100

--03. Town Names Starting With

CREATE PROCEDURE usp_GetTownsStartingWith  (@inputString  VARCHAR(100))
AS
BEGIN
  SELECT Name 
  FROM Towns
  WHERE [Name] LIKE @inputString + '%'
END


EXEC usp_GetTownsStartingWith 'b'

--04. Employees from Town

CREATE PROC usp_GetEmployeesFromTown(@townName NVARCHAR(50))
AS
BEGIN
	SELECT FirstName, LastName 
		FROM Employees e
		JOIN Addresses a ON a.AddressID = e.AddressID
		JOIN Towns t ON t.TownID = a.TownID
		WHERE t.[Name] = @townName
END


EXEC usp_GetEmployeesFromTown  'b'

--05. Salary Level Function

CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4)) 
RETURNS VARCHAR(10)
AS
	BEGIN
		DECLARE @result  VARCHAR(10);
		IF(@salary <30000)
		BEGIN
			SET @result='Low';
		END
		ELSE IF(@salary <=50000 )
		BEGIN
			SET @result='Average';
		END
		ELSE
		BEGIN
			SET @result='High';
		END

		RETURN @result;
	END;

--06. Employees by Salary Level

CREATE PROC usp_EmployeesBySalaryLevel (@salaryLevel NVARCHAR(50))
AS
BEGIN
	SELECT FirstName, LastName 
		FROM Employees
		WHERE dbo.ufn_GetSalaryLevel(Salary) = @salaryLevel
END

--07. Define Function

CREATE FUNCTION ufn_IsWordComprised(@setOfLetters VARCHAR(MAX), @word VARCHAR(MAX)) 
RETURNS BIT
BEGIN
	DECLARE @count INT = 1;

	WHILE (@count <= LEN(@word))
	BEGIN
		DECLARE @currentLetter CHAR(1) = SUBSTRING(@word, @count, 1)

		IF (CHARINDEX(@currentLetter, @setOfLetters) = 0)
			RETURN 0

		SET @count += 1;
	END
	RETURN 1
END

--08. Delete Employees and Departments

CREATE PROC usp_DeleteEmployeesFromDepartment (@departmentId INT)
AS
BEGIN
	ALTER TABLE Departments
	ALTER COLUMN ManagerID INT NULL

	DELETE FROM EmployeesProjects
	WHERE EmployeeID IN (SELECT EmployeeID FROM Employees WHERE DepartmentID = @departmentId)

	UPDATE Employees
		SET ManagerID = NULL
		WHERE EmployeeID IN (SELECT EmployeeID FROM Employees WHERE DepartmentID = @departmentId)

	UPDATE Employees
		SET ManagerID = NULL
		WHERE ManagerID IN (SELECT EmployeeID FROM Employees WHERE DepartmentID = @departmentId)

	UPDATE Departments
		SET ManagerID = NULL
		WHERE DepartmentID = @departmentId

	DELETE FROM Employees
	WHERE DepartmentID = @departmentId

	DELETE FROM Departments
	WHERE DepartmentID = @departmentId

SELECT COUNT(*) FROM Employees WHERE DepartmentID = @departmentId
END

--09. Find Full Name

USE Bank

GO

CREATE PROCEDURE usp_GetHoldersFullName
AS
BEGIN
	SELECT CONCAT(FirstName, ' ', LastName) AS [Full Name]
	FROM AccountHolders
END

--10. People with Balance Higher Than

CREATE PROC usp_GetHoldersWithBalanceHigherThan(@money DECIMAL(15,2))
AS
BEGIN 
	SELECT FirstName, LastName FROM AccountHolders ah
	JOIN Accounts a ON a.AccountHolderId = ah.Id
	GROUP BY FirstName, LastName
	HAVING SUM(Balance) > @money
	ORDER BY ah.FirstName, ah.LastName
END

-- 11. Future Value Function

CREATE FUNCTION ufn_CalculateFutureValue (@sum DECIMAL(15, 2), @yearlyInerestRate FLOAT, @years INT)
RETURNS DECIMAL(15, 4)
BEGIN
	DECLARE @Result DECIMAL(15, 4) 
	SET @Result = (@sum * POWER((1 + @yearlyInerestRate),@years))

	RETURN @Result
END

SELECT dbo.ufn_CalculateFutureValue (1000, 0.1 ,5)


-- 12. Calculating Interest

CREATE PROC usp_CalculateFutureValueForAccount (@accountId INT, @interestRate FLOAT)
AS
BEGIN
	SELECT a.Id, ah.FirstName, ah.LastName, a.Balance, dbo.ufn_CalculateFutureValue (a.Balance, @interestRate, 5)
		FROM AccountHolders ah
		JOIN Accounts a ON a.AccountHolderId = ah.Id
		WHERE a.Id = @accountId
END

-- Queries for Diablo Database

USE [Diablo]

-- 13. *Scalar Function: Cash in User Games Odd Rows

CREATE FUNCTION ufn_CashInUsersGames (@gameName VARCHAR(100))
RETURNS TABLE
AS
RETURN (SELECT SUM(k.TotalCash) AS TotalCash 
	FROM ( SELECT Cash AS TotalCash,
			ROW_NUMBER() OVER (ORDER BY Cash DESC) AS [RowNumber]
			FROM Games g
			JOIN UsersGames ug ON ug.GameId = g.Id
			WHERE [Name] = @gameName) AS k
	WHERE k.RowNumber % 2 = 1)
