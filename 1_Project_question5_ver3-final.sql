SELECT
	sub.common_years
	,sum(sub.avg_wage) AS sum_avg_wage
	,sum(sub.avg_food_price) AS sum_avg_food_price
	,sum(sub.avg_HDP) AS sum_avg_HDP
	,round((sum(sub.avg_wage) - LAG(sum(sub.avg_wage)) OVER (ORDER BY sub.common_years)) / (LAG(sum(sub.avg_wage)) OVER (ORDER BY sub.common_years)) *100, 2) AS wage_change_ratio
	,round((sum(sub.avg_food_price) - LAG(sum(sub.avg_food_price)) OVER (ORDER BY sub.common_years)) / (LAG(sum(sub.avg_food_price)) OVER (ORDER BY sub.common_years)) *100, 2) AS food_change_ratio
	,round((sum(sub.avg_HDP) - LAG(sum(sub.avg_HDP)) OVER (ORDER BY sub.common_years)) / (LAG(sum(sub.avg_HDP)) OVER (ORDER BY sub.common_years)) *100, 2)  AS HDP_change_ratio
FROM 	(
		SELECT
			tmf.common_years 
			,tmf.research_subject
			,CASE WHEN tmf.research_subject = 'mzda' THEN round(avg(avg_value), 0) END AS avg_wage
			,CASE WHEN tmf.research_subject = 'potravina' THEN round(avg(avg_value), 2) END AS avg_food_price
			,CASE WHEN tmf.research_subject = 'HDP' THEN round(avg(avg_value), 0) END AS avg_HDP
		FROM t_michael_fink_project_sql_primary_final tmf
		GROUP BY tmf.common_years, tmf.research_subject 
		) sub
GROUP BY sub.common_years
;