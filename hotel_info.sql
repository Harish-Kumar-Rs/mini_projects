CREATE TABLE hotel_info (
quarter TEXT,
year BIGINT,
value INT,
title VARCHAR (255),
quarter_number INT,
sort_id INT
)
-------------------------------------------------------------
SELECT * FROM hotel_info
--LIMIT(10)
-------------------------------------------------------------
-- GROWTH OF HOTEL APARTMENT OVER YEARS
SELECT 
year AS year,
SUM(value) AS total_apartments
FROM hotel_info
WHERE TRIM(LOWER(title)) LIKE '%number of hotel apartments%'
GROUP BY year
ORDER BY year 
---------------------------------------------------------------
--YEAR OVER YEAR GROWTH USING LAG 
CREATE VIEW yoy_apt AS
WITH yearly_total AS( -- CTE COMMON TABLE EXPRESSION 
SELECT 
year,
SUM(value) AS total_apartments
FROM hotel_info
WHERE TRIM(LOWER(title)) LIKE '%number of hotel apartments%'
GROUP BY year
),
yoy_data AS(
SELECT 
year,
total_apartments,
LAG(total_apartments) OVER (ORDER BY year) AS prev_year_total
FROM yearly_total
)
SELECT
year,
total_apartments,
prev_year_total,
total_apartments - prev_year_total AS yoy_change,
ROUND(((total_apartments - prev_year_total)*100.0)/prev_year_total,2) AS yoy_growth_pct
FROM yoy_data
-------------------------------------------------------------------------------------------
CREATE VIEW std_yoy_aprtments AS
WITH yearly_totals AS ( -- STANDARD DEVIATION OF YOY GROWTH 
    SELECT
        year,
        SUM(value) AS total_apartments
    FROM hotel_info
    WHERE LOWER(TRIM(title)) LIKE '%number of hotel apartments%'
    GROUP BY year
),
yoy_changes AS (
    SELECT
        year,
        total_apartments,
        total_apartments -
        LAG(total_apartments) OVER (ORDER BY year) AS yoy_change
    FROM yearly_totals
)
SELECT
    ROUND(STDDEV_SAMP(yoy_change), 2) AS std_dev_yoy_change
FROM yoy_changes
WHERE yoy_change IS NOT NULL
AND year NOT IN (2020,2021);
----------------------------------------------------------------------------------------------------------
-- EXCLUDING THE YEARS 2020 & 2021 AS AN EXPECTION OF PANDAMIC WE HAVE A STD OF 2632.18 FOR THE YOY GROWTH
--INDICATING RELATIVELY STABLE ANNUAL FLUCTUATIONS INCLUDING EXCEPTIONAL YEARS MAY SKEW THE STD FAR HIGH 
----------------------------------------------------------------------------------------------------------

-- YOY GROWTH OF HOTEL ROOMS
CREATE VIEW yoy_growth_rooms AS
WITH yearly_totals AS (
SELECT 
year,
SUM(value) AS total_rooms
FROM hotel_info
WHERE LOWER(TRIM(title)) ILIKE '%number of hotel rooms%'
GROUP BY year
),
yoy_data AS (
SELECT
year,
total_rooms,
LAG(total_rooms) OVER (ORDER BY year) AS prev_year_total
FROM yearly_totals
)
SELECT
year,
total_rooms,
prev_year_total,
total_rooms - prev_year_total AS yoy_change,
ROUND(((total_rooms - prev_year_total)*100.0)/prev_year_total,2) AS yoy_growth_pct
FROM yoy_data
-------------------------------------------------------------------------------------
-- AVG & STD OF YOY GROWTH PERCENTAGE EXCLUDING PANDEMIC MONTHS FOR ROOMS 
WITH yearly_totals AS (
SELECT
year,
SUM(value) AS total_rooms
FROM hotel_info
WHERE LOWER(TRIM(title)) ILIKE '%number of hotel rooms%'
GROUP BY year
),
yoy_change AS (
SELECT 
year,
total_rooms,
LAG(total_rooms) OVER(ORDER  BY year) AS prev_year_total
FROM yearly_totals
),
yoy_growth_pct AS(
SELECT
year,
total_rooms,
prev_year_total,
total_rooms - prev_year_total AS yoy_change,
ROUND(((total_rooms - prev_year_total)*100.0)/prev_year_total,2) AS yoy_growth_pct
FROM yoy_change
)
SELECT
ROUND(AVG(yoy_growth_pct),2) AS avg_growth_pct,
ROUND(STDDEV_SAMP(yoy_growth_pct),2) AS std_dev_sample,
ROUND(STDDEV_POP(yoy_growth_pct),2) AS std_dev_population
FROM yoy_growth_pct
WHERE year NOT IN (2020,2021)
AND prev_year_total IS NOT NULL 
-------------------------------------------------------------------------------------------------------
-- Excluding the exceptional pandamic years(2020,2021) the number of total rooms grew at an avg annual rate
-- of 6.31. The sample std of 3.07 percentage points indicates that annual growth was relatively stable
-- with moderate variation around long term avg
-------------------------------------------------------------------------------------------------------

-- AVG & STD OF YOY GROWTH PERCENTAGE EXCLUDING PANDEMIC MONTHS FOR ROOMS 
CREATE VIEW avg_std AS
WITH yearly_totals AS(
SELECT 
year,
SUM(value) AS total_apartments
FROM hotel_info
WHERE LOWER(TRIM(title)) ILIKE '%number of hotel apartments%'
GROUP BY year
),
yoy_change AS (
SELECT
year,
total_apartments,
LAG(total_apartments) OVER (ORDER BY year) AS prev_year_total
FROM yearly_totals
),
yoy_growth_pct AS(
SELECT
year,
total_apartments,
prev_year_total,
((total_apartments - prev_year_total)*100.0)/prev_year_total AS yoy_pct
FROM yoy_change
)
SELECT
ROUND(AVG(yoy_pct),2) AS avg_growth_pct,
ROUND(STDDEV_SAMP(yoy_pct),2) AS std_growth_pct
FROM yoy_growth_pct
WHERE year NOT IN (2020,2021)
AND prev_year_total IS NOT NULL
------------------------------------------------------------------------------------------------
--QURTERLY GROWTH TREND
CREATE VIEW quarter_trend AS
WITH quarter_totals AS (
    SELECT
        year,
        quarter,
        SUM(value) AS total_rooms
    FROM hotel_info
    WHERE TRIM(title) ILIKE '%number of hotel rooms%'
    GROUP BY year, quarter
),
q_change AS (
    SELECT
        year,
        quarter,
        total_rooms,
        LAG(total_rooms) OVER (
            ORDER BY
                year,
                CASE quarter
                    WHEN 'First Quarter' THEN 1
                    WHEN 'Second Quarter' THEN 2
                    WHEN 'Third Quarter' THEN 3
                    WHEN 'Fourth Quarter' THEN 4
                END
        ) AS prev_q_total
    FROM quarter_totals
)
SELECT
    year,
    quarter,
    total_rooms,
    prev_q_total,
    ROUND(
        ((total_rooms - prev_q_total) * 100.0) / prev_q_total,
        2
    ) AS growth_pct
FROM q_change
ORDER BY
    year,
    CASE quarter
        WHEN 'First Quarter' THEN 1
        WHEN 'Second Quarter' THEN 2
        WHEN 'Third Quarter' THEN 3
        WHEN 'Fourth Quarter' THEN 4
    END;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



