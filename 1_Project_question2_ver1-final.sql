WITH 
wage_data AS
		(
		SELECT
			tmf.common_years 
			,tmf.research_subject 
			,round(avg(avg_value), 0) AS wage
		FROM t_michael_fink_project_sql_primary_final tmf
		WHERE tmf.common_years IN (2006, 2018) AND tmf.research_subject = 'mzda'
		GROUP BY tmf.common_years, tmf.research_subject 
		),
food_data AS
		(
		SELECT 
			tmf.common_years 
			,max(CASE WHEN tmf.research_category LIKE '%Mléko%' THEN tmf.avg_value END) AS milk_price
			,max(CASE WHEN tmf.research_category LIKE '%Chléb%' THEN tmf.avg_value END) AS bread_price
		FROM t_michael_fink_project_sql_primary_final tmf
		WHERE tmf.common_years IN (2006, 2018) AND research_subject = 'potravina'
		GROUP BY tmf.common_years, tmf.research_subject 
		)
SELECT 
	wage_data.common_years
	,wage_data.wage
	,food_data.milk_price
	,food_data.bread_price
	,round((wage_data.wage / food_data.milk_price), 0) AS liters_milk_for_wage
	,round((wage_data.wage / food_data.bread_price), 0) AS kilos_bread_for_wage
FROM wage_data
JOIN food_data
	ON wage_data.common_years = food_data.common_years
;