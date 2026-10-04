/*  product report 
purpose: This report consolidates key product metrics and behviors
Highlights:
1. gathers essential fields such as prodcut name, category, subcategory, and cost 
2. Segements product by revenue to indentify high-performers, Mid-range, or low-performance
3. Aggregates product level metrics:
-total orders
-total Sales
-total qunatity sold
-total total customers (unique)
-lifespan (in months)
4. clculates valuable KPIs:
-receny (months since last order)
-average order value
-average monthly spend 
*/

/* ----------------------------------------------------------------------------------------------------------------------------------------
1.base query
____________________________________________________________________________________________________________________________________________*/
CREATE VIEW report_products AS
WITH base_query AS(

SELECT 
p.product_name,
p.category,
p.subcategory,
p.cost,
f.customer_key,
f.sales_amount,
f.order_date,
f.order_number,
f.quantity
FROM dim_products AS p
LEFT JOIN fact_sales AS f
ON p.product_key = f.product_key
WHERE CAST(f.order_date AS CHAR) <> '0000-00-00'
)
,product_aggergation AS (
SELECT 
	product_name,
	category,
	subcategory,
	-- Total cunstoemrs unique
	COUNT(DISTINCT customer_key) As total_customers,
	-- lift Span in month
    MAX(order_date) as last_order,
	TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan_months,
	-- total orders
	Count(order_number) as total_orders,
	-- total quantity sold
	SUM(quantity) as total_quantity_sold,
	-- total sales
	SUM(sales_amount) as total_sales
FROM base_query
GROUP BY 
product_name, 
category, 
subcategory) 

SELECT 
	product_name,
	category,
	subcategory,
	total_customers,
    total_orders,
	total_sales,
	last_order,
	lifespan_months,
CASE
    WHEN total_sales > 50000 THEN 'High-Performer'
    WHEN total_sales >= 10000 THEN 'Mid-Range'
    ELSE 'Low-Performer'
END AS product_segment,
-- Compute receny 
TIMESTAMPDIFF(MONTH, last_order, CURDATE()) AS recency_months,

-- Avergae order revenue 
CASE WHEN total_orders= 0 THEN 0
        ELSE
	total_sales/ total_orders END  AS avg_order_value,
   
    -- Average monthly revnue 
   CASE WHEN total_sales = 0 THEN total_sales
        ELSE
	
	ROUND(total_sales / lifespan_months, 2) END AS avg_monthly_revenue

FROM product_aggergation

