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
pkgTest("data.table")
pkgTest("rJava")
pkgTest("xlsx")
pkgTest("reshape2")


setwd("D:/Hasmat/Inmar/Excercise2/Raw Data/")

incentives = read.xlsx("incentives.xlsx",header = TRUE,sheetName = "Sheet1")
incentive_upc = read.xlsx("incentive_upc.xlsx",header = TRUE,sheetName = "Sheet1")

names(incentive_upc)[2]="PRODUCT_ID"

Transactions=fread("Transactions.txt",header = TRUE,sep = "|",colClasses=c("BASKET_ID"="number"))

Transaction_items=fread("Transaction_item.txt",header = TRUE,sep = "|",colClasses=c("BASKET_ID"="character","PRODUCT_ID"="character"))
Transaction_items1=fread("Transaction_item1.txt",header = TRUE,sep = "|",colClasses=c("BASKET_ID"="character","PRODUCT_ID"="character"))

Transaction_items=rbind(Transaction_items,Transaction_items1)

rm(Transaction_items1)

transaction_items_final=join(Transaction_items,Transactions[,c("BASKET_ID","CONSUMER_ID_ID")], by=c("BASKET_ID"))

transaction_items_final=join(transaction_items_final,incentive_upc, by=c("PRODUCT_ID"))

names(transaction_items_final)[5]="Value"

transaction_items_final=transaction_items_final[,c(1,2,3,6,7,4,5)]

#transaction_items_final_temp= dcast(transaction_items_final, formula =  CLIENTID + DATE + BASKET_ID + CONSUMER_ID_ID + INCENTIVE_ID ~ PRODUCT_ID,sum,value.var = 'Value')

transaction_items_final_temp=transaction_items_final[!is.na(transaction_items_final$INCENTIVE_ID)]

transaction_items_final_temp=join(transaction_items_final_temp,incentives[,c("INCENTIVE_ID","ACTIVE_DATE","EXPIRE_DATE")], by=c("INCENTIVE_ID"))

transaction_items_final_temp$DATE=as.Date(trimws(transaction_items_final_temp$DATE))
transaction_items_final_temp$ACTIVE_DATE=as.Date(trimws(transaction_items_final_temp$ACTIVE_DATE))
transaction_items_final_temp$EXPIRE_DATE=as.Date(transaction_items_final_temp$EXPIRE_DATE)

transaction_items_final_temp=transaction_items_final_temp[transaction_items_final_temp$Purch_flag != "NA"]

transaction_items_final_temp$Purch_flag=ifelse(transaction_items_final_temp$DATE>=transaction_items_final_temp$ACTIVE_DATE-(180) & transaction_items_final_temp$DATE<transaction_items_final_temp$ACTIVE_DATE,"Purchase Made Before Offer",ifelse(transaction_items_final_temp$DATE<=transaction_items_final_temp$EXPIRE_DATE+(180) & transaction_items_final_temp$DATE>transaction_items_final_temp$EXPIRE_DATE,"Purchase Made After Offer",ifelse(transaction_items_final_temp$DATE>=transaction_items_final_temp$ACTIVE_DATE & transaction_items_final_temp$DATE<=transaction_items_final_temp$EXPIRE_DATE,"Purchase Made During Offer","NA")))

write.table(transaction_items_final_temp,"transactions_items_final.txt",sep="\t",row.names = FALSE)
