-- CREATE TABLE t_Michael_Fink_project_SQL_secondary_final AS
SELECT
	e.`year` 
	,e.country 
	,e.GDP 
	,e.gini 
	,e.population
FROM economies e 
JOIN countries c 
	ON e.country = c.country 
		AND c.continent = 'Europe' 
WHERE e.`year` IN (
	SELECT tmf.common_years
	FROM t_michael_fink_project_sql_primary_final tmf
	)
;
