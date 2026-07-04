SELECT  
  member_casual,
  EXTRACT(MONTH FROM started_at) AS month,
  COUNT(*) AS total_rides
FROM 
  `casestudy1-500707.Cyclistic.Cleaned_master_table` 
GROUP BY
  member_casual,
  month
ORDER BY
  member_casual,
  month;
