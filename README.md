# Credit-Risk
This is a broad project to gather data on the risks of lending to different categories.
Problem Statement: What is the average default rate of the data set and which factors generally have higher default rates?

Prediction: Lower income individuals and loan intentions for medical will have higher default rates.

In SQL we will clean the data by:

1) Removing any null values that may skew analysis.
2) Remove outliers that may skew analysis.
3) Change values to make it more clear.

Things to Note in Tableau Dashboard:

1) Loan grade A (best) has the lowest interest rates.
   Loan grade G (worst) has the highest interest rates.
   
2) Low income refers to an individual making < $50,000.
   Medium income refers to between $50,000 and $100,000.
   High income refers to > $100,000.
   
Conclusion:
- The average default rate was 17.82% out of a total of 28,626 people in the dataset.
- Individuals with a loan intention in home improvement had the highest default rate at 19.51%.
- Low income individuals had the highest default rates at 18.90%.
- Loan grade A and B's had 0 defaults. Loan grade G's had the highest default rate at 58%.
- Individuals who do not rent, own, or have mortgage (can assume they are living with parents or just lost their home), have the highest default rate at 24% followed by renters at 20%.
- Suprisingly, credit history length does not have a significant correlation in default rates. The trend line shows a very nominal decrease in the 30 years of roughly 2%.
