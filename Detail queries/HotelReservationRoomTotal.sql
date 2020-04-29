USE HotelReservation;

SELECT CONCAT(c.LastName,', ', c.FirstName) AS FullName, res.ReservationID, r.RoomID, rt.RoomDescription, rr.PricePerNight, 
SUM(rr.NumberOfNights) AS TotalRoomNights, SUM(rr.NumberOfNights * rr.PricePerNight) AS RoomTotal
FROM ReservationRoom rr
INNER JOIN Reservation res ON rr.ReservationID = res.ReservationID
INNER JOIN RoomPrice rp ON rr.RoomPriceID = rp.RoomPriceID
INNER JOIN Room r ON rp.RoomID = r.RoomID
INNER JOIN RoomType rt ON r.RoomTypeID = rt.RoomTypeID
INNER JOIN Customer c ON res.CustomerID = c.CustomerID
GROUP BY r.RoomID
ORDER BY FullName;