## This folder contains the codes when I worked on the AMA (American Marketing Association) Membership Retention project.

## The R codes are running on platform x86_64-apple-darwin13.4.0 in R version 3.3.1. 

MonthDiff.R are the tricks for data transformation and aggregation.

AMAMembership.Rmd is the R Markdown file for data analysis on the AMA Membership dataset. Since the dataset contains proprietary information, it is not uploaded here. It combines 36 xlsx files for the membership from September 2013 to september 2016, missing the file from August, 2015. The goal is to identify who renews their membership (RENEW ==1, otherwise RENEW == 0), and when they renew it, which will be the dependent variable for future logistic regression modeling. 
 
 After combing all the files, all the dates are in Date type. The important ones are "MEMBER.SINCE.DATE", "EXPIRATION.DATE" and "DATE.PULLED".
 
 Also some exploratary analysis was performed in order to understand the data.
 1. EMP represents EXPIRATION.DATE-DATE.PULLED2 (in month). The smallest number of EMP is -1, which means that once it has passed the expiration date by one month, he/she is dropped out from the system.
 2. It is confirmed that if the member renews the membership before the expiration date, the new expiration date gets extended to one more year than the current expiration date. As the example shows here, the member renews the membership on Mar 2016, and the new EXPIRATION.DATE is 2017-06-30, which is one year after the previous EXPIRATION.DATE 2016-06-30.
 - MEMBER.ID  MEMBER.SINCE.DATE   EXPIRATION.DATE   DATE.PULLED2    EMP
 - 684951        1981-11-01          2014-06-30       Sep 2013        9
 - 684951        1981-11-01          2015-06-30       Jun 2014        12
 - 684951        1981-11-01          2016-06-30       Feb 2015        16
 - 684951        1981-11-01          2017-06-30       Mar 2016        15
3. It shows the number of times each member appears in the combined data, ordered in MEMBER.SINCE.DATE.

At the end of the file, a strategy is designed to define if the member renews the membership or not. For the member who has EXPIRATION.DATE 4 months after the DATE.PULLED2, and renewed the membership within 10 months after DATE.PULLED2, label the member at DATE.PULLED2 with Renew == 1. If the member did not renew it within 10 months after DATE.PULLED2, then label Renew == 0.

AMA_Boston_ID_03_03.Rmd is to match the MEMBER.ID in the membership dataset to event dataset. Since the both the membership and event dataset contain proprietary information, they are not uploaded here. It uses the merge() function (similar to JOIN in SQL) with options of all.x = TRUE/FALSE, all.y = TRUE/FALSE (similar to LEFT JOIN, RIGHT JOIN in SQL). I tried to merge the two file using different combinations of the variable (by.x = "Email", by = by.x = c("First.Name","Last.Name", "Company"), by.x = c("First.Name","Last.Name", "Home.Address.1"), etc.). There are conflicts from different results, and I use the result from "Email" as the correct one.

WaterFall.txt is the QC file for MEMBER.ID matching. It lists the results from each matching methods, and the final result as well.
