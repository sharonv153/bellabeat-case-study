# find the minutes of activity and distance
SELECT 
  ROUND(AVG(SedentaryMinutes),2) AS Sedentary_m, 
  ROUND(AVG(SedentaryActiveDistance),2) AS Sed_miles, 
  ROUND(AVG(LightlyActiveMinutes), 2) AS Lightly_Act_m, 
  ROUND(AVG(LightActiveDistance), 2) AS Light_distance, 
  ROUND(AVG(FairlyActiveMinutes), 2) AS Mode_Act_m, 
  ROUND(AVG(ModeratelyActiveDistance), 2) AS Mode_miles,
  ROUND(AVG(VeryActiveMinutes), 2) AS very_act_m,
  ROUND(AVG(VeryActiveDistance), 2) AS very_act_miles
FROM `smart-window-371015.Fitbit.dailyIntensities`;

# find the hours of activity and distance
SELECT 
  ROUND(AVG(SedentaryMinutes)/60,2) AS Sedentary_h, 
  ROUND(AVG(SedentaryActiveDistance)/60,2) AS Sed_miles, 
  ROUND(AVG(LightlyActiveMinutes)/60, 2) AS Lightly_Act_h, 
  ROUND(AVG(LightActiveDistance)/60, 2) AS Light_distance, 
  ROUND(AVG(FairlyActiveMinutes)/60, 2) AS Mode_Act_h, 
  ROUND(AVG(ModeratelyActiveDistance)/60, 2) AS Mode_miles,
  ROUND(AVG(VeryActiveMinutes)/60, 2) AS very_act_h,
  ROUND(AVG(VeryActiveDistance)/60, 2) AS very_act_miles
FROM `smart-window-371015.Fitbit.dailyIntensities`;

# find the total activity for each user and order by ID, convert the minutes to hours
SELECT
  Id,
  Count(ActivityDay) AS total_active_days,
  ROUND(SUM(SedentaryMinutes)/60, 2) AS Sed_total_H,
  ROUND(SUM(SedentaryActiveDistance),2) AS Sed_total_miles, 
  ROUND(SUM(LightlyActiveMinutes)/60, 2) AS Lightly_Act_total_h, 
  ROUND(SUM(LightActiveDistance), 2) AS Light_total_distance, 
  ROUND(SUM(FairlyActiveMinutes)/60, 2) AS Mode_Act_total_h, 
  ROUND(SUM(ModeratelyActiveDistance), 2) AS Mode_total_miles,
  ROUND(SUM(VeryActiveMinutes)/60, 2) AS Very_act_total_h,
  ROUND(SUM(VeryActiveDistance), 2) AS Very_act_total_miles
FROM `smart-window-371015.Fitbit.dailyIntensities`
GROUP BY Id
ORDER BY Id DESC;

# filter out only the users (id) with MORE than 20 days and then order by sedentary time
SELECT
  Id,
  Count(ActivityDay) AS total_active_days,
  ROUND(SUM(SedentaryMinutes)/60, 2) AS Sed_total_H,
  ROUND(SUM(SedentaryActiveDistance),2) AS Sed_total_miles, 
  ROUND(SUM(LightlyActiveMinutes)/60, 2) AS Lightly_Act_total_h, 
  ROUND(SUM(LightActiveDistance), 2) AS Light_total_distance, 
  ROUND(SUM(FairlyActiveMinutes)/60, 2) AS Mode_Act_total_h, 
  ROUND(SUM(ModeratelyActiveDistance), 2) AS Mode_total_miles,
  ROUND(SUM(VeryActiveMinutes)/60, 2) AS Very_act_total_h,
  ROUND(SUM(VeryActiveDistance), 2) AS Very_act_total_miles
FROM `smart-window-371015.Fitbit.dailyIntensities`
GROUP BY Id
HAVING total_active_days > 20
ORDER BY Id DESC;

# filter out only the users (id) with LESS than 20 days and then order by sedentary time
SELECT
  Id,
  Count(ActivityDay) AS total_active_days,
  ROUND(SUM(SedentaryMinutes)/60, 2) AS Sed_total_H,
  ROUND(SUM(SedentaryActiveDistance),2) AS Sed_total_miles, 
  ROUND(SUM(LightlyActiveMinutes)/60, 2) AS Lightly_Act_total_h, 
  ROUND(SUM(LightActiveDistance), 2) AS Light_total_distance, 
  ROUND(SUM(FairlyActiveMinutes)/60, 2) AS Mode_Act_total_h, 
  ROUND(SUM(ModeratelyActiveDistance), 2) AS Mode_total_miles,
  ROUND(SUM(VeryActiveMinutes)/60, 2) AS Very_act_total_h,
  ROUND(SUM(VeryActiveDistance), 2) AS Very_act_total_miles
FROM `smart-window-371015.Fitbit.dailyIntensities`
GROUP BY Id
HAVING total_active_days < 20
ORDER BY Id DESC;

# compare activity times for users with total active days >20 & <20

# is there a correlation between more minutes & higher distances ran/walked?


# convert the dates oin the minuteMETsNArrow table and extract the dat & time then analyze the METS
/* METS 
Sedentary <= 1.5
Light 1.6 - 2.9
Moderate 3 - 5.9
Vigorous >= 6
*/
/* this query converts the ActivityMinute column from STRING to a DATETIME format
 then i extracted the date and the time*/
SELECT
  Id,
  DATE(PARSE_DATETIME("%m/%d/%Y %I:%M:%S %p", ActivityMinute)) AS Activity_Date,
  TIME(PARSE_DATETIME("%m/%d/%Y %I:%M:%S %p", ActivityMinute)) AS Activity_Time,
  METs
FROM `smart-window-371015.Fitbit.minuteMETsNarrow` 
ORDER BY Id, Activity_Date, Activity_Time;

# CREATE A VIEW AND STORE THE TABLE WITH ACTUAL DAT FORMATS IN IT
# tablename_T (where T = time)
CREATE VIEW Fitbit.sleepDay_T AS (
  SELECT 
    Id,
    DATE(PARSE_DATETIME("%m/%d/%Y %I:%M:%S %p", SleepDay)) as Sleep_Date,
    TotalSleepRecords,
    TotalMinutesAsleep,
    TotalMinutesInBed
  FROM `smart-window-371015.Fitbit.sleepDay`
);

# had to delete view because I computed the date wrong the first time
DROP VIEW Fitbit.sleepDay_T;

/* Based on what I checked the dailySteps table already has the date 
format so there's no need to convert like with the sleepDay table */

/* calculate the average time of sleep and time in bed */
SELECT
  AVG(TotalMinutesAsleep) AS avg_minutes_asleep,
  AVG(TotalMinutesInBed) AS avg_minutes_in_bed
FROM `smart-window-371015.Fitbit.sleepDay_T`;

# add calories burned then get the hours of sleep and total time in bed
SELECT
  d.Id,
  d.ActivityDay,
  #a.ActivityDate, # this is to verify that right dates are selected
  #s.Sleep_Date, # this column is just to verify that I selected the right date
  d.StepTotal,
  s.TotalMinutesAsleep AS min_sleep_previous_night,
  s.TotalMinutesInBed,
  a.TrackerDistance,
  c.Calories AS caloriesBurned
FROM `smart-window-371015.Fitbit.dailySteps` d
  INNER JOIN Fitbit.sleepDay_T s
    ON d.Id = s.Id
  INNER JOIN `smart-window-371015.Fitbit.dailyActivity` a
    ON d.Id = a.Id
  INNER JOIN `smart-window-371015.Fitbit.dailyCalories` c
    ON a.Id = c.Id
WHERE d.ActivityDay = s.Sleep_Date AND
  d.ActivityDay = a.ActivityDate AND
  a.ActivityDate = c.ActivityDay
ORDER BY d.ActivityDay DESC;

/* use the heart rate to calculate heart rate average for the hour and then classify by fitbit's heart rate zone to estimate intensity of activity within the hour*/
SELECT 
  Id,
  DATE(PARSE_DATETIME("%m/%d/%Y %I:%M:%S %p", Date_time)) AS Date_act,
  EXTRACT(HOUR FROM (PARSE_DATETIME("%m/%d/%Y %I:%M:%S %p", Date_time))) AS Date_hr,
  AVG(Heart_rate) AS heart_rate,
  CASE 
    WHEN AVG(Heart_rate) < 114 THEN "Rest Zone"
    WHEN AVG(Heart_rate) >= 114 AND AVG(Heart_rate) < 135 THEN "Fat Burn Zone"
    WHEN AVG(Heart_rate) >= 135 AND AVG(Heart_rate) < 160 THEN "Cardio Zone"
    ELSE "Peak Zone" 
    END AS heart_rate_zone
FROM `smart-window-371015.Fitbit.heartrate_seconds` 
GROUP BY Id, Date_act, Date_hr;

#gather the average METs per hour for every day from minuteMETsNarrow
SELECT 
  Id,
  Active_date,
  EXTRACT(HOUR FROM Active_time) as Active_hr,
  AVG(METs) AS avg_METs_hourly
FROM `smart-window-371015.Fitbit.minuteMETsNarrow_T`
GROUP BY Id, Active_date, Active_hr;

#sum mets for the day
SELECT 
  Id,
  Active_date,
  SUM(METs) AS daily_METs
FROM `smart-window-371015.Fitbit.minuteMETsNarrow_T`
GROUP BY Id, Active_date;
