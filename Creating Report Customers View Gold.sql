CREATE OR ALTER VIEW gold.report_customers AS
WITH cte_info AS(
	SELECT 
	f.order_number,
	f.product_key,
	f.order_date,
	f.sales_amount,
	f.quantity,
	c.Customer_Key, 
	c.Customer_Number,
	CONCAT( c.First_Name, ' ' ,c.Last_Name)AS Cust_Name,
	DATEDIFF(YEAR, c.birthdate, GETDATE()) AS Age
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
	ON c.customer_key = f.customer_key 
	WHERE order_date IS NOT NULL
)
, cust_aggregation AS
(
	SELECT 
		Customer_Key, 
		customer_Number,
		Cust_Name,
		Age,
		COUNT(DISTINCT order_number) AS total_orders,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity,
		COUNT(DISTINCT product_key) AS total_products,
		MAX(Order_date) AS last_order_date,
		DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
	FROM cte_info
	GROUP BY Customer_Key, customer_Number, Cust_Name, Age
)
SELECT 
Customer_Key,
Customer_Number,
Cust_Name,
Age,
CASE WHEN total_sales >= 5000 AND lifespan >24 THEN 'VIP'
	 WHEN total_sales >= 5000 AND lifespan BETWEEN 12 AND 24 THEN 'Normal'
	 ELSE 'Bad'
END Customer_Class,
total_quantity,
total_products,
last_order_date,
lifespan,
CASE WHEN total_orders = 0 THEN 0
	 ELSE total_sales/total_orders
END Avg_order_value,
DATEDIFF(MONTH, last_order_date, GETDATE()) recency,
CASE WHEN lifespan = 0 THEN total_sales
	 ELSE total_sales/ lifespan 
END AS Avg_monthly_spend 
FROM cust_aggregation