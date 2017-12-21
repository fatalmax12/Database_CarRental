--1

SELECT DISTINCT Office.OffCode, Office.Addr, Office.City FROM Office
JOIN Contract ON Contract.GetRecN = Office.RecN OR Contract.RetRecN = Office.RecN
WHERE
	Contract.GetRecN = Contract.RetRecN

--2


SELECT Tenant.ArN, Car.RegNum FROM Tenant 
CROSS JOIN Car 
EXCEPT 
SELECT Contract.ArN, Contract.CarN AS C FROM Contract

--3

SELECT Car.RegNum, Car.Model FROM Contract
CROSS JOIN (SELECT 
	AVG((Car.DailyPay*Contract.PlanDays)+(Car.DailyPay*Contract.OverDays)+(Contract.OverDays*Contract.Fine))  AS SUMM
FROM Contract
JOIN Car ON Car.CarN = Contract.CarN) AS SUMM
JOIN Car ON Car.CarN = Contract.CarN
GROUP BY
	Car.RegNum, Car.Model,SUMM
HAVING
	SUM((Car.DailyPay*Contract.PlanDays)+(Car.DailyPay*Contract.OverDays)+(Contract.OverDays*Contract.Fine)) > SUMM

--4

SELECT Tenant.* FROM Tenant
JOIN (
SELECT Tenant.ArN, COUNT(Contract.InvN) AS CON, COUNT(DISTINCT Car.CarN) AS COL, SUM((Car.DailyPay*Contract.PlanDays)+(Car.DailyPay*Contract.OverDays)+(Contract.OverDays*Contract.Fine))  AS SUMM  FROM Contract
		JOIN Tenant ON Tenant.ArN = Contract.ArN
		JOIN Car ON Car.CarN = Contract.CarN
GROUP BY 
	Tenant.ArN	
HAVING
	COUNT(Contract.InvN) IN (
		SELECT MAX(CON) FROM Contract
		JOIN Tenant ON Tenant.ArN = Contract.ArN
		JOIN (
			SELECT Tenant.ArN, COUNT(Contract.InvN) AS CON, COUNT(DISTINCT Car.CarN) AS COL, SUM((Car.DailyPay*Contract.PlanDays)+(Car.DailyPay*Contract.OverDays)+(Contract.OverDays*Contract.Fine))  AS SUMM  FROM Contract
				JOIN Tenant ON Tenant.ArN = Contract.ArN
				JOIN Car ON Car.CarN = Contract.CarN
			GROUP BY 
				Tenant.ArN	
		) V1 ON V1.ArN = Tenant.ArN
	) 
) V2 ON V2.ArN = Tenant.ArN




--5

SELECT T.RegNum, T.CarN, T.Dohod, SUM(PlanDays+OverDays)/COUNT(*) AS rentDays
FROM	(	
			SELECT C.RegNum, C.CarN, SUM((C.DailyPay*Con.PlanDays)+(C.DailyPay*Con.OverDays)+(Con.OverDays*Con.Fine)) as Dohod
			FROM Car C
			JOIN Contract Con ON Con.CarN = C.CarN
			GROUP BY C.CarN, C.RegNum
		) T
JOIN Contract C ON T.CarN = C.CarN
GROUP BY T.CarN, T.Dohod, T.RegNum
HAVING	SUM(PlanDays+OverDays)/COUNT(*) >	(
												SELECT SUM(PlanDays+OverDays)/COUNT(*) AS AvgRentDaysLexus
												FROM Car C
												JOIN Contract Con ON C.CarN = Con.CarN
												WHERE Model like 'Lexus RX%'
												GROUP BY C.Model
											)