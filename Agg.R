library(xlsx)
library(lubridate)
library(dplyr)
library(zoo)

# Renew is the renew-selected file from the membership data.
RenewSel <- read.table("data_1312to1602(No1508).txt", sep="\t", header = TRUE);
# MERGEID.csv contains all the 1706 observation from Boston event data where the MEMBER.ID have been appended.
BosEvtID <- read.csv("BosEvtRenew_GitHub.csv");
# BosEvtRenew_GitHub.csv is the Boston event data with the id labelled where the id's are in the renew-selected file where RENEW == 0
# and RENEW == 1 are labelled.
BosEvtRenew <- BosEvtID[BosEvtID$MEMBER.ID %in% RenewSel$MEMBER.ID,]

Hear1 <- BosEvtRenew$How.you.hear.about.this.event.;
Hear2 <- BosEvtRenew$How.did.you.hear.about.this.event.;
Hear <- table(Hear1, Hear2);
# There is no observations that have values on both attributes.
# Now try to combine/coalesce these two attributes.
BosEvtRenew$HEAR <- ifelse(is.na(BosEvtRenew$How.you.hear.about.this.event.), 
                           as.character(BosEvtRenew$How.did.you.hear.about.this.event.), 
                           as.character(BosEvtRenew$How.you.hear.about.this.event.));

# BosEvtRenew2 is the one with names corrected.
BosEvtRenew2 <- BosEvtRenew;
BosEvtRenew2$Ticket.Type <- as.character(BosEvtRenew2$Ticket.Type);
BosEvtRenew2$Ticket.Type[BosEvtRenew2$Ticket.Type == "AMA member" 
                         | BosEvtRenew2$Ticket.Type == "AMA Member"
                         | BosEvtRenew2$Ticket.Type == "AMA Members" 
                         | BosEvtRenew2$Ticket.Type == "Members"] <- "AMA Member";
BosEvtRenew2$Ticket.Type[BosEvtRenew2$Ticket.Type == "AMA Non Member"
                         | BosEvtRenew2$Ticket.Type == "AMA non-member"
                         | BosEvtRenew2$Ticket.Type == "AMA Non-member"
                         | BosEvtRenew2$Ticket.Type == "AMA Non-Member"
                         | BosEvtRenew2$Ticket.Type == "Non Members"
                         |BosEvtRenew2$Ticket.Type == "Non-AMA Members"
                         | BosEvtRenew2$Ticket.Type == "Non-members"
                         | BosEvtRenew2$Ticket.Type == "Non-Members"] <- "AMA Non-member";
BosEvtRenew2$Ticket.Type[BosEvtRenew2$Ticket.Type == "Early Bird (Non AMA Member)"
                         | BosEvtRenew2$Ticket.Type == "Early Bird AMA Non-Member"
                         | BosEvtRenew2$Ticket.Type == "Early Bird Non-AMA Member"
                         | BosEvtRenew2$Ticket.Type == "Early Bird Non-member"
                         | BosEvtRenew2$Ticket.Type == "Non-members, Early Bird"] <- "AMA Non-member (Early Bird)";
BosEvtRenew2$Ticket.Type[BosEvtRenew2$Ticket.Type == "Early Bird AMA Member"
                         | BosEvtRenew2$Ticket.Type == "Early Bird AMA-Member"
                         | BosEvtRenew2$Ticket.Type == "Early Bird Pricing - AMA Member"
                         | BosEvtRenew2$Ticket.Type == "Early Bird, Members"] <- "AMA Member (Early Bird)";
BosEvtRenew2$Ticket.Type[BosEvtRenew2$Ticket.Type == "Student - AMA Member"
                         | BosEvtRenew2$Ticket.Type == "Student AMA Member"
                         | BosEvtRenew2$Ticket.Type == "Student-AMA Member"] <- "AMA Member Student";
BosEvtRenew2$Ticket.Type[BosEvtRenew2$Ticket.Type == "Student (Non-member)"
                         | BosEvtRenew2$Ticket.Type == "Student AMA Non-member"
                         | BosEvtRenew2$Ticket.Type == "Student Non Members"] <- "AMA Member Non-student";

BosEvtRenew2$HEAR[BosEvtRenew2$HEAR == "AMA Boston email"
                  | BosEvtRenew2$HEAR == "AMA email"
                  | BosEvtRenew2$HEAR == "AMA Email"] <- "AMA Email";
BosEvtRenew2$HEAR[BosEvtRenew2$HEAR == "AMA Boston web site"
                  | BosEvtRenew2$HEAR == "AMA Boston website"] <- "AMA Boston Website";
BosEvtRenew2$HEAR[BosEvtRenew2$HEAR == "email"
                  | BosEvtRenew2$HEAR == "Email"] <- "Email";

BosEvtRenew2$Order.Date <- parse_date_time(BosEvtRenew2$Order.Date, orders="Ymd HMS");

BosEvt_Agg <- BosEvtRenew2;

BosEvt_Agg$Event.Name <- as.character(BosEvt_Agg$Event.Name);
BosEvt_Agg$HEAR <- as.character(BosEvt_Agg$HEAR);
BosEvt_Agg$Order.Type <- as.character(BosEvt_Agg$Order.Type);
BosEvt_Agg$Ticket.Type <- as.character(BosEvt_Agg$Ticket.Type);

BosEvt_Agg$Event.Name[BosEvt_Agg$Event.Name %in% c("AMA Boston Holiday Mixer",
                                                   "AMA Boston Holiday Mixer 2015","AMA Boston & NEDMA Epic 2016 Holiday Party!",
                                                   "AMA Boston Summer Celebration","AMA Boston Summer Networking Party! #BOSummer16",
                                                   "AMA Boston\'s Totally \'80s Summer Party","AMA Boston\'s Ugly Sweater Holiday Party",
                                                   "Summer Networking: Here Today, Gone to Maui")]<- "Party";
BosEvt_Agg$Event.Name[BosEvt_Agg$Event.Name %in% c("AMA Boston Recruitment Event 2014",
                                                   "AMA Boston Volunteer Information Event  3/10/16",
                                                   "AMA Boston Volunteer Recruitment Event","AMA Boston Volunteer Team Meeting 2014",
                                                   "AMA Boston Volunteer Thanks - at Jillian\'s","AMA Boston Winter Volunteer Recruitment Event",
                                                   "AMA Volunteer Appreciation Event","AMA Volunteer Onboarding Meeting",
                                                   "AMA Boston\'s Social Media & Communication Team Appreciation Night out at Jillian\'s",
                                                   "Hang Out At The Harp: AMABoston\'s Social Media + Communications Team Meeting",
                                                   "AMA Boston Social Team Building and Volunteer Appreciation Event")] <- "Volunteer";
BosEvt_Agg$Event.Name[BosEvt_Agg$Event.Name %in% c("Marketing Attribution Analysis: Lessons From Practitioners",
                                                   "Be Heard:  Brand Engagement Strategies that Deliver Results",
                                                   "Marketing in 2024: What You Need to Know Today to Prepare for the Future",
                                                   "Modern Marketing Mashup",
                                                   "The Marketing Landscape of the Future and Its Impact on Careers",
                                                   "Sirius Decisions - Research-driven Strategies to Drive Growth #SiriusGrowth",
                                                   "More than Credits and Debits: Marketing Best Practices in Financial Services",
                                                   "Innovate, Disrupt, Lead - Cutting-Edge AMA Boston Event | Free to AMA members",
                                                   "Find Your Golden Thread - Insight Driven Marketing and The Human Condition",
                                                   "Integrated Marketing: If It Were Easy, Everyone Would Do It", 
                                                   "Customer Conversion Through Funnel",
                                                   "Customer Experience 20/20: A New Era of Customer-centric Marketing",
                                                   "NERD Challenge: Content Marketing",
                                                   "Past, Present and Future of Content Marketing: Impacting Behavioral Change",
                                                   "Three Steps to Content Marketing Success: Lessons from the Pros",
                                                   "Content Marketing: Tell Bigger Stories Without Selling",
                                                   "Mobile in Financial Services Marketing",
                                                   "Mobile Influence - Business Strategies & Tactics for the Mobile Market",
                                                   "The Future of Video Media: TV, Cable, Web, Mobile and Beyond",
                                                   "How Do You Measure Your Social Media ROI?",
                                                   "Media Convergence: Possibilities and Opportunities For Integrated Marketing",
                                                   "Are You Getting Digital Right?", "2013 Marketing Leadership Forum",
                                                   "AMA Boston CMO Roundtable: Authentic Marketing",
                                                   "Fireside Chat with Career Guru Dan Schawbel: An AMA Mixer Event",
                                                   "Leadership on Fire - AMA Mid-Year Retreat",
                                                   "Storytelling: The Art of Moving People")]<-"Strategy";
BosEvt_Agg$Event.Name[BosEvt_Agg$Event.Name %in% unique(BosEvt_Agg$Event.Name)[4]] <- "Strategy";

BosEvt_Agg$HEAR[BosEvt_Agg$HEAR %in% c("AMA Boston Website", "Internet search")] <- "AMA Boston Website";
BosEvt_Agg$HEAR[BosEvt_Agg$HEAR %in% c("AMA Email", "Email", "Nirmal\'s email!")] <- "Email";
BosEvt_Agg$HEAR[BosEvt_Agg$HEAR %in% c("Facebook/Twitter/LinkedIn", "LinkedIn", 
                                       "Facebook", "Twitter", "Social media")] <-  "Social Media";
BosEvt_Agg$HEAR[BosEvt_Agg$HEAR %in% c("From family or friends", "Coworker/Friend")] <- "Friends";
BosEvt_Agg$HEAR[BosEvt_Agg$HEAR %in% c("", "Other", "Board member", "AMA Member")] <- "Other";

BosEvt_Agg$Order.Type[BosEvt_Agg$Order.Type %in% c("Free Order")] <- "Free";
BosEvt_Agg$Order.Type[BosEvt_Agg$Order.Type %in% c("PayPal Completed", "PayPal Partially Refunded")] <- "PayPal";
BosEvt_Agg$Order.Type[BosEvt_Agg$Order.Type %in% c("Complimentary")] <- "Complimentary";
BosEvt_Agg$Order.Type[BosEvt_Agg$Order.Type %in% c("Other", "Paid with Check")] <- "Other";

BosEvt_Agg$Ticket.Type[BosEvt_Agg$Ticket.Type %in% c("AMA Member", "AMA Member Student", 
                                                     "Professional Members and Student Members", "AMA Members rev", "AMA Members RSVP (will be verified)",
                                                     "AMA Regular Ticket", "Members (will be verified)", "AMA Member Non-student")]<-"AMA Member";
BosEvt_Agg$Ticket.Type[BosEvt_Agg$Ticket.Type %in% c("AMA Member (Early Bird)", "Early Bird Student AMA Member")]<- "AMA Member (Early Bird)";
BosEvt_Agg$Ticket.Type[BosEvt_Agg$Ticket.Type %in% c("AMA Non-member", "General Admission")] <- "AMA Non-member";
BosEvt_Agg$Ticket.Type[BosEvt_Agg$Ticket.Type %in% c("AMA Non-member (Early Bird)")]<- "AMA Non-member (Early Bird)";
BosEvt_Agg$Ticket.Type[BosEvt_Agg$Ticket.Type %in% c("AMA Volunteer", "AMA Boston Volunteer")]<- "AMA Volunteer";
BosEvt_Agg$Ticket.Type[BosEvt_Agg$Ticket.Type %in% c("Attendee", "Yes I\'m in!", "One Guest", "RSVP", 
                                                     "Social Media/Communication Teams Appreciation Night at Jillians",
                                                     "Save The Date", "Early Bird Registration", "Paid with Check")]<- "Other";


RenewSel$DATE.PULLED <- as.Date(as.character(RenewSel$DATE.PULLED), format = ("%Y-%m-%d"));
# MEMBER.ID == "3125514" has been pulled twice on 2014-08-31
Renew2 <- RenewSel[!(rownames(RenewSel) == which(duplicated(RenewSel[c("MEMBER.ID", "DATE.PULLED")])==TRUE)),];

test1 <- Renew2[Renew2$MEMBER.ID %in% BosEvt_Agg$MEMBER.ID,];

BosEvtRenewID <- split(BosEvt_Agg, BosEvt_Agg$MEMBER.ID);

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
                 B_OdTp_Other_12mos = numeric(0),
                 B_OdTp_Other_6mos = numeric(0),
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
                 B_Hr_Other_6mos = numeric(0),
                 B_Evt_Party_12mos = numeric(0),
                 B_Evt_Party_6mos = numeric(0),
                 B_Evt_Strategy_12mos = numeric(0),
                 B_Evt_Strategy_6mos = numeric(0),
                 B_Evt_Volunteer_12mos = numeric(0),
                 B_Evt_Volunteer_6mos = numeric(0));

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
                                 B_OdTp_Free_12mos = nrow(subset(twelve, Order.Type == "Free")),
                                 B_OdTp_Free_6mos = nrow(subset(six, Order.Type == "Free")),
                                 B_OdTp_PayPal_12mos = nrow(subset(twelve, Order.Type == "PayPal")),
                                 B_OdTp_PayPal_6mos = nrow(subset(six, Order.Type == "PayPal")),
                                 B_OdTp_Complimentary_12mos = nrow(subset(twelve, Order.Type == "Complimentary")),
                                 B_OdTp_Complimentary_6mos = nrow(subset(six, Order.Type == "Complimentary")),
                                 B_OdTp_Other_12mos = nrow(subset(twelve, Order.Type == "Other")),
                                 B_OdTp_Other_6mos = nrow(subset(six, Order.Type == "Other")),
                                 B_TkTp_AMA_12mos = nrow(subset(twelve, Ticket.Type == "AMA Member")),
                                 B_TkTp_AMA_6mos = nrow(subset(six, Ticket.Type == "AMA Member")),
                                 B_TkTp_AMAEarly_12mos = nrow(subset(twelve, Ticket.Type == "AMA Member (Early Bird)")),
                                 B_TkTp_AMAEarly_6mos = nrow(subset(six, Ticket.Type  == "AMA Member (Early Bird)")),
                                 B_TkTp_NonAMA_12mos = nrow(subset(twelve, Ticket.Type == "AMA Non-member")),
                                 B_TkTp_NonAMA_6mos = nrow(subset(six, Ticket.Type == "AMA Non-member")),
                                 B_TkTp_NonAMAEarly_12mos = nrow(subset(twelve, Ticket.Type == "AMA Non-member (Early Bird)")),
                                 B_TkTp_NonAMAEarly_6mos = nrow(subset(six, Ticket.Type == "AMA Non-member (Early Bird)")),
                                 B_TkTp_Volunteer_12mos = nrow(subset(twelve, Ticket.Type == "AMA Volunteer")),
                                 B_TkTp_Volunteer_6mos = nrow(subset(six, Ticket.Type== "AMA Volunteer")),
                                 B_TkTp_Other_12mos = nrow(subset(twelve, Ticket.Type == "Other")),
                                 B_TkTp_Other_6mos = nrow(subset(six, Ticket.Type == "Other")),
                                 B_Hr_AMAWeb_12mos = nrow(subset(twelve, HEAR == "AMA Boston Website")),
                                 B_Hr_AWAWeb_6mos = nrow(subset(six, HEAR == "AMA Boston Website")),
                                 B_Hr_Email_12mos = nrow(subset(twelve, HEAR == "Email")),
                                 B_Hr_Email_6mos = nrow(subset(six, HEAR == "Email")),
                                 B_Hr_SocialMedia_12mos = nrow(subset(twelve, HEAR == "Social Media")),
                                 B_Hr_SocialMedia_6mos = nrow(subset(six, HEAR == "Social Media")),
                                 B_Hr_Friend_12mos = nrow(subset(twelve, HEAR == "Friends")),
                                 B_Hr_Friend_6mos = nrow(subset(six, HEAR == "Friends")),
                                 B_Hr_Other_12mos = nrow(subset(twelve, HEAR == "Other")),
                                 B_Hr_Other_6mos = nrow(subset(six, HEAR == "Other")),
                                 B_Evt_Party_12mos = nrow(subset(twelve, Event.Name == "Party")),
                                 B_Evt_Party_6mos = nrow(subset(six, Event.Name == "Party")),
                                 B_Evt_Strategy_12mos = nrow(subset(twelve, Event.Name == "Strategy")),
                                 B_Evt_Strategy_6mos = nrow(subset(six, Event.Name == "Strategy")),
                                 B_Evt_Volunteer_12mos = nrow(subset(twelve, Event.Name == "Volunteer")),
                                 B_Evt_Volunteer_6mos = nrow(subset(six, Event.Name == "Volunteer")));
                g2 <- rbind(g1,g2)
        }
        return(g2);
}

Agg <- do.call(rbind, lapply(BosEvtRenewID, Sel));

Agg$B_recency[Agg$B_recency == Inf] <- 0;
# Agg 407 observations

# Add all the MEMBER.ID from renew-selected file to the aggregate file
sub1 <- subset(RenewSel, select=c("MEMBER.ID", "RENEW", "DATE.PULLED"));
Boston_Agg_All <- merge(Agg, sub1, by.x = c("MEMBER.ID", "DATE.PULLED","Renew"), 
                   by.y = c("MEMBER.ID", "DATE.PULLED","RENEW"), all=TRUE);

write.csv(Boston_Agg_All, file = "Agg_all_3.csv", row.names = FALSE);