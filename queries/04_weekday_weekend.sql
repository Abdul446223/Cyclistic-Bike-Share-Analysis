SELECT 
  member_casual,
  ROUND(COUNTIF(day_of_week IN (2,3,4,5,6)) * 100.0 / COUNT(*), 1) AS weekday_pct,
  ROUND(COUNTIF(day_of_week IN (1,7)) * 100.0 / COUNT(*), 1) AS weekend_pct
FROM `casestudy1-500707.Cyclistic.Cleaned_master_table`
GROUP BY member_casual;
