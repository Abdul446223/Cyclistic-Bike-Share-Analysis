# Cyclistic Bike-Share Analysis
## Google Data Analytics Capstone Project

---

## Business Task

Analyze ride patterns of annual members and casual riders over the past 12 months to identify key behavioral differences between the two groups, in order to design a targeted marketing strategy to convert casual riders into annual members.

---

## Data Source

- Data was downloaded from the [Divvy Bikes public dataset](https://divvy-tripdata.s3.amazonaws.com/index.html), collected by Motivate International Inc. under an open license.
- The previous 12 months of bike trip data was downloaded as zip files containing CSV files.

### Data Credibility (ROCCC Evaluation)

| Criteria | Assessment |
|---|---|
| **Reliable** | Data is collected directly by the bike-share operator from automated docking systems — first-party data at the source level |
| **Original** | We are accessing data directly from the provider, not through a third-party aggregator |
| **Comprehensive** | Data includes timestamps, station names, coordinates, and rider type — sufficient to analyze behavioral differences between groups. Note: privacy restrictions prevent linking rides to personal identity, so we cannot determine if casual riders live in the service area |
| **Current** | The most recent 12 months of data was used, reflecting current seasonal patterns and user behavior |
| **Cited** | Data is publicly available under the [Divvy Data License Agreement](https://www.divvybikes.com/data-license-agreement) |

---

## Tools Used

- **Google BigQuery** — Data combination, cleaning, and analysis
- **Tableau Public** — Data visualization and dashboard
- **GitHub** — Portfolio and documentation

---

## Data Cleaning & Processing

### Before Cleaning

A master table was first created by combining 12 monthly CSV files using UNION ALL in BigQuery.

- **Total rows:** 5,848,703
- **Issues found:**

| Issue | Count |
|---|---|
| Duplicate ride_ids | 35 |
| Null start station names and IDs | 660,241 |
| Null end station names and IDs | 697,706 |
| Null end coordinates | 5,896 |
| Logically impossible timestamps (started_at > ended_at) | 29 |

### Cleaning Decisions

**Duplicate ride_ids — Removed**
ride_id acts as a primary key in this dataset, representing each unique trip. Duplicate IDs could skew ride counts and produce inaccurate results, so they were removed using ROW_NUMBER() window function.

**Null station names — Retained**
Station patterns could reveal important behavioral differences between casual riders and members. Rather than removing these rows, we acknowledged the limitation and retained the data for volume-level analysis.

**Null coordinates — Retained**
Only 5,896 null coordinate pairs exist (less than 0.1% of data), which would not significantly affect analysis.

**Logically impossible timestamps — Removed**
29 rows where the trip start time was later than the end time represent data entry errors and were removed.

**Extreme duration outliers — Removed**
- Trips with duration less than 0 minutes cannot be considered valid trips.
- Trips with duration greater than 24 hours (1,440 minutes) are almost certainly system errors, unreturned bikes, or stolen bikes rather than genuine trips.

**Data Quality Insight:** Further investigation of the negative duration rows revealed 79,238 members and 82,114 casual riders were affected — a roughly even split. This indicates a systemic hardware or software issue (such as docking sensor errors) rather than a behavioral difference between the two groups. This equal distribution confirms the removal was unbiased.

### New Columns Added

Two calculated columns were added permanently to the cleaned table to avoid repeated calculation in every query:

- **ride_length** — Trip duration in minutes, calculated using TIMESTAMP_DIFF
- **day_of_week** — Day number extracted from started_at (1 = Sunday, 7 = Saturday)

### Cleaning Query

```sql
CREATE OR REPLACE TABLE `casestudy1-500707.Cyclistic.Cleaned_master_table` AS
SELECT   
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS ride_length,
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
    `casestudy1-500707.Cyclistic.master_table`
WHERE
    TIMESTAMP_DIFF(ended_at, started_at, MINUTE) > 0
    AND 
    TIMESTAMP_DIFF(ended_at, started_at, MINUTE) < 1440
    AND
    started_at < ended_at
QUALIFY
    ROW_NUMBER() OVER(PARTITION BY ride_id ORDER BY started_at) = 1;
```

### After Cleaning

- **Rows removed:** 167,223 (167,159 due to duration outliers + 35 duplicates + 29 impossible timestamps)
- **Final cleaned table:** 5,681,480 rows

---

## Analysis & Key Findings

### 1. Ride Volume and Duration

| Group | Total Rides | Avg Ride Duration | % of Total |
|---|---|---|---|
| Casual Riders | 2,013,334 | 19.13 minutes | 35.4% |
| Annual Members | 3,668,146 | 11.81 minutes | 64.6% |

**Finding:** Casual riders take 62% longer trips on average than members. This suggests members use bikes for short, direct commutes while casual riders use bikes for leisure.

---

### 2. Weekday vs Weekend Patterns

| Group | Weekday % | Weekend % |
|---|---|---|
| Annual Members | 76.5% | 23.5% |
| Casual Riders | 62.3% | 37.7% |

**Finding:** Casual riders show a higher weekend riding proportion relative to members (37.7% vs 23.5%), supporting the leisure-use hypothesis. Members are concentrated on weekdays, consistent with commuting behavior.

---

### 3. Seasonal Patterns

| Group | Peak Month (Aug) | Lowest Month | Seasonal Swing |
|---|---|---|---|
| Annual Members | 443,130 rides | 109,371 (Dec) | 4x |
| Casual Riders | 323,533 rides | 23,878 (Jan) | 13.5x |

**Finding:** Casual ridership drops dramatically in winter (13.5x swing) compared to members (4x swing). This confirms casual riders are weather-sensitive leisure users, while members ride more consistently year-round due to commuting needs.

Additional insight: In January, members outnumber casuals by 4.6x. By August, this ratio drops to just 1.37x — summer is essentially casual rider season.

---

### 4. Time of Day Patterns

| Group | Day Type | Peak Hours |
|---|---|---|
| Annual Members | Weekdays | 7–8 AM and 4–6 PM (bimodal commuter peaks) |
| Casual Riders | Weekdays | 12–7 PM (single leisure arc) |
| Annual Members | Weekends | 9 AM – 7 PM (leisure arc) |
| Casual Riders | Weekends | 10 AM – 7 PM (leisure arc) |

**Finding:** Members show a classic bimodal commuter pattern on weekdays. Casual riders show a single afternoon leisure arc on both weekdays and weekends. On weekends, member patterns shift to resemble casual rider patterns — further confirming the commute motivation disappears on weekends.

---

### 5. Bike Type Preferences

| Group | Classic Bike % | Electric Bike % |
|---|---|---|
| Annual Members | 35% | 65% |
| Casual Riders | 33% | 67% |

**Finding:** Both groups show nearly identical bike type preferences. Bike type is not a differentiating factor between members and casual riders.

---

### Overall Conclusion

All four key findings consistently point to the same conclusion: **casual riders are leisure-motivated while annual members are utility/commute-motivated.** This behavioral difference directly informs the marketing strategy needed to convert casual riders into members.

---

## Dashboard

**[View Interactive Dashboard on Tableau Public](https://public.tableau.com/views/CyclisticBike-ShareAnalysis_17830814410230/CyclisticBike-ShareHowMembersandCasualRidersDiffer?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)**

<img width="999" height="799" alt="dashboard_screenshot png" src="https://github.com/user-attachments/assets/fc5c65e2-e53b-4ba6-9eb6-d0a2ad6c76e3" />

---

## Recommendations

Based on the analysis, we recommend the following three strategies to convert casual riders into annual members:

**1. Launch Seasonal Campaigns in Late Spring and Early Summer**

Casual ridership shows a 13.5x increase from winter to summer. The casual rider audience is most active and most reachable when the weather is at its best. Cyclistic should concentrate its marketing budget in the late spring to early fall window to maximize reach and conversion readiness.

**2. Target Casual Riders Through Digital Media During Pre-Ride and Post-Ride Windows**

Based on hourly ridership patterns, casual riders should be targeted:
- **Weekdays:** Pre-ride window 11 AM – 12 PM, Post-ride window 7–8 PM
- **Weekends:** Pre-ride window 9–10 AM, Post-ride window 7–8 PM

Mid-ride hours should be avoided, as riders are actively cycling and digitally unreachable. Pre-ride targeting reaches riders while they are planning their trip, and post-ride targeting reaches them immediately after a positive riding experience — the most receptive moment for a membership message.

**3. Highlight the Financial Value of Annual Membership**

Data shows casual riders average 19.13 minutes per ride and are most active during summer weekends. These frequent leisure riders pay per ride or per day, making membership a clear financial advantage. Based on current Divvy membership pricing, members spend less than a dollar per day and receive unlimited 45-minute classic bike rides, reduced e-bike rates, free unlocks, and additional benefits. Marketing should communicate this value directly to high-frequency casual riders during the summer season.

---

## Project Files

- `queries/` — All BigQuery SQL queries used in this project
 
- [Ride Duration.csv](https://github.com/user-attachments/files/29655776/Ride.Duration.csv)
- [Weekday vs Weekend.csv](https://github.com/user-attachments/files/29655830/Weekday.vs.Weekend.csv)
- [Seasonal Patterns.csv](https://github.com/user-attachments/files/29655834/Seasonal.Patterns.csv)
- [Hourly Patterns.csv](https://github.com/user-attachments/files/29655839/Hourly.Patterns.csv)

---

*This project was completed as part of the Google Data Analytics Professional Certificate capstone.*
