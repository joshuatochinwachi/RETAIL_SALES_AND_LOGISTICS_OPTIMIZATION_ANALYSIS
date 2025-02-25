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
Extract: The dataset was downloaded from Kaggle using the Kaggle API and extracted from a zip file.
Transform:
a)	Handled null values by replacing 'Not Available' and 'unknown' with NaN.
b)	Renamed columns to lowercase and replaced spaces with underscores for consistency.
c)	Derived new columns: discount, sale_price, and profit using existing columns.
d)	Converted order_date from an object to a datetime data type.
e)	Dropped unnecessary columns like cost_price, list_price, and discount_percent.
Load: The cleaned data was loaded into a SQL Server database using the sqlalchemy library, with options to either replace or append the data.

