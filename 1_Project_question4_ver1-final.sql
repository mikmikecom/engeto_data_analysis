SELECT *
FROM 	(
		SELECT 
			sub3.common_years
			,max(CASE WHEN sub3.research_subject = "potravina" THEN avg_ratio END) AS avg_food
			,max(CASE WHEN sub3.research_subject = "mzda" THEN avg_ratio END) AS avg_wage
			,max(CASE WHEN sub3.research_subject = "HDP" THEN avg_ratio END) AS avg_HDP
		FROM 	(
				SELECT *
				FROM (
					SELECT
						sub.common_years 
						,sub.research_subject
						,round(avg(sub.ratio), 2) AS avg_ratio
					FROM 	(
							SELECT 
								tmf.common_years 
								,tmf.research_subject
								,tmf.research_category
								,tmf.avg_value
								,LAG(tmf.avg_value) OVER (PARTITION BY tmf.research_category ORDER BY tmf.common_years) AS avg_value_before_year
								,round((tmf.avg_value - LAG(tmf.avg_value) OVER (PARTITION BY tmf.research_category ORDER BY tmf.common_years)) / (LAG(tmf.avg_value) OVER (PARTITION BY tmf.research_category ORDER BY tmf.common_years)) *100, 2) AS ratio		
							FROM t_michael_fink_project_sql_primary_final tmf
							) sub
					GROUP BY sub.research_subject, sub.common_years
					ORDER BY sub.common_years DESC 
					) sub2
				) sub3
		GROUP BY sub3.common_years
		) sub4
WHERE -(sub4.avg_food - sub4.avg_wage) > 10 OR (sub4.avg_food - sub4.avg_wage) > 10
;