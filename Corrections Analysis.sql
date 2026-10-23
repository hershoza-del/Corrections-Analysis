#previewing the csv dataset

SELECT * FROM data.corrections_analysis;

#question 1: comparing overtime pay between Rikers Island (Queens) and the other boroughs

WITH staff AS (
  SELECT *, `Regular Gross Paid` + `Total OT Paid` + `Total Other Pay` AS total_comp
  FROM data.corrections_analysis
  WHERE `Leave Status` = "Active" AND `Pay Basis` = "per Annum" AND `Work Location Borough` <> "Westchester"
)
SELECT `Work Location Borough`, COUNT(*) AS n,
       ROUND(AVG(`Total OT Paid`)) AS avg_ot, 
       ROUND(AVG(total_comp)) AS avg_comp
FROM staff
GROUP BY `Work Location Borough`
ORDER BY avg_ot DESC;

#question 2: to what extent longer-tenured staff get compensated more

WITH staff AS (
  SELECT *, 2025 - CAST(SUBSTR(`Agency Start Date`, 7, 4) AS UNSIGNED) AS tenure_yrs
  FROM data.corrections_analysis
  WHERE `Leave Status` = "Active" AND `Pay Basis` = "per Annum" AND `Work Location Borough` <> "Westchester"
)
SELECT (tenure_yrs DIV 5) * 5 AS tenure_band, COUNT(*) AS n,
       ROUND(AVG(`Total OT Paid`)) AS avg_ot, 
       ROUND(AVG(`Base Salary`)) AS avg_base
FROM staff
GROUP BY tenure_band
ORDER BY tenure_band;

#question 3: comparing overtime pay of corrections officers to other roles

WITH staff AS (
  SELECT * FROM data.corrections_analysis
  WHERE `Leave Status` = "Active" AND `Pay Basis` = "per Annum" AND `Work Location Borough` <> "Westchester"
),
titles AS (
  SELECT title, COUNT(*) AS n, ROUND(AVG(`OT Hours`)) AS avg_ot_hrs,
         ROUND(AVG(`Regular Gross Paid` + `Total OT Paid` + `Total Other Pay`)) AS avg_comp,
         RANK() OVER (ORDER BY COUNT(*) DESC) AS headcount_rank
  FROM staff
  GROUP BY title
)
SELECT * FROM titles
WHERE headcount_rank <= 8
ORDER BY avg_ot_hrs DESC;
