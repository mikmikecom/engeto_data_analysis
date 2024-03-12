SELECT *
FROM	(
		SELECT
			sub.research_category
			,round(avg(sub.ratio), 2) AS avg_ratio
		FROM	(
				SELECT
					tmf.common_years 
					,tmf.research_category
					,tmf.avg_value AS avg_wage
					,LAG(tmf.avg_value) OVER (PARTITION BY tmf.research_category ORDER BY tmf.common_years) AS avg_value_before_year
					,tmf.avg_value - LAG(tmf.avg_value) OVER (PARTITION BY tmf.research_category ORDER BY tmf.common_years) AS annual_increment
					,round((tmf.avg_value - LAG(tmf.avg_value) OVER (PARTITION BY tmf.research_category ORDER BY tmf.common_years)) / (LAG(tmf.avg_value) OVER (PARTITION BY tmf.research_category ORDER BY tmf.common_years)) *100, 2) AS ratio
				FROM t_michael_fink_project_sql_primary_final tmf
				WHERE tmf.research_subject= 'potravina'  
				) sub
		GROUP BY sub.research_category
		) sub2
WHERE sub2.avg_ratio > 0
ORDER BY sub2.avg_ratio
LIMIT 1
;

-- better option
WITH 
batching_food_1 AS (
		SELECT
		tmf.common_years 
		,tmf.research_category
		,tmf.avg_value AS avg_wage
		,LAG(tmf.avg_value) OVER (PARTITION BY tmf.research_category ORDER BY tmf.common_years) AS avg_value_before_year
		,tmf.avg_value - LAG(tmf.avg_value) OVER (PARTITION BY tmf.research_category ORDER BY tmf.common_years) AS annual_increment
		,round((tmf.avg_value - LAG(tmf.avg_value) OVER (PARTITION BY tmf.research_category ORDER BY tmf.common_years)) / (LAG(tmf.avg_value) OVER (PARTITION BY tmf.research_category ORDER BY tmf.common_years)) *100, 2) AS ratio
		FROM t_michael_fink_project_sql_primary_final tmf
		WHERE tmf.research_subject= 'potravina'  
		),	
batching_food_2 AS (
		SELECT 
			research_category
			,round(avg(ratio), 2) AS avg_ratio
		FROM batching_food_1
		GROUP BY research_category
		)
SELECT *
FROM batching_food_2
WHERE avg_ratio > 0
ORDER BY avg_ratio
LIMIT 1
;
