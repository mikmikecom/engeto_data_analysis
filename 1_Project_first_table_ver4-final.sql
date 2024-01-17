CREATE TABLE t_Michael_Fink_project_SQL_primary_final AS	
SELECT *
FROM 	(
		SELECT
			cp.payroll_year AS common_years
			,cpib.name AS research_category
			,round(avg(value), 0) AS avg_value
			,'mzda' AS research_subject
		FROM czechia_payroll cp 
		JOIN czechia_payroll_industry_branch cpib 
			ON cp.industry_branch_code = cpib.code AND cp.value_type_code = 5958
		GROUP BY cp.payroll_year, industry_branch_code		
	 	UNION
		SELECT
			YEAR(cp.date_from) AS common_years
			,cpc.name AS research_category
			,round(avg(cp.value), 2) AS avg_value
			,'potravina' AS research_subject
		FROM czechia_price cp
		JOIN czechia_price_category cpc 
			ON cp.category_code = cpc.code
		GROUP BY common_years, cp.category_code
	 	UNION
		SELECT
			e.`year` AS common_years
			,e.country AS research_category
			,e.GDP AS avg_hodnota
			,'HDP' AS research_subject
		FROM economies e 
		WHERE e.country = 'Czech Republic'
			AND e.GDP IS NOT NULL) sub	
WHERE sub.common_years IN (
	SELECT cp.payroll_year  AS common_year
	FROM czechia_payroll cp 
	INTERSECT		
	SELECT YEAR(cp.date_from) AS common_year
	FROM czechia_price cp
	INTERSECT	
	SELECT e.`year` AS common_year
	FROM economies e
	)
;
