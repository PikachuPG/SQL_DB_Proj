
SELECT 
country,
COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

SELECT 
Gender,
COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY Gender
ORDER BY total_customers DESC;


SELECT 
Category,
COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

SELECT 
Category,
AVG(cost) AS avg_costs
FROM gold.dim_products
GROUP BY category
ORDER BY avg_costs DESC;

SELECT 
SUM(f.sales_amount) AS total_revenue,
p.category
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC

SELECT 
SUM(f.sales_amount) AS total_revenue,
c.customer_key,
c.first_name,
c.last_name
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_revenue DESC

SELECT 
SUM(f.quantity) AS total_sales,
c.country
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_sales DESC

SELECT  TOP 5
p.product_name,
SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC

SELECT  TOP 5
p.product_name,
SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC

SELECT *
	FROM(
		SELECT 
		p.product_name,
		SUM(f.sales_amount) AS total_revenue,
		ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank
		FROM gold.fact_sales f
		LEFT JOIN gold.dim_products p
		ON p.product_key = f.product_key
		GROUP BY p.product_name
		)t
	WHERE rank <= 5


SELECT 
YEAR(order_date) AS order_year,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT(customer_key)) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date)

SELECT
YEAR(order_date) AS order_year,
DATENAME(month,order_date) AS order_year,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT(customer_key)) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date),DATENAME(month,order_date)
ORDER BY YEAR(order_date),SUM(quantity) DESC



SELECT
order_month,
total_sales,
SUM(total_sales) OVER (ORDER BY order_month ASC) AS running_total
FROM
	(
	SELECT
	DATETRUNC(month,order_date) AS order_month,
	SUM(sales_amount) AS total_sales
	FROM gold.fact_sales 
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(month,order_date)
	) t



SELECT
order_month,
total_sales,
SUM(total_sales) OVER ( PARTITION BY YEAR(order_month) ORDER BY order_month ASC) AS running_total
FROM
	(
	SELECT
	DATETRUNC(month,order_date) AS order_month,
	SUM(sales_amount) AS total_sales
	FROM gold.fact_sales 
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(month,order_date)
	) t


SELECT
order_year,
total_sales,
SUM(total_sales) OVER ( ORDER BY order_year ASC) AS running_total,
avg_price,
AVG(avg_price) OVER (ORDER BY order_year) AS moving_avg_price
FROM
	(
	SELECT
	DATETRUNC(YEAR,order_date) AS order_year,
	SUM(sales_amount) AS total_sales,
	AVG(price) AS avg_price
	FROM gold.fact_sales 
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(YEAR,order_date)
	) t

;
WITH yearly_product_sales AS
(
	SELECT 
	YEAR(f.order_date) AS order_year,
	p.product_name,
	SUM(f.sales_amount) AS current_sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	WHERE f.order_date IS NOT NULL 
	GROUP BY YEAR(f.order_date), p.product_name
)
SELECT 
order_year,
product_name,
current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS lag_sales
FROM yearly_product_sales
ORDER BY product_name, order_year
;

 WITH customer_spending AS (
	SELECT 
	c.customer_key,
	SUM(f.sales_amount) AS total_spending,
	MIN(order_date) AS first_order,
	MAX(order_date) AS last_order,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
	ON f.customer_key = c.customer_key
	GROUP BY c.customer_key
)
SELECT 
Customer_Key,
total_spending,
lifespan,
CASE WHEN total_spending >= 5000 AND lifespan >24 THEN 'VIP'
	 WHEN total_spending >= 5000 AND lifespan BETWEEN 12 AND 24 THEN 'Normal'
	 ELSE 'Bad'
END Customer_Class
FROM customer_spending

