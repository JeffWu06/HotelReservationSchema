-- Create new database HotelReservation and set to use.
DROP DATABASE IF EXISTS HotelReservation;
CREATE DATABASE HotelReservation;
USE HotelReservation;

-- Create tables that will have a "-to-many" relationship with others.
CREATE TABLE IF NOT EXISTS Customer
	(
    CustomerID INT NOT NULL auto_increment,
    FirstName varchar(30) NOT NULL,
    LastName varchar(30) NOT NULL,
    PhoneNum varchar(15) NOT NULL,
    Email varchar(30) NOT NULL,
    PRIMARY KEY(CustomerID)
    );
    
CREATE TABLE IF NOT EXISTS RoomType
	(
    RoomTypeID INT NOT NULL auto_increment,
    RoomDescription varchar(10) NOT NULL,
    PRIMARY KEY(RoomTypeID)
    );
    
CREATE TABLE IF NOT EXISTS Amenity
	(
    AmenityID INT NOT NULL auto_increment,
    AmenityDescription varchar(10) NOT NULL,
    PRIMARY KEY(AmenityID)
    );

CREATE TABLE IF NOT EXISTS Promotion
	(
    PromotionID varchar(10) NOT NULL,
    PromotionDescription varchar(70) NOT NULL,
    FromDate DATE NOT NULL,
    ToDate DATE NULL,
    DiscountAmount DECIMAL(5,2) NOT NULL,
    DiscountPercentage DECIMAL(2,2) NOT NULL,
    PRIMARY KEY(PromotionID)
    );
    
CREATE TABLE IF NOT EXISTS Tax
	(
    TaxRateID INT NOT NULL auto_increment,
    TaxRate DECIMAL(5,5) NOT NULL,
    FromDate DATE NOT NULL,
    ToDate DATE NULL,
    PRIMARY KEY(TaxRateID)
    );
    
CREATE TABLE IF NOT EXISTS AddOn
	(
    AddOnID INT NOT NULL auto_increment,
    AddOnDescription varchar(30) NOT NULL,
    PRIMARY KEY(AddOnID)
    );
    
-- Create tables on the "many" side of the relationship with above "one" tables.
-- Create AddOnPrice table and establish AddOnID from AddOn table as FK.
CREATE TABLE IF NOT EXISTS AddOnPrice
	(
    AddOnPriceID INT NOT NULL auto_increment,
    AddOnID INT NOT NULL,
    Price DECIMAL(5,2) NOT NULL,
    FromDate DATE NOT NULL,
    ToDate DATE NULL,
    PRIMARY KEY(AddOnPriceID)
    );
ALTER TABLE AddOnPrice
ADD CONSTRAINT fk_AddOn_AddOnPrice FOREIGN KEY(AddOnID) REFERENCES AddOn(AddOnID)
ON DELETE NO ACTION;

-- Create Room table and establish RoomTypeID from RoomType table as FK.
CREATE TABLE IF NOT EXISTS Room
	(
    RoomID INT NOT NULL,
    Floor TINYINT NOT NULL,
    OccupancyLimit TINYINT NOT NULL,
    RoomTypeID INT NOT NULL,
    PRIMARY KEY(RoomID)
    );    
ALTER TABLE Room
ADD CONSTRAINT fk_Room_RoomType FOREIGN KEY(RoomTypeID) REFERENCES RoomType(RoomTypeID)
ON DELETE NO ACTION;

-- Create RoomPrice table and establish RoomID from Room table as FK.
CREATE TABLE IF NOT EXISTS RoomPrice
	(
    RoomPriceID INT NOT NULL auto_increment,
    FromDate DATE NOT NULL,
    ToDate DATE NULL,
    PricePerNight DECIMAL(5,2) NOT NULL,
    RoomID INT NOT NULL,
    PRIMARY KEY(RoomPriceID)
    );    
ALTER TABLE RoomPrice
ADD CONSTRAINT fk_RoomPrice_Room FOREIGN KEY(RoomID) REFERENCES Room(RoomID)
ON DELETE NO ACTION;

-- Create RoomAmentity bridge table; many-to-many between Room and Amenity tables.
CREATE TABLE IF NOT EXISTS RoomAmenity
	(
    RoomID INT NOT NULL,
    AmenityID INT NOT NULL,
    PRIMARY KEY(RoomID, AmenityID)
    );
ALTER TABLE RoomAmenity
ADD CONSTRAINT fk_RoomAmenity_Room FOREIGN KEY(RoomID) REFERENCES Room(RoomID)
ON DELETE NO ACTION;
ALTER TABLE RoomAmenity
ADD CONSTRAINT fk_RoomAmenity_Amenity FOREIGN KEY(AmenityID) REFERENCES Amenity(AmenityID)
ON DELETE NO ACTION;

-- Create Reservation table and establish CustomerID, PromotionID, and TaxRateID as FKs.
CREATE TABLE IF NOT EXISTS Reservation
	(
    ReservationID INT NOT NULL,
    CustomerID INT NOT NULL,
    CheckInDate DATE NOT NULL,
    CheckOutDate DATE NOT NULL,
    PromotionID varchar(10) NOT NULL,
    TaxRateID INT NOT NULL,
    PRIMARY KEY(ReservationID)
    );
ALTER TABLE Reservation
ADD CONSTRAINT fk_Reservation_Customer FOREIGN KEY(CustomerID) REFERENCES Customer(CustomerID)
ON DELETE NO ACTION;
ALTER TABLE Reservation
ADD CONSTRAINT fk_Reservation_Promotion FOREIGN KEY(PromotionID) REFERENCES Promotion(PromotionID)
ON DELETE NO ACTION;
ALTER TABLE Reservation
ADD CONSTRAINT fk_Reservation_Tax FOREIGN KEY(TaxRateID) REFERENCES Tax(TaxRateID)
ON DELETE NO ACTION;

-- Create ReservationRoom table and establish ReservationID and RoomPriceID as FKs.
CREATE TABLE IF NOT EXISTS ReservationRoom
	(
    ReservationRoomID INT NOT NULL,
    ReservationID INT NOT NULL,
    RoomPriceID INT NOT NULL,
    PricePerNight DECIMAL(5,2) NOT NULL,
    NumberOfNights TINYINT NOT NULL,
    PRIMARY KEY(ReservationRoomID)
    );
ALTER TABLE ReservationRoom
ADD CONSTRAINT fk_ReservationRoom_Reservation FOREIGN KEY(ReservationID) REFERENCES Reservation(ReservationID)
ON DELETE NO ACTION;
ALTER TABLE ReservationRoom
ADD CONSTRAINT fk_ReservationRoom_RoomPrice FOREIGN KEY(RoomPriceID) REFERENCES RoomPrice(RoomPriceID)
ON DELETE NO ACTION;

-- Create ReservationAddOn table and establish ReservationID and AddOnPriceID as FKs.
CREATE TABLE IF NOT EXISTS RoomAddOn
	(
    ReservationRoomID INT NOT NULL,
    AddOnPriceID INT NOT NULL,
    Price DECIMAL(5,2) NOT NULL,
    Quantity TINYINT NOT NULL,
    PRIMARY KEY(ReservationRoomID, AddOnPriceID)
    );
ALTER TABLE RoomAddOn
ADD CONSTRAINT fk_RoomAddOn_Reservation FOREIGN KEY(ReservationRoomID) REFERENCES ReservationRoom(ReservationRoomID)
ON DELETE NO ACTION;
ALTER TABLE RoomAddOn
ADD CONSTRAINT fk_RoomAddOn_AddOnPrice FOREIGN KEY(AddOnPriceID) REFERENCES AddOnPrice(AddOnPriceID)
ON DELETE NO ACTION;

-- Create ReservationGuest table and establish ReservationID as FK.
CREATE TABLE IF NOT EXISTS Guest
	(
    GuestID INT NOT NULL,
    FirstName varchar(30) NOT NULL,
    LastName varchar(30) NOT NULL,
    Age TINYINT NOT NULL,
    PRIMARY KEY(GuestID)
    );
    
CREATE TABLE IF NOT EXISTS ReservationGuest
	(
    ReservationID INT NOT NULL,
    GuestID INT NOT NULL,
    PRIMARY KEY(ReservationID, GuestID)
    );
ALTER TABLE ReservationGuest
ADD CONSTRAINT fk_ReservationGuest_Reservation FOREIGN KEY(ReservationID) REFERENCES Reservation(ReservationID)
ON DELETE NO ACTION;
ALTER TABLE ReservationGuest
ADD CONSTRAINT fk_ReservationGuest_Guest FOREIGN KEY(GuestID) REFERENCES Guest(GuestID)
ON DELETE NO ACTION;

-- Create Invoice table.
CREATE TABLE IF NOT EXISTS Invoice
	(InvoiceID INT NOT NULL auto_increment,
    ReservationID INT NOT NULL,
    RoomTotal DECIMAL(7,2),
    AddOnTotal DECIMAL(7,2),
    Discount DECIMAL(7,2),
    Subtotal DECIMAL(7,2),
    Tax DECIMAL(7,2),
    GrandTotal DECIMAL(7,2),
    PRIMARY KEY(InvoiceID)
    );
ALTER TABLE Invoice
ADD CONSTRAINT fk_Invoice_Reservation FOREIGN KEY(ReservationID) REFERENCES Reservation(ReservationID)
ON DELETE NO ACTION;

-- Add mock data.
-- Create data rows for hotel offerings.
INSERT IGNORE INTO RoomType (RoomTypeID, RoomDescription)
VALUES (1, 'Single'), (2, 'Double'), (3, 'King');

INSERT IGNORE INTO Amenity (AmenityID, AmenityDescription)
VALUES (1, 'Fridge'), (2, 'Spa bath'), (3, 'Ocean view');

INSERT IGNORE INTO Room (RoomID, Floor, OccupancyLimit, RoomTypeID)
VALUES (101, 1, 4, 2), (102, 1, 4, 2), (201, 2, 2, 3), (301, 3, 1, 1);

INSERT IGNORE INTO RoomAmenity (RoomID, AmenityID)
VALUES (101, 1), (101, 3), (102, 1), (201, 1), (201, 2), (201, 3), (301, 1), (301, 3);

INSERT IGNORE INTO RoomPrice (RoomPriceID, RoomID, PricePerNight, FromDate, ToDate)
VALUES (1, 101, 49.99, '2020/01/01', NULL), 
(2, 102, 39.99, '2020/01/01', NULL), 
(3, 201, 69.99, '2020/01/01', NULL), 
(4, 301, 29.99, '2020/01/01', NULL);

INSERT IGNORE INTO AddOn (AddOnID, AddOnDescription)
VALUES (1, 'PPV Movie'), (2, 'Room service - breakfast');

INSERT IGNORE INTO AddOnPrice (AddOnPriceID, AddOnID, Price, FromDate, ToDate)
VALUES (1, 1, 5.99, '2019/01/01', '2019/12/31'), (2, 1, 6.99, '2020/01/01', NULL), (3, 2, 29.99, '2020/01/01', NULL);

INSERT IGNORE INTO Promotion (PromotionID, PromotionDescription, DiscountAmount, DiscountPercentage, FromDate, ToDate)
VALUES ('20OFF2', '$20 off total bill (gross) for reservations of two rooms or more', -20.00, 0, '2020/05/01', '2020/06/30'),
('GUILDIE10', '10% off total bill (gross) for attendies of GuildCon', 0, -.10, '2020/04/17', '2020/04/19');

INSERT IGNORE INTO Tax (TaxRateID, TaxRate, FromDate, ToDate)
VALUES (1, .095, '2019/01/01', '2020/03/31'),
(2, .1025, '2020/04/01', NULL);

-- Book sample reservations.
INSERT IGNORE INTO Customer (CustomerID, FirstName, LastName, PhoneNum, Email)
VALUES (1, 'John', 'Doe', '5555551234', 'jdoe@email.com'),
(2, 'Greg', 'Focker', '9999996543', 'gaylord@chicagomercy.com');

INSERT IGNORE INTO Reservation (ReservationID, CustomerID, CheckInDate, CheckOutDate, PromotionID, TaxRateID)
VALUES (1, 1, '2020/04/17', '2020/04/19', 'GUILDIE10', 2),
(2, 2, '2020/05/05', '2020/05/08', '20OFF2', 2);

INSERT IGNORE INTO Guest (GuestID, FirstName, LastName, Age)
VALUES (1, 'John', 'Doe', 32),
(2, 'Greg', 'Focker', 40),
(3, 'Pam', 'Focker', 40),
(4, 'Samantha', 'Focker', 9),
(5, 'Henry', 'Focker', 9);

INSERT IGNORE INTO ReservationGuest (ReservationID, GuestID)
VALUES (1, 1), (2, 2), (2, 3), (2, 4), (2, 5);

INSERT IGNORE INTO ReservationRoom (ReservationRoomID, ReservationID, RoomPriceID, PricePerNight, NumberOfNights)
VALUES (1, 1, 3, 69.99, 2), (2, 2, 1, 49.99, 3), (3, 2, 2, 39.99, 3);

INSERT IGNORE INTO RoomAddOn (ReservationRoomID, AddOnPriceID, Price, Quantity)
VALUES (1, 3, 29.99, 1), (2, 2, 6.99, 2), (3, 3, 29.99, 2);

-- Create rows in Invoice table for each reservations' respective invoice.
INSERT IGNORE INTO Invoice (InvoiceID, ReservationID)
VALUES (1001, 1), (1002, 2);

-- Create View for reservation invoice that calculates the total charges and various totals and subtotals.
DROP VIEW IF EXISTS TotalsByReservation;
CREATE VIEW TotalsByReservation AS
SELECT rr.ReservationID, rr.ReservationRoomID, SUM(rr.NumberOfNights * rr.PricePerNight) AS GrossRoomTotal, 
SUM(rao.Price * rao.Quantity) AS GrossAddOnTotal, 
((SUM(rr.NumberOfNights * rr.PricePerNight) + SUM(rao.Price * rao.Quantity)) * p.DiscountPercentage) + p.DiscountAmount AS PromoDiscount,
((SUM(rr.NumberOfNights * rr.PricePerNight) + SUM(rao.Price * rao.Quantity)) * (1 + p.DiscountPercentage)) + p.DiscountAmount AS NetTotal,
(((SUM(rr.NumberOfNights * rr.PricePerNight) + SUM(rao.Price * rao.Quantity)) * (1 + p.DiscountPercentage)) + p.DiscountAmount) * t.TaxRate AS TotalTax,
(((SUM(rr.NumberOfNights * rr.PricePerNight) + SUM(rao.Price * rao.Quantity)) * (1 + p.DiscountPercentage)) + p.DiscountAmount) * (1 + t.TaxRate) AS ReservationTotal
FROM ReservationRoom rr
INNER JOIN Reservation res ON rr.ReservationID = res.ReservationID
CROSS JOIN RoomAddOn rao ON rao.ReservationRoomID = rr.ReservationRoomID
INNER JOIN Promotion p ON res.PromotionID = p.PromotionID
INNER JOIN Tax t ON res.TaxRateID = t.TaxRateID
GROUP BY rr.ReservationID;

-- Update invoice rows with totals aggregated from the TotalsByReservation View template.
UPDATE Invoice i
INNER JOIN TotalsByReservation tot ON i.ReservationID = tot.ReservationID
SET RoomTotal = tot.GrossRoomTotal,
AddOnTotal = tot.GrossAddOnTotal,
Discount = tot.PromoDiscount,
Subtotal = tot.NetTotal,
Tax = tot.TotalTax,
GrandTotal = tot.ReservationTotal
WHERE i.ReservationID = 1;

UPDATE Invoice i
INNER JOIN TotalsByReservation tot ON i.ReservationID = tot.ReservationID
SET RoomTotal = tot.GrossRoomTotal,
AddOnTotal = tot.GrossAddOnTotal,
Discount = tot.PromoDiscount,
Subtotal = tot.NetTotal,
Tax = tot.TotalTax,
GrandTotal = tot.ReservationTotal
WHERE i.ReservationID = 2;
