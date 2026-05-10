CREATE OR REPLACE VIEW `data-geeking-gcp.the_data_challenge.comparison`
AS
SELECT
	s.state,
	AVG(s.avg_state_min_salary)
		AS avg_min_salary,
	AVG(s.median_household_income_2019)
		AS median_household_income_2019,
	AVG(s.avg_state_min_salary)
	> AVG(s.median_household_income_2019) AS happy_data_engineer
FROM `data-geeking-gcp.the_data_challenge.avg_per_state` AS s
	INNER JOIN
		`data-geeking-gcp.the_data_challenge.usa_median_household_income_2019` AS mi
		ON s.state = mi.state
GROUP BY 1
