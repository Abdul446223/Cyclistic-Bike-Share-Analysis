-- Check for duplicate ride_ids
SELECT
  ride_id
FROM 
  `casestudy1-500707.Cyclistic.master_table`
GROUP BY
  ride_id
HAVING
  COUNT(ride_id) > 1;

-- Count null start station names and IDs
SELECT
  COUNT(*)
FROM 
  `casestudy1-500707.Cyclistic.master_table`
WHERE
  start_station_id IS NULL
  AND
  start_station_name IS NULL;

-- Count null end station names and IDs
SELECT
  COUNT(*)
FROM 
  `casestudy1-500707.Cyclistic.master_table`
WHERE
  end_station_id IS NULL
  AND
  end_station_name IS NULL;

-- Count negative trip duration 
SELECT
  COUNT(*)
FROM 
  `casestudy1-500707.Cyclistic.master_table`
WHERE
  started_at > ended_at;

-- Count null start lat and lng
SELECT
  COUNT(*)
FROM 
  `casestudy1-500707.Cyclistic.master_table`
WHERE
  start_lat IS NULL
  OR
  start_lng IS NULL;

-- Count null end lat and lng
SELECT
  COUNT(*)
FROM 
  `casestudy1-500707.Cyclistic.master_table`
WHERE
  end_lat IS NULL
  OR
  end_lng IS NULL;
