CREATE DATABASE Zoo

CREATE TABLE Owners(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	PhoneNumber VARCHAR(15) NOT NULL,
	[Address] VARCHAR(50)
)

CREATE TABLE AnimalTypes(
	Id INT PRIMARY KEY IDENTITY,
	AnimalType VARCHAR(30) NOT NULL
)

CREATE TABLE Cages(
	Id INT PRIMARY KEY IDENTITY,
	AnimalTypeId INT NOT NULL FOREIGN KEY REFERENCES AnimalTypes(Id)
)

CREATE TABLE Animals(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL,
	BirthDate DATE NOT NULL,
	OwnerId INT FOREIGN KEY REFERENCES Owners(Id),
	AnimalTypeId INT NOT NULL FOREIGN KEY REFERENCES AnimalTypes(Id)
)

CREATE TABLE AnimalsCages(
	CageId INT NOT NULL FOREIGN KEY REFERENCES Cages(Id),
	AnimalId INT NOT NULL FOREIGN KEY REFERENCES Animals(Id),
	PRIMARY KEY(CageId,AnimalId)
)

CREATE TABLE VolunteersDepartments(
	Id INT PRIMARY KEY IDENTITY,
	DepartmentName VARCHAR(30) NOT NULL
)

CREATE TABLE Volunteers(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	PhoneNumber VARCHAR(15) NOT NULL,
	[Address] VARCHAR(50),
	AnimalId INT FOREIGN KEY REFERENCES Animals(Id),
	DepartmentId INT NOT NULL FOREIGN KEY REFERENCES VolunteersDepartments(Id)
)

--INSERT

INSERT INTO Volunteers([Name],PhoneNumber,[Address],AnimalId,DepartmentId)
	VALUES
		('Anita Kostova','0896365412','Sofia, 5 Rosa str.',15,1),
		('Dimitur Stoev','0877564223',NULL,42,4),
		('Kalina Evtimova','0896321112','Silistra, 21 Breza str.',9,7),
		('Stoyan Tomov','0898564100','Montana, 1 Bor str.',18,8),
		('Boryana Mileva','0888112233',NULL,31,5)

INSERT INTO Animals([Name],BirthDate,OwnerId,AnimalTypeId)
	VALUES
		('Giraffe','2018-09-21',21,1),
		('Harpy Eagle','2015-04-17',15,3),
		('Hamadryas Baboon','2017-11-02',NULL,1),
		('Tuatara','2021-06-30',2,4)

--UPDATE

UPDATE Animals
	SET OwnerId=4
	WHERE OwnerId IS NULL

--DELETE
DELETE Volunteers WHERE DepartmentId=2

DELETE VolunteersDepartments WHERE Id=2


--05. Volunteers

SELECT
	[Name],
	PhoneNumber,
	[Address],
	AnimalId,
	DepartmentId
	FROM Volunteers
	ORDER BY [Name],AnimalId,DepartmentId

--06. Animals data

SELECT
	[Name],
	AnimalType,
	FORMAT(BirthDate,'dd.MM.yyyy') AS BirthDate
	FROM Animals a 
	JOIN AnimalTypes ats ON ats.Id=a.AnimalTypeId
	ORDER BY a.Name

--07. Owners and Their Animals

SELECT TOP(5)
	o.[Name] AS [Owner],
	COUNT(a.Id) AS CountOfAnimals
	FROM Owners o
	JOIN Animals a ON a.OwnerId=o.Id
	GROUP BY o.[Name]
	ORDER BY CountOfAnimals DESC,[Owner]

--08. Owners, Animals and Cages

SELECT
	CONCAT(o.Name,'-',a.Name) AS OwnersAnimals,
	PhoneNumber,
	CageId
	FROM Owners o
	JOIN Animals a ON a.OwnerId=o.Id
	JOIN AnimalsCages ac ON ac.AnimalId=a.Id
	WHERE AnimalTypeId=1
	ORDER BY o.[Name],a.Name DESC

--09. Volunteers in Sofia

SELECT
	[Name],
	PhoneNumber,
	SUBSTRING([Address],CHARINDEX(', ',[Address]) +2,100) AS [Address]
	FROM Volunteers v
	WHERE DepartmentId=2 AND ([Address] LIKE 'Sofia%' OR  [Address] LIKE ' Sofia%')
	ORDER BY [Name]

--10. Animals for Adoption

SELECT
	[Name],
	DATEPART(YEAR,BirthDate) AS BirthYear,
	AnimalType
	FROM Animals a
	JOIN AnimalTypes atp ON atp.Id=a.AnimalTypeId
	WHERE OwnerId IS NULL AND DATEDIFF(YEAR,BirthDate,'2022-01-01')<5 AND AnimalTypeId IN (1,2,4,5,6)
	ORDER BY [Name]

--11. All Volunteers in a Department

CREATE FUNCTION udf_GetVolunteersCountFromADepartment (@VolunteersDepartment VARCHAR(30)) 
RETURNS INT
AS
BEGIN
	DECLARE @result INT=(SELECT COUNT(v.DepartmentId) FROM VolunteersDepartments vd JOIN Volunteers v ON v.DepartmentId=vd.Id GROUP BY DepartmentName HAVING vd.DepartmentName=@VolunteersDepartment)
	RETURN @result;
END;

--12.	Animals with Owner or Not

CREATE PROCEDURE usp_AnimalsWithOwnersOrNot(@AnimalName VARCHAR(30))
AS
BEGIN
	SELECT a.[Name], 
			CASE	
				WHEN OwnerId IS NULL THEN 'For adoption'
				ELSE o.[Name]
			END AS OwnersName
			FROM Animals a 
			LEFT JOIN Owners o ON a.OwnerId=o.Id
			GROUP BY a.[Name],OwnerId,o.[Name]
			HAVING a.[Name] LIKE @AnimalName
END