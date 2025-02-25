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

### Extract:
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

### Transform (Data Cleaning):
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

### Load:
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

Top 10 Revenue-Generating Products:
