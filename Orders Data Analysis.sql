use Projects;

drop table df_orders;  --to implement the append method on Python

CREATE TABLE df_orders (
    [order_id] INT PRIMARY KEY,
    [order_date] DATE,
    [ship_mode] VARCHAR(20),
    [segment] VARCHAR(20),
    [country] VARCHAR(20),
    [city] VARCHAR(20),
    [state] VARCHAR(20),
    [postal_code] VARCHAR(20),
    [region] VARCHAR(20),
    [category] VARCHAR(20),
    [sub_category] VARCHAR(20),
    [product_id] VARCHAR(50),
    [quantity] INT,
    [discount] DECIMAL(7,2),
    [sale_price] DECIMAL(7,2),
    [profit] DECIMAL(7,2)
);

--after appending from python...



--- AT THIS STAGE, ETL HAS BEEN DONE
------ extracted from Kaggle (--https://www.kaggle.com/datasets/ankitbansal06/retail-orders) with orders.csv file name
------ transformed with Python (Pandas)
------ and loaded to MSSQL server for further analysis


---EDA

select 
	* 
from df_orders;
---9994 records

select 
	count(distinct product_id) from df_orders; 
---1862 unique product IDs

select
	distinct region
from df_orders;
---4 unique regions

select 
	distinct year(order_date) 
from df_orders
---2 unique years

select 
	DAY(order_date) as day,
	MONTH(order_date) as month,
	YEAR(order_date) as year
from df_orders
---to get the correct day, month and year of the ordr_date column



-- ANALYTICAL QUESTIONS

-- 1. find top 10 highest revenue generating products

SELECT TOP 10
    product_id,
    SUM(sale_price) AS sales
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC;

-- 2. find top 5 highest selling products in each region

WITH cte AS (
    SELECT 
        region,
        product_id,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY region, product_id
)

SELECT 
    *
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY sales DESC) AS rn
    FROM cte
) AS A
WHERE rn <= 5;

-- 3. find month over month growth comparison for 2022 and 2023 sales e.g jan 2022 vs jan 2023

WITH cte AS (
    SELECT 
        YEAR(order_date) AS order_year, 
        MONTH(order_date) AS order_month,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY YEAR(order_date), MONTH(order_date)
    --ORDER BY YEAR(order_date), MONTH(order_date)
)

SELECT 
    order_month,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;

-- 4. for each category, which month had highest sales?

WITH cte AS (
    SELECT 
        category, 
        FORMAT(order_date, 'yyyy-MM') AS order_year_month,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY category, FORMAT(order_date, 'yyyy-MM')
    --ORDER BY category, FORMAT(order_date, 'yyyy-MM')
)

SELECT * 
FROM (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) AS rn
    FROM cte
) AS a
WHERE rn = 1;

--or

WITH cte AS (
    SELECT 
        category, 
        FORMAT(order_date, 'yyyy-MM') AS order_year_month,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY category, FORMAT(order_date, 'yyyy-MM')
    --ORDER BY category, FORMAT(order_date, 'yyyy-MM')
)
,
rn2 AS (
SELECT * 
FROM (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) AS rn
    FROM cte
) AS a
WHERE rn = 1
)
SELECT 
	category,
	order_year_month,
	sales
FROM rn2;
---this gives same result without the rn column

-- 5. which sub category had the highest growth by profit in 2023 compared to 2022?

WITH cte AS (
    SELECT 
        sub_category, 
        YEAR(order_date) AS order_year,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY sub_category, YEAR(order_date)
), 
cte2 AS (
    SELECT 
        sub_category,
		SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023,
        SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022
    FROM cte 
    GROUP BY sub_category
)
SELECT TOP 1 
    *,
    (sales_2023 - sales_2022) AS sales_growth
FROM cte2
ORDER BY (sales_2023 - sales_2022) DESC;