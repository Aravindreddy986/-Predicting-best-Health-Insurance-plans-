names(planbenefits) <- c("x","y")

sumplan <- sqldf(" select sum(y) from planbenefits")

exclusions <- sqldf("select distinct exclusions from BenefitsCostSharingtest")

## removing repeating columns

head(BenefitsCostSharingtest)

BenefitsCostSharingtestt1 <- BenefitsCostSharingtest[,c(-12,-21,-31,-32)]

duplicates <- data.frame(duplicated(BenefitsCostSharingtest))

dim(duplicates)

unique <- unique(BenefitsCostSharingtestt1)

stat <- sqldf(" select bct.planid, bct.businessyear , 
              (select count(*) from BenefitsCostSharingtestt1 bct1 where bct1.planid = bct.planid and bct.businessyear = bct1.businessyear and bct1.Iscovered = \"Covered\" ) as countofcovered
              from BenefitsCostSharingtestt1 bct
              group by bct.planid, bct.businessyear
              
              ")