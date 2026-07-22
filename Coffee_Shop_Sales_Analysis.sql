/*
===============================================================================
                     COFFEE SHOP SALES ANALYSIS USING SQL
===============================================================================

Project  : Coffee Shop Sales Analytics Dashboard
Author   : Yashovardhan Agrawal
Database : MySQL

Sections:
1. Database Setup
2. Data Cleaning & Preparation
3. Monthly Sales Analysis
4. Month-over-Month (MoM) Analysis
5. Daily KPI Analysis
6. Weekday vs Weekend Analysis
7. Store Performance Analysis
8. Daily Sales Analysis
9. Product Performance Analysis
10. Hourly Sales Analysis
11. Day-wise Sales Analysis

===============================================================================
*/


/*==============================================================================
1. DATABASE SETUP
==============================================================================*/

CREATE DATABASE Coffee_Shop_Sales_Db;

SELECT *
FROM `coffee shop sales`;

DESCRIBE `coffee shop sales`;


/*==============================================================================
2. DATA CLEANING & PREPARATION
==============================================================================*/

SET SQL_SAFE_UPDATES = 0;

-- Convert transaction_date to DATE
UPDATE `coffee shop sales`
SET transaction_date = STR_TO_DATE(transaction_date,'%d-%m-%Y');

ALTER TABLE `coffee shop sales`
MODIFY COLUMN transaction_date DATE;


-- Convert transaction_time to TIME
UPDATE `coffee shop sales`
SET transaction_time = STR_TO_DATE(transaction_time,'%H:%i:%s');

ALTER TABLE `coffee shop sales`
MODIFY COLUMN transaction_time TIME;


-- Rename transaction_id column
ALTER TABLE `coffee shop sales`
CHANGE COLUMN ï»¿transaction_id transaction_id INT;


-- Verify cleaned data
SELECT *
FROM `coffee shop sales`;


/*==============================================================================
3. MONTHLY SALES ANALYSIS
==============================================================================*/

SELECT
    ROUND(SUM(transaction_qty * unit_price)) AS total_sales
FROM `coffee shop sales`
WHERE MONTH(transaction_date) = 5;


/*==============================================================================
4. MONTH-OVER-MONTH (MoM) ANALYSIS
==============================================================================*/


-- 4.1 Month-over-Month Sales Growth

SELECT
    MONTH(transaction_date) AS month,
    ROUND(SUM(transaction_qty * unit_price)) AS total_sales,
    (
        SUM(transaction_qty * unit_price) -
        LAG(SUM(transaction_qty * unit_price), 1)
        OVER (ORDER BY MONTH(transaction_date))
    )
    /
    LAG(SUM(transaction_qty * unit_price), 1)
    OVER (ORDER BY MONTH(transaction_date))
    * 100 AS inc_in_per

FROM `coffee shop sales`

WHERE MONTH(transaction_date) IN (4,5)

GROUP BY MONTH(transaction_date)

ORDER BY MONTH(transaction_date);



-- 4.2 Month-over-Month Orders Growth

SELECT
    MONTH(transaction_date) AS month,
    COUNT(transaction_id) AS total_orders,
    (
        COUNT(transaction_id) -
        LAG(COUNT(transaction_id),1)
        OVER (ORDER BY MONTH(transaction_date))
    )
    /
    LAG(COUNT(transaction_id),1)
    OVER (ORDER BY MONTH(transaction_date))
    *100 AS inc_in_per

FROM `coffee shop sales`

WHERE MONTH(transaction_date) IN (4,5)

GROUP BY MONTH(transaction_date)

ORDER BY MONTH(transaction_date);



-- 4.3 Month-over-Month Quantity Sold Growth

SELECT
    MONTH(transaction_date) AS month,
    SUM(transaction_qty) AS total_quantity,
    (
        SUM(transaction_qty) -
        LAG(SUM(transaction_qty),1)
        OVER (ORDER BY MONTH(transaction_date))
    )
    /
    LAG(SUM(transaction_qty),1)
    OVER (ORDER BY MONTH(transaction_date))
    *100 AS inc_in_per

FROM `coffee shop sales`

WHERE MONTH(transaction_date) IN (4,5)

GROUP BY MONTH(transaction_date)

ORDER BY MONTH(transaction_date);



/*==============================================================================
5. DAILY KPI ANALYSIS
==============================================================================*/


SELECT
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1),'K') AS total_sales,
    CONCAT(ROUND(SUM(transaction_qty)/1000,1),'K') AS total_quantity,
    CONCAT(ROUND(COUNT(transaction_id)/1000,1),'K') AS total_orders

FROM `coffee shop sales`

WHERE transaction_date = '2023-05-18';


/*==============================================================================
6. WEEKDAY VS WEEKEND SALES ANALYSIS
==============================================================================*/

-- 6.1 Weekday vs Weekend Sales

SELECT
    CASE
        WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,

    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1),'K') AS total_sales

FROM `coffee shop sales`

WHERE MONTH(transaction_date) = 5

GROUP BY day_type;



/*==============================================================================
7. STORE PERFORMANCE ANALYSIS
==============================================================================*/

-- 7.1 Store-wise Sales Performance

SELECT
    store_location,
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,2),'K') AS total_sales

FROM `coffee shop sales`

WHERE MONTH(transaction_date) = 6

GROUP BY store_location

ORDER BY SUM(unit_price * transaction_qty) DESC;



/*==============================================================================
8. DAILY SALES ANALYSIS
==============================================================================*/

-- 8.1 Average Daily Sales

SELECT
    MONTH(transaction_date) AS month,
    CONCAT(
        ROUND(
            SUM(unit_price * transaction_qty) / 1000 /
            COUNT(DISTINCT transaction_date),1
        ),
        'K'
    ) AS avg_daily_sales

FROM `coffee shop sales`

WHERE MONTH(transaction_date) = 5

GROUP BY MONTH(transaction_date);



-- 8.2 Daily Sales

SELECT
    DAY(transaction_date) AS day_of_month,
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1),'K') AS total_sales

FROM `coffee shop sales`

WHERE MONTH(transaction_date) = 5

GROUP BY DAY(transaction_date)

ORDER BY DAY(transaction_date);



-- 8.3 Daily Sales Classification

SELECT
    day_of_month,

    CASE
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,

    total_sales

FROM
(
    SELECT
        DAY(transaction_date) AS day_of_month,

        SUM(unit_price * transaction_qty) AS total_sales,

        AVG(SUM(unit_price * transaction_qty))
        OVER () AS avg_sales

    FROM `coffee shop sales`

    WHERE MONTH(transaction_date) = 5

    GROUP BY DAY(transaction_date)

) AS sales_data

ORDER BY day_of_month;


/*==============================================================================
9. PRODUCT PERFORMANCE ANALYSIS
==============================================================================*/

-- 9.1 Sales by Product Category

SELECT
    product_category,
    ROUND(SUM(unit_price * transaction_qty),2) AS total_sales

FROM `coffee shop sales`

WHERE MONTH(transaction_date) = 5

GROUP BY product_category

ORDER BY total_sales DESC;



-- 9.2 Top 10 Coffee Products

SELECT
    product_type,
    ROUND(SUM(unit_price * transaction_qty),2) AS total_sales

FROM `coffee shop sales`

WHERE MONTH(transaction_date) = 5
  AND product_category = 'Coffee'

GROUP BY product_type

ORDER BY total_sales DESC

LIMIT 10;



/*==============================================================================
10. HOURLY SALES ANALYSIS
==============================================================================*/

-- 10.1 Sales Metrics for a Specific Hour

SELECT
    SUM(unit_price * transaction_qty) AS total_sales,
    SUM(transaction_qty) AS total_quantity,
    COUNT(*) AS total_orders

FROM `coffee shop sales`

WHERE MONTH(transaction_date) = 5
  AND DAYOFWEEK(transaction_date) = 1
  AND HOUR(transaction_time) = 14;



-- 10.2 Hourly Sales Trend

SELECT
    HOUR(transaction_time) AS hour_of_day,
    ROUND(SUM(unit_price * transaction_qty),2) AS total_sales

FROM `coffee shop sales`

WHERE MONTH(transaction_date) = 5

GROUP BY HOUR(transaction_time)

ORDER BY hour_of_day;



/*==============================================================================
11. DAY-WISE SALES ANALYSIS
==============================================================================*/

SELECT
    CASE
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS day_of_week,

    ROUND(SUM(unit_price * transaction_qty)) AS total_sales

FROM `coffee shop sales`

WHERE MONTH(transaction_date) = 5

GROUP BY
    CASE
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END

ORDER BY FIELD(
    day_of_week,
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
);



/*==============================================================================
END OF SQL ANALYSIS
==============================================================================*/
