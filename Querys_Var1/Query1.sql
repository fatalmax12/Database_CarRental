SELECT Car.*, C.GetData
FROM Car
JOIN	(	
			SELECT B1.CarN, B1.GetData
			FROM (	SELECT DISTINCT CarN, GetData
					FROM Contract
					WHERE YEAR(GetData) != YEAR(getdate())
				 ) B1
			JOIN ( 
					SELECT DISTINCT CarN, GetData
					FROM Contract 
					WHERE YEAR(GetData) = YEAR(getdate())
				 ) B2 
			ON B1.CarN != B2.CarN
		) C 
ON Car.CarN = C.CarN
