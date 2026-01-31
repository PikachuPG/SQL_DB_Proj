CREATE OR ALTER VIEW gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY cst_id) AS Customer_Key,
	ci.cst_id AS Customer_ID,
	ci.cst_key AS Customer_Number,
	ci.cst_firstname AS First_Name,
	ci.cst_lastname AS Last_Name,
	la.cntry AS Country,
	ci.cst_marital_status AS Marital_Status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
		 ELSE COALESCE(ca.gen,'n/a') 
	END Gender,
	ci.cst_create_date AS Create_Date,
	ca.bdate AS Birthdate
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid


