SELECT
  member_casual,
  rideable_type,
  ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (PARTITION BY member_casual), 1) AS Percentage
FROM 
  `casestudy1-500707.Cyclistic.master_table`
GROUP BY 
  member_casual, 
  rideable_type
