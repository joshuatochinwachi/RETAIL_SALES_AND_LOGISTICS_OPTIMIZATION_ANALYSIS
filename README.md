# RETAIL_SALES_AND_LOGISTICS_OPTIMIZATION_ANALYSIS
I analyzed retail data (2022–2023) using Python (ETL) and SQL. Identified top products, regional trends, and sales growth, providing actionable insights to optimize logistics, boost sales, and improve profitability.

## Project Overview
This project focuses on analyzing retail order data to uncover insights that can help optimize logistics, improve sales performance, and enhance decision-making for a retail business. The dataset, sourced from Kaggle, contains information about orders, including order dates, shipping modes, product categories, sales, discounts, and profits. The analysis was conducted using a combination of Python for data extraction, transformation, and loading (ETL), and SQL for advanced analytical queries. The goal was to transform raw data into actionable insights that can drive strategic business decisions.

## Project Objective
The primary objective of this project was to:
1.	Analyze Sales Performance: Identify top-performing products, regions, and categories.
2.	Optimize Logistics: Understand shipping patterns and their impact on sales.
3.	Track Growth: Compare month-over-month sales growth between 2022 and 2023.
4.	Identify Trends: Determine which months and categories had the highest sales and profits.
5.	Provide Recommendations: Offer data-driven recommendations to improve business operations and profitability.

## Data Used
The dataset used in this project is the Retail Orders Dataset (can be downloaded [here]( https://www.kaggle.com/datasets/ankitbansal06/retail-orders) with orders.csv file name), which contains the following key columns:
Order Details: order_id, order_date, ship_mode, segment, region, category, sub_category, product_id, quantity.
Financial Metrics: cost_price, list_price, discount_percent, sale_price, profit.
Geographical Data: country, city, state, postal_code.
The dataset contains 9,994 records with data spanning two years (2022 and 2023).

## Tools Used
Python: Used for data extraction, cleaning, transformation, and loading (ETL). Libraries like pandas, zipfile, and sqlalchemy were utilized.
SQL: Used for advanced data analysis, including aggregations, window functions, and trend analysis.
SQL Server: Used as the database to store and query the cleaned data.
Kaggle API: Used to download the dataset directly from Kaggle.

## Key Questions
The analysis aimed to answer the following key business questions:
1.	Top Products: What are the top 10 highest revenue-generating products?
2.	Regional Performance: What are the top 5 highest-selling products in each region?
3.	Sales Growth: How does month-over-month sales growth compare between 2022 and 2023?
4.	Category Performance: For each category, which month had the highest sales?
5.	Profit Growth: Which sub-category had the highest profit growth in 2023 compared to 2022?

## ETL Process Using Python
The ETL process was implemented using Python to prepare the data for analysis:

#### Extract:
The dataset was downloaded from Kaggle using the Kaggle API and extracted from a zip file using the python codes below.
```
!pip install kaggle
import kaggle
!kaggle datasets download ankitbansal06/retail-orders -f orders.csv

import zipfile
zip_ref = zipfile.ZipFile('orders.csv.zip')
zip_ref.extractall() # extract file to dir
zip_ref.close() # close file

import pandas as pd
df = pd.read_csv('orders.csv')
```

#### Transform (Data Cleaning):
1.	Handled null values by replacing 'Not Available' and 'unknown' with NaN.
```
df = pd.read_csv('orders.csv', na_values=['Not Available', 'unknown'])
```
2.	Renamed columns to lowercase and replaced spaces with underscores for consistency.
```
df.columns = df.columns.str.lower()

df.columns = df.columns.str.replace(' ','_')
```
3.	Derived new columns: discount, sale_price, and profit using existing columns.
```
#the values in discount_percent column is in percentage. Therefore, when calculating, we'll multiply by 0.01

#for discount
df['discount'] = df['list_price'] * df['discount_percent'] * .01

#for sale price
df['sale_price'] = df['list_price'] - df['discount']

#for profit
df['profit'] = df['sale_price'] - df['cost_price']
```
4.	Converted order_date from an object to a datetime data type.
```
df['order_date'] = pd.to_datetime(df['order_date'], format = '%Y-%m-%d')
```
5.	Dropped unnecessary columns like cost_price, list_price, and discount_percent.
```
df.drop(columns = ['cost_price', 'list_price', 'discount_percent'], inplace=True)
```

#### Load:
The cleaned data was loaded into a SQL Server database using the sqlalchemy library, with options to either replace or append the data.
```
import sqlalchemy as sal
engine = sal.create_engine('mssql://Josh/Projects?driver=SQL+SERVER')
conn = engine.connect()

# loading the data into sql server using replace option
df.to_sql('df_orders', con=conn, index=False, if_exists = 'replace')
```
The append option was more suitable because the data types in the SQL table was not proper. So, I manually created an empty table with the SQL syntax below then appended the table from Python to it.

SQL server Code for the table creation
```
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
```
Implementing the append option on the created table in Python
```
# loading the data into sql server using append option
df.to_sql('df_orders', con=conn, index=False, if_exists = 'append')
```

## Analytical Steps Using SQL
The following analytical steps were performed using SQL:
1.	Top 10 Revenue-Generating Products:
```
SELECT TOP 10
    product_id,
    SUM(sale_price) AS sales
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC;
```
2.	Top 5 Selling Products by Region:
```
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
```
3.	Month-over-Month Sales Growth (2022 vs 2023):
```
WITH cte AS (
    SELECT 
        YEAR(order_date) AS order_year, 
        MONTH(order_date) AS order_month,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    order_month,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;
```
4.	Highest Sales Month for Each Category:
```
WITH cte AS (
    SELECT 
        category, 
        FORMAT(order_date, 'yyyy-MM') AS order_year_month,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY category, FORMAT(order_date, 'yyyy-MM')
)
SELECT * 
FROM (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) AS rn
    FROM cte
) AS a
WHERE rn = 1;
```
5.	Sub-Category with Highest Profit Growth (2023 vs 2022):
```
WITH cte AS (
    SELECT 
        sub_category, 
        YEAR(order_date) AS order_year,
        SUM(profit) AS profit
    FROM df_orders
    GROUP BY sub_category, YEAR(order_date)
), 
cte2 AS (
    SELECT 
        sub_category,
        SUM(CASE WHEN order_year = 2023 THEN profit ELSE 0 END) AS profit_2023,
        SUM(CASE WHEN order_year = 2022 THEN profit ELSE 0 END) AS profit_2022
    FROM cte 
    GROUP BY sub_category
)
SELECT TOP 1 
    *,
    (profit_2023 - profit_2022) AS profit_growth
FROM cte2
ORDER BY (profit_2023 - profit_2022) DESC;
```

## Findings
The analysis yielded the following key insights based on the SQL queries:
1. Top 10 Revenue-Generating Products
The top 10 products contributing the most to revenue were identified. These products are critical for driving sales and should be prioritized in inventory and marketing efforts.

Result:


![image](https://github.com/user-attachments/assets/4c19496f-dca0-4371-a044-a9a796eff6ef)


2. Top 5 Selling Products by Region
The top 5 products in each region were identified, highlighting regional preferences and opportunities for targeted marketing.

Result:


![image](https://github.com/user-attachments/assets/6bfa282c-5cd4-4123-9e57-cca9c0cfe305)


3. Month-over-Month Sales Growth (2022 vs 2023)
The month-over-month sales growth comparison revealed significant growth in 2023 compared to 2022, with certain months showing exponential growth.

Result:


![image](https://github.com/user-attachments/assets/6884f6b1-d5aa-4a3f-aaeb-1530be33e246)


4. Highest Sales Month for Each Category
The best-performing months for each category were identified, with Furniture and Office Supplies leading in sales.

Result:


![image](https://github.com/user-attachments/assets/88c6c296-78b9-445a-9c11-b45ecd74f1de)


5. Sub-Category with Highest Profit Growth (2023 vs 2022)
The Technology sub-category had the highest profit growth in 2023 compared to 2022, making it a key area for investment.

Result:


![image](https://github.com/user-attachments/assets/4c4842e7-1ea1-4bba-bf10-32bd3432582a)


## Recommendations
Focus on Top Products: Allocate more resources to the top 10 revenue-generating products, such as TEC-PH-10003645 and FUR-CH-10000454, to maximize profits.
Regional Optimization: Tailor marketing strategies based on regional preferences. For example, TEC-PH-10003645 is a top performer in both the South and West regions.
Seasonal Promotions: Leverage insights from month-over-month growth to plan seasonal promotions. For instance, March and May are high-performing months for Furniture and Office Supplies, respectively.
Category Expansion: Invest in high-performing categories like Furniture and Technology to drive further growth.
Profit Maximization: Focus on sub-categories with the highest profit growth, such as Technology, to ensure sustained profitability.

## Conclusion
This project demonstrates my ability to extract, transform, and analyze large datasets using Python and SQL. By uncovering key insights into sales performance, regional trends, and profit growth, I provided actionable recommendations to optimize business operations. My expertise in data analysis, combined with my proficiency in Python, SQL, and database management, makes me a strong candidate for data-driven roles in any organization. This project showcases my ability to turn raw data into meaningful insights that drive business success.
