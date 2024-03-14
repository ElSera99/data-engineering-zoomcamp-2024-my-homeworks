# Introduction
As part of the Data Engineering Zoomcamp from DataTalks, in this section for Analytics Engineering using dbt solve for the following homework questionnaire:
https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/cohorts/2024/04-analytics-engineering/homework.md

# Setup

In this homework, we'll use the models developed during the week 4 videos and enhance the already presented dbt project using the already loaded Taxi data for fhv vehicles for year 2019 in our DWH.

This means that in this homework we use the following data [Datasets list](https://github.com/DataTalksClub/nyc-tlc-data/)

- Yellow taxi data - Years 2019 and 2020
- Green taxi data - Years 2019 and 2020
- fhv data - Year 2019.

We will use the data loaded for:

- Building a source table: `stg_fhv_tripdata`
- Building a fact table: `fact_fhv_trips`
- Create a dashboard

If you don't have access to GCP, you can do this locally using the ingested data from your Postgres database instead. If you have access to GCP, you don't need to do it for local Postgres - only if you want to.

> Note: if your answer doesn't match exactly, select the closest option
> 

# Setup Solution

In order to ingest **fhv** data to **BigQuery**, **Parquet files from** https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page ****where downloaded and directly uploaded into a bucket in **Cloud Storage**:

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/fb4c62dd-8761-4eee-86c2-b71024ca4cf4/37efa4cd-ec5a-4070-a541-7dc07c09a40d/Untitled.png)

In order to transform from cloud storage to **BigQuery**, first, create an **external table** as previously done in the past weeks, can create as follows:

```sql
-- Create external table referrig to gcs path
CREATE OR REPLACE EXTERNAL TABLE `lyrical-compass-412311.stb_de_zoomcamp.fhv_2019`
-- (
--   dispatching_base_num STRING,
--   pickup_datetime TIMESTAMP,
--   dropOff_datetime TIMESTAMP,
--   PUlocationID INT64,
--   DOlocationID INT64,
--   SR_Flag INT64,
--   Affiliated_base_number STRING
-- ) 
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://stb-de-zoomcamp/fhv_from_source/fhv_tripdata_2019-01.parquet', 'gs://stb-de-zoomcamp/fhv_from_source/fhv_tripdata_2019-02.parquet']
);

```

After the creation of the table, this **external table** is now available in the dataset:

 

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/fb4c62dd-8761-4eee-86c2-b71024ca4cf4/d91b15bb-03bf-455d-a7fc-31b9ea933ff4/Untitled.png)

In order to increase efficiency and make data persistent in the dataset, is necessary to create a table **from the external table already created**, this can be done as previously via a query:

```sql
-- Materialize table
CREATE OR REPLACE TABLE `lyrical-compass-412311.stb_de_zoomcamp.fhv`  
AS 
SELECT 
*
FROM `lyrical-compass-412311.stb_de_zoomcamp.fhv_2019`;
```

Now, tables are available for usage in BigQuery:

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/fb4c62dd-8761-4eee-86c2-b71024ca4cf4/59acdae4-6993-4d6a-b6e5-dae87fba5a68/Untitled.png)

Now, add this table as source in the **schema.yml** for staging:

```sql
sources:
  - name: staging
    database: lyrical-compass-412311
    schema: stb_de_zoomcamp

    tables:
      - name: fhv
      - name: green_tripdata
      - name: yellow_tripdata
```

Create the staging table as follows:

```sql
{{ config(materialized='view') }}
 
-- with source as (
--     select * from {{ source('staging', 'fhv') }}
-- )
select
    {{ dbt.safe_cast("dispatching_base_num", api.Column.translate_type("string")) }} as dispatching_base_num,
    {{ dbt.safe_cast("pulocationid", api.Column.translate_type("integer")) }} as pickup_locationid,
    {{ dbt.safe_cast("dolocationid", api.Column.translate_type("integer")) }} as dropoff_locationid,
    cast(pickup_datetime as timestamp) as pickup_datetime,
    cast(dropoff_datetime as timestamp) as dropoff_datetime,
    {{ dbt.safe_cast("sr_flag", api.Column.translate_type("integer")) }} as sr_flag,

from {{ source('staging', 'fhv') }}

-- dbt build --select <model.sql> --vars '{'is_test_run: false}'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}
```

Now, create fact table as follows:

```
{{ config(materialized='view') }}
 
-- with source as (
--     select * from {{ source('staging', 'fhv') }}
-- )
select
    {{ dbt.safe_cast("dispatching_base_num", api.Column.translate_type("string")) }} as dispatching_base_num,
    {{ dbt.safe_cast("pulocationid", api.Column.translate_type("integer")) }} as pickup_locationid,
    {{ dbt.safe_cast("dolocationid", api.Column.translate_type("integer")) }} as dropoff_locationid,
    cast(pickup_datetime as timestamp) as pickup_datetime,
    cast(dropoff_datetime as timestamp) as dropoff_datetime,
    {{ dbt.safe_cast("sr_flag", api.Column.translate_type("integer")) }} as sr_flag,

from {{ source('staging', 'fhv') }}

-- dbt build --select <model.sql> --vars '{'is_test_run: false}'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}
```

The execution of **dbt** can be visualized in the following repo:

https://github.com/ElSera99/dbt_test

# Questions

## Question 1

**What happens when we execute dbt build --vars '{'is_test_run':'true'}'** You'll need to have completed the ["Build the first dbt models"](https://www.youtube.com/watch?v=UVI30Vxzd6c) video.

- It's the same as running *dbt build*
- It applies a *limit 100* to all of our models
- **`It applies a *limit 100* only to our staging models`**
- Nothing

## Question 2

**What is the code that our CI job will run? Where is this code coming from?**

- The code that has been merged into the main branch
- The code that is behind the creation object on the dbt_cloud_pr_ schema
- The code from any development branch that has been opened based on main
- **`The code from the development branch we are requesting to merge to main`**

## Question 3

**What is the count of records in the model fact_fhv_trips after running all dependencies with the test run variable disabled (:false)?**

Create a staging model for the fhv data, similar to the ones made for yellow and green data. Add an additional filter for keeping only records with pickup time in year 2019. Do not add a deduplication step. Run this models without limits (is_test_run: false).

Create a core model similar to fact trips, but selecting from stg_fhv_tripdata and joining with dim_zones. Similar to what we've done in fact_trips, keep only records with known pickup and dropoff locations entries for pickup and dropoff locations. Run the dbt model without limits (is_test_run: false).

- 12998722
- 22998722
- `**32998722**`
- 42998722

## Question 4

**What is the service that had the most rides during the month of July 2019 month with the biggest amount of rides after building a tile for the fact_fhv_trips table and the fact_trips tile as seen in the videos?**

Create a dashboard with some tiles that you find interesting to explore the data. One tile should show the amount of trips per month, as done in the videos for fact_trips, including the fact_fhv_trips data.

- FHV
- Green
- Yellow
- **`FHV and Green`**