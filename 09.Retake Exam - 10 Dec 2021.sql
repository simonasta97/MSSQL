

CREATE TABLE Passengers(
	Id INT PRIMARY KEY IDENTITY,
	FullName VARCHAR(100) NOT NULL UNIQUE,
	Email VARCHAR(50) NOT NULL UNIQUE,
)

CREATE TABLE Pilots(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(30) NOT NULL UNIQUE,
	LastName VARCHAR(30) NOT NULL UNIQUE,
	Age TINYINT CHECK(Age >= 21 AND Age <= 62) NOT NULL,
	Rating DECIMAL(3,1) CHECK(Rating >= 0.0 AND Rating <= 10.0) 
)

CREATE TABLE AircraftTypes(
	Id INT PRIMARY KEY IDENTITY,
	TypeName VARCHAR(30) NOT NULL UNIQUE
)

CREATE TABLE Aircraft(
	Id INT PRIMARY KEY IDENTITY,
	Manufacturer VARCHAR(25) NOT NULL,
	Model VARCHAR(30) NOT NULL,
	[Year] INT NOT NULL,
	FlightHours INT,
	[Condition] VARCHAR(1) NOT NULL,
	TypeId INT NOT NULL FOREIGN KEY REFERENCES AircraftTypes(Id)
)

CREATE TABLE PilotsAircraft(
	AircraftId INT NOT NULL FOREIGN KEY REFERENCES Aircraft(Id),
	PilotId INT NOT NULL FOREIGN KEY REFERENCES Pilots(Id),
	PRIMARY KEY(AircraftId,PilotId)
)

CREATE TABLE Airports(
	Id INT PRIMARY KEY IDENTITY,
	AirportName VARCHAR(70) NOT NULL UNIQUE,
	Country VARCHAR(100) NOT NULL UNIQUE,
)

CREATE TABLE FlightDestinations(
	Id INT PRIMARY KEY IDENTITY,
	AirportId INT NOT NULL FOREIGN KEY REFERENCES Airports(Id),
	Start DATETIME NOT NULL,
	AircraftId INT NOT NULL FOREIGN KEY REFERENCES Aircraft(Id),
	PassengerId INT NOT NULL FOREIGN KEY REFERENCES Passengers(Id),
	TicketPrice DECIMAL(18,2) DEFAULT 15 NOT NULL
)


--2.	Insert

DECLARE @idx INT = 5;

WHILE(@idx<=15)
	BEGIN
		INSERT INTO Passengers(FullName,Email)
		SELECT FirstName + ' ' + LastName AS FullName,
				CONCAT(FirstName,LastName,'@gmail.com')
			FROM Pilots
			WHERE Id=@idx
			SET @idx+=1;
	END


--03. Update

UPDATE Aircraft
	SET Condition='A'
	WHERE Condition IN('C','B') 
			AND (FlightHours IS NULL OR FlightHours = 0 OR FlightHours<=100)
			AND YEAR>=2013
		
--04. Delete
ALTER TABLE FlightDestinations
	DROP CONSTRAINT FK__FlightDes__Passe__6D0D32F4

DELETE
	FROM Passengers 
	WHERE LEN(FullName) >=10

--05. Aircraft

SELECT 
	Manufacturer,
	Model,
	FlightHours,
	Condition
	FROM Aircraft
	ORDER BY FlightHours DESC

--06. Pilots and Aircraft

SELECT
	FirstName, LastName, Manufacturer, Model,FlightHours
	FROM Pilots AS	p
	JOIN PilotsAircraft AS pa ON p.Id=pa.PilotId
	JOIN Aircraft AS a ON a.Id=pa.AircraftId
	WHERE FlightHours < 304 AND FlightHours IS NOT NULL
	ORDER BY FlightHours DESC, FirstName

--07. Top 20 Flight Destinations

SELECT TOP (20)
	fd.Id AS DestinationId,
	Start,
	p.FullName,
	a.AirportName,
	TicketPrice
	FROM FlightDestinations AS fd
	JOIN Passengers AS p ON p.Id=fd.PassengerId
	JOIN Airports AS a ON a.Id=fd.AirportId
	WHERE DATEPART(DAY,Start) % 2 = 0 
	ORDER BY TicketPrice DESC,AirportName 


--08. Number of Flights for Each Aircraft

SELECT 
	a.Id AS AircraftId,
	Manufacturer,
	FlightHours,
	COUNT(AircraftId) AS FlightDestinationsCount,
	ROUND(AVG(TicketPrice), 2) AS [AvgPrice]
	FROM Aircraft AS a
	JOIN FlightDestinations AS fd ON fd.AircraftId=a.Id
	GROUP BY  a.Id,AircraftId,Manufacturer,FlightHours
	HAVING COUNT(AircraftId) >= 2
	ORDER BY FlightDestinationsCount DESC,AircraftId

--09. Regular Passengers

SELECT
	FullName,COUNT(PassengerId) AS CountOfAircraft,SUM(TicketPrice) AS TotalPayed
	FROM Passengers p
	JOIN FlightDestinations AS fd ON fd.PassengerId=p.Id
	GROUP BY PassengerId,FullName
	HAVING COUNT(PassengerId)>1 AND FullName LIKE '_a%'
	ORDER BY FullName

--10. Full Info for Flight Destinations

SELECT
	AirportName,[Start],TicketPrice,FullName,Manufacturer,Model
	FROM FlightDestinations fd
	JOIN Airports AS a ON fd.AirportId=a.Id
	JOIN Passengers AS p ON p.Id=fd.PassengerId
	JOIN Aircraft AS ac ON ac.Id=fd.AircraftId
	WHERE DATEPART(HOUR,[Start]) BETWEEN 6 AND 20  AND TicketPrice>2500
	ORDER BY Model
	
--11. Find all Destinations by Email Address

CREATE FUNCTION udf_FlightDestinationsByEmail(@email VARCHAR(MAX))
RETURNS INT
AS
	BEGIN
		DECLARE @result INT=(
		SELECT COUNT(PassengerId)
			FROM Passengers p
			JOIN FlightDestinations AS fd ON p.Id=fd.PassengerId
			WHERE p.Email=@email
			GROUP BY PassengerId)
		IF(@result IS NULL)
			SET @result=0;
		RETURN @result;
	END;
	
--12. Full Info for Airports

CREATE PROC usp_SearchByAirportName(@airportName VARCHAR(70))
AS
BEGIN
	SELECT AirportName,
	   Fullname,
	   CASE
			WHEN TicketPrice <= 400 THEN 'Low'
			WHEN TicketPrice BETWEEN 401 AND 1500 THEN 'Medium'
			ELSE 'High'
	   END AS [LevelOfTicketPrice],
	   Manufacturer,
	   Condition,
	   TypeName
	FROM Airports ai
	JOIN FlightDestinations fd ON fd.AirportId = ai.Id
	JOIN Passengers p ON fd.PassengerId = p.Id
	JOIN Aircraft a ON fd.AircraftId = a.Id
	JOIN AircraftTypes ait ON a.TypeId = ait.Id
	WHERE AirportName = @airportName
	ORDER BY Manufacturer,Fullname
END
