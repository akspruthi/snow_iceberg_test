CREATE OR REPLACE EXTERNAL VOLUME my_iceberg_azure_vol
    STORAGE_LOCATIONS = ((
        NAME = 'primary-azure'
        STORAGE_PROVIDER = 'AZURE'
        STORAGE_BASE_URL = 'azure://saicebergtest.blob.core.windows.net/iceberg/icebergfolder/'
        AZURE_TENANT_ID = 'a386a6b1-bf62-4c19-a2b4-21e3801a2887'
    ))
    ALLOW_WRITES = TRUE;


DESC EXTERNAL VOLUME my_iceberg_azure_vol;
-- Copy AZURE_CONSENT_URL → open in browser → click Accept
-- Then in Azure Portal: Storage Account → Access Control (IAM)
--   → Add role: "Storage Blob Data Contributor"
--   → Assign to the service principal (name before underscore in AZURE_MULTI_TENANT_APP_NAME)



CREATE OR REPLACE ICEBERG TABLE RESTAURANT_STREAM_DEMO.PUBLIC.sample_iceberg_table (
    id INT,
    name STRING,
    amount DECIMAL(10,2),
    created_at TIMESTAMP_NTZ
)
    CATALOG = 'SNOWFLAKE'
    EXTERNAL_VOLUME = 'my_iceberg_azure_vol'
    BASE_LOCATION = 'sample_iceberg_table/';


INSERT INTO RESTAURANT_STREAM_DEMO.PUBLIC.sample_iceberg_table (id, name, amount, created_at)
VALUES
    (1, 'Alice Johnson', 250.00, '2026-10-01 09:30:00'),
    (2, 'Bob Smith', 175.50, '2026-10-02 14:15:00'),
    (3, 'Carol White', 320.75, '2026-10-03 11:45:00'),
    (4, 'David Brown', 89.99, '2026-10-05 16:00:00'),
    (5, 'Eve Davis', 412.30, '2026-10-08 08:20:00');


CREATE OR REPLACE USER databricks_iceberg_user
    PASSWORD = 'Dbx_Iceberg_2026!'
    TYPE = LEGACY_SERVICE
    DEFAULT_ROLE = PUBLIC
    MUST_CHANGE_PASSWORD = FALSE
    COMMENT = 'Legacy service user for Databricks foreign catalog federation';

CREATE ROLE IF NOT EXISTS databricks_iceberg_role;

GRANT ROLE databricks_iceberg_role TO USER databricks_iceberg_user;
ALTER USER databricks_iceberg_user SET DEFAULT_ROLE = databricks_iceberg_role;

GRANT USAGE ON DATABASE RESTAURANT_STREAM_DEMO TO ROLE databricks_iceberg_role;
GRANT USAGE ON SCHEMA RESTAURANT_STREAM_DEMO.PUBLIC TO ROLE databricks_iceberg_role;
GRANT SELECT ON TABLE RESTAURANT_STREAM_DEMO.PUBLIC.sample_iceberg_table TO ROLE databricks_iceberg_role;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE databricks_iceberg_role;