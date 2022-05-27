CREATE DATABASE EntityRelationsDemo

-- Problem 1. One-To-One Relationship

CREATE TABLE Passports(
	PassportID INT PRIMARY KEY IDENTITY,
	PassportNumber CHAR(8) NOT NULL
)

CREATE TABLE Persons(
	PersonID INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(50) NOT NULL,
	Salary DECIMAL(7,2) NOT NULL,
	PassportID INT NOT NULL FOREIGN KEY REFERENCES Passports(PassportID) UNIQUE
)

INSERT INTO Passports(PassportID,PassportNumber)
	VALUES
		(101,'N34FG21B'),
		(102,'K65LO4R7'),
		(103,'ZE657QP2')

INSERT INTO Persons(FirstName, Salary, PassportID)
	VALUES
		('Roberto', 43300.00, 102),
		('Tom', 56100.00, 103),
		('Yana', 60200.00, 101)

--Problem 2. One-To-Many Relationship

CREATE TABLE Manufacturers(
	ManufacturerID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	EstablishedOn DATE NOT NULL
)

CREATE TABLE Models(
	ModelID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	ManufacturerID INT FOREIGN KEY REFERENCES Manufacturers(ManufacturerID) NOT NULL
)

INSERT INTO Manufacturers([Name],EstablishedOn)
	VALUES
		('BMW','07/03/1916'),
		('Tesla','01/01/2003'),
		('Lada','01/05/1966')

INSERT INTO Models([Name],ManufacturerID)
	VALUES
		('X1',1),
		('i6',1),
		('ModelS',2),
		('ModelX',2),
		('Model3',2),
		('Nova',3)

--03. Many-To-Many Relationship

CREATE TABLE Students(
	StudentID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Exams(
	ExamID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE StudentsExams(
	StudentID INT FOREIGN KEY REFERENCES Students(StudentID),
	ExamID INT FOREIGN KEY REFERENCES Exams(ExamID),
	PRIMARY KEY(StudentID,ExamID)
)

INSERT INTO Students([Name])
	VALUES
		('Mila'),
		('Toni'),
		('Ron')

INSERT INTO Exams([Name])
	VALUES
		('SpringMVC'),
		('Neo4j'),
		('Oracle 11g')

INSERT INTO StudentsExams(StudentID, ExamID)
	VALUES
		(1, 101),
		(1, 102),
		(2, 101),
		(3, 103),
		(2, 102),
		(2, 103)

SELECT s.[Name], e.[Name]
	FROM StudentsExams AS se
	JOIN Students AS s ON se.StudentID = s.StudentID
	JOIN Exams AS e ON se.ExamID = e.ExamID

--04. Self-Referencing

CREATE TABLE Teachers(
	TeacherID INT PRIMARY KEY,
	[Name] VARCHAR(50) NOT NULL,
	ManagerID INT FOREIGN KEY REFERENCES Teachers(TeacherID)
)

INSERT INTO Teachers(TeacherID,[Name],ManagerID)
	VALUES
		(101,'John',NULL),
		(102,'Maya',106),
		(103,'Silvia',106),
		(104,'Ted',105),
		(105,'Mark',101),
		(106,'Greta',101)

-- Problem 5. Online Store Database

CREATE DATABASE OnlineStore

CREATE TABLE Cities(
	CityID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Custumers(
	CustumerID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	Birthday DATE NOT NULL,
	CityID INT NOT NULL FOREIGN KEY REFERENCES Cities(CityID)
)

CREATE TABLE Orders(
	OrderID INT PRIMARY KEY IDENTITY,
	CustumerID INT NOT NULL FOREIGN KEY REFERENCES Custumers(CustumerID)
)

CREATE TABLE ItemTypes(
	ItemTypeID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Items(
	ItemID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	ItemTypeID INT NOT NULL FOREIGN KEY REFERENCES ItemTypes(ItemTypeID)
)

CREATE TABLE OrderItems(
	OrderID INT NOT NULL FOREIGN KEY REFERENCES Orders(OrderID),
	ItemID INT NOT NULL FOREIGN KEY REFERENCES Items(ItemID),
	PRIMARY KEY(OrderID,ItemID)
)

--06. University Database

CREATE DATABASE University

CREATE TABLE Majors(
	MajorID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Students(
	StudentID INT PRIMARY KEY IDENTITY,
	StudentNumber CHAR(10) NOT NULL,
	StudentName VARCHAR(50) NOT NULL,
	MajorID INT NOT NULL FOREIGN KEY REFERENCES Majors(MajorID)
)

CREATE TABLE Payments(
	PaymentID INT PRIMARY KEY IDENTITY,
	PaymentDate DATE NOT NULL,
	PaymentAmount DECIMAL(7,2) NOT NULL,
	StudentID INT NOT NULL FOREIGN KEY REFERENCES Students(StudentID)
)

CREATE TABLE Subjects(
	SubjectID INT PRIMARY KEY IDENTITY,
	SubjectName VARCHAR(50) NOT NULL
)

CREATE TABLE Agenda(
	StudentID INT NOT NULL FOREIGN KEY REFERENCES Students(StudentID),
	SubjectID INT NOT NULL FOREIGN KEY REFERENCES Subjects(SubjectID),
	PRIMARY KEY(StudentID, SubjectID)
)


--09. *Peaks in Rila

SELECT m.MountainRange, p.PeakName, p.Elevation
	FROM Mountains AS m
	JOIN Peaks AS p ON m.Id = p.MountainId
	WHERE m.MountainRange = 'Rila'
	ORDER BY p.Elevation DESC