SELECT  
  member_casual,
  CASE 
  WHEN day_of_week IN (2,3,4,5,6) THEN 'Weekday'
  WHEN day_of_week IN (1,7) THEN 'Weekend'
  END AS day_type,
  EXTRACT(HOUR FROM started_at) AS Hour,
  COUNT(*) AS total_rides
FROM 
  `casestudy1-500707.Cyclistic.Cleaned_master_table` 
GROUP BY
  member_casual,
  day_type,
  Hour
ORDER BY
  member_casual,
  day_type,
  Hour
