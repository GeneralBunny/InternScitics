## This folder contains the codes when I worked on the AMA (American Marketing Association) Membership Retention project.
## The R codes are running on platform x86_64-apple-darwin13.4.0 in R version 3.3.1. 

## 1. Introduction
This project work on American Marketing Association membership and event data. The goal is to increase the membership retention rate by building a predictive model using historical membership event data.

## 2. Data Cleaning and exploratory data analysis.

### AMAMembership.Rmd 
It is the R Markdown file for data analysis on the AMA Membership dataset. Since the dataset contains proprietary information, it is not uploaded here. It combines 36 xlsx files for the membership from September 2013 to september 2016, missing the file from August, 2015. The goal is to identify who renews their membership (RENEW ==1, otherwise RENEW == 0), and when they renew it, which will be the dependent variable for future logistic regression modeling. 
 
 After combing all the files, all the dates are in Date type. The important ones are "MEMBER.SINCE.DATE", "EXPIRATION.DATE" and "DATE.PULLED".
 
 Also some exploratary analysis was performed in order to understand the data.
 1. EMP represents EXPIRATION.DATE-DATE.PULLED2 (in month). The smallest number of EMP is -1, which means that once it has passed the expiration date by one month, he/she is dropped out from the system.
 2. It is confirmed that if the member renews the membership before the expiration date, the new expiration date gets extended to one more year than the current expiration date. As the example shows here, the member renews the membership on Mar 2016, and the new EXPIRATION.DATE is 2017-06-30, which is one year after the previous EXPIRATION.DATE 2016-06-30.
 ```
 - MEMBER.ID  MEMBER.SINCE.DATE   EXPIRATION.DATE   DATE.PULLED2    EMP
 - 684951        1981-11-01          2014-06-30       Sep 2013        9
 - 684951        1981-11-01          2015-06-30       Jun 2014        12
 - 684951        1981-11-01          2016-06-30       Feb 2015        16
 - 684951        1981-11-01          2017-06-30       Mar 2016        15
 ```
 3. It shows the number of times each member appears in the combined data, ordered in MEMBER.SINCE.DATE.

At the end of the file, a strategy is designed to define if the member renews the membership or not. For the member who has EXPIRATION.DATE 4 months after the DATE.PULLED2, and renewed the membership within 10 months after DATE.PULLED2, label the member at DATE.PULLED2 with Renew == 1. If the member did not renew it within 10 months after DATE.PULLED2, then label Renew == 0.

## 3. Matching the MEMBER.ID in the membership dataset to event dataset.

### AMA_Boston_ID_03_03.Rmd 
Since the both the membership and event dataset contain proprietary information, they are not uploaded here. It uses the merge() function (similar to JOIN in SQL) with options of all.x = TRUE/FALSE, all.y = TRUE/FALSE (similar to LEFT JOIN, RIGHT JOIN in SQL). I tried to merge the two file using different combinations of the variable (by.x = "Email", by = by.x = c("First.Name","Last.Name", "Company"), by.x = c("First.Name","Last.Name", "Home.Address.1"), etc.). There are conflicts from different results, and I use the result from "Email" as the correct one.

### WaterFall.txt 
It is the QC file for MEMBER.ID matching. It lists the results from each matching methods, and the final result as well.

## 4. Data aggregation on event dataset.
### EventAgg.R
This R file reads "BosEvtRenew_GitHub.csv" and "data_1312to1602(Nov1508).txt". 
"BosEvtRenew_GitHub.csv" is the Boston event data with the id labelled where the id's are in the renew-selected file where RENEW == 0 and RENEW == 1 are labelled.
"data_1312to1602(Nov1508).txt" is the analysis file where RENEW == 0 and RENEW == 1 are labelled. It contains the information like DATE.PULLED when RENEW is defined. DATE.PULLED is used when I do data aggregation.
The specifications of data aggregation is in "Agg_Spec.docx".

## 5. Use Information Value for variable selection.
### IV_WOE.R
Weight of eveidence (WOE) for each variable is 
WOE = \ln(Percentage of Goods/Percentage of Bads). 
For example, as shown below, for the aggregated variable B_amt_12mos (this is the sum of total paid for Boston event where the order date is within 12 month of date.pulled), the number of total paid within the range [0, 18.42] with RENEW == 1 divided by the number with RENEW == 1 is 0.31524008.
```
- IV$Tables$B_amt_12mos
-      B_amt_12mos   N    Percent          WOE          IV     Perc_G     Perc_B
- 1             NA 735 0.64304462 -0.101611807 0.006579644 0.60542797 0.67018072
- 2      [0,18.42] 285 0.24934383  0.446021589 0.057173146 0.31524008 0.20180723
- 3  [20.21,29.69]  36 0.03149606 -0.125403572 0.057662843 0.02922756 0.03313253
- 4  [31.74,53.24]  44 0.03849519 -1.519245138 0.125577385 0.01252610 0.05722892
- 5 [57.37,296.97]  43 0.03762030 -0.001922515 0.125577524 0.03757829 0.03765060
```
The WOE plots for the top 5 variables with the largest IV are shown below.
![alt tag](https://github.com/GeneralBunny/InternScitics/blob/master/WOE_5Var.jpeg)

Information Value (IV) 
IV = \sum (Percentage of Goods - Percentage of Bads)\* WOE. 
Some of the example of the IV values are shown below. 

```
print(head(IVsMR));
                 Variable         IV
13              B_recency 0.17719401
1           B_order_12mos 0.14161253
7             B_amt_12mos 0.12557752
5  B_order_NotChkIn_12mos 0.11139664
11   B_amt_NotChkIn_12mos 0.10873110
16    B_OdTp_PayPal_12mos 0.08433095
```

A rule of thumb for variable selection using IV is that 
*  < 0.02: unpredictive 
* 0.02 to 0.1: weak 
* 0.1 to 0.3: medium 
* 0.3 to 0.5: strong
*  > 0.5: suspicious

For a logistic regression, log(p/(1-p))=a + b\*X1 + c\*X2 + ... + z\*Xn, fter we do data aggregation for each independent variable, the variable X is change to WOE. 
## 6. Logistic Regression

## 7. Others files in this repository.
### MonthDiff.R 
It contains some codes for data transformation and aggregation.
