create database factsales_db;
use factsales_db;
select count(*) from fact_sales;
SET GLOBAL local_infile = 1;

truncate table fact_sales;
CREATE TABLE fact_sales (
    ProductKey INT,
    OrderDateKey INT,
    DueDateKey INT,
    ShipDateKey INT,
    CustomerKey INT,
    PromotionKey INT,
    CurrencyKey INT,
    SalesTerritoryKey INT,

    SalesOrderNumber VARCHAR(20),
    SalesOrderLineNumber INT,
    RevisionNumber INT,

    OrderQuantity INT,
    UnitPrice DECIMAL(10,2),
    ExtendedAmount DECIMAL(12,2),
    UnitPriceDiscountPct DECIMAL(5,2),
    DiscountAmount DECIMAL(12,2),

    ProductStandardCost DECIMAL(10,2),
    TotalProductCost DECIMAL(12,2),
    SalesAmount DECIMAL(12,2),

    TaxAmt DECIMAL(10,2),
    Freight DECIMAL(10,2),

    CarrierTrackingNumber VARCHAR(50),
    CustomerPONumber VARCHAR(50),

    OrderDate DATE,
    DueDate DATE,
    ShipDate DATE,

    ProductName VARCHAR(150),
    CustomerFullName VARCHAR(150),
    UnitPriceProduct DECIMAL(10,2)
);

LOAD DATA LOCAL INFILE 'E:/Data Analyst/Fact_sales.csv' 
INTO TABLE fact_sales 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS;
desc fact_sales;
USE factsales_db;



  
SELECT * FROM fact_sales LIMIT 100;

ALTER TABLE fact_sales
ADD COLUMN Year INT,
ADD COLUMN MonthNo INT,
ADD COLUMN MonthFullName VARCHAR(20),
ADD COLUMN Quarter VARCHAR(2),
ADD COLUMN YearMonth VARCHAR(10),
ADD COLUMN WeekdayNo INT,
ADD COLUMN WeekdayName VARCHAR(20),
ADD COLUMN FinancialMonth INT,
ADD COLUMN FinancialQuarter VARCHAR(2);

desc fact_sales;
SET SQL_SAFE_UPDATES = 0;
#Q3
UPDATE fact_sales
    SET
    Year = YEAR(OrderDate),
    MonthNo = MONTH(OrderDate),
    MonthFullName = MONTHNAME(OrderDate),
    Quarter = CONCAT('Q', QUARTER(OrderDate)),
    YearMonth = DATE_FORMAT(OrderDate, '%Y-%b'),
    WeekdayNo = WEEKDAY(OrderDate) + 1,
    WeekdayName = DAYNAME(OrderDate),
    FinancialMonth =
        CASE
            WHEN MONTH(OrderDate) >= 4
                THEN MONTH(OrderDate) - 3
            ELSE MONTH(OrderDate) + 9
        END,
    FinancialQuarter =
        CASE
            WHEN MONTH(OrderDate) BETWEEN 4 AND 6 THEN 'Q1'
            WHEN MONTH(OrderDate) BETWEEN 7 AND 9 THEN 'Q2'
            WHEN MONTH(OrderDate) BETWEEN 10 AND 12 THEN 'Q3'
            ELSE 'Q4'
        END;
  select * from fact_sales limit 100; 
  
  
  
# Q3


CREATE TABLE Q3 AS
SELECT
    OrderDate,
    YEAR(OrderDate) AS Year,
    MONTH(OrderDate) AS MonthNo,
    MONTHNAME(OrderDate) AS MonthFullName,
    CONCAT('Q', QUARTER(OrderDate)) AS Quarter,
    DATE_FORMAT(OrderDate, '%Y-%b') AS YearMonth,
    WEEKDAY(OrderDate) + 1 AS WeekdayNo,
    DAYNAME(OrderDate) AS WeekdayName,
    CASE
        WHEN MONTH(OrderDate) >= 4 THEN MONTH(OrderDate) - 3
        ELSE MONTH(OrderDate) + 9
    END AS FinancialMonth,
    CASE
        WHEN MONTH(OrderDate) BETWEEN 4 AND 6 THEN 'Q1'
        WHEN MONTH(OrderDate) BETWEEN 7 AND 9 THEN 'Q2'
        WHEN MONTH(OrderDate) BETWEEN 10 AND 12 THEN 'Q3'
        ELSE 'Q4'
    END AS FinancialQuarter
FROM fact_sales;

select * from Q3 limit 100;



#Q4 SALES_AMOUNT
CREATE TABLE Q4 AS
SELECT (UnitPrice * OrderQuantity * (1 - UnitPriceDiscountPct)) AS Sales_Amount
FROM fact_sales;

select * from Q4;
select * from fact_sales limit 10;




#Q5 PRODUCTION COST
ALTER TABLE fact_sales
ADD COLUMN ProductionCost DECIMAL(12,2);

UPDATE fact_sales
SET ProductionCost =
    ProductStandardCost * OrderQuantity;
    
CREATE TABLE Q5 AS
SELECT (ProductStandardCost * OrderQuantity) AS Production_Cost
FROM fact_sales;


select * from Q5 limit 100;




#Q6 PROFIT

ALTER TABLE fact_sales
ADD COLUMN Profit DECIMAL(12,2);

UPDATE fact_sales
SET Profit = SalesAmount - ProductionCost;

select * from fact_sales limit 100;

CREATE TABLE Q6 AS
SELECT (SalesAmount - ProductionCost) AS Profit
FROM fact_sales;




#Q7 MONTH-WISE SALES WITH YEAR FILTER
#IF YOU SET NULL THEN IT WILL SHOW RESULT FOR ALL YEAR ,
#IF YOU NEED DATA FOR ANY PARTICULAR YEAR THEN PASS YEAR IN ' '. SAME FOR MULTIPLE YEAR JUST ADD , IN BETWEEN 
SET @input_years = NULL;
CREATE TABLE Q7 AS
SELECT
    MonthNo,
    MonthFullName,
    ROUND(SUM(SalesAmount) / 1000000, 2) AS TotalSales_Million
FROM fact_sales
WHERE
    (@input_years IS NULL
     OR FIND_IN_SET(Year, @input_years) > 0)
GROUP BY MonthNo, MonthFullName
ORDER BY MonthNo;

SELECT * FROM Q7;

DROP TABLE Q7;





#Q8 YEAR-WISE SALES
CREATE TABLE Q8 AS
SELECT
    Year,
    ROUND(SUM(SalesAmount) / 1000000, 2) AS TotalSales_Million
FROM fact_sales
GROUP BY Year
ORDER BY Year;

SELECT * FROM Q8;





#9  MONTH-WISE SALES
CREATE TABLE Q9 AS
SELECT
    MonthNo,
    MonthFullName,
    ROUND(SUM(SalesAmount) / 1000000, 2) AS TotalSales_Million
FROM fact_sales
GROUP BY MonthNo, MonthFullName
ORDER BY MonthNo;

SELECT * FROM Q9;



#Q10 QUARTER-WISE SALES

CREATE TABLE Q10 AS
SELECT
    Quarter,
    ROUND(SUM(SalesAmount) / 1000000, 2) AS TotalSales_Million
FROM fact_sales
GROUP BY Quarter
ORDER BY Quarter;

SELECT * FROM Q10;



#Q11 YEAR-WISE SALES Vs PRODUCTION COST

CREATE TABLE Q11 AS
SELECT
    Year,
    ROUND(SUM(SalesAmount) / 1000000, 2) AS TotalSales_Million,
    ROUND(SUM(TotalProductCost) / 1000000, 2) AS TotalProductCost_Million
FROM fact_sales
GROUP BY Year
ORDER BY Year;

SELECT * FROM Q11;



#Q12_1 TOP 5 CUSTOMERS By SALES 
CREATE TABLE Top5_customers AS
SELECT
    CustomerFullName,
    SUM(SalesAmount) AS TotalSales
FROM fact_sales
GROUP BY CustomerFullName
ORDER BY TotalSales DESC
LIMIT 5;

SELECT * FROM Top5_customers;



#Q12_2 TOP 5 PRODUCT By SALES 

CREATE TABLE Top5_Product AS
SELECT
    ProductName,
    ROUND(SUM(SalesAmount) / 1000000, 2) AS TotalSales_Million
FROM fact_sales
GROUP BY ProductName
ORDER BY TotalSales_Million DESC
LIMIT 5;

SELECT * FROM Top5_Product;




#Q12_3 ANNUAL PROFIT 
CREATE TABLE Annual_Profit_Calculation AS
SELECT
    CAST(Year AS CHAR) AS Year,
    ROUND(SUM(Profit) / 1000000, 2) AS TotalProfit_Million
FROM fact_sales
GROUP BY Year 
UNION ALL
SELECT
    'Grand Total' AS Year,
    ROUND(SUM(Profit) / 1000000, 2) AS TotalProfit_Million
FROM fact_sales
ORDER BY YEAR;

select * from Annual_Profit_Calculation;


#KPI

#TOTAL SALES

CREATE TABLE kpi_total_sales AS
SELECT ROUND(SUM(SalesAmount) / 1000000, 2) AS TotalSales_Million
FROM fact_sales;

SELECT * FROM kpi_total_sales;

#TOTAL ORDERS

CREATE TABLE kpi_total_orders AS
SELECT
    COUNT(SalesOrderNumber) AS TotalOrders
FROM fact_sales;

SELECT * FROM kpi_total_orders;

select count(*) from factsales_db;

#TOTAL PROFIT

CREATE TABLE kpi_total_profit AS
SELECT ROUND(SUM(Profit) / 1000000, 2) AS TotalProfit_Million
FROM fact_sales;

SELECT * FROM kpi_total_profit;

#PROFIT RATIO

CREATE TABLE kpi_profit_ratio AS
SELECT ROUND((SUM(Profit) / SUM(SalesAmount)) * 100, 2) AS ProfitRatio_Percent
FROM fact_sales;

SELECT * FROM kpi_profit_ratio;

#AVERAGE ORDER VALUE

CREATE TABLE kpi_average_order_value AS
SELECT
    ROUND(SUM(SalesAmount) / COUNT(DISTINCT SalesOrderNumber),2) AS AverageOrderValue
FROM fact_sales;

SELECT * FROM kpi_average_order_value;


# TOP PERFROMING YEAR

CREATE TABLE TOP_PERFROMING_YEAR AS
SELECT
    Year as Top_Perfroming_Year,
    ROUND(SUM(SalesAmount) / 1000000, 2) AS TotalSales_Million
FROM fact_sales
GROUP BY Year
ORDER BY TotalSales_Million DESC LIMIT 1; 

SELECT * FROM TOP_PERFROMING_YEAR;




































  
  
  










