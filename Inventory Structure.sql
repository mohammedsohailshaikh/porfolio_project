--Inventory Structur

CREATE DATABASE Inventory;
USE Inventory;

--Normalizing the DataBase
ALTER TABLE Inv_Product
DROP  CONSTRAINT FK1;

ALTER TABLE Inv_Orders
DROP  CONSTRAINT FK2;

ALTER TABLE Inv_Orders
DROP  CONSTRAINT FK3;

ALTER TABLE Inv_Stock
DROP  CONSTRAINT FK4;

ALTER TABLE Inv_Product
DROP  CONSTRAINT PK1;

ALTER TABLE SInv_upplier
DROP  CONSTRAINT PK2;

ALTER TABLE Inv_Cust
DROP  CONSTRAINT PK3;

ALTER TABLE Inv_Orders
DROP  CONSTRAINT PK4;

-----Constraints on Product table
SELECT *
FROM Product;

ALTER TABLE Product
ALTER COLUMN PID VARCHAR(250) NOT NULL;

ALTER TABLE Product
ADD CONSTRAINT PK1 PRIMARY KEY(PID);

ALTER TABLE Product
ALTER COLUMN PDESC VARCHAR(250) NOT NULL;

ALTER TABLE Product
ADD CONSTRAINT CK1 CHECK(PRICE > 0);

ALTER TABLE Product
ADD CONSTRAINT CK2 CHECK(CATEGORY IN ('IT','HA','HC'));

ALTER TABLE Product
ALTER COLUMN SID VARCHAR(250) NOT NULL;

ALTER TABLE Product
ADD CONSTRAINT FK1 FOREIGN KEY(SID) REFERENCES Supplier(SID);
---end

-----constarins on Supplier table
SELECT *
FROM Supplier;

UPDATE Supplier
SET SCITY = 'Delhi' WHERE SCITY = 'Dehli';

ALTER TABLE Supplier
ALTER COLUMN SID VARCHAR(250) NOT NULL;

ALTER TABLE Supplier
ADD CONSTRAINT PK2 PRIMARY KEY(SID);

ALTER TABLE Supplier
ALTER COLUMN SNAME VARCHAR(250) NOT NULL;

ALTER TABLE Supplier
ALTER COLUMN SADD VARCHAR(250) NOT NULL;

ALTER TABLE Supplier
ADD CONSTRAINT CK3 CHECK(SCITY = 'Delhi');

ALTER TABLE Supplier
ADD CONSTRAINT UN1 UNIQUE(SPHONE);
---END

-----CONSTAINTS ON Customer
SELECT *
FROM Cust;

ALTER TABLE Cust
ALTER COLUMN CID VARCHAR(250) NOT NULL;

ALTER TABLE Cust
ADD CONSTRAINT PK3 PRIMARY KEY(CID);

ALTER TABLE Cust
ALTER COLUMN CNAME VARCHAR(250) NOT NULL;

ALTER TABLE Cust
ALTER COLUMN ADDRESS VARCHAR(250) NOT NULL;

ALTER TABLE Cust
ALTER COLUMN CITY VARCHAR(250) NOT NULL;

ALTER TABLE Cust
ALTER COLUMN PHONE VARCHAR(250) NOT NULL;

ALTER TABLE Cust
ALTER COLUMN EMAIL VARCHAR(250) NOT NULL;

ALTER TABLE Cust
ADD CONSTRAINT CK4 CHECK(DOB < '01-01-2000');
----END

-----CONSTAINTS ON ORDERS
SELECT * 
FROM Orders;

ALTER TABLE Orders
ALTER COLUMN OID VARCHAR(250) NOT NULL;

ALTER TABLE Orders
ADD CONSTRAINT PK4 PRIMARY KEY(OID);

ALTER TABLE Orders
ALTER COLUMN CID VARCHAR(250) NOT NULL;

ALTER TABLE Orders
ADD CONSTRAINT FK2 FOREIGN KEY(CID) REFERENCES Cust(CID);

ALTER TABLE Orders
ALTER COLUMN PID VARCHAR(250) NOT NULL;

ALTER TABLE Orders
ADD CONSTRAINT FK3 FOREIGN KEY(PID) REFERENCES Product(PID);

ALTER TABLE Orders
ADD CONSTRAINT CK5 CHECK(OQTY >= 1);
---END

-----CONSTRAINT ON STOCK
ALTER TABLE Stock
ALTER COLUMN PID VARCHAR(250) NOT NULL;

ALTER TABLE Stock
ADD CONSTRAINT FK4 FOREIGN KEY(PID) REFERENCES Product(PID);

ALTER TABLE Stock
ADD CONSTRAINT CK6 CHECK(SQTY >= 0)

ALTER TABLE Stock
ADD CONSTRAINT CK7 CHECK(ROL > 0)

ALTER TABLE Stock
ADD CONSTRAINT CK8 CHECK(MOQ >= 5)


--Billing for all customers
 CREATE VIEW Bill
 AS
 (
 SELECT O.OID,O.ODATE,C.CNAME,C.ADDRESS,C.PHONE,P.PDESC, P.PRICE, O.OQTY, (P.PRICE*O.OQTY) AS Amount
 FROM Inv_Orders O
 INNER JOIN Inv_Cust C
  ON O.CID = C.CID
INNER JOIN Inv_Product P
 ON P.PID = O.PID
 )
 DROP VIEW Bill;

 SELECT *
 FROM Bill;


--Stored procedure for simplifying data input
------User defined Fuction for autogenerating Unique transaction IDs
CREATE FUNCTION inv_id (@A AS VARCHAR(20), @B AS INT)
RETURNS VARCHAR(20)
BEGIN
	DECLARE @C AS VARCHAR(20)
	SET @C = CASE
				WHEN @B < 10 THEN CONCAT(@A,'000',@B)
				WHEN @B < 100 THEN CONCAT(@A,'00',@B)
				WHEN @B < 1000 THEN CONCAT(@A,'0',@B)
				WHEN @B < 10000 THEN CONCAT(@A,@B)
				ELSE NULL
				END;
	RETURN @C;
	
END;

------Sequence and Stored Procedure(shows input record once inserted)
--------Supplier
CREATE SEQUENCE inv_supp
AS INT
START WITH 9
INCREMENT BY 1;

CREATE PROCEDURE Addsupplier1 (@A AS VARCHAR(255), @B AS VARCHAR(255), @C AS VARCHAR(255),@D AS FLOAT,@E AS VARCHAR(255))
AS
BEGIN
	DECLARE @F AS VARCHAR(25);
	SET @F = DBO.inv_id('S', NEXT VALUE FOR inv_supp);

	INSERT INTO Inv_Supplier
	VALUES (@F,@A,@B,@C,@D,@E);

	SELECT *
	FROM Inv_Supplier
	WHERE SID = @F;
END;

Addsupplier1 'Sohail','mumbai street','Delhi',5268623548,NULL;--WILL ADD WITH S0009

--------Product
CREATE SEQUENCE inv_pro
AS INT
START WITH 18
INCREMENT BY 1;

CREATE PROCEDURE Addpro1 (@G AS VARCHAR(250),@H AS FLOAT, @I AS VARCHAR(255), @J AS VARCHAR(250))
AS
BEGIN
	DECLARE @K AS VARCHAR(20);
	SET @K = DBO.inv_id('P',NEXT VALUE FOR inv_pro);

	INSERT INTO Inv_Product
	VALUES(@K,@G,@H,@I,@J)

	SELECT *
	FROM Inv_Product
	WHERE PID = @K;
END;

Addpro1 'EARPHONE',750,'HA',S0001;--ADD WITH P0018

--------Customer
CREATE SEQUENCE inv_cu
AS INT
START WITH 11
INCREMENT BY 1;

CREATE PROCEDURE Addpcust1 (@L AS VARCHAR(250),@M AS VARCHAR(250), @N AS VARCHAR(255), @O AS VARCHAR(250),@P AS VARCHAR(250),@Q AS DATETIME)
AS
BEGIN
	DECLARE @R AS VARCHAR(20);
	SET @R = DBO.inv_id('C',NEXT VALUE FOR inv_cu);

	INSERT INTO Inv_Cust
	VALUES(@R,@L,@M,@N,@O,@P,@Q)

	SELECT *
	FROM Inv_Cust
	WHERE CID = @R;
END;

Addpcust1 'me','momin plot','?','1258362989','me@','1999-02-02';--ADD WITH C0011

--------Orders
CREATE SEQUENCE inv_ord
AS INT
START WITH 7
INCREMENT BY 1;

CREATE PROCEDURE Addporder1 (@T AS VARCHAR(250), @U AS VARCHAR(250), @V AS FLOAT)
AS
BEGIN
	DECLARE @W AS VARCHAR(20);
	SET @W = DBO.inv_id('O',NEXT VALUE FOR inv_ord);

	INSERT INTO Inv_Orders
	VALUES(@W,GETDATE(),@T,@U,@V);

	SELECT *
	FROM Inv_Orders
	WHERE OID = @W;
END;

Addporder1 'C0002','P0002',3;--ADD WITH C0007

-----Triggers for efficient transactions
--------After DELETING FROM PRODUCT THE CORRESPONDING RECORD IN STOCK TABLE will BE DELETED
CREATE TRIGGER TR_PRODUCT1
ON Inv_Product
FOR DELETE
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM Inv_Stock
	WHERE PID = (SELECT PID FROM DELETED);--DELETED IS TMP TABLE
END;

DELETE FROM PRODUCT1
WHERE PID = 'P0004';

--------Updating Stock as New order places
CREATE TRIGGER TR_IN_OR1
ON Inv_Orders
FOR INSERT
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @QR AS INT;--REQUIRED QUANTITY
	DECLARE @QS AS INT;--QUANTITY IN STOCK

	SET @QR = (SELECT QTY FROM INSERTED)
	SET @QS = (SELECT SQTY FROM STOCK1 WHERE PID = (SELECT PID FROM INSERTED))

	IF @QS >= @QR
		BEGIN
			UPDATE Inv_Stock
			SET SQTY = SQTY- @QR;
			COMMIT;
			PRINT('ORDER HAS BEEN ACCEPTED');
		END;
	ELSE
		BEGIN
			ROLLBACK;
			PRINT('ISUFFICIENT STOCK : ORDER REJECTED');
		END;
END;

INSERT INTO ORDERS1
VALUES('O0008','C0008','P0001',20);---EXCEED SQTY SO SHOULD ROLLBACK OR NOT CONSIDER ORDER

--------Updating Stock if Order is revised 
CREATE TRIGGER TR_IN_OR2
ON Inv_Orders
FOR UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @NQR AS INT;
	DECLARE @QS AS INT;
	DECLARE @OQR AS INT;
	
	SET @NQR = (SELECT QTY FROM INSERTED);
	SET @OQR = (SELECT QTY FROM DELETED);
	SET @QS = (SELECT SQTY 
				FROM STOCK1 
				WHERE PID = (SELECT PID FROM INSERTED));

	IF @QS+@OQR >= @NQR
		BEGIN
			UPDATE Inv_Stock
			SET SQTY = SQTY+@OQR-@NQR;
			COMMIT;
			PRINT('ORDER HAS BEEN ACCEPTED');
		END;
	ELSE
		BEGIN
			ROLLBACK;
			PRINT('ISUFFICIENT STOCK : ORDER REJECTED');
		END;
END;

UPDATE Inv_Orders
SET QTY = 21
WHERE OID = 'O0004';

--End