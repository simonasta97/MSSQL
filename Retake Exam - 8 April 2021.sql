CREATE DATABASE Service

CREATE TABLE Users (
	Id INT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) NOT NULL UNIQUE,
	Password VARCHAR(50) NOT NULL,
	Name VARCHAR(50),
	Birthdate DATETIME,
	Age INT CHECK(Age >= 14 AND Age <= 110),
	Email VARCHAR(50) NOT NULL
)

CREATE TABLE Departments(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(25),
	LastName VARCHAR(25),
	Birthdate DATETIME,
	Age INT CHECK(Age >= 18 AND Age <= 110) NOT NULL,
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id)
)

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	DepartmentId INT NOT NULL FOREIGN KEY REFERENCES Departments(Id)
)

CREATE TABLE Status(
	Id INT PRIMARY KEY IDENTITY,
	Label VARCHAR(30) NOT NULL,
)

CREATE TABLE Reports(
	Id INT PRIMARY KEY IDENTITY,
	CategoryId INT NOT NULL FOREIGN KEY REFERENCES Categories(Id),
	StatusId INT NOT NULL FOREIGN KEY REFERENCES Status(Id),
	OpenDate DATETIME NOT NULL,
	CloseDate DATETIME,
	Description VARCHAR(200) NOT NULL,
	UserId INT NOT NULL FOREIGN KEY REFERENCES Users(Id),
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id),
)

--2.Insert 

INSERT INTO Employees
	(FirstName,LastName,Birthdate,DepartmentId) 
		VALUES
	('Marlo', 'O''Malley','1958-9-21',1),
	('Niki', 'Stanaghan','1969-11-26',4),
	('Ayrton', 'Senna','1960-03-21',9),
	('Ronnie', 'Peterson','1944-02-14',9),
	('Giovanna', 'Amati','1959-07-20',5)


INSERT INTO Reports
(CategoryId,StatusId,OpenDate,CloseDate,[Description],UserId,EmployeeId)
	VALUES
(1,1,'2017-04-13',NULL,'Stuck Road on Str.133',6,2),
(6,3,'2015-09-05','2015-12-06','Charity trail running',3,5),
(14,2,'2015-09-07',NULL,'Falling bricks on Str.58',5,2),
(4,3,'2017-07-03','2017-07-06','Cut off streetlight on Str.11',1,1)

-- 3. Update

UPDATE Reports 
	SET CloseDate=GETDATE()
	WHERE CloseDate IS NULL

--04. Delete

DELETE FROM Reports
	WHERE StatusId = 4

--05. Unassigned Reports

SELECT
	[Description],
	FORMAT(OpenDate, 'dd-MM-yyyy')
	FROM Reports
	WHERE EmployeeId IS NULL
	ORDER BY OpenDate,[Description]

--06. Reports & Categories

SELECT
	[Description],
	[Name] as CategoryName
	FROM Reports r
	JOIN Categories AS c ON R.CategoryId=c.Id
	WHERE NOT CategoryId IS NULL
	ORDER BY [Description],[Name]

--07. Most Reported Category

SELECT TOP(5)
	[Name] as CategoryName,
	COUNT([Name]) AS ReportsNumber
	FROM Reports r
	JOIN Categories AS c ON R.CategoryId=c.Id
	GROUP BY [Name]
	ORDER BY COUNT([Name]) DESC,[Name]

--08. Birthday Report

SELECT
	Username, c.[Name] AS [CategoryName]
	FROM Users u
	JOIN Reports AS r ON r.UserId=u.Id
	JOIN Categories c ON C.Id=r.CategoryId
	WHERE DATEPART(MONTH, r.OpenDate) = DATEPART(MONTH, u.Birthdate) AND
		  DATEPART(DAY, r.OpenDate) = DATEPART(DAY, u.Birthdate)
	ORDER BY Username,[CategoryName]

--09. User per Employee

SELECT
	CONCAT(FirstName,' ',LastName) AS FullName,
	COUNT(DISTINCT r.UserId) AS UsersCount
	FROM Employees e
	JOIN Reports AS r ON r.EmployeeId=e.Id
	GROUP BY CONCAT(e.FirstName, ' ', e.LastName)
	ORDER BY UsersCount DESC,FullName

--10.	Full Info

SELECT DISTINCT
	CASE
		WHEN e.FirstName IS NULL OR e.LastName IS NULL THEN 'None'
		ELSE CONCAT(e.FirstName,' ',e.LastName)
	END AS Employee,
	ISNULL(d.[Name],'None') AS [Department],
	ISNULL(c.[Name], 'None') AS [Category],
	[Description],
	FORMAT(OpenDate,'dd.MM.yyyy') AS OpenDate,
	s.Label AS [Status],
	u.[Name] AS [User]
	FROM Reports r
	JOIN Employees e ON r.EmployeeId=e.Id
	JOIN Departments d ON e.DepartmentId=d.Id
	JOIN Categories c ON r.CategoryId=c.Id
	JOIN Users u ON r.UserId=u.Id
	JOIN Status s ON r.StatusId=s.Id
	ORDER BY e.FirstName DESC,e.LastName DESC,[Department],[Category],[Description],OpenDate,[Status],[User]

--11. Hours to Complete

CREATE FUNCTION udf_HoursToComplete(@StartDate DATETIME, @EndDate DATETIME) 
RETURNS INT
AS
	BEGIN 
		DECLARE @result INT;
		IF(@StartDate IS NULL OR @EndDate IS NULL)
			SET  @result=0;
		ELSE
			SET @result=DATEDIFF(hour,@StartDate,@EndDate)

		RETURN  @result;
	END;

--12. Assign Employee

CREATE PROC usp_AssignEmployeeToReport(@EmployeeId INT, @ReportId INT)
AS
BEGIN
	BEGIN TRANSACTION
		DECLARE @EmpDepart INT = (
		SELECT DepartmentId FROM Employees WHERE Id = @EmployeeId)
		DECLARE @CategId INT = (
		SELECT CategoryId FROM Reports WHERE Id = @ReportId)
		DECLARE @ReportDepart INT = (
		SELECT DepartmentId FROM Categories WHERE Id = @CategId)
			IF (@EmpDepart <> @ReportDepart)
			BEGIN
				ROLLBACK;
				THROW 50001, 'Employee doesn''t belong to the appropriate department!', 1
			END

			UPDATE Reports
			SET EmployeeId = @EmployeeId
			WHERE Id = @ReportId
	COMMIT
END			
