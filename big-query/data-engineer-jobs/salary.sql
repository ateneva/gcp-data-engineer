CREATE OR REPLACE VIEW `data-geeking-gcp.the_data_challenge.salary`
AS
SELECT
	job_title,
	job_description,
	salary_estimate,
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
	CAST(
		TRIM(
			REPLACE(REPLACE(SPLIT(salary_estimate, '-')[0], '$', ''), 'K', '')
		) AS FLOAT64
	) AS min_salary,
	CAST(
		TRIM(
			REPLACE(
				REPLACE(SPLIT(SPLIT(salary_estimate, '-')[1], '(')[0], '$', ''), 'K', ''
			)
		) AS FLOAT64
	) AS max_salary
FROM `data-geeking-gcp.the_data_challenge.data_engineer_jobs`
