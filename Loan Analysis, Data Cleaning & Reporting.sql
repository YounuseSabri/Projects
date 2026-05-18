/*
===============================================================================
 Project: Loan Data Cleaning & Reporting
 Dataset Table: universalbank_csv

 Purpose:
 This SQL project identifies customer banking behavior to identify high-value
 customers, personal loan conversion trends, digital banking adoption, credit
 card usage (In previous years), and cross-sell opportunities.

 Why this is useful:
 - Data cleaning
 - KPI reporting
 - Customer segmentation
 - Conversion analysis
 - Business-focused insights

 Business Goal:
 Obtaining Kaggle dataset to understand which customer segments are most likely
 to accept personal loans and which groups should be targeted for future marketing.
===============================================================================
*/


/*=============================================================================
  1. Preview the Dataset
=============================================================================*/

SELECT *
FROM universalbank_csv
LIMIT 10;


/*=============================================================================
  2. Check Total Customers and Basic Data Quality
=============================================================================*/

SELECT 
    COUNT(*) AS total_customers,
    COUNT(DISTINCT ID) AS unique_customers,
    COUNT(*) - COUNT(DISTINCT ID) AS duplicate_customer_records
FROM universalbank_csv;


/*=============================================================================
  3. Check for Missing or Unusual Values
=============================================================================*/

SELECT
    SUM(CASE WHEN ID IS NULL THEN 1 ELSE 0 END) AS missing_id,
    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS missing_age,
    SUM(CASE WHEN Experience IS NULL THEN 1 ELSE 0 END) AS missing_experience,
    SUM(CASE WHEN Income IS NULL THEN 1 ELSE 0 END) AS missing_income,
    SUM(CASE WHEN CCAvg IS NULL THEN 1 ELSE 0 END) AS missing_ccavg,
    SUM(CASE WHEN Mortgage IS NULL THEN 1 ELSE 0 END) AS missing_mortgage
FROM universalbank_csv;


/*=============================================================================
  4. Overall Customer KPI Dashboard
=============================================================================*/

SELECT
    COUNT(*) AS total_customers,
    ROUND(AVG(Age), 2) AS avg_age,
    ROUND(AVG(Experience), 2) AS avg_experience,
    ROUND(AVG(Income), 2) AS avg_income,
    ROUND(AVG(CCAvg), 2) AS avg_credit_card_spend,
    ROUND(AVG(Mortgage), 2) AS avg_mortgage,
    SUM("Personal Loan") AS customers_with_personal_loan,
    ROUND(100.0 * SUM("Personal Loan") / COUNT(*), 2) AS personal_loan_conversion_rate
FROM universalbank_csv;


/*=============================================================================
  5. Creating a Personal Loan Conversion by Education Level

 Education Meaning:
 1 = Undergraduate
 2 = Graduate
 3 = Advanced/Professional
=============================================================================*/

SELECT
    Education,
    CASE 
        WHEN Education = 1 THEN 'Undergraduate'
        WHEN Education = 2 THEN 'Graduate'
        WHEN Education = 3 THEN 'Advanced/Professional'
        ELSE 'Unknown'
    END AS education_level,
    COUNT(*) AS total_customers,
    SUM("Personal Loan") AS loan_customers,
    ROUND(100.0 * SUM("Personal Loan") / COUNT(*), 2) AS loan_conversion_rate,
    ROUND(AVG(Income), 2) AS avg_income,
    ROUND(AVG(CCAvg), 2) AS avg_credit_card_spend
FROM universalbank_csv
GROUP BY Education
ORDER BY loan_conversion_rate DESC;


/*=============================================================================
  6. Creating a Customer Segmentation by Income Group
=============================================================================*/

SELECT
    CASE
        WHEN Income < 50 THEN 'Low Income'
        WHEN Income BETWEEN 50 AND 99 THEN 'Middle Income'
        WHEN Income BETWEEN 100 AND 149 THEN 'Upper-Middle Income'
        ELSE 'High Income'
    END AS income_segment,
    COUNT(*) AS total_customers,
    SUM("Personal Loan") AS loan_customers,
    ROUND(100.0 * SUM("Personal Loan") / COUNT(*), 2) AS conversion_rate,
    ROUND(AVG(Income), 2) AS avg_income,
    ROUND(AVG(CCAvg), 2) AS avg_credit_card_spend,
    ROUND(AVG(Mortgage), 2) AS avg_mortgage
FROM universalbank_csv
GROUP BY income_segment
ORDER BY conversion_rate DESC;


/*=============================================================================
  7. Age Group Analysis
=============================================================================*/

SELECT
    CASE
        WHEN Age < 30 THEN 'Under 30'
        WHEN Age BETWEEN 30 AND 39 THEN '30s'
        WHEN Age BETWEEN 40 AND 49 THEN '40s'
        WHEN Age BETWEEN 50 AND 59 THEN '50s'
        ELSE '60+'
    END AS age_group,
    COUNT(*) AS total_customers,
    SUM("Personal Loan") AS loan_customers,
    ROUND(100.0 * SUM("Personal Loan") / COUNT(*), 2) AS conversion_rate,
    ROUND(AVG(Income), 2) AS avg_income,
    ROUND(AVG(Experience), 2) AS avg_experience
FROM universalbank_csv
GROUP BY age_group
ORDER BY conversion_rate DESC;


/*=============================================================================
  8. Digital Banking Adoption Analysis
=============================================================================*/

SELECT
    CASE 
        WHEN Online = 1 THEN 'Online Banking User'
        ELSE 'Non-Online Banking User'
    END AS online_banking_status,
    COUNT(*) AS total_customers,
    SUM("Personal Loan") AS loan_customers,
    ROUND(100.0 * SUM("Personal Loan") / COUNT(*), 2) AS loan_conversion_rate,
    ROUND(AVG(Income), 2) AS avg_income,
    ROUND(AVG(CCAvg), 2) AS avg_credit_card_spend
FROM universalbank_csv
GROUP BY Online
ORDER BY loan_conversion_rate DESC;


/*=================================================================================
  9. Cross-Sell Opportunity: Customers Without Personal Loans

 This query identifies what financially strong customers who do not currently have 
 a personal loan but may be strong candidates for future marketing campaigns.
==================================================================================*/

SELECT
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
    CASE
        WHEN Income >= 100 AND CCAvg >= 3 AND Online = 1 THEN 'High Priority'
        WHEN Income >= 75 AND CCAvg >= 2 THEN 'Medium Priority'
        ELSE 'Low Priority'
    END AS marketing_priority
FROM universalbank_csv
WHERE "Personal Loan" = 0
ORDER BY 
    CASE
        WHEN Income >= 100 AND CCAvg >= 3 AND Online = 1 THEN 1
        WHEN Income >= 75 AND CCAvg >= 2 THEN 2
        ELSE 3
    END,
    Income DESC,
    CCAvg DESC;


/*=============================================================================
  10. Top 25 Highest Value Customers
=============================================================================*/

SELECT
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
    Income + Mortgage + CCAvg AS customer_value_score
FROM universalbank_csv
ORDER BY customer_value_score DESC
LIMIT 25;


/*=============================================================================
  11. Product Usage Analysis
=============================================================================*/

SELECT
    COUNT(*) AS total_customers,
    SUM("Personal Loan") AS personal_loan_customers,
    SUM("Securities Account") AS securities_account_customers,
    SUM("CD Account") AS cd_account_customers,
    SUM(Online) AS online_banking_customers,
    SUM(CreditCard) AS credit_card_customers,
    ROUND(100.0 * SUM("Personal Loan") / COUNT(*), 2) AS personal_loan_pct,
    ROUND(100.0 * SUM("Securities Account") / COUNT(*), 2) AS securities_account_pct,
    ROUND(100.0 * SUM("CD Account") / COUNT(*), 2) AS cd_account_pct,
    ROUND(100.0 * SUM(Online) / COUNT(*), 2) AS online_banking_pct,
    ROUND(100.0 * SUM(CreditCard) / COUNT(*), 2) AS credit_card_pct
FROM universalbank_csv;


/*=============================================================================
  12. Personal Loan Customers vs Non-Loan Customers
=============================================================================*/

SELECT
    CASE 
        WHEN "Personal Loan" = 1 THEN 'Accepted Personal Loan'
        ELSE 'Did Not Accept Personal Loan'
    END AS loan_status,
    COUNT(*) AS customer_count,
    ROUND(AVG(Age), 2) AS avg_age,
    ROUND(AVG(Experience), 2) AS avg_experience,
    ROUND(AVG(Income), 2) AS avg_income,
    ROUND(AVG(CCAvg), 2) AS avg_credit_card_spend,
    ROUND(AVG(Mortgage), 2) AS avg_mortgage,
    ROUND(100.0 * SUM(Online) / COUNT(*), 2) AS online_banking_rate,
    ROUND(100.0 * SUM(CreditCard) / COUNT(*), 2) AS credit_card_rate
FROM universalbank_csv
GROUP BY "Personal Loan";


/*=============================================================================
  13. Ranking Customers by Income Within Each Education Level
=============================================================================*/

SELECT
    ID,
    Education,
    Income,
    Age,
    Experience,
    CCAvg,
    RANK() OVER (
        PARTITION BY Education
        ORDER BY Income DESC
    ) AS income_rank_within_education
FROM universalbank_csv
ORDER BY Education, income_rank_within_education;


/*=============================================================================
  14. Find Customers Above Average Income
=============================================================================*/

SELECT
    ID,
    Age,
    Income,
    CCAvg,
    Mortgage,
    "Personal Loan",
    Online,
    CreditCard
FROM universalbank_csv
WHERE Income > (
    SELECT AVG(Income)
    FROM universalbank_csv
)
ORDER BY Income DESC;


/*=============================================================================
  15. ZIP Code Market Opportunity Analysis
=============================================================================*/

SELECT
    "ZIP Code",
    COUNT(*) AS total_customers,
    ROUND(AVG(Income), 2) AS avg_income,
    SUM("Personal Loan") AS loan_customers,
    ROUND(100.0 * SUM("Personal Loan") / COUNT(*), 2) AS loan_conversion_rate,
    ROUND(AVG(Mortgage), 2) AS avg_mortgage
FROM universalbank_csv
GROUP BY "ZIP Code"
HAVING COUNT(*) >= 5
ORDER BY loan_conversion_rate DESC, avg_income DESC;


/*=============================================================================
  16. Final Executive Summary Query

 This query creates a business-ready summary that can be used in dashboards,
 reports, or portfolio presentations.
=============================================================================*/

SELECT
    'Universal Bank Customer Analytics Summary' AS report_name,
    COUNT(*) AS total_customers,
    ROUND(AVG(Income), 2) AS avg_customer_income,
    ROUND(AVG(CCAvg), 2) AS avg_monthly_credit_card_spend,
    SUM("Personal Loan") AS total_personal_loan_customers,
    ROUND(100.0 * SUM("Personal Loan") / COUNT(*), 2) AS overall_personal_loan_conversion_rate,
    SUM(CASE WHEN Income >= 100 AND "Personal Loan" = 0 THEN 1 ELSE 0 END) AS high_income_non_loan_prospects,
    SUM(CASE WHEN Online = 1 THEN 1 ELSE 0 END) AS online_banking_users,
    SUM(CASE WHEN CreditCard = 1 THEN 1 ELSE 0 END) AS credit_card_users
FROM universalbank_csv;
