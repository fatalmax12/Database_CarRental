
--1

SELECT T.OffCode, C.RegNum
FROM	(
		SELECT O.OffCode, C.CarN
		FROM Office O
		CROSS JOIN Car C
		EXCEPT
		SELECT O.OffCode, C.CarN
		FROM Office O
		JOIN Contract C ON O.RecN = C.GetRecN
		) T
JOIN Car C ON C.CarN = T.CarN

--2

SELECT DISTINCT Office.OffCode, Office.City, Office.Addr FROM Office
JOIN Contract ON Contract.GetRecN = Office.RecN
JOIN (
	SELECT 
	Office.OffCode, 
	COUNT(DISTINCT Contract.CarN) AS REG
	 FROM Office
	JOIN Contract ON Contract.RetRecN = Office.RecN
	GROUP BY 
	Office.OffCode
	HAVING
	COUNT(DISTINCT Contract.CarN) > 1
)AS A1 ON Office.OffCode = A1.OffCode


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
