# Filters the scraped_vacancies view into the scraped_vacancies_in_scope view by excluding vacancies from out of scope schools or where we don't know which school posted the vacancy
SELECT
  scraped_vacancies.*
FROM
  `teacher-vacancy-service.production_dataset.scraped_vacancies` AS scraped_vacancies
LEFT JOIN
  `teacher-vacancy-service.production_dataset.feb20_school` AS school
ON
  scraped_vacancies.school_id=school.id
LEFT JOIN
  `teacher-vacancy-service.production_dataset.feb20_detailedschooltype` AS detailed_school_type
ON
  detailed_school_type.id=school.detailed_school_type_id
WHERE
  scraped
  AND NOT expired_before_scrape
  AND CAST(detailed_school_type.code AS NUMERIC) IN ( #exclude schools recorded in our database which have an out of scope establishment type
  SELECT
    code
  FROM
    `teacher-vacancy-service.production_dataset.STATIC_establishment_types_in_scope`)
