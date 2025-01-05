-- Walmart Project Queries

-- Exploratory Data Analysis (EDA)
-- General overview of the dataset to identify its structure and key statistics

-- View all data
SELECT * FROM walmart;

-- Count the total number of rows in the dataset
SELECT COUNT(*) AS total_rows FROM walmart;

-- Count the number of distinct branches
SELECT COUNT(DISTINCT branch) AS distinct_branches FROM walmart;

-- Count the number of distinct categories
SELECT COUNT(DISTINCT category) AS distinct_categories FROM walmart;

-- Find the minimum and maximum quantity sold
SELECT 
    MIN(quantity) AS min_quantity, 
    MAX(quantity) AS max_quantity
FROM walmart;

-- Identify distinct payment methods
SELECT DISTINCT payment_method FROM walmart;

-- Check for null values in key columns
SELECT 
    COUNT(*) AS total_rows, 
    COUNT(quantity) AS non_null_quantity, 
    COUNT(unit_price) AS non_null_unit_price
FROM walmart;

-- View summary statistics for numeric columns (quantity, unit_price, rating)
SELECT 
    AVG(quantity) AS avg_quantity, 
    AVG(unit_price) AS avg_unit_price, 
    AVG(rating) AS avg_rating, 
    MIN(rating) AS min_rating, 
    MAX(rating) AS max_rating
FROM walmart;

-- Main Business Questions

-- Q1: What are the top five best-selling products by quantity?
SELECT 
    category, 
    SUM(quantity) AS total_quantity
FROM walmart
GROUP BY category
ORDER BY total_quantity DESC
LIMIT 5;

-- Q2: What is the busiest day for each branch based on the number of transactions?
SELECT * 
FROM (
    SELECT 
        branch,
        TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
    FROM walmart
    GROUP BY branch, day_name
)
WHERE rank = 1;

-- Q3: What is the most active time period for each branch?
SELECT
    branch,
    CASE 
        WHEN EXTRACT(HOUR FROM time::time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM time::time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_period,
    COUNT(*) AS transaction_count
FROM walmart
GROUP BY branch, time_period
ORDER BY branch, transaction_count DESC;

-- Q4: What is the most common payment method for each branch?
WITH payment_stats AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT branch, payment_method, total_transactions
FROM payment_stats
WHERE rank = 1;

-- Q5: What are the total profits for each category, ordered from highest to lowest?
SELECT 
    category,
    SUM(total * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;