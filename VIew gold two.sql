CREATE OR ALTER VIEW gold.dim_products AS
SELECT 
	ROW_NUMBER() OVER ( ORDER BY pn.prd_start_dt,pn.prd_key) AS Product_Key,
	pn.prd_id AS Product_ID,
	pn.prd_key AS Producr_Number,
	pn.prd_nm AS Product_Name,
	pn.cat_id AS Category_ID,
	pc.cat AS Category,
	pc.subcat AS SubCategory,
	pc.maintenance,
	pn.prd_cost AS Cost,
	pn.prd_line AS Product_Line,
	pn.prd_start_dt AS Start_Date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL