# Calculate the difference in months

library(lubridate)
var1 <- as.Date("2013-08-31",format = "%Y-%m-%d");
var2 <- as.Date("2014-09-15",format = "%Y-%m-%d");
months <- (as.yearmon(var2) - as.yearmon(var1))*12;
sprintf("%.10f", months);

# Work with names objects in a loop
NAMES <- c("var1", "var2", "var3")

for (i in NAMES)
{j = get(i); # assigned the named object to j
# Do the manipulations you want here.
assign(i,j);
}

# remove the duplicated observation

a <- data.frame(MEMBER.ID = c("001", "001", "002", "003", "003", "003"),
                DATE.PULLED = c("2013-01-31", "2013-03-31", "2014-04-30", "2015-06-30", "2015-06-30", "2015-07-31"));

aRemove <- a[!(rownames(a) == which(duplicated(a[c("MEMBER.ID", "DATE.PULLED")]) == TRUE)),];

# To get the unique combination of different attributes.
a <- data.frame(MEMBER.ID = c("001", "001", "002", "003", "003", "003"),
                DATE.PULLED = c("2013-01-31", "2013-03-31", "2014-04-30", "2015-06-30", "2015-06-30", "2015-07-31"));

b <- a[!duplicated(a$MEMBER.ID),];
c <- a[duplicated(a$MEMBER.ID),];
d <- a[duplicated(a$MEMBER.ID) | duplicated(a$MEMBER.ID,fromLast = TRUE),];

e <- a[duplicated(a[c("MEMBER.ID", "DATE.PULLED")]),];
f <- a[duplicated(a[c("MEMBER.ID", "DATE.PULLED")]) | duplicated(a[c("MEMBER.ID", "DATE.PULLED")], fromLast = TRUE),];

# use lapply and rbind to combine lists to dataframe

a <- data.frame(MEMBER.ID = c("001", "001", "002", "003", "003", "003"),
                DATE.PULLED = c("2013-01-31", "2013-03-31", "2014-04-30", "2015-06-30", "2015-06-30", "2015-07-31"));

ID <-split(a, a$MEMBER.ID);

freq <- do.call(rbind, lapply(ID, 
                              function(x) 
                                      data.frame(MEMBER.ID = unique(x$MEMBER.ID), 
                                                 frequency = nrow(x))));
freq <- arrange(freq, MEMBER.ID);

freq <- cbind(freq, lable = 1:nrow(freq));
plot(freq[,3],freq[,2],xlab = "MEMBER.ID",
     ylab="Time appears in DATE.PULLED");
