planattributestest <- planattributes
colnames(planattributes)

colnames(planattributestest)

planattributestest <- planattributestest[,c(2,3,4,5,9,59,60,61,62,63,64,101,102,103,105,108,109,110,111,113,114,115,117,118,134,135)]
colnames(planattributestest)

planattributestest <- planattributestest[,-21]
colnames(planattributestest)

unique(planattributestest$OutOfCountryCoverage)
unique(planattributestest$OutOfCountryCoverageDescription)

planoutofcountry <- sqldf("select BusinessYear,statecode, standardcomponentid, benefitpackageid, OutOfCountryCoverageDescription, count(*)
                            from  planattributestest
                           where OutOfCountryCoverage = 'YES' 
                           group by BusinessYear,statecode, standardcomponentid, benefitpackageid, OutOfCountryCoverageDescription")
#################

plandialysis <- sqldf("select * from planattributes where standardcomponentid in (select standardcomponentid from benefitcostsharingdialysis)")
colnames(plandialysis)

unique(planattributestest$MedicalDrugDeductiblesIntegrated)
unique(planattributes$PlanType)
unique(planattributes$MarketCoverage)
unique(planattributes$TEHBOutOfNetFamilyMOOP)

plandialysistest <- plandialysis[,c(2,3,4,5,9,59,32,89,159,60,61,62,63,64,101,102,103,105,108,109,110,111,113,114,115,117,118,134,135)]
colnames(plandialysistest)

plandialysistest <- plandialysistest[,c(4,29,3,28,27,26,23,24,1,2,6,7,8,9,15)]
colnames(plandialysistest)

unique(plandialysistest$TEHBInnTier1FamilyMOOP)

## removing dollar symbol and comma

plandialysistest$TEHBInnTier1FamilyMOOP<- gsub(',', '', plandialysistest$TEHBInnTier1FamilyMOOP)
plandialysistest$TEHBInnTier1FamilyMOOP<- gsub('\\$', '', plandialysistest$TEHBInnTier1FamilyMOOP)
unique(plandialysistest$TEHBInnTier1FamilyMOOP)

plandialysistest <- subset(plandialysistest, (plandialysistest$TEHBInnTier1FamilyMOOP != "Not Applicable"))
unique(plandialysistest$TEHBInnTier1FamilyMOOP)
  
options(scipen=999)

statdialysis1 <- sqldf("select businessyear, statecode,TEHBInnTier1FamilyMOOP, count(standardcomponentid)
                        from plandialysistest
                        group by businessyear, statecode,TEHBInnTier1FamilyMOOP ")

statdialysis2 <- sqldf("select businessyear, TEHBInnTier1FamilyMOOP, count(standardcomponentid)
                        from plandialysistest
                        group by businessyear, TEHBInnTier1FamilyMOOP ")

statdialysis3 <- sqldf("select businessyear, TEHBInnTier1FamilyMOOP, count(standardcomponentid) as countofplanids
                        from plandialysistest
                        where TEHBInnTier1FamilyMOOP >0
                       group by businessyear, TEHBInnTier1FamilyMOOP ")

statdialysis4 <- sqldf("select businessyear, statecode,TEHBInnTier1FamilyMOOP, count(standardcomponentid)
                        from plandialysistest
                        where TEHBInnTier1FamilyMOOP >0
                        group by businessyear, statecode,TEHBInnTier1FamilyMOOP
                        order by statecode, businessyear")

year2014 <- subset(statdialysis3, (statdialysis3$BusinessYear == 2014))

for(i in 1: dim(year2014)[1])
{
  year2014$percentoftotal[i] <- (((year2014$countofplanids[i])/ sum(year2014$countofplanids) ) * 100)
}

year2015 <- subset(statdialysis3, (statdialysis3$BusinessYear == 2015))

for(i in 1: dim(year2015)[1])
{
  year2015$percentoftotal[i] <- (((year2015$countofplanids[i])/ sum(year2015$countofplanids) ) * 100)
}

statdialysis5 <- rbind(year2014,year2015)

## http://healthcoverageguide.org/reference-guide/coverage-types/plan-characteristics-and-types/

write.xlsx(statdialysis5,"A:/statdialysis5.xlsx")
