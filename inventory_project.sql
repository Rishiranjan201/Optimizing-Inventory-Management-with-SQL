create database if not exists Inventoryforecasting;


CREATE TABLE inventoryData (
    table_date date ,
    Store_ID VARCHAR(255),
    Product_ID VARCHAR(255),
    Category CHAR(255),
    Region CHAR(255),
    Inventory_Level INT,
    Units_Sold INT,
    Units_Ordered INT,
    Demand_Forecast FLOAT,
    Price FLOAT,
    Discount INT,
    Weather_Condition CHAR(255),
    Holiday_Promotion INT,
    Competitor_Pricing FLOAT,
    Seasonality CHAR(255)
);
    
SELECT 
    *
FROM
    inventorydata;

 
 -- Total stock per product by store and region
SELECT 
    Store_ID,
    Region,
    Product_ID,
    SUM(Inventory_Level) AS Total_Stock
FROM
    inventoryData
GROUP BY Store_ID , Region , Product_ID
ORDER BY 
    Total_Stock DESC;

-- Assuming a Reorder Point = 50 units — change as needed
select Inventory_Level from inventorydata where Inventory_Level<50;
-- Low Inventory Detection based on Reorder Point
SELECT 
    Store_ID,
    Product_ID,
    Inventory_Level
FROM 
    inventoryData
WHERE 
    Inventory_Level < 50
ORDER BY 
    Inventory_Level;
    
    -- Reorder Point Estimation using Historical Trend
    SELECT 
    Product_ID,
    AVG(Units_Sold) AS Avg_Sold,
    STDDEV(Units_Sold) AS Std_Dev_Sold,
    (AVG(Units_Sold) + STDDEV(Units_Sold)) AS Estimated_Reorder_Point
FROM 
    inventoryData
GROUP BY 
    Product_ID;

-- Inventory Turnover Ratio = Units Sold / Average Inventory Level

 SELECT 
    Product_ID,
    SUM(Units_Sold) AS Total_Sold,
    AVG(Inventory_Level) AS Avg_Inventory,
    (SUM(Units_Sold) / NULLIF(AVG(Inventory_Level), 0)) AS Inventory_Turnover_Ratio
FROM 
    inventoryData
GROUP BY 
    Product_ID
ORDER BY 
    Inventory_Turnover_Ratio DESC;
    
    -- Summary Reports with KPIs
    -- A. Stockout Rate (where Inventory_Level = 0)
    
 SELECT 
    COUNT(*) AS Total_Records,
    SUM(CASE WHEN Inventory_Level = 0 THEN 1 ELSE 0 END) AS Stockouts,
    ROUND(100.0 * SUM(CASE WHEN Inventory_Level = 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS Stockout_Rate_Percent
FROM 
    inventoryData;
    
    -- B. Average Inventory Level
    
   SELECT 
    AVG(Inventory_Level) AS Avg_Inventory_Level
FROM 
    inventoryData;

-- C. Average Inventory Age (proxy = Inventory_Level / Daily Units Sold)
SELECT 
    Product_ID,
    ROUND(AVG(CASE WHEN Units_Sold > 0 THEN Inventory_Level / Units_Sold ELSE NULL END), 2) AS Avg_Inventory_Age
FROM 
    inventoryData
GROUP BY 
    Product_ID;
    
    -- Creating Indexes
    CREATE INDEX idx_product_date ON inventoryData(Product_ID, table_date);
CREATE INDEX idx_store_product ON inventoryData(Store_ID, Product_ID);

-- Moving Average of Sales
SELECT 
    Product_ID,
    table_date,
    Units_Sold,
    AVG(Units_Sold) OVER (PARTITION BY Product_ID ORDER BY table_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS Moving_Avg_7days
FROM inventoryData;

 -- Analytical Outputs
-- A. Fast-Selling vs Slow-Moving Products

SELECT Product_ID,
       SUM(Units_Sold) AS Total_Sales
FROM inventoryData
GROUP BY Product_ID
ORDER BY Total_Sales DESC;

-- B. Recommend Stock Adjustments

SELECT Product_ID,
       AVG(Inventory_Level) - AVG(Units_Sold) AS Surplus_Stock
FROM inventoryData
GROUP BY Product_ID
HAVING Surplus_Stock > 50;

-- C. Supplier Performance (Needs external table Supplier_Delivery)
CREATE TABLE supplierData (
    Product_ID VARCHAR(255),
    Supplier_ID VARCHAR(255),
    Delivery_Time INT,
    Quality_Score FLOAT
);
SELECT Supplier_ID,
       AVG(Delivery_Time) AS Avg_Delay,
       COUNT(CASE WHEN Delivery_Time > 2 THEN 1 END) AS Late_Deliveries
FROM SupplierData
GROUP BY Supplier_ID;

-- D. Forecast Demand Trends

SELECT Product_ID, Seasonality, 
       AVG(Demand_Forecast) AS Avg_Seasonal_Demand
FROM inventoryData
GROUP BY Product_ID, Seasonality
ORDER BY Product_ID;

--  Stockout Detection

SELECT 
    Product_ID,
    COUNT(*) AS Days_Tracked,
    SUM(CASE WHEN Inventory_Level = 0 THEN 1 ELSE 0 END) AS Stockout_Days,
    ROUND(SUM(CASE WHEN Inventory_Level = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Stockout_Percentage
FROM inventoryData
GROUP BY Product_ID;

-- Competitor Price Advantage Analysis
-- Helps evaluate if pricing is competitive
SELECT 
    Product_ID,
    ROUND(AVG(Price - Competitor_Pricing), 2) AS Avg_Price_Difference,
    CASE 
        WHEN AVG(Price) > AVG(Competitor_Pricing) THEN 'Expensive'
        ELSE 'Cheaper'
    END AS Market_Position
FROM inventoryData
GROUP BY Product_ID;




    
    
    
    
    
    
    
    
    
    
    
