--Create Database
CREATE DATABASE Minions

--Create tables
CREATE TABLE [Minions](
	[Id] INT PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	[Age] INT
)

CREATE TABLE [Towns](
	[Id] INT PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
)

--Alter Minions Table
ALTER TABLE [Minions]
ADD [TownId] INT FOREIGN KEY REFERENCES [Towns](Id)

--Insert Records in Both Tables
INSERT INTO Towns(Id, [Name])
	VALUES
		(1, 'Sofia'),
		(2, 'Plovdiv'),
		(3, 'Varna')

INSERT INTO Minions(Id, [Name], Age, TownId)
	VALUES
		(1, 'Kevin', 22, 1),
		(2, 'Bob', 15, 3),
		(3, 'Steward', NULL, 2)

--Truncate Table Minions
TRUNCATE TABLE Minions

--Drop All Tables
DROP TABLE Minions
DROP TABLE Towns

--Create Table People
CREATE TABLE [People](
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(200) NOT NULL,
	[Picture] VARBINARY(MAX)
	CHECK (DATALENGTH([Picture])<=2000000),
	[Height] DECIMAL(3,2),
	[Weight] DECIMAL(5,2),
	Gender CHAR(1) NOT NULL
	CHECK (Gender IN('m', 'f')),
	[Birthdate] DATETIME2 NOT NULL,
	[Biography] NVARCHAR(MAX)
)

INSERT INTO People([Name], Height, [Weight], Gender, Birthdate)
	VALUES
		('Pesho', 1.7, 62.1, 'm', '1994-05-02'),
		('Gosho', 1.56, 63.3, 'm', '1994-05-02'),
		('Ivan', 1.78, 77.3, 'm', '1994-05-02'),
		('Dragan', 1.87, 57.7, 'm', '1994-05-02'),
		('Stamat', 1.75, 67.6, 'm', '1994-05-02')

--Create Table Users
CREATE TABLE [Users](
	[Id] BIGINT PRIMARY KEY IDENTITY,
	[Username] VARCHAR(30) UNIQUE NOT NULL,
	[Password] VARCHAR(26) NOT NULL,
	[ProfilePicture] VARCHAR(MAX),
	[LastLoginTime] DATETIME2 NOT NULL,
	[IsDeleted] BIT NOT NULL
)

INSERT INTO Users(Username, [Password], LastLoginTime, IsDeleted)
	VALUES
			('Pesho0', '123456', '05.19.2020', 0),
			('Gosho', '123456', '05.19.2020', 1),
			('Ivan', '123456', '05.19.2020', 0),
			('Stamat', '123456', '05.19.2020', 0),
			('Nikola', '123456', '05.19.2020', 1)

--Change Primary Key
ALTER TABLE Users
DROP CONSTRAINT [PK__Users__3214EC077FBFBD62]

ALTER TABLE Users
ADD CONSTRAINT [PK_Users_CompositeIdUsername] PRIMARY KEY ([Id],[Username])

--Add Check Constraint
ALTER TABLE Users
ADD CONSTRAINT CK_Users_PasswordLength
CHECK(LEN([Password]) >= 5)

--Set Default Value of a Field
ALTER TABLE Users
ADD CONSTRAINT DF_Users_LastLoginTime
DEFAULT GETDATE() FOR LastLoginTime

--Set Unique Field
ALTER TABLE Users
DROP CONSTRAINT PK_Users_CompositeIdUsername

ALTER TABLE Users
ADD CONSTRAINT PK_Users_Id
PRIMARY KEY(Id)

ALTER TABLE Users
ADD CONSTRAINT CK_Users_UsernameLength
CHECK(LEN(Username) >= 3)

--Movies Database
CREATE DATABASE Movies

USE Movies


CREATE TABLE Directors(
	[Id] INT PRIMARY KEY IDENTITY,
	[DirectorName] VARCHAR(50) NOT NULL,
	[Notes] VARCHAR(MAX)
)

INSERT INTO Directors([DirectorName])
	VALUES
		('Pesho'),
		('Gosho'),
		('Ivan'),
		('Stamat'),
		('Stoyan')

CREATE TABLE Genres(
	[Id] INT PRIMARY KEY IDENTITY,
	[GenreName] VARCHAR(50) NOT NULL,
	[Notes] VARCHAR(MAX)
)

INSERT INTO Genres([GenreName])
	VALUES
		('Petkp'),
		('Dragan'),
		('Shisho'),
		('Stamat'),
		('Stoyan')

CREATE TABLE Categories(
	[Id] INT PRIMARY KEY IDENTITY,
	[CategoryName] VARCHAR(50) NOT NULL,
	[Notes] VARCHAR(MAX)
)

INSERT INTO Categories(CategoryName)
	VALUES
		('Petko'),
		('Ivan'),
		('Misho'),
		('Ivo'),
		('Stoyan')

CREATE TABLE Movies(
	[Id] INT PRIMARY KEY IDENTITY,
	[Title] NVARCHAR(50) NOT NULL,
	[DirectorId] INT FOREIGN KEY REFERENCES Directors(Id),
	[CopyrightYear] DATE NOT NULL,
	[Length] TIME NOT NULL,
	[GenreId] INT FOREIGN KEY REFERENCES Genres(Id),
	[CategoryId] INT FOREIGN KEY REFERENCES Categories(Id),
	[Rating] DECIMAL(2,1) NOT NULL,
	[Notes] VARCHAR(MAX)
)

INSERT INTO Movies(Title, DirectorId, CopyrightYear, [Length], GenreId, CategoryId, Rating)
	VALUES
		('Matrix', 1, '2000-02-03', '03:33', 2, 'Action', 5.0),
		('Matrix', 3, '2000-02-03', '03:33', 2, 'Action', 5.0),
		('Matrix', 5, '2000-02-03', '03:33', 2, 'Action', 5.0),
		('Matrix', 3, '2000-02-03', '03:33', 2, 'Action', 5.0),
		('Matrix', 2, '2000-02-03', '03:33', 2, 'Action', 5.0)

--Car Rental Database
CREATE DATABASE CarRental

CREATE TABLE Categories(
	[Id] INT PRIMARY KEY IDENTITY,
	[CategoryName] VARCHAR(50) NOT NULL,
	[DailyRate] DECIMAL(4,1) NOT NULL,
	[WeeklyRate] DECIMAL(4,1) NOT NULL,
	[MonthlyRate] DECIMAL(4,1) NOT NULL,
	[WeekendRate] DECIMAL(4,1) NOT NULL,
)

INSERT INTO Categories(CategoryName, DailyRate, WeeklyRate, MonthlyRate,
 WeekendRate)
	VALUES
		('Sedan', 20.0, 70.50, 200.0, 50.0),
		('SUV', 10.0, 70.50, 200.0, 50.0),
		('Truck', 40.0, 80.50, 300.0, 50.0)

CREATE TABLE Cars(
	[Id] INT PRIMARY KEY IDENTITY,
	[PlateNumber] VARCHAR(10) NOT NULL,
	[Manufacturer] VARCHAR(20) NOT NULL,
	[Model] VARCHAR(20) NOT NULL,
	[CarYear] INT NOT NULL,
	[CategoryId] INT NOT NULL FOREIGN KEY REFERENCES Categories(Id),
	[Doors] TINYINT NOT NULL,
	[Picture] VARCHAR(MAX),
	[Condition] VARCHAR(20) NOT NULL,
	[Available] CHAR(1) NOT NULL
	CHECK (Available IN('Y', 'N'))
)

INSERT INTO Cars(PlateNumber, Manufacturer, Model, CarYear, CategoryId, Doors, Condition, Available)
	VALUES
		('1XL626', 'Ford', 'Fusion', 2011, 1, 4, 'Good', 'Y'),
		('NI3340', 'Infiniti', 'QX60', 2019, 2, 5, 'Excellent', 'Y'),
		('1HL377', 'Ford', 'Mustang', 2011, 1, 4, 'Very Good', 'N')

CREATE TABLE Employees(
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] VARCHAR(30) NOT NULL,
	[LastName] VARCHAR(30) NOT NULL,
	[Title] VARCHAR(10),
	[Notes] VARCHAR(MAX)
)

INSERT INTO Employees(FirstName, LastName)
	VALUES
		('John', 'Smith'),
		('Ivan', 'Petkov'),
		('Pesho', 'Peshev')

CREATE TABLE Customers(
	[Id] INT PRIMARY KEY IDENTITY,
	[DriverLicenceNumber] INT NOT NULL,
	[FullName] VARCHAR(50) NOT NULL,
	[Address] VARCHAR(100) NOT NULL,
	[City] VARCHAR(20) NOT NULL,
	[ZIPCode] INT NOT NULL,
	[Notes] VARCHAR(MAX)
)

INSERT INTO Customers (DriverLicenceNumber, FullName, [Address], City, ZIPCode)
	VALUES
		(794527, 'Pesho Petkov', 'knyaz Boris 26', 'Sofia', 5000),
		(442327, 'Stamat Petkov', 'Peshtersko Shose 43', 'Sofia', 5000),
		(235375, 'Ivana Georgieva', 'Alexander Stamboliyski 3', 'Plovdiv', 4000)

CREATE TABLE RentalOrders(
	[Id] INT PRIMARY KEY IDENTITY,
	[EmployeeId] INT NOT NULL FOREIGN KEY REFERENCES Employees(Id),
	[CustomerId] INT NOT NULL FOREIGN KEY REFERENCES Customers(Id),
	[CarId] INT NOT NULL FOREIGN KEY REFERENCES Cars(Id),
	[TankLevel] VARCHAR(10) NOT NULL,
	[KilometrageStart] INT NOT NULL,
	[KilometrageEnd] INT NOT NULL,
	[TotalKilometrage] INT NOT NULL,
	[StartDate] DATE NOT NULL,
	[EndDate] DATE,
	[TotalDays] INT,
	[RateApplied] DECIMAL(2,1),
	[TaxRate] DECIMAL(2,1),
	[OrderStatus] VARCHAR(20),
	[Notes] VARCHAR(MAX)
)

INSERT INTO RentalOrders(EmployeeId, CustomerId, CarId, TankLevel,
KilometrageStart, KilometrageEnd, TotalKilometrage, StartDate, EndDate)
	VALUES
		(1, 2, 1, 'Full', 34000, 34500, 500, '2021.01.10', NULL),
		(2, 2, 3, 'Half', 64000, 65000, 1000, '2021.01.10', '2021.01.14'),
		(3, 1, 1, 'Full', 24000, 24400, 400, '2021.01.10', NULL)

--Hotel Database

CREATE DATABASE Hotel

USE Hotel

CREATE TABLE Employees(
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] VARCHAR(50) NOT NULL,
	[LastName] VARCHAR(50) NOT NULL,
	[Title] VARCHAR(50) NOT NULL,
	[Notes] VARCHAR(MAX)
)

INSERT INTO Employees([FirstName],[LastName],[Title])
	VALUES
		('Mihaela', 'Petrova', 'CEO'),
		('Pesho', 'Kostov', 'CFO'),
		('Mike', 'Smith', 'CTO')

CREATE TABLE Customers(
	[AccountNumber] INT PRIMARY KEY,
	[FirstName] VARCHAR(50) NOT NULL,
	[LastName] VARCHAR(50) NOT NULL,
	[PhoneNumber] CHAR(10) NOT NULL, 
	[EmergencyName] VARCHAR(50) NOT NULL,
	[EmergencyNumber] CHAR(10) NOT NULL, 
	[Notes] VARCHAR(MAX)
)

INSERT INTO Customers
	VALUES
		(120, 'Gosho', 'Ivanov', '0883563481', 'Pesho', '0884246732', NULL),
		(121, 'Pesho', 'Peshev', '0887363423', 'Pesho', '0889746732', NULL),
		(122, 'Mimi', 'Ivanova', '0888563367', 'Pesho', '0884242732', NULL)

CREATE TABLE RoomStatus(
	[RoomStatus] VARCHAR(30) NOT NULL,
	[Notes] VARCHAR(MAX)
)

INSERT INTO RoomStatus(RoomStatus)
	VALUES
		('Cleaning'),
		('Available'),
		('Not Available')

CREATE TABLE RoomTypes(
	[RoomType] VARCHAR(20) NOT NULL,
	[Notes] VARCHAR(MAX)
)

INSERT INTO RoomTypes(RoomType)
	VALUES
		('Apartment'),
		('One Bedroom'),
		('Two Bedroom')

CREATE TABLE BedTypes(
	[BedType] VARCHAR(20) NOT NULL,
	[Notes] VARCHAR(MAX)
)

INSERT INTO BedTypes(BedType)
	VALUES
		('Queen'),
		('King'),
		('Double')

CREATE TABLE Rooms(
	[RoomNumber] INT PRIMARY KEY, 
	[RoomType] VARCHAR(20) NOT NULL, 
	[BedType] VARCHAR(20) NOT NULL, 
	[Rate] INT, 
	[RoomStatus] VARCHAR(20) NOT NULL,
	[Notes] VARCHAR(MAX)
)

INSERT INTO Rooms
	VALUES
		(120, 'Apartment', 'King', 10, 'Available', NULL),
		(121, 'Apartment', 'King', 10, 'Available', NULL),
		(122, 'One Bedroom', 'Queen', 9, 'Available', NULL)

CREATE TABLE Payments(
	[Id] INT PRIMARY KEY, 
	[EmployeeId] INT NOT NULL, 
	[PaymentDate] DATETIME NOT NULL,
	[AccountNumber] INT NOT NULL,
	[FirstDateOccupied] DATETIME NOT NULL, 
	[LastDateOccupied] DATETIME NOT NULL,
	[TotalDays] INT NOT NULL, 
	[AmountCharged] DECIMAL(15,2), 
	[TaxRate] INT,
	[TaxAmount] INT, 
	[PaymentTotal] DECIMAL(15,2), 
	[Notes] VARCHAR(MAX)
)

INSERT INTO Payments 
	VALUES
		(1, 1, GETDATE(), 120, '5/5/2012', '5/8/2012', 3, 450.24, NULL, NULL, 450.24, NULL),
		(2, 1, GETDATE(), 121, '5/5/2012', '5/10/2012', 5, 530.14, NULL, NULL, 523.24, NULL),
		(3, 1, GETDATE(), 122, '5/5/2012', '5/12/2012', 7, 650.24, NULL, NULL, 1450.24, NULL)

CREATE TABLE Occupancies(
	[Id] INT PRIMARY KEY, 
	[EmployeeId] INT NOT NULL, 
	[DateOccupied] DATETIME NOT NULL,
	[AccountNumber] INT NOT NULL, 
	[RoomNumber] INT NOT NULL,
	[RateApplied] INT,
	[PhoneCharge] DECIMAL(15,2),
	[Notes] VARCHAR(MAX)
)

INSERT INTO Occupancies 
	VALUES
		(1, 120, GETDATE(), 120, 120, 0, 0, NULL),
		(2, 122, GETDATE(), 120, 120, 0, 0, NULL),
		(3, 121, GETDATE(), 120, 120, 0, 0, NULL)

--Create SoftUni Database

CREATE DATABASE SoftUni

USE SoftUni

CREATE TABLE Towns(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Addresses(
	[Id] INT PRIMARY KEY IDENTITY,
	[AddressText] NVARCHAR(100) NOT NULL,
	[TownId] INT FOREIGN KEY REFERENCES Towns(Id)
)

CREATE TABLE Departments(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Employees(
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] VARCHAR(50) NOT NULL,
	[MiddleName] VARCHAR(50) NOT NULL,
	[LastName] VARCHAR(50) NOT NULL,
	[JobTitle] VARCHAR(50) NOT NULL,
	[DepartmentId] INT FOREIGN KEY REFERENCES Departments(Id),
	[HireDate] DATE NOT NULL,
	[Salary] DECIMAL (7,2) NOT NULL,
	[AddressId] INT FOREIGN KEY REFERENCES Addresses(Id),
)

INSERT INTO Towns([Name])
	VALUES
		('Sofia'),
		('Plovdiv'),
		('Varna'),
		('Burgas')

INSERT INTO Departments([Name])
	VALUES
		('Engineering'),
		('Sales'),
		('Marketing'),
		('Software Development'),
		('Quality Assurance')

INSERT INTO Employees(FirstName, MiddleName, LastName, JobTitle, DepartmentId, HireDate, Salary)
	VALUES
			('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, '02/01/2013', 3500.00),
			('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, '03/02/2004', 4000.00),
			('Maria', 'Petrova', 'Ivanova', 'Intern', 5, '08/28/2016', 525.25),
			('Georgi', 'Teziev', 'Ivanov', 'CEO', 2, '12/09/2007', 3000.00),
			('Peter', 'Pan', 'Pan', 'Intern', 3, '08/28/2016', 599.88)

--Basic Select All Fields

SELECT * FROM Towns

SELECT * FROM Departments

SELECT * FROM Employees	

--Basic Select All Fields and Order Them


SELECT * FROM Towns
	ORDER BY [Name]

SELECT * FROM Departments
	ORDER BY [Name]

SELECT * FROM Employees
	ORDER BY [Salary] DESC

--Basic Select Some Fields
SELECT [Name] FROM Towns
	ORDER BY [Name]

SELECT [Name] FROM Departments
	ORDER BY [Name]

SELECT [FirstName], [LastName], [JobTitle], [Salary] FROM Employees
	ORDER BY [Salary] DESC

--Increase Employees Salary

UPDATE Employees
SET Salary=Salary+Salary*0.1
SELECT Salary FROM Employees

--Decrease Tax Rate
USE [Hotel]

UPDATE Payments
SET TaxRate = TaxRate * 0.97

SELECT TaxRate FROM Payments

-- Problem 24. Delete All Records

TRUNCATE TABLE Occupancies
