CREATE DATABASE CigarShop

CREATE TABLE Sizes(
	Id INT PRIMARY KEY IDENTITY,
	Length INT NOT NULL CHECK(Length BETWEEN 10 AND 25),
	RingRange DECIMAL(3,2) NOT NULL CHECK(RingRange BETWEEN 1.50 AND 7.50)
)

CREATE TABLE Tastes(
	Id INT PRIMARY KEY IDENTITY,
	TasteType VARCHAR(20) NOT NULL,
	TasteStrength VARCHAR(15) NOT NULL,
	ImageURL VARCHAR(100) NOT NULL
)

CREATE TABLE Brands(
	Id INT PRIMARY KEY IDENTITY,
	BrandName VARCHAR(30) NOT NULL UNIQUE,
	BrandDescription VARCHAR(MAX)
)

CREATE TABLE Cigars(
	Id INT PRIMARY KEY IDENTITY,
	CigarName VARCHAR(80) NOT NULL,
	BrandId INT NOT NULL FOREIGN KEY REFERENCES Brands(Id),
	TastId INT NOT NULL FOREIGN KEY REFERENCES Tastes(Id),
	SizeId INT NOT NULL FOREIGN KEY REFERENCES Sizes(Id),
	PriceForSingleCigar DECIMAL(18,2) NOT NULL,
	ImageURL VARCHAR(100) NOT NULL
)

CREATE TABLE Addresses(
	Id INT PRIMARY KEY IDENTITY,
	Town VARCHAR(30) NOT NULL,
	Country VARCHAR(30) NOT NULL,
	Streat VARCHAR(100) NOT NULL,
	ZIP VARCHAR(20) NOT NULL,
)

CREATE TABLE Clients(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(30) NOT NULL,
	LastName VARCHAR(30) NOT NULL,
	Email VARCHAR(50) NOT NULL,
	AddressId INT NOT NULL FOREIGN KEY REFERENCES Addresses(Id),
)

CREATE TABLE ClientsCigars(
	ClientId INT NOT NULL FOREIGN KEY REFERENCES Clients(Id),
	CigarId INT NOT NULL FOREIGN KEY REFERENCES Cigars(Id),
	PRIMARY KEY (ClientId,CigarId)
)

--

--03. Update
UPDATE Cigars
	SET PriceForSingleCigar+=PriceForSingleCigar*0.2
	WHERE TastId=1

UPDATE Brands
	SET BrandDescription='New description'
	WHERE BrandDescription IS NULL

--04. Delete
ALTER TABLE Clients
	DROP CONSTRAINT FK__Clients__Address__45F365D3

DELETE FROM Addresses
	WHERE Country LIKE 'C%'

--05. Cigars by Price

SELECT
	CigarName,PriceForSingleCigar,ImageURL
	FROM Cigars
	ORDER BY PriceForSingleCigar,CigarName DESC

--06. Cigars by Taste

SELECT
	c.Id,CigarName,PriceForSingleCigar,TasteType,TasteStrength
	FROM Cigars c
	LEFT JOIN Tastes t ON t.Id=c.TastId
	WHERE TastId IN (2,3)
	ORDER BY PriceForSingleCigar DESC

--07. Clients without Cigars

SELECT
	Id,
	CONCAT(FirstName,' ',LastName) AS ClientName,
	Email
	FROM Clients c
	LEFT JOIN ClientsCigars cig ON cig.ClientId=c.Id
	WHERE CigarId IS NULL
	ORDER BY ClientName

--08. First 5 Cigars

SELECT TOP (5)
	CigarName,PriceForSingleCigar,ImageURL
	FROM Cigars c
	RIGHT JOIN Sizes s ON s.Id=c.SizeId
	WHERE (s.Length>=12 AND (CigarName LIKE '%ci' OR CigarName LIKE'Ci%' OR CigarName LIKE '%ci%')) OR (PriceForSingleCigar>50.00 AND s.RingRange>2.55)
	ORDER BY CigarName,PriceForSingleCigar DESC

--09. Clients with ZIP Codes

SELECT
	CONCAT(c.FirstName,' ',c.LastName) AS FullName,
	Country,
	ZIP,
	CONCAT('$',MAX(PriceForSingleCigar)) AS CigarPrice
	FROM Clients c
	JOIN  Addresses a ON a.Id=c.AddressId
	JOIN ClientsCigars cig ON c.Id=cig.ClientId
	JOIN Cigars cc ON cc.Id=cig.CigarId
	GROUP BY c.FirstName,c.LastName,Country,ZIP
	HAVING NOT ZIP LIKE '%[^0-9]%'
	ORDER BY FullName

--10. Cigars by Size

SELECT
	LastName,
	AVG(Length) AS CiagrLength,
	CEILING(s.RingRange) AS CiagrRingRange
	FROM Clients c
	JOIN ClientsCigars cig ON cig.ClientId=c.Id
	JOIN Cigars cc ON cc.Id=cig.CigarId
	JOIN Sizes s ON s.Id=cc.SizeId
	GROUP BY LastName,[Length],RingRange,CigarId
	HAVING NOT CigarId IS NULL
	ORDER BY CiagrLength DESC

--11. Client with Cigars

CREATE FUNCTION udf_ClientWithCigars(@name VARCHAR(30)) 
RETURNS INT
AS
BEGIN
	DECLARE @result INT=(SELECT COUNT(CigarId) FROM ClientsCigars cc JOIN Clients c ON c.Id=cc.ClientId WHERE @name=c.FirstName)
	RETURN @result;
END;

--12. Search for Cigar with Specific Taste

CREATE PROCEDURE usp_SearchByTaste(@taste VARCHAR(20))
AS
	BEGIN
		SELECT
			CigarName,
			CONCAT('$',PriceForSingleCigar) AS Price,
			TasteType,
			BrandName,
			CONCAT([Length],' cm') AS CigarLength,
			CONCAT(RingRange,' cm') AS CigarRingRange
			FROM Cigars c
			LEFT JOIN Tastes t ON t.Id=c.TastId
			JOIN Brands b ON b.Id=c.BrandId
			JOIN Sizes s ON s.Id=c.SizeId
			WHERE t.TasteType=@taste
			ORDER BY CigarLength,CigarRingRange  DESC
	END
