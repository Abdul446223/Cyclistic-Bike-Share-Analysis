SELECT  
  member_casual,
  COUNT(*) AS TotalRides,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage,
  ROUND(AVG(ride_length), 2) AS avg_ride_length
FROM 
  `casestudy1-500707.Cyclistic.Cleaned_master_table`
GROUP BY
  member_casual;
