library(xlsx)
library(lubridate)
library(zoo)
library(dplyr)

# BosEvtRenew2.csv is the Boston event data with the id labelled where the 
# id's are in the renew-selected file where RENEW ==0 and RENEW == 1 are labelled.

# Comparing to BosEvtRenew.csv, for the four attributes - "EventName", "TicketType", 
# "OrderType", "HowHear", the values having the same meaning are combined. For example,
# "AMA member", "AMA Member", "AMA Members", and "Members" are all coalesced to "AMA Member". 

# BosEvtRenew2.csv has 1331 observations, 296 unique member id.
BosEvtRenew <- read.csv("BosEvtRenew_GitHub.csv", header = TRUE);
# RenewSel is the analysis file where RENEW == 0 and RENEW == 1 are labelled.
RenewSel <- read.table("data_1312to1602(No1508).txt", sep="\t", header = TRUE);

BosEvtRenew$Order.Date <- parse_date_time(BosEvtRenew$Order.Date, orders="Ymd HMS");

RenewSel$DATE.PULLED <- as.Date(RenewSel$DATE.PULLED, format = ("%Y-%m-%d"));
# MEMBER.ID == "3125514" has been pulled twice on 2014-08-31
# Renew2 has 1142 observations, and 872 unique member id.
Renew2 <- RenewSel[!(rownames(RenewSel) == which(duplicated(RenewSel[c("MEMBER.ID", "DATE.PULLED")])==TRUE)),];

# test1 has 407 observations, which is the same as 407 observations in Agg. Checked!
test1 <- Renew2[Renew2$MEMBER.ID %in% BosEvtRenew$MEMBER.ID,];

BosEvtRenewID <- split(BosEvtRenew, BosEvtRenew$MEMBER.ID);

g2 <- data.frame(MEMBER.ID =  integer(),
                 DATE.PULLED = as.Date(character()),
                 Renew = integer(),
                 B_order_12mos = integer(),
                 B_order_6mos  = integer(),
                 B_order_ChkIn_12mos = integer(),
                 B_order_ChkIn_6mons = integer(),
                 B_order_NotChkIn_12mos = integer(),
                 B_order_NotChkIn_6mos  = integer(),
                 B_amt_12mos = numeric(0),
                 B_amt_6mos  = numeric(0),
                 B_amt_ChkIn_12mos = numeric(0),
                 B_amt_ChkIn_6mos  = numeric(0),
                 B_amt_NotChkIn_12mos = numeric(0),
                 B_amt_NotChkIn_6mos  = numeric(0),
                 B_amt_NotChkIn_12mos = numeric(0),
                 B_recency = numeric(0),
                 B_OdTp_Free_12mos = numeric(0),
                 B_OdTp_Free_6mos = numeric(0),
                 B_OdTp_PayPal_12mos = numeric(0),
                 B_OdTp_PayPal_6mos = numeric(0),
                 B_OdTp_Complimentary_12mos = numeric(0),
                 B_OdTp_Complimentary_6mos =  numeric(0),
                 #B_OdTp_Other_12mos = numeric(0),
                 #B_OdTp_Other_6mos = numeric(0),
                 B_TkTp_AMA_12mos = numeric(0),
                 B_TkTp_AMA_6mos = numeric(0),
                 B_TkTp_AMAEarly_12mos = numeric(0),
                 B_TkTp_AMAEarly_6mos = numeric(0),
                 B_TkTp_NonAMA_12mos = numeric(0),
                 B_TkTp_NonAMA_6mos = numeric(0),
                 B_TkTp_NonAMAEarly_12mos = numeric(0),
                 B_TkTp_NonAMAEarly_6mos = numeric(0),
                 B_TkTp_Volunteer_12mos = numeric(0),
                 B_TkTp_Volunteer_6mos = numeric(0),
                 B_TkTp_Other_12mos = numeric(0),
                 B_TkTp_Other_6mos = numeric(0),
                 B_Hr_AMAWeb_12mos = numeric(0),
                 B_Hr_AMAWeb_6mos = numeric(0),
                 B_Hr_Email_12mos = numeric(0),
                 B_Hr_Email_6mos = numeric(0),
                 B_Hr_SocialMedia_12mos = numeric(0),
                 B_Hr_SocialMedia_6mos = numeric(0),
                 B_Hr_Friend_12mos = numeric(0),
                 B_Hr_Friend_6mos = numeric(0),
                 B_Hr_Other_12mos = numeric(0),
                 B_Hr_Other_6mos = numeric(0));

Sel <- function(x) { 
RenewData <- subset(Renew2, MEMBER.ID == unique(x$MEMBER.ID));
for (i in 1:nrow(RenewData)){
        twelve <- subset(x, 
                round((as.yearmon(Order.Date) - as.yearmon(RenewData[i,]$DATE.PULLED))*12, 
                digits = 0) <=0
                & round((as.yearmon(Order.Date) - as.yearmon(RenewData[i,]$DATE.PULLED))*12, 
                digits = 0) >= -11);
        six <- subset(x, 
                round((as.yearmon(Order.Date) - as.yearmon(RenewData[i,]$DATE.PULLED))*12, 
                digits = 0) <=0
                & round((as.yearmon(Order.Date) - as.yearmon(RenewData[i,]$DATE.PULLED))*12, 
                digits = 0) >= -6);
        BeforeOrder <- subset(x, Order.Date <= RenewData[i,]$DATE.PULLED);
        g1 <- data.frame(MEMBER.ID = unique(x$MEMBER.ID),
                DATE.PULLED = RenewData[i,]$DATE.PULLED,
                Renew = RenewData[i,]$RENEW,
                B_order_12mos = nrow(subset(twelve,!is.na(Order.Date))),
                B_order_6mos  = nrow(subset(six,!is.na(Order.Date))),
                B_order_ChkIn_12mos = nrow(subset(twelve, Attendee.Status == "Checked In")),
                B_order_ChkIn_6mos = nrow(subset(six, Attendee.Status == "Checked In")),
                B_order_NotChkIn_12mos = nrow(subset(twelve, Attendee.Status == "Attending")),
                B_order_NotChkIn_6mos = nrow(subset(six, Attendee.Status == "Attending")),
                B_amt_12mos = sum(twelve$Total.Paid),
                B_amt_6mos  = sum(six$Total.Paid),
                B_amt_ChkIn_12mos = sum(subset(twelve, Attendee.Status == "Checked In")$Total.Paid),
                B_amt_ChkIn_6mos  = sum(subset(six, Attendee.Status == "Checked In")$Total.Paid),
                B_amt_NotChkIn_12mos = sum(subset(twelve, Attendee.Status == "Attending")$Total.Paid),
                B_amt_NotChkIn_6mos  = sum(subset(six, Attendee.Status == "Attending")$Total.Paid),
                B_recency = as.numeric(RenewData[i,]$DATE.PULLED - max(as.Date(BeforeOrder$Order.Date))),
                B_OdTp_Free_12mos = nrow(subset(twelve, Order.Type == "Free Order")),
                B_OdTp_Free_6mos = nrow(subset(six, Order.Type == "Free Order")),
                B_OdTp_PayPal_12mos = nrow(subset(twelve, Order.Type == "PayPal Completed" 
                                                  | Order.Type == "PayPal Partially Refunded")),
                B_OdTp_PayPal_6mos = nrow(subset(six, Order.Type == "PayPal Completed" 
                                                  | Order.Type == "PayPal Partially Refunded")),
                B_OdTp_Complimentary_12mos = nrow(subset(twelve, Order.Type == "Complimentary")),
                B_OdTp_Complimentary_6mos = nrow(subset(six, Order.Type == "Complimentary")),
                #B_OdTp_Other_12mos = nrow(subset(twelve, Order.Type == "Other"
                #                                 | Order.Type == "Paid with Check")),
                #B_OdTp_Other_6mos = nrow(subset(six, Order.Type == "Other"
                #                                 | Order.Type == "Paid with Check")),
                B_TkTp_AMA_12mos = nrow(subset(twelve, Ticket.Type %in% 
                        c("AMA Member", "AMA Member Student", "Professional Members and Student Members", 
                          "AMA Members rev", "AMA Members RSVP (will be verified)", "AMA Regular Ticket", 
                          "Members (will be verified)", "AMA Member Non-student"))),
                B_TkTp_AMA_6mos = nrow(subset(six, Ticket.Type %in% 
                        c("AMA Member", "AMA Member Student", "Professional Members and Student Members", 
                        "AMA Members rev", "AMA Members RSVP (will be verified)", "AMA Regular Ticket", 
                        "Members (will be verified)", "AMA Member Non-student"))),
                B_TkTp_AMAEarly_12mos = nrow(subset(twelve, Ticket.Type %in% 
                        c("AMA Member (Early Bird)", "Early Bird Student AMA Member"))),
                B_TkTp_AMAEarly_6mos = nrow(subset(six, Ticket.Type %in% 
                        c("AMA Member (Early Bird)", "Early Bird Student AMA Member"))),
                B_TkTp_NonAMA_12mos = nrow(subset(twelve, Ticket.Type %in% 
                        c("AMA Non-member", "General Admission"))),
                B_TkTp_NonAMA_6mos = nrow(subset(six, Ticket.Type %in% 
                        c("AMA Non-member", "General Admission"))),
                B_TkTp_NonAMAEarly_12mos = nrow(subset(twelve, Ticket.Type %in% 
                        c("AMA Non-member (Early Bird)"))),
                B_TkTp_NonAMAEarly_6mos = nrow(subset(six, Ticket.Type %in% 
                        c("AMA Non-member (Early Bird)"))),
                B_TkTp_Volunteer_12mos = nrow(subset(twelve, Ticket.Type %in% 
                        c("AMA Volunteer", "AMA Boston Volunteer"))),
                B_TkTp_Volunteer_6mos = nrow(subset(six, Ticket.Type %in% 
                        c("AMA Volunteer", "AMA Boston Volunteer"))),
                B_TkTp_Other_12mos = nrow(subset(twelve, Ticket.Type %in% 
                        c("Attendee", "Yes I'm in!", "One Guest","RSVP", 
                          "Social Media/Communication Teams Appreciation Night at Jillians", 
                          "Save The Date", "Early Bird Registration", "Paid with Check"))),
                B_TkTp_Other_6mos = nrow(subset(six, Ticket.Type %in% 
                        c("Attendee", "Yes I'm in!", "One Guest","RSVP", 
                        "Social Media/Communication Teams Appreciation Night at Jillians", 
                        "Save The Date", "Early Bird Registration", "Paid with Check"))),
                B_Hr_AMAWeb_12mos = nrow(subset(twelve, HEAR %in% c("AMA Boston Website", "Internet Search"))),
                B_Hr_AWAWeb_6mos = nrow(subset(six, HEAR %in% c("AMA Boston Website", "Internet Search"))),
                B_Hr_Email_12mos = nrow(subset(twelve, HEAR %in% c("AMA Email", "Email", "Nirmal's email!"))),
                B_Hr_Email_6mos = nrow(subset(six, HEAR %in% c("AMA Email", "Email", "Nirmal's email!"))),
                B_Hr_SocialMedia_12mos = nrow(subset(twelve, HEAR %in% 
                        c("Facebook/Twitter/LinkedIn", "LinkedIn", "Facebook", "Twitter", "Social media"))),
                B_Hr_SocialMedia_6mos = nrow(subset(six, HEAR %in% 
                        c("Facebook/Twitter/LinkedIn", "LinkedIn", "Facebook", "Twitter", "Social media"))),
                B_Hr_Friend_12mos = nrow(subset(twelve, HEAR %in% 
                        c("From family or friends", "Coworker/Friend"))),
                B_Hr_Friend_6mos = nrow(subset(six, HEAR %in% 
                        c("From family or friends", "Coworker/Friend"))),
                B_Hr_Other_12mos = nrow(subset(twelve, HEAR %in% 
                        c("", "Other", "Board member", "AMA Member"))),
                B_Hr_Other_6mos = nrow(subset(six, HEAR %in% 
                                                       c("", "Other", "Board member", "AMA Member"))));
        g2 <- rbind(g1,g2)
        }
        return(g2);
}

Agg <- do.call(rbind, lapply(BosEvtRenewID, Sel));

Agg$B_recency[Agg$B_recency == Inf] <- 0;

# write.csv(Agg, file = "Agg.csv", row.names = FALSE);

# Add all the MEMBER.ID from renew-selected file to the aggregate file
sub1 <- subset(RenewSel, select=c("MEMBER.ID", "RENEW", "DATE.PULLED"));
Agg_all <- merge(Agg, sub1, by.x = c("MEMBER.ID", "DATE.PULLED","Renew"), 
      by.y = c("MEMBER.ID", "DATE.PULLED","RENEW"), all=TRUE);

write.csv(Agg_all, file = "Agg_all.csv", row.names = FALSE);

