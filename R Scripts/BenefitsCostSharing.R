BenefitsCostSharingtest <- BenefitsCostSharing

head(BenefitsCostSharingtest)
colnames(BenefitsCostSharingtest)
### here standard componentid is plan id


## to get distinct benefits avaliable till now
distnbenefitname <- sqldf("select distinct  benefitname from BenefitsCostSharingtest ")
head(distnbenefitname)

## to get distinct benefts for each year
byrcntbenefitname <- sqldf("select businessyear, count(distinct benefitname) from BenefitsCostSharingtest  group by businessyear")
head(byrcntbenefitname)

## to get distinct benefts for each year and for each state
statedistinctsbenefitname <- sqldf("select businessyear, statecode, count(distinct benefitname) from BenefitsCostSharingtest group by statecode, businessyear ")
head(statedistinctsbenefitname)

##statedistinctsbenefitname2 <- sqldf("select t.businessyear, t.statecode, count(distinct t.benefitname), 
                                     #(select distinct t1.benefitname + '; ' from BenefitsCostSharingtest t1
                                      #where t1.businessyear = t.businessyear and t1.statecode = t.statecode 
                                       #     FOR XML PATH ('') ) as distinctbenefitnames
                                     #from BenefitsCostSharingtest t group by t.statecode, t.businessyear ")

#write.xlsx(planbenefits,"A:/Data mining/Data files/health-insurance-marketplace/planbenefits.xlsx")

planid <- sqldf("select distinct standardcomponentid from  BenefitsCostSharingtest")
head(planid)

planidcnt <- sqldf("select businessyear, statecode, count(distinct benefitname), count(distinct standardcomponentid) from BenefitsCostSharingtest
                   group by businessyear,statecode")
head(planidcnt)

planbenefits <- sqldf("select standardcomponentid , count(benefitname)  from BenefitsCostSharingtest group by standardcomponentid ")
head(planbenefits)

planbenefits2 <- sqldf("select businessyear,statecode, standardcomponentid, count(*) from BenefitsCostSharingtest 
                       group by businessyear,statecode, standardcomponentid 
                       order by businessyear,statecode ")
head(planbenefits2)

planbenefits <- sqldf("select businessyear,statecode, standardcomponentid, count(ISCovered) from BenefitsCostSharingtest 
                       where IScovered = 'Covered'
                       group by businessyear,statecode, standardcomponentid 
                       order by businessyear,statecode ")
head(planbenefits)

sqldf("select * from BenefitsCostSharingtest where standardcomponentid = '15833FL0080001'")

#####################################################################################################################

## working on a particular benefit: dialysis seeing how insurance providers pay and how the copay is

benefitcostsharingdialysis <-  sqldf("select * from BenefitsCostSharingtest where benefitname like '%Dialysis%'")
head(benefitcostsharingdialysis)
colnames(benefitcostsharingdialysis)

## selecting only the required columns
benefitcostsharingdialysis <- benefitcostsharingdialysis[,c(30,2,29,20,1,3,6,13,14,17,26)]
head(benefitcostsharingdialysis)
colnames(benefitcostsharingdialysis)

unique(benefitcostsharingdialysis$CoinsInnTier1)
unique(benefitcostsharingdialysis$CopayInnTier1)

benefitcostsharingdialysis$CoinsInnTier1 <- as.character(benefitcostsharingdialysis$CoinsInnTier1)
benefitcostsharingdialysis$CopayInnTier1 <- as.character(benefitcostsharingdialysis$CopayInnTier1 )

benefitcostsharingdialysistest <- benefitcostsharingdialysis

head(benefitcostsharingdialysistest)

stat1 <- sqldf("select businessyear, statecode,copayInntier1, count(standardcomponentid) 
               from benefitcostsharingdialysistest group by businessyear, statecode,copayInntier1")

stat2 <- sqldf("select businessyear, statecode,CoinsInnTier1, count(standardcomponentid) 
               from benefitcostsharingdialysistest group by businessyear, statecode,CoinsInnTier1")

stat3 <- sqldf("select businessyear, copayInntier1, count(standardcomponentid) 
               from benefitcostsharingdialysistest group by businessyear,copayInntier1")

stat4 <- sqldf("select businessyear,CoinsInnTier1,count(standardcomponentid) 
               from benefitcostsharingdialysistest group by businessyear, CoinsInnTier1")

## bad plans analysis

plans <- data.frame(unique(benefitcostsharingdialysis$CoinsInnTier1))
colnames(plans) <- "plans"

worstplans <- data.frame(plans[c(5,6,8,14,20,21,23,25,26,29,33,34,37,38,16,17),1])
colnames(worstplans) <- "plans"                  

goodplans <- data.frame(unique(benefitcostsharingdialysis$CoinsInnTier1))
colnames(goodplans) <- "plans"
goodplans <- sqldf("select * from goodplans where plans not in (select plans from worstplans)")

stat5forworst <-  sqldf("select businessyear, statecode,CoinsInnTier1, count(standardcomponentid) 
               from benefitcostsharingdialysistest
               where CoinsInnTier1 in (select plans from worstplans)
               group by businessyear, statecode,CoinsInnTier1
               order by businessyear, statecode")

stat5forworst <- stat5forworst[order(stat5forworst$CoinsInnTier1),]

write.xlsx(stat5forworst,"A:/stat5forworst.xlsx")
