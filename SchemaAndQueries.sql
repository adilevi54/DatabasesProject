--Building tables:
--DROP TABLE USERS

CREATE TABLE USERS(
	UserEmail Varchar(50) PRIMARY KEY NOT NULL,
	FirstName Varchar(30) NOT NULL,
	LastName Varchar(30) NOT NULL,
	MobilePhoneNumber ntext NOT NULL,

	CONSTRAINT CK_UserEmail CHECK  (UserEmail   LIKE   '%@%.%')
)

--DROP TABLE [CREDIT CARDS]

CREATE TABLE [CREDIT CARDS](
	CardNumber Varchar(16) PRIMARY KEY NOT NULL,
	[Type] Varchar(30) NOT NULL,
	ExpirationDate Varchar(5) NOT NULL,
	CVV Int NOT NULL,
	UserEmail Varchar(50) NOT NULL,

	CONSTRAINT fk_CreditCardsEmail FOREIGN KEY (UserEmail)
	REFERENCES USERS(UserEmail),
	CONSTRAINT CK_ExperationDate CHECK (ExpirationDate LIKE ('[0-9][0-9]/[0-9][0-9]'))
)

--DROP TABLE RESERVATIONS

CREATE TABLE RESERVATIONS (
	ReservationID Int PRIMARY KEY NOT NULL,
	StartDate Date NOT NULL,
	EndDate Date NOT NULL,
	NumOfDivers Int,
	NumOfNonDivers Int,
	NumOfDives Int,
	IsRefundable Varchar(3),
	CardNumber Varchar(16) NOT NULL,

	CONSTRAINT CK_IsRefundable Check (IsRefundable IN ('Yes','No')),
	CONSTRAINT CK_ResDateOrder Check (StartDate < EndDate),
	CONSTRAINT CK_MinPeople check (NumOfDivers + NumOfNonDivers > 0),
	CONSTRAINT fk_CardNumber FOREIGN KEY (CardNumber)
	REFERENCES [CREDIT CARDS](CardNumber)
	)

--DROP TABLE EXTRAS

CREATE TABLE EXTRAS(
	ReservationID Int NOT NULL,
	ExtraName Varchar(50) NOT NULL,
	Quantity Int NOT NULL,
	Cost Money NOT NULL,

	CONSTRAINT PK_EXTRAS PRIMARY KEY (ReservationID, ExtraName),
	CONSTRAINT CK_Quantity CHECK (Quantity >= 0),
	CONSTRAINT FK_ExtrasRes FOREIGN KEY (ReservationID)
	REFERENCES [RESERVATIONS](ReservationID)
)

--DROP TABLE SEARCHES

CREATE TABLE SEARCHES(
	IPAddress Varchar(15) NOT NULL,
	DTsearch DateTime NOT NULL,
	SearchType Varchar(10) NOT NULL,
	Destination Varchar(60) NOT NULL,
	NumOfDivers Int,
	NumOfNonDivers Int,
	StartDate Date,
	EndDate Date,
	ReservationID Int,
	UserEmail Varchar(50),

	CONSTRAINT Pk_SEARCHES PRIMARY KEY (IPAddress, DTsearch),
	CONSTRAINT fk_ReservationSearch FOREIGN KEY (ReservationID)
	REFERENCES RESERVATIONS(ReservationID),
	CONSTRAINT fk_UserSearched FOREIGN KEY (UserEmail)
	REFERENCES USERS(UserEmail),
	CONSTRAINT Ck_SearchDateOrder CHECK (StartDate < EndDate),
	CONSTRAINT CK_IP CHECK (IPAddress LIKE ('%.%.%.%')),
	CONSTRAINT CK_SearchType CHECK (SearchType IN ('Resort', 'Liveaboard'))
)
--DROP TABLE VACATIONS

CREATE TABLE VACATIONS (
	SerialNumber Int PRIMARY KEY NOT NULL,
	VacationName Varchar(50) NOT NULL
)

--DROP TABLE REVIEWS

CREATE TABLE REVIEWS (
	UserEmail Varchar(50) NOT NULL,
	ReviewDT DateTime NOT NULL,
	Rating Int NOT NULL,
	SerialNumber Int not null,

	CONSTRAINT Pk_REVIWES PRIMARY KEY (UserEmail, ReviewDT),
	CONSTRAINT fk_UserReview FOREIGN KEY (UserEmail)
	REFERENCES [USERS](UserEmail),
	CONSTRAINT CK_Rating CHECK (Rating BETWEEN 1 AND 5)
	)

--DROP TABLE LIVEABOARDS

CREATE TABLE LIVEABOARDS (
	SerialNumber Int PRIMARY KEY NOT NULL,
	NumberOfCabins int NOT NULL,
	Destination Varchar(60) NOT NULL,
	[Dimensions–Length] Real, 
	[Dimensions–Width] Real, 
	YearBuilt Int, 
	YearRenovated Int, 
	RentalEquip VarChar(3),
	Internet VarChar(3), 
	Nitrox VarChar(3),

	CONSTRAINT FK_LiveabVacation FOREIGN KEY (SerialNumber)
	REFERENCES VACATIONS(SerialNumber),
	CONSTRAINT CK_Internt CHECK(Internet IN('Yes','No')),
	CONSTRAINT CK_Nitrox CHECK(Nitrox IN('Yes','No')),
	CONSTRAINT CK_RentalEquip CHECK(RentalEquip IN('Yes','No'))
)

--DROP TABLE RESORTS

CREATE TABLE RESORTS(
	SerialNumber Int PRIMARY KEY NOT NULL,
	[Address–City] Varchar (100) NOT NULL,
	[Address–Country] Varchar(60) NOT NULL, 
	[Address–Street] Varchar(100) NOT NULL,
	[Address–Number] Int NOT NULL,
	[Address–Zip] Int NOT NULL,
	Category Int,
	NumberOfRooms Int,

	CONSTRAINT FK_ResortsVacation FOREIGN KEY (SerialNumber)
	REFERENCES VACATIONS(SerialNumber),
	CONSTRAINT CK_Category CHECK (Category BETWEEN 1 AND 5),
	CONSTRAINT CK_SizeR CHECK (NumberOfRooms > 0)
)

--DROP TABLE ROOMS

CREATE TABLE ROOMS (
	SerialNumber Int NOT NULL,
	RoomNumber Int NOT NULL,
	RoomType Varchar(100) NOT NULL,
	Size Int,
	MaxOccupancy Int NOT NULL, 
	Beds Varchar(30) NOT NULL,
	PrivateBathroom Varchar(3) NOT NULL, 
	WIFI Varchar(3) NOT NULL,
	AirConditioning Varchar(3) NOT NULL,
	
	CONSTRAINT PK_ROOMS PRIMARY KEY (SerialNumber,RoomNumber),
	CONSTRAINT FK_RoomVacation FOREIGN KEY (SerialNumber)
	REFERENCES VACATIONS(SerialNumber),
	CONSTRAINT CK_PrivateBathroomR CHECK (PrivateBathroom IN ('Yes', 'No')),
	CONSTRAINT CK_WIFIR CHECK (WIFI IN ('Yes', 'No')),
	CONSTRAINT CK_AirConditioningR CHECK (AirConditioning IN ('Yes', 'No'))
)

--DROP TABLE [BOOK ROOMS]

CREATE TABLE [BOOK ROOMS] (
	ReservationID Int NOT NULL, 
	SerialNumber Int NOT NULL,
	RoomNumber Int NOT NULL,

	CONSTRAINT PK_BOOKROOMS PRIMARY KEY (ReservationID, SerialNumber,RoomNumber),
	CONSTRAINT FK_RESERVATIONS FOREIGN KEY (ReservationID) 
	REFERENCES [RESERVATIONS](ReservationID),
	CONSTRAINT FK_RoomsBR FOREIGN KEY (SerialNumber, RoomNumber) 
	REFERENCES ROOMS(SerialNumber, RoomNumber)
)

--DROP TABLE [RETRIEVES VACATION]

CREATE TABLE [RETRIEVES VACATION](
	IPAddress Varchar(15) NOT NULL,
	DTsearch DateTime NOT NULL,
	SerialNumber Int NOT NULL,

	CONSTRAINT Pk_RetrievesResorts PRIMARY KEY (IPAddress, DTsearch, SerialNumber),
	CONSTRAINT fk_IPRetrievesResorts FOREIGN KEY (IPAddress, DTsearch)
	REFERENCES SEARCHES(IPAddress, DTsearch),
	CONSTRAINT FK_VacationRV FOREIGN KEY (SerialNumber)
	REFERENCES VACATIONS(SerialNumber),
)


--Queries:
--Query 1- Not Nested
SELECT 
    r.SerialNumber AS ResortID,
    r.[Address–City] AS ResortCity,
    COUNT(br.ReservationID) AS TotalReservations,
    r.Category AS ResortCategory
FROM [BOOK ROOMS] AS br JOIN ROOMS AS ro ON br.SerialNumber = ro.SerialNumber
	JOIN RESORTS AS r ON ro.SerialNumber = r.SerialNumber
WHERE r.Category >= 3
GROUP BY r.SerialNumber, r.[Address–City] , r.Category
HAVING COUNT(br.ReservationID) > 3
ORDER BY TotalReservations DESC

--Query 2- Not Nested
SELECT  TOP 5 [Serial Number]=L.SerialNumber ,[Liveaboard Name] = V.VacationName ,Year =YEAR(RV.DTsearch)
FROM LIVEABOARDS AS L JOIN VACATIONS AS V ON L.SerialNumber = V.SerialNumber
	JOIN [RETRIEVES VACATION] AS RV ON L.SerialNumber = RV.SerialNumber 
WHERE YEAR(RV.DTsearch)=2024 AND MONTH(RV.DTsearch) IN (6,7,8)
ORDER BY L.YearRenovated DESC

--Query 3- Nested
SELECT TOP 3 R.SerialNumber, R.[Address–Country], NumBooked = COUNT(*)
FROM RESORTS AS R JOIN [BOOK ROOMS] AS B ON R.SerialNumber=B.SerialNumber
WHERE R.[Address–Country] IN (SELECT TOP 3 Destination
FROM SEARCHES
GROUP BY Destination
ORDER BY COUNT(*) Desc)
GROUP BY R.SerialNumber, R.[Address–Country]
ORDER BY COUNT(*) DESC

--Query 4- Nested
SELECT rt.RoomType, rt.OrderCount
FROM 
	(SELECT ro.RoomType, COUNT(br.ReservationID) AS OrderCount
    FROM [BOOK ROOMS] AS br
		JOIN ROOMS AS ro ON br.SerialNumber = ro.SerialNumber
		JOIN LIVEABOARDS AS l ON ro.SerialNumber = l.SerialNumber
    GROUP BY ro.RoomType
    ) AS rt
WHERE rt.OrderCount = (
	SELECT MAX(sub.OrderCount)
	FROM (SELECT ro2.RoomType, COUNT(br2.ReservationID) AS OrderCount
		  FROM [BOOK ROOMS] AS br2 JOIN ROOMS AS ro2 ON br2.SerialNumber = ro2.SerialNumber
			   JOIN LIVEABOARDS AS l2 ON ro2.SerialNumber = l2.SerialNumber
		  GROUP BY ro2.RoomType
        ) AS sub
    )
ORDER BY rt.RoomType

--Query 5- Nested Update
--To see the before
SELECT *
FROM EXTRAS
WHERE ReservationID IN (
	SELECT DISTINCT ReservationID
	FROM RESERVATIONS AS RES JOIN [CREDIT CARDS] AS C ON RES.CardNumber=C.CardNumber 
	JOIN REVIEWS AS R ON R.UserEmail=C.UserEmail
	WHERE R.Rating <= 2 AND MONTH(RES.StartDate)> 8 AND YEAR(RES.StartDate) = 2024
	)
	AND ExtraName LIKE '%Transfer%'

-- The Query
UPDATE EXTRAS
SET Cost = 0
WHERE ReservationID IN (
	SELECT DISTINCT ReservationID
	FROM RESERVATIONS AS RES JOIN [CREDIT CARDS] AS C ON RES.CardNumber=C.CardNumber 
		JOIN REVIEWS AS R ON R.UserEmail=C.UserEmail
	WHERE R.Rating <= 2 AND MONTH(RES.StartDate)> 8 AND YEAR(RES.StartDate) = 2024
	)
AND ExtraName LIKE '%Transfer%'

--Query 6- Nested with INTERSECT
SELECT	u.UserEmail, u.FirstName + ' ' + u.LastName AS FullName
FROM USERS AS u JOIN [CREDIT CARDS] cc ON u.UserEmail = cc.UserEmail
	 JOIN RESERVATIONS r ON cc.CardNumber = r.CardNumber
INTERSECT
SELECT u.UserEmail, u.FirstName + ' ' + u.LastName AS FullName
FROM USERS AS u JOIN REVIEWS rv ON u.UserEmail = rv.UserEmail

--Query 7- With WIndow Function
SELECT 
  EXTRAS.ReservationID AS [Reservation Number],
  EXTRAS.ExtraName,
  cost= EXTRAS.Cost*EXTRAS.Quantity ,
  TotalProfit.Total,
  DENSE_RANK() OVER (ORDER BY TotalProfit.Total DESC) AS RankTotal
FROM EXTRAS JOIN 
   (SELECT  ReservationID, SUM(Cost*Quantity) AS Total
    FROM EXTRAS
    GROUP BY ReservationID
   ) AS TotalProfit ON EXTRAS.ReservationID = TotalProfit.ReservationID
ORDER BY RankTotal

--Query 8- With WIndow Function
SELECT U.UserEmail, NumOfReservations = COUNT(*), [RANK] = RANK() OVER(ORDER BY COUNT(*) DESC)
FROM USERS AS U JOIN [CREDIT CARDS] AS C ON U.UserEmail=C.UserEmail JOIN RESERVATIONS AS R ON R.CardNumber=C.CardNumber
GROUP BY U.UserEmail

--Query 9- With WIndow Function
SELECT TOP 10 U.UserEmail, FullName = U.FirstName + ' ' + U.LastName, DaysToStart = DATEDIFF(dd, '2024-08-01', FIRST_VALUE(StartDate) OVER (PARTITION BY U.UserEmail ORDER BY StartDate))
FROM USERS AS U JOIN [CREDIT CARDS] AS C ON U.UserEmail=C.UserEmail JOIN RESERVATIONS AS R ON R.CardNumber=C.CardNumber
GROUP BY U.UserEmail, U.FirstName, U.LastName, R.StartDate
ORDER BY DaysToStart

--Query 10- WITH REPORT
WITH
-- Query 1: Get all users who booked a vacation
UserBookings AS (
SELECT u.UserEmail, u.FirstName + ' ' + u.LastName AS FullName, r.ReservationID
FROM USERS u
JOIN [CREDIT CARDS] cc ON u.UserEmail = cc.UserEmail
JOIN RESERVATIONS r ON cc.CardNumber = r.CardNumber
),

-- Query 2: Count the number of resort bookings for each user
ResortBookings AS (
SELECT ub.UserEmail, COUNT(DISTINCT br.SerialNumber) AS ResortBookingsCount
FROM UserBookings ub
JOIN [BOOK ROOMS] br ON ub.ReservationID = br.ReservationID
JOIN RESORTS rs ON br.SerialNumber = rs.SerialNumber
GROUP BY ub.UserEmail
),

-- Query 3: Count the number of liveaboard bookings for each user
LiveaboardBookings AS (
SELECT ub.UserEmail, COUNT(DISTINCT br.SerialNumber) AS LiveaboardBookingsCount
FROM UserBookings ub
JOIN [BOOK ROOMS] br ON ub.ReservationID = br.ReservationID
JOIN LIVEABOARDS lb ON br.SerialNumber = lb.SerialNumber
GROUP BY ub.UserEmail
),

-- Query 4: Calculate the average review score for each user and categorize their booking preference
UserSummary AS (
SELECT	ub.UserEmail,
MAX(ub.FullName) AS FullName,
ISNULL(MAX(rb.ResortBookingsCount), 0) AS ResortBookingsCount,
ISNULL(MAX(lb.LiveaboardBookingsCount), 0) AS LiveaboardBookingsCount,
AVG(rv.Rating) AS AverageReviewScore,
CASE
WHEN ISNULL(MAX(rb.ResortBookingsCount), 0) > ISNULL(MAX(lb.LiveaboardBookingsCount), 0) THEN 'Resort'
WHEN ISNULL(MAX(rb.ResortBookingsCount), 0) < ISNULL(MAX(lb.LiveaboardBookingsCount), 0) THEN 'Liveaboard'
ELSE 'No Preference'
END AS PreferredVacation
FROM UserBookings ub
LEFT JOIN ResortBookings rb ON ub.UserEmail = rb.UserEmail
LEFT JOIN LiveaboardBookings lb ON ub.UserEmail = lb.UserEmail
LEFT JOIN REVIEWS rv ON ub.UserEmail = rv.UserEmail
GROUP BY ub.UserEmail
)

-- Final Select to combine all the information
SELECT	us.UserEmail, us.FullName, us.ResortBookingsCount, us.LiveaboardBookingsCount, us.AverageReviewScore, us.PreferredVacation
FROM UserSummary us
ORDER BY us.UserEmail

GO
-- Views for Power BI
CREATE VIEW V_RESERVATIONS_EXTRAS  AS
	SELECT RES.ReservationID, RES.NumOfDivers, RES.NumOfNonDivers, 
	[DATEDIFF] = DATEDIFF(dd, RES.Startdate,RES.EndDate), 
	Country = (ISNULL (L.Destination,r.[Address–Country])), 
	RES.StartDate, E.ExtraName, E.Quantity, E.Cost, TotalCost= E.Quantity*E.Cost
	FROM RESERVATIONS AS RES JOIN [BOOK ROOMS] AS B ON B.ReservationID=RES.ReservationID 
	LEFT JOIN RESORTS AS R ON R.SerialNumber=B.SerialNumber LEFT JOIN LIVEABOARDS AS L ON L.SerialNumber=B.SerialNumber 
	LEFT JOIN EXTRAS AS E ON E.ReservationID=RES.ReservationID
GO

CREATE VIEW V_VACATIONS_REVIEWS AS
	SELECT V.SerialNumber, V.VacationName, REV.Rating, REV.ReviewDT, 
	Country = (ISNULL (L.Destination,r.[Address–Country]))
	FROM RESORTS AS R FULL JOIN LIVEABOARDS AS L ON R.SerialNumber=L.SerialNumber 
	JOIN REVIEWS AS REV ON REV.SerialNumber=R.SerialNumber OR REV.SerialNumber=L.SerialNumber
	JOIN VACATIONS AS V ON V.SerialNumber=R.SerialNumber OR V.SerialNumber=L.SerialNumber
