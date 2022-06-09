USE [Bank]

-- 1. Create Table Logs

CREATE TABLE Logs(
	LogId INT PRIMARY KEY IDENTITY,
	AccountId INT NOT NULL FOREIGN KEY REFERENCES Accounts(Id),
	OldSum DECIMAL(15, 2) NOT NULL,
	NewSum DECIMAL(15, 2) NOT NULL
)

CREATE TRIGGER tr_InsertAccountInfo
ON Accounts FOR UPDATE
AS
	DECLARE @newSum DECIMAL(15, 2) = (SELECT Balance FROM inserted)
	DECLARE @oldSum DECIMAL(15, 2) = (SELECT Balance FROM deleted)
	DECLARE @accountId INT = (SELECT Id FROM inserted)

	INSERT INTO Logs(AccountId, OldSum, NewSum)
		VALUES
			(@accountId, @oldSum, @newSum)
GO

UPDATE Accounts
SET Balance += 10
WHERE Id = 1

SELECT * FROM Logs

-----------------------------------------------
-- 2. Create Table Emails

CREATE TABLE NotificationEmails(
	Id INT PRIMARY KEY IDENTITY, 
	Recipient INT NOT NULL FOREIGN KEY REFERENCES Accounts(Id), 
	[Subject] VARCHAR(100) NOT NULL,
	Body VARCHAR(200) NOT NULL
)

CREATE TRIGGER tr_LogEmail
ON Logs FOR INSERT
AS

	DECLARE @accountId INT = (SELECT TOP(1) AccountId FROM inserted)
	DECLARE @oldSum DECIMAL(15, 2) = (SELECT TOP(1) OldSum FROM inserted)
	DECLARE @newSum DECIMAL(15, 2) = (SELECT TOP(1) NewSum FROM inserted)

INSERT INTO NotificationEmails(Recipient, [Subject], Body)
	VALUES
		(@accountId,
		 'Balance change for account: ' + CAST(@accountId AS varchar(20)),
		 'On ' + CONVERT(varchar(30), GETDATE(), 103) + ' your balance was changed from ' + CAST(@oldSum AS varchar(20)) + ' to ' +  CAST(@newSum AS varchar(20)) + '.')

SELECT * FROM NotificationEmails

UPDATE Accounts
SET Balance += 100
WHERE Id = 1

--------------------------------------------------
-- 3. Deposit Money

CREATE PROC usp_DepositMoney @accountId INT, @moneyAmount DECIMAL(15, 4)
AS
BEGIN TRANSACTION
	DECLARE @account INT = (SELECT Id FROM Accounts WHERE Id = @accountId)
	
IF (@account IS NULL)
BEGIN
	ROLLBACK
	RAISERROR('Invalid account id!', 16, 1)
	RETURN
END

IF(@moneyAmount < 0)
BEGIN
	ROLLBACK
	RAISERROR('Negative amount!', 16, 1)
	RETURN
END

UPDATE Accounts
SET Balance += @moneyAmount
WHERE Id = @accountId

COMMIT

EXEC usp_DepositMoney 1, 100

SELECT * FROM Accounts
WHERE Id = 1

----------------------------------------------
-- 4. Withdraw Money

CREATE PROC usp_WithdrawMoney @accountId INT, @moneyAmount DECIMAL(15, 4)
AS
BEGIN TRANSACTION
	DECLARE @account INT = (SELECT Id FROM Accounts WHERE Id = @accountId)
	DECLARE @accountBalance DECIMAL (15, 4) = (SELECT Balance FROM Accounts WHERE Id = @accountId)

IF (@account IS NULL)
BEGIN
	ROLLBACK
	RAISERROR('Invalid account id!', 16, 1)
	RETURN
END

IF (@moneyAmount < 0)
BEGIN
	ROLLBACK
	RAISERROR('Negative amount!', 16 , 1)
	RETURN
END

IF (@accountBalance < 0)
BEGIN
	ROLLBACK
	RAISERROR('Insufficient funds!', 16 , 1)
	RETURN
END

	UPDATE Accounts
	SET Balance -= @moneyAmount
	WHERE Id = @accountId

COMMIT

SELECT * FROM Accounts WHERE Id = 1
EXEC usp_WithdrawMoney 1, 200

----------------------------------------------------
-- 5. Money Transfer

CREATE PROC usp_TransferMoney(@senderId INT, @receiverId INT, @amount DECIMAL(15, 4))
AS
BEGIN TRANSACTION
	EXEC usp_WithdrawMoney @senderId, @amount
	EXEC usp_DepositMoney @receiverId, @amount
COMMIT
GO

SELECT * FROM Accounts WHERE Id = 1 OR Id = 2

EXEC usp_TransferMoney 1, 2, 100

--------------------------------------------------
-- Queries for Diablo Database

USE [Diablo]

-- 6. Trigger
-- 1
GO
CREATE TRIGGER tr_RestrictItems 
ON UserGameItems INSTEAD OF INSERT
AS
DECLARE @itemId INT = (SELECT ItemId FROM inserted)
DECLARE @userGameId INT = (SELECT UserGameId FROM inserted)

DECLARE @itemLevel INT = (SELECT MinLevel FROM Items WHERE Id = @itemId)
DECLARE @userGameLevel INT = (SELECT [Level] FROM UsersGames WHERE Id = @userGameId)

IF (@userGameLevel >= @itemLevel)
BEGIN 
	INSERT INTO UserGameItems (ItemId, UserGameId)
		VALUES
			(@itemId, @userGameId)
END

SELECT * 
	FROM UserGameItems
	WHERE UserGameId = 38 AND ItemId = 14

INSERT INTO UserGameItems (ItemId, UserGameId) VALUES
	(14, 38)

-- 2
 
 SELECT * 
	FROM Users AS u
	JOIN UsersGames AS ug ON ug.UserId = u.Id
	JOIN Games AS g ON g.Id = ug.GameId
	WHERE g.Name = 'Bali' AND u.Username IN ('baleremuda','loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos')

UPDATE UsersGames
SET CASH += 50000
WHERE GameId = (SELECT Id FROM Games WHERE Name = 'Bali') AND
	UserId IN (SELECT Id FROM Users WHERE Username IN ('baleremuda','loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos'))

-- 3

DECLARE @itemId INT = 251;

WHILE(@itemId <= 299)
BEGIN 
	EXEC usp_BuyItem 22, @itemId, 212
	EXEC usp_BuyItem 37, @itemId, 212
	EXEC usp_BuyItem 52, @itemId, 212
	EXEC usp_BuyItem 61, @itemId, 212

	SET @itemId += 1;
END

DECLARE @counter INT = 501;

WHILE(@counter <= 539)
BEGIN 
	EXEC usp_BuyItem 22, @counter, 212
	EXEC usp_BuyItem 37, @counter, 212
	EXEC usp_BuyItem 52, @counter, 212
	EXEC usp_BuyItem 61, @counter, 212

	SET @counter += 1;
END

SELECT * FROM UsersGames WHERE GameId = 212

GO
CREATE PROC usp_BuyItem @userId INT, @itemId INT, @gameId INT
AS
BEGIN TRANSACTION
DECLARE @user INT = (SELECT Id FROM Users WHERE Id = @userId)
DECLARE @item INT = (SELECT Id FROM Items WHERE Id = @itemId)

IF (@user IS NULL OR @item IS NULL)
BEGIN
	ROLLBACK
	RAISERROR('Invalid user or item id!', 16, 1)
	RETURN
END

DECLARE @userCash DECIMAL(15, 2) = (SELECT Cash FROM UsersGames WHERE UserId = @itemId AND GameId = @gameId)
DECLARE @itemPrice DECIMAL(15, 2) = (SELECT Price FROM Items WHERE Id = @itemId)

IF (@userCash - @itemPrice < 0)
BEGIN
	ROLLBACK
	RAISERROR('Insufficient funds!', 16, 2)
	RETURN
END

UPDATE UsersGames
SET Cash -= @itemPrice
WHERE UserId = @userId AND GameId = @gameId

DECLARE @userGameId DECIMAL(15, 2) = (SELECT Id FROM UsersGames WHERE UserId = @itemId AND GameId = @gameId)

INSERT INTO UserGameItems (ItemId, UserGameId) VALUES
	(@itemId, @userGameId)

COMMIT

-- 4

SELECT u.Username, g.Name, ug.Cash, i.Name
	FROM Users AS u
	JOIN UsersGames AS ug ON ug.UserId = u.Id
	JOIN Games AS g ON g.Id = ug.GameId
	JOIN UserGameItems AS ugi ON ugi.UserGameId = ug.Id
	JOIN Items AS i ON i.Id = ugi.ItemId
	WHERE G.Name = 'Bali'
	ORDER BY u.Username, i.Name

-----------------------------------------------------
-- 7. *Massive Shopping



-----------------------------------------------------
-- Queries for SoftUni Database
GO
USE [SoftUni]
GO
-- 8. Employees with Three Projects

CREATE PROC usp_AssignProject @emloyeeId INT, @projectID INT
AS
BEGIN TRANSACTION
DECLARE @employee INT = (SELECT EmployeeID FROM Employees WHERE EmployeeID = @emloyeeId)
DECLARE @project INT = (SELECT ProjectID FROM Projects WHERE ProjectID = @projectID)

IF (@employee IS NULL OR @project IS NULL)
BEGIN 
	ROLLBACK
	RAISERROR('Invalid employee id or project id!', 16, 1)
	RETURN
END
DECLARE @employeeProjects INT = (SELECT COUNT(*) FROM EmployeesProjects WHERE EmployeeID = @emloyeeId)

IF (@employeeProjects >= 3)
BEGIN 
	ROLLBACK
	RAISERROR('The employee has too many projects!', 16, 2)
	RETURN
END

INSERT INTO EmployeesProjects(EmployeeID, ProjectID) VALUES
	(@emloyeeId, @projectID)

COMMIT

------------------------------------------------------
-- 9. Delete Employees

CREATE TABLE Deleted_Employees(
	EmployeeId INT PRIMARY KEY,
	FirstName VARCHAR(50) NOT NULL, 
	LastName VARCHAR(50) NOT NULL,
	MiddleName VARCHAR(50), 
	JobTitle VARCHAR(50) NOT NULL,
	DepartmentId INT,
	Salary DECIMAL(15, 2)
)

CREATE TRIGGER tr_DeletedEmployees
ON Employees FOR DELETE
AS
INSERT INTO Deleted_Employees(FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary)
SELECT FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary FROM deleted