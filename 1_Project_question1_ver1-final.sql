SELECT *
FROM 	(
		SELECT 
			tmf.common_years 
			,tmf.research_category
			,tmf.avg_value AS avg_wage
			,LAG(tmf.avg_value) OVER (PARTITION BY tmf.research_category ORDER BY tmf.common_years) AS avg_value_before_year
			,round((tmf.avg_value - LAG(tmf.avg_value) OVER (PARTITION BY tmf.research_category ORDER BY tmf.common_years)) / (LAG(tmf.avg_value) OVER (PARTITION BY tmf.research_category ORDER BY tmf.common_years)) *100, 2) AS ratio		
			,CASE 
				WHEN tmf.avg_value > LAG(tmf.avg_value) OVER (PARTITION BY tmf.research_category ORDER BY tmf.common_years) THEN 'roste'
				WHEN tmf.avg_value < LAG(tmf.avg_value) OVER (PARTITION BY tmf.research_category ORDER BY tmf.common_years) THEN 'klesá'
				WHEN tmf.avg_value = LAG(tmf.avg_value) OVER (PARTITION BY tmf.research_category ORDER BY tmf.common_years) THEN 'stagnuje'
				ELSE 'rok 0'
			 END trend
		FROM t_michael_fink_project_sql_primary_final tmf
		WHERE tmf.research_subject= 'mzda'
		) sub
WHERE sub.trend = 'klesá'
ORDER BY sub.research_category
;