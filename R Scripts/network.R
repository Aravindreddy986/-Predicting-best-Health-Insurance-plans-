networktest <- network

colnames(networktest)
networktestt1 <- networktest[,c(-5,-6,-7,-8,-10,-11,-12)]

networktestt2 <-  networktestt1[!duplicated(networktestt1), ]

distinctissueridsnw <- sqldf("select distinct IssuerId from networktestt2")
