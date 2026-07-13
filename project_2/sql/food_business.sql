CREATE VIEW top_kpi AS (
SELECT SUM(number_of_employees) AS total_employees,
COUNT(business_activities) AS total_business,
ROUND(AVG(number_of_employees),2) AS avg_employees
FROM food_business
)
--------------------------------------------------
SELECT business_activities, 
       COUNT(*) AS business_count,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM food_business
GROUP BY business_activities
ORDER BY business_count DESC
LIMIT 10;