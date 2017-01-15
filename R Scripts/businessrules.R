businessrulestest <- Businessrules

colnames(businessrulestest)

businessrulestestt1<- subset( businessrulestest, select = -c(BusinessYear, ImportDate, IssuerId2,VersionNum,TIN, RowNumber, IssuerId ) )
colnames(businessrulestestt1)


apriori<- apriori(businessrulestestt1, parameter = list(minlen=2, supp=0.7, conf=0.7))
rules_set<-sort(apriori, by="lift")

inspect(rules_set[10]) 

rules_set <- data.frame(rules_set)

