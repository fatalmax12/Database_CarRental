
--1
SELECT DISTINCT Office.OffCode, Car.RegNum FROM Office
JOIN Contract ON Contract.RetRecN = Office.RecN
JOIN Car ON Car.CarN = Contract.CarN
JOIN (
	SELECT Office.OffCode, Car.RegNum FROM Office
	JOIN Contract ON Contract.GetRecN = Office.RecN
	JOIN Car ON Car.CarN = Contract.CarN
) A1 ON A1.RegNum <> Car.RegNum 


--2
SELECT DISTINCT Office.OffCode, Office.City, Office.Addr FROM Office
JOIN Contract ON Contract.GetRecN = Office.RecN
JOIN Car ON Car.CarN = Contract.CarN
JOIN (
	SELECT 
	Office.OffCode, 
	COUNT(Car.RegNum) AS REG,
	Car.CarN
	 FROM Office
	JOIN Contract ON Contract.RetRecN = Office.RecN
	JOIN Car ON Car.CarN = Contract.CarN
	GROUP BY 
	Office.OffCode,
	Car.CarN
	HAVING
	COUNT(Car.RegNum) > 1
)AS A1 ON Car.CarN = A1.CarN


--3
SELECT DISTINCT Tenant.*  FROM Tenant 
JOIN Contract ON Contract.ArN = Tenant.ArN
JOIN (
SELECT Tenant.ArN, SUM(Contract.PlanDays) AS col_3  FROM Tenant
	JOIN Contract ON Contract.ArN = Tenant.ArN
	GROUP BY
		Tenant.ArN	
HAVING SUM(Contract.PlanDays) in (
	SELECT  MAX(col) AS col_2 FROM Tenant
	JOIN Contract ON Contract.ArN = Tenant.ArN
	JOIN (
		SELECT Tenant.ArN, SUM(Contract.PlanDays) AS col  FROM Tenant
		JOIN Contract ON Contract.ArN = Tenant.ArN
		GROUP BY
			Tenant.ArN	
	)A1 ON A1.ArN = Tenant.ArN
)
)A2 ON A2.ArN = Tenant.ArN






--4

SELECT Office.OffCode,Office.City,Office.Addr, COUNT(DISTINCT Car.Model) AS COL FROM Office
JOIN Contract ON Contract.GetRecN = Office.RecN
JOIN Car ON Car.CarN = Contract.CarN
JOIN (
SELECT Contract.RetRecN FROM Contract
JOIN Car ON Car.CarN = Contract.CarN
WHERE
	Car.Model = 'BMW' --'BMW 2'
) AS D ON D.RetRecN = Office.RecN
GROUP BY
	Office.OffCode,Office.City,Office.Addr

--5

SELECT 
	Car.RegNum, Car.Model, 
	SUM((Car.DailyPay*Con.PlanDays)+(Car.DailyPay*Con.OverDays)+(Con.OverDays*Con.Fine)) as Dohod ,
	AVG(Con.PlanDays + Con.OverDays) AS Col, AVG(SUMM) 
FROM Car
JOIN Contract AS Con ON Con.CarN = Car.CarN
CROSS JOIN (
	SELECT Car.RegNum AS C, AVG(Contract.PlanDays + Contract.OverDays) AS SUMM FROM Car
	JOIN Contract ON Contract.CarN = Car.CarN
	GROUP BY 
		Car.RegNum
) AS D
WHERE
	C != Car.RegNum
GROUP BY 
	Car.RegNum, Car.Model
HAVING
	AVG(Con.PlanDays + Con.OverDays) > AVG(SUMM)
