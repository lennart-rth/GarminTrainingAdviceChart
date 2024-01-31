# GarminTrainingAdviceChart
Source code for [this]() app on the Garmin ConnectIQ Store.

A polar chart based on HRV and resting heart rate data to easily interpret your daily training advice.

Uses Intervals.icu api to get the hrv and resting heart rate data of the last 30 days and plots them in a polar chart. This shows if you are "overtrained", "coping well", "undertrained" or have signs of Illness/Stress etc.
This is based on https://forum.intervals.icu/t/how-to-imready4-app-for-hrv-guided-training/25778 .
Calculates the rolling z-score for hrv and resting heart rate for a window of the last 30 days. HRV from -3 to +3 as the angle, and resting heart rate from -3 to +3 as the radius.

YOU NEED THE FOLLOWING FOR THIS APP TO WORK:
1. Garmin Connect to upload your wellness data to Intervals.icu.
2. Your Intervals.icu api key and athlete id.
3. An Internet connection.
