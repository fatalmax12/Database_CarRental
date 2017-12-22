
--1
SELECT DISTINCT Car.* FROM Car
JOIN Contract ON Contract.CarN = Car.CarN
LEFT JOIN (
	SELECT CarN, GetData FROM [Contract] 
	WHERE 
		YEAR(GetData) = YEAR(GETDATE())
)A1 ON A1.CarN = Car.CarN 
WHERE
	A1.CarN is NULL
	AND
	YEAR(Contract.GetData) <> YEAR(GETDATE())


--2

SELECT DISTINCT Office.* 
FROM Office 
JOIN (	SELECT OffCode,CarN, RetRecN, GetRecN
		FROM Contract 
		JOIN Office ON Office.RecN = Contract.GetRecN 
	 ) Contract 
ON Contract.RetRecN = Office.RecN 
JOIN Car ON Car.CarN = Contract.CarN
WHERE Contract.RetRecN <> Contract.GetRecN


--3
SELECT Tenant.*, col FROM Tenant
JOIN (
SELECT Tenant.ArN, count(distinct Car.CarN) AS col From Tenant
LEFT JOIN Contract ON Contract.ArN = Tenant.ArN
LEFT JOIN Car ON Car.CarN = Contract.CarN
GROUP BY
	Tenant.ArN
	) A2 ON A2.ArN = Tenant.ArN

--4


WITH CountRentCarsOffice_CTE (OffCode, City, Addr, RecN, CountRentCar, Dohod, CountRentContract) 
AS	(
		SELECT O.OffCode, O.City, O.Addr, O.RecN, COUNT(DISTINCT C.CarN) AS CountRentCar, SUM((C.DailyPay*Con.PlanDays)+(C.DailyPay*Con.OverDays)+(Con.OverDays*Con.Fine)) as Dohod, COUNT(Con.ArN) as CountRentContract
		FROM Office O
		JOIN Contract Con ON O.RecN =  Con.GetRecN 
		JOIN Car C ON Con.CarN = C.CarN
		GROUP BY O.RecN, O.OffCode, O.City, O.Addr
	)

SELECT MAX(CountRentCar) CountRentCar, CCTE.RecN, Dohod, CCTE.CountRentContract, OffCode, City, Addr 
FROM CountRentCarsOffice_CTE CCTE
GROUP BY CCTE.RecN, Dohod, CCTE.CountRentContract, OffCode, City, Addr
HAVING MAX(CountRentCar) > = (
								SELECT MAX(CountRentCar)
								FROM(	
										SELECT *
										FROM CountRentCarsOffice_CTE
									) K
							 )


--5

WITH DohodOffice_CTE (RecN, Dohod) 
AS ( 
SELECT O.RecN, SUM((C.DailyPay*Con.PlanDays)+(C.DailyPay*Con.OverDays)+(Con.OverDays*Con.Fine)) as Dohod 
FROM Office O 
JOIN Contract Con ON O.RecN = Con.GetRecN 
JOIN Car C ON Con.CarN = C.CarN 
GROUP BY O.RecN 
) 

SELECT * 
FROM DohodOffice_CTE D 
JOIN ( 
SELECT CTE1.RecN as RecN1, AVG(CTE2.Dohod) DohodBezOficaRecN1 
FROM DohodOffice_CTE CTE1 
FULL JOIN DohodOffice_CTE CTE2 ON CTE1.RecN != CTE2.RecN 
GROUP BY CTE1.RecN 
) R ON D.RecN = R.RecN1 
WHERE D.Dohod > R.DohodBezOficaRecN1
	



