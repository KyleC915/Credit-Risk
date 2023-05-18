-- Problem Statement: Which variable is the most attributed to a person defaulting on their loan?

-- Clean Data

SELECT *
FROM PortfolioProject..CreditRisk

------------------------------------------------------------------------------------------------------------------------
-- Let's remove all null data.
DELETE FROM PortfolioProject..CreditRisk
WHERE person_emp_length IS NULL OR loan_int_rate IS NULL;

------------------------------------------------------------------------------------------------------------------------
-- Check age range. (There is someone that is 144 years old which is not possible).
SELECT MIN(person_age) AS min_age, MAX(person_age) AS max_age
FROM PortfolioProject..CreditRisk

------------------------------------------------------------------------------------------------------------------------
-- Let's check the average age and the standard deviation so we can delete outliers from the average.
SELECT AVG(person_age) AS mean_age, STDEV(person_age) AS std_dev_age
FROM PortfolioProject..CreditRisk;

------------------------------------------------------------------------------------------------------------------------
-- Delete the outliers for person_age. We used 7 STDEV because the st_dev_age was 6.3.
DELETE FROM PortfolioProject..CreditRisk
WHERE person_age > (SELECT mean_age + 7 * std_dev_age FROM (SELECT AVG(person_age) AS mean_age, STDEV(person_age) AS std_dev_age FROM PortfolioProject..CreditRisk) AS stats)
   OR person_age < (SELECT mean_age - 7 * std_dev_age FROM (SELECT AVG(person_age) AS mean_age, STDEV(person_age) AS std_dev_age FROM PortfolioProject..CreditRisk) AS stats);

------------------------------------------------------------------------------------------------------------------------
-- Check for any outliers in employment length. (There is someone employed for 123 years which is not possible).
SELECT MIN(person_emp_length) AS min_emp, MAX(person_emp_length) AS max_emp
FROM PortfolioProject..CreditRisk

------------------------------------------------------------------------------------------------------------------------
-- Check for average employment length and standard deviation to delete outliers from the average.
SELECT AVG(person_emp_length) AS mean_emp, STDEV(person_emp_length) AS std_dev_emp
FROM PortfolioProject..CreditRisk;

------------------------------------------------------------------------------------------------------------------------
-- Delete the upper outlier. We used STDEV of 5 because the std_dev_emp was 4.1.
-- We did not remove the lower outlier because it is possible to be employed for 0 years and some months.
DELETE FROM PortfolioProject..CreditRisk
WHERE person_emp_length > (SELECT mean_age + 5 * std_dev_emp FROM (SELECT AVG(person_age) AS mean_age, STDEV(person_age) AS std_dev_emp FROM PortfolioProject..CreditRisk) AS stats)

------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "cb_person_default_on_file".
UPDATE PortfolioProject..CreditRisk
SET cb_person_default_on_file =
CASE cb_person_default_on_file 
		WHEN 'Y' THEN 'Yes'
		WHEN 'N' THEN 'No'
		ELSE cb_person_default_on_file 
		END

------------------------------------------------------------------------------------------------------------------------
-- Not sure what the loan_status "0" or "1" is telling us so let's delete it.
ALTER TABLE PortfolioProject..CreditRisk
DROP COLUMN loan_status

------------------------------------------------------------------------------------------------------------------------
-- Create Tables for Tableau Dashboard (See README for additional information)

-- Overall default rate average of all people regardless of age, home ownership, loan intention, etc. For comparative purposes.
1.
SELECT CASE WHEN cb_person_default_on_file IS NULL THEN 'Total:' ELSE cb_person_default_on_file END AS cb_person_default_on_file,
       COUNT(cb_person_default_on_file) AS Total_People,
       CASE WHEN cb_person_default_on_file IS NULL THEN SUM(CASE WHEN cb_person_default_on_file = 'Yes' THEN 1 ELSE 0 END) / CAST(COUNT(*) AS FLOAT) ELSE NULL END AS Default_Rate
FROM PortfolioProject..CreditRisk
GROUP BY ROLLUP (cb_person_default_on_file);

-- Finding which loan_intent has the highest default rates

2.
SELECT loan_intent,
       COUNT(CASE WHEN cb_person_default_on_file = 'Yes' THEN 1 END) AS 'Default',
       COUNT(CASE WHEN cb_person_default_on_file = 'No' THEN 1 END) AS No_Default,
	   COUNT(CASE WHEN cb_person_default_on_file = 'Yes' THEN 1 END) / CAST(COUNT(*) AS FLOAT) AS Default_Percentage
FROM PortfolioProject..CreditRisk
GROUP BY loan_intent
ORDER BY Default_Percentage DESC;

-- Sort income into 3 catergories and get # of defaults for each, as well as the rate.

3.
SELECT income_group,
	SUM(CASE WHEN cb_person_default_on_file = 'Yes' THEN 1 ELSE 0 END) AS Default_Count,
    COUNT(*) AS Total_Count,
    SUM(CASE WHEN cb_person_default_on_file = 'Yes' THEN 1 ELSE 0 END) / CAST(COUNT(*) AS FLOAT) AS Default_Rate
FROM (
    SELECT person_income,
		CASE
			WHEN person_income < 50000 THEN 'Low Income'
            WHEN person_income >= 50000 AND person_income < 100000 THEN 'Medium Income'
				ELSE 'High Income'
           END AS income_group,
           cb_person_default_on_file
    FROM PortfolioProject..CreditRisk
) AS subquery
GROUP BY income_group
ORDER BY default_rate DESC;

-- Let' see if there is a correlation with a low loan grade (D) and higher default rates.

4. 
SELECT loan_grade,
	COUNT(CASE WHEN cb_person_default_on_file = 'Yes' THEN 1 END) AS 'Default',
    COUNT(CASE WHEN cb_person_default_on_file = 'No' THEN 1 END) AS No_Default,
	COUNT(CASE WHEN cb_person_default_on_file = 'Yes' THEN 1 END) / CAST(COUNT(*) AS FLOAT) AS Default_Percentage
FROM PortfolioProject..CreditRisk
GROUP BY loan_grade
ORDER BY Default_Percentage DESC;

-- Now let's check if home ownership has any correlation with default rates.

5.
SELECT person_home_ownership,
	COUNT(CASE WHEN cb_person_default_on_file = 'Yes' THEN 1 END) AS 'Default',
    COUNT(CASE WHEN cb_person_default_on_file = 'No' THEN 1 END) AS No_Default,
    COUNT(CASE WHEN cb_person_default_on_file = 'Yes' THEN 1 END) / CAST(COUNT(*) AS FLOAT) AS Default_Percentage
FROM PortfolioProject..CreditRisk
GROUP BY person_home_ownership
ORDER BY 'Default' DESC, No_Default ASC;

-- Finally let's check if credit history length has any correlation.
6. 
SELECT cb_person_cred_hist_length,
	COUNT(CASE WHEN cb_person_default_on_file = 'Yes' THEN 1 END) AS 'Default',
    COUNT(CASE WHEN cb_person_default_on_file = 'No' THEN 1 END) AS No_Default,
    COUNT(CASE WHEN cb_person_default_on_file = 'Yes' THEN 1 END) / CAST(COUNT(*) AS FLOAT) AS Default_Percentage
FROM PortfolioProject..CreditRisk
GROUP BY cb_person_cred_hist_length
ORDER BY cb_person_cred_hist_length
