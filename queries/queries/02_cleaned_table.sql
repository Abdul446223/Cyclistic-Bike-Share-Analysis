CREATE OR REPLACE TABLE casestudy1-500707.Cyclistic.Cleaned_master_table AS
SELECT   
     ride_id,
    rideable_type,
    started_at,
    ended_at,
    TIMESTAMP_DIFF(ended_at, started_at,minute) AS ride_length,
    EXTRACT(DAYOFWEEK FROM started_at) AS day_of_week,
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    member_casual
FROM
    casestudy1-500707.Cyclistic.master_table
WHERE
    TIMESTAMP_DIFF(ended_at, started_at,minute) > 0
    AND 
    TIMESTAMP_DIFF(ended_at, started_at,minute) < 1440
    AND
    started_at < ended_at
QUALIFY
    ROW_NUMBER() OVER(PARTITION BY ride_id ORDER BY started_at )=1
