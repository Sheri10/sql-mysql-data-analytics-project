/*  customer report 
purpose: This report consolidates key customer metrics and behviors
Highlights:
1. gathers essential fields such as names, ages and transaction details
2. Segements customers in categories (VIP, Regular, New) and age croup
3. Aggregates customer level metrics:
-total orders
-total Sales
-total qunatity purchase
-total products
-lifespan (in months)
4. clculates valuable KPIs:
-receny (months since last order)
-average order value
-average monthly spend 
*/

/* ----------------------------------------------------------------------------------------------------------------------------------------
1.base query
____________________________________________________________________________________________________________________________________________*/ 
CREATE VIEW report_customers AS

WITH base_query AS(
SELECT 
c. customer_key,
c.customer_number,
CONCAT(c.first_name,' ', c.last_name) AS customer_name,
TIMESTAMPDIFF(YEAR, birthdate, CURDATE()) AS age,
f.product_key,
f.order_date,
f.quantity,
f.order_number,
f.sales_amount
FROM dim_customers as C
Left join fact_sales as f 
ON c.customer_key = f.customer_key 
WHERE CAST(f.order_date AS CHAR) <> '0000-00-00'
 AND CAST(c.birthdate AS CHAR) <> '0000-00-00')
, customer_aggregation AS (

/* ----------------------------------------------------------------------------------------------------------------------------------------
Customer Agggeregations: Summarize the key metrices at the cusomer lever
____________________________________________________________________________________________________________________________________________*/ 

SELECT 
customer_key,
customer_number,
customer_name,
age,
COUNT(DISTINCT order_number) AS total_orders,
SUM(sales_amount)AS total_sale,
SUM(quantity)as total_quantity,
COUNT(DISTINCT product_key)  AS total_products,
MAX(order_date) As last_order,
TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan_months
FROM base_query
GROUP BY 
customer_key,
customer_number,
customer_name,
age
)

SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
    CASE 
        WHEN age < 20 THEN 'under 20'
        WHEN age between 20 and 29  THEN '20-29'
		WHEN age between 30 and 39  THEN '30-39'
		WHEN age between 40 and 49  THEN '40-49'
	ELSE '50 and above'
    END AS age_group,
          
    CASE
        WHEN lifespan_months >= 12 AND total_sale > 5000 THEN 'VIP'
        WHEN lifespan_months >= 12 AND total_sale <= 5000 THEN 'Regular'
        ELSE 'New'
   END AS customer_segment,
	TIMESTAMPDIFF(MONTH, last_order, CURDATE()) AS recency_months,
	total_orders,
	total_sale,
	total_quantity,
	total_products,
	last_order,
	lifespan_months,
   -- compuate average order value (AVO)
   CASE WHEN total_orders= 0 THEN 0
        ELSE
   total_sale/ total_orders END  AS avg_order_value,
    --   compuate average monthly spend 
    CASE WHEN total_orders= 0 THEN total_sale
        ELSE 
    total_sale/lifespan_months END  As average_monthly_spend 
    
FROM customer_aggregation