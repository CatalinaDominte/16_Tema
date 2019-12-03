CREATE DATABASE OnlineShop
USE [OnlineShop]
GO
CREATE TABLE Customer
(
Id INT NOT NULL PRIMARY KEY IDENTITY (1,1),
[Name] NVARCHAR(150) NOT NULL,
Email NVARCHAR(100) NOT NULL CHECK( Email like '%_@__%._%'),

)
INSERT INTO Customer([Name],Email)
VALUES
('Georgescu Mihai', 'mihai.georgescu@gmai.com'),
('Popescu Ioan', 'ioan.popescu@wantsome.com'),
('Balint Alina', 'alina.balint@wantsome.com'),
('Savin George', 'george.savin@yahoo.com');
CREATE TABLE Employee
(
Id INT NOT NULL PRIMARY KEY IDENTITY (1,1),
[Name] NVARCHAR(150) NOT NULL,
Email NVARCHAR(100) NOT NULL CHECK( Email like '%_@__%._%'),
)
INSERT INTO Employee ([Name],Email)
VALUES
('Dominte Catalina', 'dominte.catalina@gmail.com'),
('Ciortescu Raluca', 'raluca.ciortescu@wantsome.com'),
('Clint Mihai', 'mihai.clint@yahoo.com');
CREATE TABLE Category
(
Id INT NOT NULL PRIMARY KEY IDENTITY (1,1),
[Name] NVARCHAR(150) NOT NULL,
EmployeeId INT NOT NULL,
FOREIGN KEY (EmployeeId) REFERENCES Employee(Id)
)
INSERT INTO Category([Name], EmployeeId)
VALUES
('Pantaloni', 1),
('Camasi', 2),
('Bluze', 3),
('Lenjerie', 1),
('Rochii', 2),
('Geci', 3),
('Paltoane', 1);
CREATE TABLE Product
(
Id INT NOT NULL PRIMARY KEY IDENTITY (1,1),
[Name] NVARCHAR(150) NOT NULL,
CategoryId INT NOT NULL,
[Description] NVARCHAR(500),
Price decimal (9,2) NOT NULL,
FOREIGN KEY (CategoryId) REFERENCES Category(Id)
)
INSERT INTO Product ([Name],CategoryId,[Description],Price)
VALUES
('Pantaloni Barbatesti', 1, 'culori disponibile: rosu, negru si verde', 75),
('Pantaloni Dama', 1, 'culori disponibile: rosu, negru si verde', 70),
('Camasi Barbatesti', 2, 'culori disponibile: rosu, negru si verde', 60),
('Camasi Dama', 2, 'culori disponibile: rosu, negru si verde', 55),
('Paltoane Barbatesti', 7, 'culori disponibile: negru ', 175),
('Paltoane Dama', 7, 'culori disponibile: rosu, negru si verde', 200),
('Geci Barbatesti', 6, 'culori disponibile: rosu, negru si verde', 180),
('Rochii seara', 5, 'culori disponibile: rosu, negru si verde', 200),
('Rochii zi', 5, 'culori disponibile: rosu, negru si verde', 150);

CREATE TABLE StatusIdd
   (
   Id int NOT NULL PRIMARY KEY,
   DescriptionStatus nvarchar(50)  
   )
   INSERT INTO StatusIdd(Id,DescriptionStatus)
   VALUES
   (1,'Pending'),
   (2,'Processing'),
   (3,'Rejected'),
   (4,'Approved');


   CREATE TABLE [Order]
(
Id INT NOT NULL PRIMARY KEY IDENTITY (1,1),
Number INT NOT NULL,
[Date] DATE NOT NULL,
CustomerId INT NOT NULL,
[Status] INT NOT NULL,
[TotalPrice] INT,

FOREIGN KEY ([Status]) REFERENCES StatusIdd (Id) ,
FOREIGN KEY (CustomerId) REFERENCES Customer(Id)
)
INSERT INTO [Order](Number,[Date],CustomerId,[Status])
VALUES
(1,'2019-11-25', 1, 4 ),
(2,'2019-10-25', 2, 2 ),
(3,'2019-11-20', 4, 4 ),
(5,'2019-11-02', 4, 4 ),
(6,'2019-11-03', 4, 4 ),
(7,'2019-11-12', 4, 4 ),
(8,'2019-11-15', 4, 4 ),
(9,'2019-11-03', 3, 3 ),
(10,'2019-01-05', 1, 4 ),
(11,'2019-03-15', 2, 2 );
SELECT *FROM [Order]
DELETE FROM [Order]

-- Order status: 1 = Pending; 2 = Processing; 3 = Rejected; 4 = Completed

   CREATE TABLE OrderProduct
(
OrderId INT NOT NULL,
ProductId INT NOT NULL,
PRIMARY KEY (OrderId,ProductId),
NumberOfProducts INT NOT NULL,
FOREIGN KEY (OrderId) REFERENCES [Order](Id),
FOREIGN KEY (ProductId) REFERENCES Product(Id)
)
INSERT INTO OrderProduct(OrderId,ProductId,NumberOfProducts)
VALUES
(1,7,2),
(9,5,3),
(2,2,1),
(3,6,1),
(5,1,2),
(6,3,1),
(7,1,2),
(8,2,1),
(4,3,1);
INSERT INTO OrderProduct(OrderId,ProductId,NumberOfProducts)
VALUES
(1,1,2),
(9,3,1);

--4. Afisati toate produsele
SELECT [NAME] FROM Product

--5. Afisati toti clientii care au in continutul email-ului @wantsome.com.
SELECT [NAME] , EMAIL FROM CUSTOMER
WHERE EMAIL LIKE ('%@wantsome.com')
   
--6. Afisati suma preturilor pentru fiecare categorie in parte.
SELECT SUM(DBO.Product.Price), DBO.CATEGORY.[Name] 
FROM CATEGORY
LEFT JOIN Product on CategoryId=DBO.CATEGORY.Id
GROUP BY DBO.CATEGORY.[Name] 

--7. Afisati clientii care au mai mult de 4 comenzi
SELECT  COUNT(dbo.[Order].CustomerId),DBO.Customer.[Name]
FROM [Order]
JOIN Customer ON [Order].CustomerId=Customer.Id
GROUP BY DBO.Customer.[Name],[Order].CustomerId
HAVING COUNT(dbo.[Order].CustomerId)>4;

--8.     Creati un view care va afisa toti clientii si produsele comandate de acestia.
SELECT CUSTOMER.Name, PRODUCT.Name
FROM CUSTOMER
JOIN [Order] ON CUSTOMER.Id=[Order].CustomerId
JOIN OrderProduct ON [Order].Id=OrderProduct.OrderId
JOIN Product ON OrderProduct.ProductId=Product.Id
GROUP BY CUSTOMER.Name, PRODUCT.Name

--9.  Folositi view-ul de la punctul precedent pentru a afisa:

 --Clientii care au comandat produse in primele trei luni ale anului.
	SELECT CUSTOMER.Name, [Order].[Date]
FROM CUSTOMER

JOIN [Order] ON CUSTOMER.Id=[Order].CustomerId
WHERE DATEDIFF(MONTH,[Order].[Date], GETDATE()) BETWEEN 9 AND 11
GROUP BY CUSTOMER.Name, [Order].[Date]


 --Clientii care au comandat produse dintr-o anumita categorie.
 SELECT CUSTOMER.Name, CATEGORY.Name
FROM CUSTOMER
JOIN [Order] ON CUSTOMER.Id=[Order].CustomerId
JOIN OrderProduct ON [Order].Id=OrderProduct.OrderId
JOIN Product ON OrderProduct.ProductId=Product.Id
JOIN CATEGORY ON Product.CategoryId=CATEGORY.Id
GROUP BY CUSTOMER.Name, CATEGORY.Name

-- 10.Creati o procedura care va modifica statusul unui Order. Aceasta procedura va updata si LastModifiedDate.
CREATE PROC OrderStatus
AS
BEGIN
UPDATE [Order]
SET [Status]= 4
WHERE [Status]=2
END

--11.Creati un raport (select cu group by) pentru a afisa vanzarile pentru fiecare produs in parte.

SELECT Product.Name, SUM(Product.Price*OrderProduct.NumberOfProducts) AS TotalVanzari, SUM(OrderProduct.NumberOfProducts) AS NrProdVandute
FROM CUSTOMER
JOIN [Order] ON CUSTOMER.Id=[Order].CustomerId
JOIN OrderProduct ON [Order].Id=OrderProduct.OrderId
JOIN Product ON OrderProduct.ProductId=Product.Id
GROUP BY Product.Name,OrderProduct.NumberOfProducts,[Order].Status
HAVING [Order].Status=4;

--12 Creati o functie care va calcula pretul total pentru o anumita comanda.
CREATE FUNCTION Total_Price2
(
@OrderId int
)
RETURNS int   
BEGIN 
	DECLARE @Pret int;
	DECLARE @iD int;
	SELECT @Pret= sum(Product.Price*OrderProduct.NumberOfProducts) 
	FROM CUSTOMER
	JOIN [Order] ON CUSTOMER.Id=[Order].CustomerId
	JOIN OrderProduct ON [Order].Id=OrderProduct.OrderId
	JOIN Product ON OrderProduct.ProductId=Product.Id
	WHERE OrderProduct.OrderId=@OrderId
 RETURN @Pret;  
 END;


 --12 select fara functie
SELECT sum(Product.Price*OrderProduct.NumberOfProducts) as [TotalPrice], OrderProduct.OrderId
FROM CUSTOMER
JOIN [Order] ON CUSTOMER.Id=[Order].CustomerId
JOIN OrderProduct ON [Order].Id=OrderProduct.OrderId
JOIN Product ON OrderProduct.ProductId=Product.Id
GROUP BY [TotalPrice],OrderProduct.OrderId,[Order].Status
HAVING [Order].Status=4;
