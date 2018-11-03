gc()
rm(list = ls(all = TRUE))

pkgTest = function(x)
{
  if (!require(x,character.only = TRUE))
    {
      install.packages(x,dep=TRUE)
      if(!require(x,character.only = TRUE)) stop("Package not found")
    }
}

pkgTest("plyr")
pkgTest("dplyr")
pkgTest("stringr")
pkgTest("RODBC")
pkgTest("tidyr")
pkgTest("lubridate")
pkgTest("readr")

setwd("D:/Hasmat/Inmar/Excercise1/Raw Data/")


consumer_incentive_compile = read.csv("consumer_incentive_1.csv",header = TRUE,na.strings = "",strip.white = TRUE)
consumer_incentive_compile=consumer_incentive_compile[consumer_incentive_compile$status==1,]

consumer_incentive_temp = read.csv("consumer_incentive_2.csv",header = TRUE,na.strings = "",strip.white = TRUE)
consumer_incentive_temp=consumer_incentive_temp[consumer_incentive_temp$status==1,]

consumer_incentive_compile = rbind(consumer_incentive_compile, consumer_incentive_temp)

consumer_incentive_temp = read.csv("consumer_incentive_3.csv",header = TRUE,sep = "|",na.strings = "",strip.white = TRUE)
consumer_incentive_temp=consumer_incentive_temp[consumer_incentive_temp$status==1,]

consumer_incentive_compile$rk=NULL

consumer_incentive_compile = rbind(consumer_incentive_compile, consumer_incentive_temp)

emptycols = colSums(is.na(consumer_incentive_compile)) == nrow(consumer_incentive_compile)
consumer_incentive_compile = consumer_incentive_compile[!emptycols]

rm(consumer_incentive_temp)
rm(emptycols)

auth_user = read.csv("auth_user.csv",header = TRUE,na.strings = "")
consumer_id = read.csv("consumer_id.csv",header = TRUE,sep = "|",na.strings = "")
Retailer = read.csv("Retailer.csv",header = TRUE,sep = "|",na.strings = "")

names(Retailer)[1]="clientid"

consumer_incentive_compile=join(consumer_incentive_compile,Retailer[,c("clientid","description")],by=c("clientid"))

consumer_incentive_compile=join(consumer_incentive_compile,consumer_id[,c("consumer_id_id","retailer_id","login_id")],by=c("consumer_id_id"))

names(consumer_incentive_compile)[18]="retailer_id_consumer"
names(consumer_incentive_compile)[19]="username"

consumer_incentive_compile=join(consumer_incentive_compile,auth_user[,c("username","date_joined")],by=c("username"))

consumer_incentive_final=consumer_incentive_compile[!is.na(consumer_incentive_compile$date_joined),]

consumer_incentive_final$offer_Redeem_date=as_date(consumer_incentive_final$redeem_date)
consumer_incentive_final$reg_date=as_date(consumer_incentive_final$date_joined)

consumer_incentive_final$Flag=ifelse(consumer_incentive_final$offer_Redeem_date<consumer_incentive_final$reg_date,1,0)

consumer_incentive_final=consumer_incentive_final[consumer_incentive_final$Flag==0,]


write.csv(consumer_incentive_final,"consumer_incentive_final.csv",row.names = FALSE)
