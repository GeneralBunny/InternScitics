# This file works on the information value and weight of evidence of the aggregated file
# Agg_all.csv.

library(xlsx)
library(Information)
library(glmnet)
# https://cran.r-project.org/web/packages/Information/vignettes/Information-vignette.html
# library(ClustOfVar)
# InformationValue package has a lot of statistics for logistic regression.


Agg_all <- read.csv("Agg_all_3.csv", header = TRUE);

Table <- file("table.csv", "w")
write.table_with_header <- function(x, file, h){
        writeLines(h, file)
        write.csv(x,file,row.names = FALSE);
}
for (i in 4:ncol(Agg_all)){
        t<- Agg_all[,i];
        write.table_with_header(table(t),Table,h=colnames(Agg_all)[i]);
}
close(Table);

sMR <- do.call(rbind, lapply(Agg_all[,4:ncol(Agg_all)],summary));
uniNum <- function(x) length(unique(x));
unNm <- do.call(rbind, lapply(Agg_all[,4:ncol(Agg_all)], uniNum));

# create_infotables(data = NULL, valid = NULL, y = NULL, bins = 10,
# trt = NULL, ncore = NULL, parallel = TRUE)
# data: it is the training dataset.
# trt: binary treatment variable for uplift analysis (Default is NUL).
# The bins are typically selected such that the bins are roughly evenly 
# sized with respect to the number of records in each bin (if possible)
IV <- create_infotables(data=Agg_all[,3:ncol(Agg_all)], y = "Renew", parallel = FALSE);

# IV$Summary shows the IV of all variables.
IVsMR<-IV$Summary;
print(head(IVsMR));
write.csv(IVsMR,"IV_Summary.csv", row.names = FALSE);

# IV$Tables is a list of the IV and WOE for all the variables.
for (i in 1:length(IV$Tables)){
        iv <- IV$Tables[[i]]$IV[1];
        IV$Tables[[i]]$Perc_G[1] <- 
                (iv/IV$Tables[[i]]$WOE[1])*exp(IV$Tables[[i]]$WOE[1])/(exp(IV$Tables[[i]]$WOE[1])-1);
        IV$Tables[[i]]$Perc_B[1] <- 
                (iv/IV$Tables[[i]]$WOE[1])/(exp(IV$Tables[[i]]$WOE[1])-1);
        
        for (j in 2:nrow(IV$Tables[[i]])){
                iv <- IV$Tables[[i]]$IV[j] - IV$Tables[[i]]$IV[j-1];
                IV$Tables[[i]]$Perc_G[j] <- 
                        (iv/IV$Tables[[i]]$WOE[j])*exp(IV$Tables[[i]]$WOE[j])/(exp(IV$Tables[[i]]$WOE[j])-1);
                IV$Tables[[i]]$Perc_B[j] <- 
                        (iv/IV$Tables[[i]]$WOE[j])/(exp(IV$Tables[[i]]$WOE[j])-1);
        }}

# for plot_infotables, show_values = TRUE does not work in the "Information" package.
# plot_infotables(IV, IV$Summary$Variable[1:5],same_scales = TRUE,show_values=TRUE);


# print(IV$Tables$B_order_12mos);

# plot WOE of one variable
# plot_infotables(IV, "B_order_12mos");

# plot WOE of several variables.

# MultiPlot(IV, names[3:6],same_scales=TRUE);

# replace the value by WOE value.
Agg_all_WOE <- Agg_all[FALSE,4:ncol(Agg_all)];

for (i in 1:length(IV$Tables)){
        w<- IV$Tables[[i]];
        range <- data.frame(WOE = numeric(nrow(w)));
        range$WOE[1] <- w$WOE[1];
        range$interval[1] <- NA;
        for (j in 2:nrow(w)){
                num <- substr(w[j,1], start = 2, stop = nchar(w[j,1])-1);
                num <- strsplit(num, ",");
                # vector should be stored as list in dataframe
                range$interval[j]<- list(c(as.numeric(num[[1]][1]), as.numeric(num[[1]][2])));
                range$WOE[j] <- w$WOE[j];
        }
        
        for (k in 1:nrow(Agg_all)){     
                for (l in 2:nrow(range)){
                        if (is.na(findInterval(Agg_all[k,i+3], unlist(range$interval[l]), rightmost.closed = TRUE)))
                        {Agg_all_WOE[k,i] <- range$WOE[1]}
                                else if (findInterval(Agg_all[k,i+3], unlist(range$interval[l]), rightmost.closed = TRUE)==1)
                                        {Agg_all_WOE[k,i] <- range$WOE[l]}
                        }
                }
}

write.csv(Agg_all_WOE, "Agg_all_WOE.csv",row.names=FALSE);
