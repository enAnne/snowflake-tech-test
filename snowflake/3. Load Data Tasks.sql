// Setup scheduled tasks for loading in sequence, to kick off at 9am daily:
// 1. Customers
// 2. Products
// 3. Transactions

USE manage_db.procedures;

// --------------------------------------------------------------------------------

CREATE OR REPLACE TASK customer_refresh_task
    WAREHOUSE = compute_wh
    SCHEDULE = '1 MINUTE'  --'USING CRON 0 9 * * * UTC'
    AS CALL customer_refresh_proc();
    
CREATE OR REPLACE TASK product_refresh_task
    WAREHOUSE = compute_wh
    AFTER customer_refresh_task
    AS CALL product_refresh_proc();
    
CREATE OR REPLACE TASK transaction_insert_task
    WAREHOUSE = compute_wh
    AFTER product_refresh_task
    AS CALL transaction_insert_proc();    
    
// --------------------------------------------------------------------------------
// Transactions are usually digitally generated, thus they will NOT get deleted or modified, but only inserted
// Use Stream object to insert new records
CREATE OR REPLACE STREAM transaction_stream ON TABLE staging_db.dbo.transaction_json APPEND_ONLY = TRUE;
SHOW STREAMS;

// Update Production table after Staging table is refreshed
CREATE OR REPLACE TASK transaction_ETL_task
    WAREHOUSE = COMPUTE_WH
    AFTER transaction_insert_task
    WHEN SYSTEM$STREAM_HAS_DATA('transaction_stream')
    AS 
INSERT INTO staging_db.dbo.transaction
    SELECT  PARSE_JSON(json_str):customer_id::STRING, 
            PARSE_JSON(json_str):date_of_purchase::DATE,
            p.value:product_id::STRING,
            p.value:price::INT
    FROM transaction_stream
         ,LATERAL FLATTEN (transaction_stream.json_str:basket, OUTER => TRUE) p;
         
// --------------------------------------------------------------------------------
// Start tasks
SHOW TASKS;

ALTER TASK transaction_ETL_task RESUME;
ALTER TASK transaction_insert_task RESUME;
ALTER TASK product_refresh_task RESUME;
ALTER TASK customer_refresh_task RESUME;

SELECT * FROM TABLE(information_schema.task_history())
  ORDER BY scheduled_time desc;





