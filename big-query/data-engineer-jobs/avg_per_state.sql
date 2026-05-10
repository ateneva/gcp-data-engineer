CREATE OR REPLACE VIEW `data-geeking-gcp.the_data_challenge.avg_per_state`
AS
SELECT
	job_title,
	job_description,
	salary_estimate,
	min_salary,
	max_salary,
	rating,
	company_name,

	location,

	headquarters,
	size,
	founded,
	type_of_ownership,
	industry,
	sector,
	revenue,
	easy_apply,
	RIGHT(location, 2) AS state,
	AVG(min_salary) OVER (
		PARTITION BY RIGHT(location, 2)
	)                  AS avg_state_min_salary,
	AVG(max_salary) OVER (
		PARTITION BY RIGHT(location, 2)
	)                  AS avg_state_max_salary
FROM `data-geeking-gcp.the_data_challenge.salary`
