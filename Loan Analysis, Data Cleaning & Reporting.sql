/*===============================================================================
 Project: Loan Data Cleaning & Reporting
 Dataset Table: universalbank_csv

 Purpose:
 This SQL project identifies customer banking behavior to identify high-value
 customers, personal loan conversion trends, digital banking adoption, credit
 card usage), and cross-sell opportunities.
=================================================================================*/


/*=============================================================================
  1. Preview the Dataset
=============================================================================*/

Select *
From universalbank_csv
Limit 10;


/*=============================================================================
  2. Check Total Customers and Basic Data Quality
=============================================================================*/

Select 
    Count(*) As total_customers,
    Count(Distinct ID) As unique_customers,
    Count(*) - Count(Distinct ID) As duplicate_customer_records
From universalbank_csv;


/*=============================================================================
  3. Check for Missing or Unusual Values
=============================================================================*/

Select
    Sum(Case When ID Is NULL Then 1 ELSE 0 END) As missing_id,
    Sum(Case When Age Is NULL Then 1 ELSE 0 END) As missing_age,
    Sum(Case When Experience Is NULL Then 1 ELSE 0 END) As missing_experience,
    Sum(Case When Income Is NULL Then 1 ELSE 0 END) As missing_income,
    Sum(Case When CCAvg Is NULL Then 1 ELSE 0 END) As missing_ccavg,
    Sum(Case When Mortgage Is NULL Then 1 ELSE 0 END) As missing_mortgage
From universalbank_csv;


/*=============================================================================
  4. Overall Customer KPI Dashboard
=============================================================================*/

Select
    Count(*) As total_customers,
    Round(Avg(Age), 2) As avg_age,
    Round(Avg(Experience), 2) As avg_experience,
    Round(Avg(Income), 2) As avg_income,
    Round(Avg(CCAvg), 2) As avg_credit_card_spend,
    Round(Avg(Mortgage), 2) As avg_mortgage,
    Sum("Personal Loan") As customers_with_personal_loan,
    Round(100.0 * Sum("Personal Loan") / Count(*), 2) As personal_loan_conversion_rate
From universalbank_csv;


/*=============================================================================
  5. Creating a Personal Loan Conversion by Education Level

 Education Meaning:
 1 = Undergraduate
 2 = Graduate
 3 = Advanced/Professional
=============================================================================*/

Select
    Education,
    Case 
        When Education = 1 Then 'Undergraduate'
        When Education = 2 Then 'Graduate'
        When Education = 3 Then 'Advanced/Professional'
        ELSE 'Unknown'
    END As education_level,
    Count(*) As total_customers,
    Sum("Personal Loan") As loan_customers,
    Round(100.0 * Sum("Personal Loan") / Count(*), 2) As loan_conversion_rate,
    Round(Avg(Income), 2) As avg_income,
    Round(Avg(CCAvg), 2) As avg_credit_card_spend
From universalbank_csv
GROUP BY Education
ORDER BY loan_conversion_rate DESC;


/*=============================================================================
  6. Creating a Customer Segmentation by Income Group
=============================================================================*/

Select
    Case
        When Income < 50 Then 'Low Income'
        When Income Between 50 And 99 Then 'Middle Income'
        When Income Between 100 And 149 Then 'Upper-Middle Income'
        ELSE 'High Income'
    END As income_segment,
    Count(*) As total_customers,
    Sum("Personal Loan") As loan_customers,
    Round(100.0 * Sum("Personal Loan") / Count(*), 2) As conversion_rate,
    Round(Avg(Income), 2) As avg_income,
    Round(Avg(CCAvg), 2) As avg_credit_card_spend,
    Round(Avg(Mortgage), 2) As avg_mortgage
From universalbank_csv
GROUP BY income_segment
ORDER BY conversion_rate DESC;


/*=============================================================================
  7. Age Group Analysis
=============================================================================*/

Select
    Case
        When Age < 30 Then 'Under 30'
        When Age Between 30 And 39 Then '30s'
        When Age Between 40 And 49 Then '40s'
        When Age Between 50 And 59 Then '50s'
        ELSE '60+'
    END As age_group,
    Count(*) As total_customers,
    Sum("Personal Loan") As loan_customers,
    Round(100.0 * Sum("Personal Loan") / Count(*), 2) As conversion_rate,
    Round(Avg(Income), 2) As avg_income,
    Round(Avg(Experience), 2) As avg_experience
From universalbank_csv
GROUP BY age_group
ORDER BY conversion_rate DESC;


/*=============================================================================
  8. Digital Banking Adoption Analysis
=============================================================================*/

Select
    Case 
        When Online = 1 Then 'Online Banking User'
        ELSE 'Non-Online Banking User'
    END As online_banking_status,
    Count(*) As total_customers,
    Sum("Personal Loan") As loan_customers,
    Round(100.0 * Sum("Personal Loan") / Count(*), 2) As loan_conversion_rate,
    Round(Avg(Income), 2) As avg_income,
    Round(Avg(CCAvg), 2) As avg_credit_card_spend
From universalbank_csv
GROUP BY Online
ORDER BY loan_conversion_rate DESC;


/*=================================================================================
  9. Cross-Sell Opportunity: Customers Without Personal Loans

 This query identifies what financially strong customers who do not currently have 
 a personal loan but may be strong candidates for future marketing campaigns.
==================================================================================*/

Select
    ID,
    Age,
    Experience,
    Income,
    Family,
    CCAvg,
    Education,
    Mortgage,
    Online,
    CreditCard,
    Case
        When Income >= 100 And CCAvg >= 3 And Online = 1 Then 'High Priority'
        When Income >= 75 And CCAvg >= 2 Then 'Medium Priority'
        ELSE 'Low Priority'
    END As marketing_priority
From universalbank_csv
WHERE "Personal Loan" = 0
ORDER BY 
    Case
        When Income >= 100 And CCAvg >= 3 And Online = 1 Then 1
        When Income >= 75 And CCAvg >= 2 Then 2
        ELSE 3
    END,
    Income DESC,
    CCAvg DESC;


/*=============================================================================
  10. Top 25 Highest Value Customers
=============================================================================*/

Select
    ID,
    Age,
    Income,
    CCAvg,
    Mortgage,
    "Personal Loan",
    "Securities Account",
    "CD Account",
    Online,
    CreditCard,
    Income + Mortgage + CCAvg As customer_value_score
From universalbank_csv
ORDER BY customer_value_score DESC
Limit 25;


/*=============================================================================
  11. Product Usage Analysis
=============================================================================*/

Select
    Count(*) As total_customers,
    Sum("Personal Loan") As personal_loan_customers,
    Sum("Securities Account") As securities_account_customers,
    Sum("CD Account") As cd_account_customers,
    Sum(Online) As online_banking_customers,
    Sum(CreditCard) As credit_card_customers,
    Round(100.0 * Sum("Personal Loan") / Count(*), 2) As personal_loan_pct,
    Round(100.0 * Sum("Securities Account") / Count(*), 2) As securities_account_pct,
    Round(100.0 * Sum("CD Account") / Count(*), 2) As cd_account_pct,
    Round(100.0 * Sum(Online) / Count(*), 2) As online_banking_pct,
    Round(100.0 * Sum(CreditCard) / Count(*), 2) As credit_card_pct
From universalbank_csv;


/*=============================================================================
  12. Personal Loan Customers vs Non-Loan Customers
=============================================================================*/

Select
    Case 
        When "Personal Loan" = 1 Then 'Accepted Personal Loan'
        ELSE 'Did Not Accept Personal Loan'
    END As loan_status,
    Count(*) As customer_count,
    Round(Avg(Age), 2) As avg_age,
    Round(Avg(Experience), 2) As avg_experience,
    Round(Avg(Income), 2) As avg_income,
    Round(Avg(CCAvg), 2) As avg_credit_card_spend,
    Round(Avg(Mortgage), 2) As avg_mortgage,
    Round(100.0 * Sum(Online) / Count(*), 2) As online_banking_rate,
    Round(100.0 * Sum(CreditCard) / Count(*), 2) As credit_card_rate
From universalbank_csv
GROUP BY "Personal Loan";


/*=============================================================================
  13. Ranking Customers by Income Within Each Education Level
=============================================================================*/

Select
    ID,
    Education,
    Income,
    Age,
    Experience,
    CCAvg,
    RANK() OVER (
        PARTITION BY Education
        ORDER BY Income DESC
    ) As income_rank_within_education
From universalbank_csv
ORDER BY Education, income_rank_within_education;


/*=============================================================================
  14. Find Customers Above Average Income
=============================================================================*/

Select
    ID,
    Age,
    Income,
    CCAvg,
    Mortgage,
    "Personal Loan",
    Online,
    CreditCard
From universalbank_csv
WHERE Income > (
    Select Avg(Income)
    From universalbank_csv
)
ORDER BY Income DESC;


/*=============================================================================
  15. ZIP Code Market Opportunity Analysis
=============================================================================*/

Select
    "ZIP Code",
    Count(*) As total_customers,
    Round(Avg(Income), 2) As avg_income,
    Sum("Personal Loan") As loan_customers,
    Round(100.0 * Sum("Personal Loan") / Count(*), 2) As loan_conversion_rate,
    Round(Avg(Mortgage), 2) As avg_mortgage
From universalbank_csv
GROUP BY "ZIP Code"
HAVING Count(*) >= 5
ORDER BY loan_conversion_rate DESC, avg_income DESC;


/*=============================================================================
  16. Final Executive Summary Query

 This query creates a business-ready summary that can be used in dashboards,
 reports, or portfolio presentations.
=============================================================================*/

Select
    'Universal Bank Customer Analytics Summary' As report_name,
    Count(*) As total_customers,
    Round(Avg(Income), 2) As avg_customer_income,
    Round(Avg(CCAvg), 2) As avg_monthly_credit_card_spend,
    Sum("Personal Loan") As total_personal_loan_customers,
    Round(100.0 * Sum("Personal Loan") / Count(*), 2) As overall_personal_loan_conversion_rate,
    Sum(Case When Income >= 100 And "Personal Loan" = 0 Then 1 ELSE 0 END) As high_income_non_loan_prospects,
    Sum(Case When Online = 1 Then 1 ELSE 0 END) As online_banking_users,
    Sum(Case When CreditCard = 1 Then 1 ELSE 0 END) As credit_card_users
From universalbank_csv;
