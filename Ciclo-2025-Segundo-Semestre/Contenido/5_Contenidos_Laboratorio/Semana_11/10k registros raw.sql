CREATE OR REPLACE TABLE `my_dataset.10kregistros`
PARTITION BY RANGE_BUCKET(data_file_month, GENERATE_ARRAY(1,12))
CLUSTER BY pickup_location_id, dropoff_location_id AS
SELECT *
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2020`
LIMIT 10000;
