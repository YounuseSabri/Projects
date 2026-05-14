-- Diabetes Risk Analysis CLEANING
-- Goal: Clean health data and identify patterns linked to diabetes outcomes



with cleaned_data as (
    Select
        Pregnancies,
        NULLIF(Glucose, 0) as Glucose,
        NULLIF(BloodPressure, 0) as BloodPressure,
        NULLIF(SkinThickness, 0) as SkinThickness,
        NULLIF(Insulin, 0) as Insulin,
        NULLIF(BMI, 0) as BMI,
        DiabetesPedigreeFunction,
        Age,
        Outcome,

  
  
 -- Selecting Data that we are using and cleaning, Glucose, BloodPressure, SkinThickness, Insulin and BMI can not logically equal 0
 -- Cleaning data where the improbable "0" will be entered as missing replaced with "NULL"
  
  
  
        Case
            When Age < 30 Then 'Under 30'
            When Age BETWEEN 30 AND 44 Then '30-44'
            When Age BETWEEN 45 AND 59 Then '45-59'
            Else '60+'
        End as Age_Group,
  
  
  
-- Creating a age group through feature engineering in order to distinguish through categories
  
  
  
        Case
            When BMI < 18.5 Then 'Underweight'
            When BMI BETWEEN 18.5 AND 24.9 Then 'Normal'
            When BMI BETWEEN 25 AND 29.9 Then 'Overweight'
            Else 'Obese'
        End as BMI_Category,
  
  
  
-- Createing a BMI Category where we can have a categorical variable through classes

  
  
        Case
            When Glucose >= 140 Then 'High Glucose'
            When Glucose BETWEEN 100 AND 139 Then 'Moderate Glucose'
            Else 'Normal Glucose'
        End as Glucose_Category
    From diabetes_csv
)



-- Created different Categorical Variables, Glucose was created as the third, this will help the model



Select
    Age_Group,
    BMI_Category,
    Glucose_Category,
    Count(*) as Total_Patients,
    Sum(Case When Outcome = 1 Then 1 Else 0 End) as Diabetes_Cases,
    
    
    
-- Grouping together our final results and visualizing how many diabetic patients we have for the groups we created
-- Creating new column

    
    
    Round(
        100.0 * Sum(Case When Outcome = 1 Then 1 Else 0 End) / Count(*),
        2      
    ) as Diabetes_Rate_Percent,
    
    
    
-- Rounding to the second decimal place, checking diabete cases vs our dataset
-- Creating new column
    
    
    
    Round(Avg(Glucose), 2) as Avg_Glucose,
    Round(Avg(BMI), 2) as Avg_BMI,
    Round(Avg(BloodPressure), 2) as Avg_BloodPressure
From cleaned_data



-- Finding average of Glucose, BMI and BloodPressure



Group By
    Age_Group,
    BMI_Category,
    Glucose_Category
Order BY
    Diabetes_Rate_Percent DESC;
    

-- Finally finishing the project by grouping the three categories and analyzing the different groups
-- Sort through an order sequence of percentage rate of Diabetes
