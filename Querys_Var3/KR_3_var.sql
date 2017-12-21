--1

SELECT Car.RegNum, Car.Model, SUM((Car.DailyPay*Con.PlanDays)+(Car.DailyPay*Con.OverDays)+(Con.OverDays*Con.Fine)) as Dohod  FROM Car
JOIN Contract AS Con ON Con.CarN = Car.CarN
CROSS JOIN (
	SELECT MAX(Car.DailyPay) AS SUMM FROM Car
	JOIN Contract ON Contract.CarN = Car.CarN
	JOIN Office ON Office.RecN = Contract.GetRecN
	WHERE 
		Office.OffCode =  'PORT-23765' --'OffCode_1'
) AS D
GROUP BY
	Car.RegNum, Car.Model,SUMM, Car.DailyPay
HAVING
	Car.DailyPay > SUMM

--2 


SELECT Office.OffCode, Office.City, Office.Addr FROM Office
JOIN Contract ON Contract.GetRecN = Office.RecN
WHERE
	Contract.GetRecN != Contract.RetRecN

--3
SELECT Tenant.* FROM Tenant
JOIN (
SELECT Tenant.ArN, COUNT(DISTINCT Contract.CarN) AS col FROM Office
JOIN Contract ON Contract.GetRecN = Office.RecN
JOIN Tenant ON Tenant.ArN = Contract.ArN
WHERE
	Contract.GetRecN = Contract.RetRecN
GROUP BY 
	Tenant.ArN
HAVING
	COUNT(DISTINCT Contract.CarN) > 1
) V1 ON V1.ArN = Tenant.ArN


--4
SELECT DISTINCT Tenant.* FROM Tenant
JOIN (
SELECT Contract.ArN, SUM (Contract.PlanDays) AS SUMM, Car.CarN FROM Contract
JOIN Car ON Car.CarN = Contract.CarN
CROSS JOIN
	(
		SELECT AVG(Contract.PlanDays) AS SUMM FROM Contract
	)AS D
GROUP BY
	Contract.ArN, SUMM, Car.CarN 
HAVING
	SUM (Contract.PlanDays) > SUMM
)V1 ON V1.ArN = Tenant.ArN

--5

SELECT Car.RegNum, Car.Model FROM Car 
JOIN (
SELECT DISTINCT Car.RegNum, Car.Model FROM Car
JOIN Contract ON Contract.CarN = Car.CarN
WHERE
	Contract.OverDays > 0
EXCEPT
	SELECT DISTINCT Car.RegNum, Car.Model  FROM Car
	JOIN Contract ON Contract.CarN = Car.CarN
	WHERE
	Contract.OverDays = 0
) V1 ON V1.RegNum = Car.RegNum


--UPDATE Contract
--SET OverDays = '0'
--WHERE
--	InvN = '7'