USE HotelReservation;

SELECT res.ReservationID, ao.AddOnDescription, rao.Price, rao.Quantity, (rao.Price * rao.Quantity) AS AddOnTotal
FROM Reservation res
INNER JOIN ReservationRoom rr ON res.ReservationID = rr.ReservationID
INNER JOIN RoomAddOn rao ON rr.ReservationRoomID = rao.ReservationRoomID
INNER JOIN AddOnPrice aop ON rao.AddOnPriceID = aop.AddOnPriceID
INNER JOIN AddOn ao ON aop.AddOnID = ao.AddOnID
-- WHERE res.ReservationID = 2;