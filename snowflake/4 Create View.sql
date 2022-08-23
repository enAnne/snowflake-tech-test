// Final output

// --------------------------------------------------------------------------------
// Create view
CREATE OR REPLACE VIEW staging_db.dbo.vw_customer_summary AS
SELECT a.customer_id, loyalty_score, b.product_id, product_category, count(*) purchase_count
FROM staging_db.dbo.customer a
left join staging_db.dbo.transaction b on a.customer_id = b.customer_id
left join staging_db.dbo.product c on b.product_id = c.product_id
group by a.customer_id, loyalty_score, b.product_id, product_category; 

SELECT * FROM staging_db.dbo.vw_customer_summary order by customer_id ;

// --------------------------------------------------------------------------------
// Check tables
SELECT * FROM staging_db.dbo.customer;
SELECT * FROM staging_db.dbo.product;
SELECT * FROM staging_db.dbo.transaction_json;
SELECT * FROM staging_db.dbo.transaction;