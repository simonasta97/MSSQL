CREATE DATABASE Bitbucket

CREATE TABLE Users(
	Id INT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) NOT NULL,
	Password VARCHAR(30) NOT NULL,
	Email VARCHAR(30) NOT NULL
)

CREATE TABLE Repositories(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE RepositoriesContributors(
	RepositoryId INT NOT NULL FOREIGN KEY REFERENCES Repositories(Id),
	ContributorId INT NOT NULL FOREIGN KEY REFERENCES Users(Id),
	PRIMARY KEY(RepositoryId,ContributorId)
)

CREATE TABLE Issues(
	Id INT PRIMARY KEY IDENTITY,
	Title VARCHAR(255) NOT NULL,
	IssueStatus CHAR(6) NOT NULL,
	RepositoryId INT NOT NULL FOREIGN KEY REFERENCES Repositories(Id),
	AssigneeId INT NOT NULL FOREIGN KEY REFERENCES Users(Id)
)

CREATE TABLE Commits(
	Id INT PRIMARY KEY IDENTITY,
	Message VARCHAR(255) NOT NULL,
	IssueId INT FOREIGN KEY REFERENCES Issues(Id),
	RepositoryId INT NOT NULL FOREIGN KEY REFERENCES Repositories(Id),
	ContributorId INT NOT NULL FOREIGN KEY REFERENCES Users(Id)
)

CREATE TABLE Files(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(100) NOT NULL,
	Size DECIMAL(18, 2) NOT NULL,
	ParentId INT FOREIGN KEY REFERENCES Files(Id),
	CommitId INT NOT NULL FOREIGN KEY REFERENCES Commits(Id)
)

--2.	Insert

INSERT INTO Files ([Name],Size,ParentId,CommitId)
	VALUES
		('Trade.idk',2598.0,1,1),
		('menu.net',9238.31,2,2),
		('Administrate.soshy',1246.93,3,3),
		('Controller.php',7353.15,4,4),
		('Find.java',9957.86,5,5),
		('Controller.json',14034.87,3,6),
		('Operate.xix',7662.92,7,7)

INSERT INTO Issues(Title,IssueStatus,RepositoryId,AssigneeId)
	VALUES
		('Critical Problem with HomeController.cs file','open',1,4),
		('Typo fix in Judge.html','open',4,3),
		('Implement documentation for UsersService.cs','close',8,2),
		('Unreachable code in Index.cs','open',9,8)

--03. Update

UPDATE Issues
	SET IssueStatus='close'
	WHERE AssigneeId=6

--04. Delete

DELETE FROM Files
WHERE CommitId = 36

DELETE FROM Commits
WHERE RepositoryId = 3

DELETE FROM Issues
WHERE RepositoryId = 3

DELETE FROM RepositoriesContributors
WHERE RepositoryId = 3

DELETE FROM Repositories
WHERE [Name] LIKE 'Softuni-Teamwork'

--05. Commits

SELECT
	Id,Message,RepositoryId,ContributorId
	FROM Commits
	ORDER BY Id,Message,RepositoryId,ContributorId

--06. Front-end

SELECT
	Id,[Name],Size
	FROM Files
	WHERE Size>1000 AND [Name] LIKE'%html%'
	ORDER BY Size DESC, Id ASC, [Name] ASC

--07. Issue Assignment

SELECT
	i.Id,
	CONCAT(Username,' : ',Title) as IssueAssignee
	FROM Issues	i
	JOIN Users u ON u.Id=i.AssigneeId
	ORDER BY i.Id DESC,IssueAssignee

--08. Single Files

SELECT f.Id,
		f.[Name],
		CONVERT(VARCHAR(MAX), f.Size) + 'KB' AS Size
	FROM Files f
	LEFT JOIN Files pf ON pf.ParentId = f.Id
	WHERE pf.Id IS NULL
	ORDER BY f.Id ASC, f.[Name] ASC, f.Size DESC

-- 9. Commits in Repositories

SELECT TOP(5) r.Id,
		r.Name,
		COUNT(*) AS Commits
	FROM Repositories r
	JOIN Commits c ON c.RepositoryId = r.Id
	JOIN RepositoriesContributors rc ON rc.RepositoryId = r.Id
	GROUP BY r.Id, r.[Name]
	ORDER BY Commits DESC, r.Id ASC, r.[Name] ASC

--10. Average Size

SELECT
	Username,
	AVG(Size) AS Size
	FROM Users u
	JOIN Commits c ON c.ContributorId=u.Id
	JOIN Files f ON f.CommitId=c.Id
	GROUP BY Username
	ORDER BY Size DESC,Username

--11. All User Commits

CREATE FUNCTION udf_AllUserCommits(@username VARCHAR(30)) 
RETURNS INT
AS
	BEGIN
		DECLARE @result INT=(
		SELECT COUNT(@username) FROM Users u JOIN Commits c ON c.ContributorId=u.Id WHERE u.Username LIKE @username 
		)
		RETURN @result;
	END;


SELECT dbo.udf_AllUserCommits('UnderSinduxrein')

--12. Search for Files

CREATE PROCEDURE usp_SearchForFiles(@fileExtension VARCHAR(50)) 
AS
BEGIN
	SELECT
		Id,
		[Name],
		CONCAT(Size,'KB') AS Size
		FROM Files
		WHERE Name LIKE '%' + @fileExtension
		ORDER BY Id,[Name],Size
END

EXEC usp_SearchForFiles 'txt'