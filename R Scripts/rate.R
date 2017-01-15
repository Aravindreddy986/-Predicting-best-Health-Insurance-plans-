
###########################################################################################

#Individual Rate: Dollar value for the insurance premium cost applicable to a non-tobacco user for the insurance plan in a rating area, 
#                 or to a general subscriber if there is no tobacco preference

#Goal: How the individual rate varies based on the count of the benefits associated to a plan id, Age = 23, Rating AreaId =  1

###########################################################################################

ratetest <- rate
colnames(ratetest)

## selecting the required columns
ratetestt1 <- ratetest[,c(-3,-4,-5,-6,-7,-8,-9,-10,-13,-16,-17,-18,-19,-20,-21,-22,-23,-24)]
colnames(ratetestt1)

## selecting only the Rating Area 1
ratetestt1  <- subset(ratetestt1, RatingAreaId == "Rating Area 1")

## converting the columns from factor to character
ratetestt1$StateCode  <- as.character(ratetestt1$StateCode)
ratetestt1$PlanId     <- as.character(ratetestt1$PlanId)
ratetestt1$Age        <- as.character(ratetestt1$Age)

unique(ratetestt1$BusinessYear)
unique(ratetestt1$Age)
unique(ratetestt1$IndividualRate)

## selecting only the age 23
ratetestt1age23 <- subset(ratetestt1, (Age == "23") ) 

## removing dublicates
ratetestt1age23wd <- ratetestt1age23[!duplicated(ratetestt1age23),]
colnames(ratetestt1age23wd)

########################################################################

AK0030002 <- subset(ratetest, PlanId == "45858AK0030002")
AK0030002b <- subset(BenefitsCostSharingtest, StandardComponentId == "45858AK0030002")

########################################################################

BenefitsCostSharingtestt1 <- BenefitsCostSharingtest[,c(2,30,29,1,3,6,13,14,17)]

colnames(BenefitsCostSharingtestt1)


planbenefits <- sqldf("select businessyear,statecode, standardcomponentid, count(*) as countofbenefits from BenefitsCostSharingtestt1 
                       group by businessyear,statecode, standardcomponentid 
                       order by businessyear,statecode ")
colnames(planbenefits)

planbenefits2 <- sqldf("select businessyear,statecode, standardcomponentid, count(ISCovered) as countofiscovered from BenefitsCostSharingtestt1 
                       where IScovered = 'Covered'
                       group by businessyear,statecode, standardcomponentid 
                       order by businessyear,statecode ")
head(planbenefits2)

unique(BenefitsCostSharingtestt1$IsEHB)
planbenefits3 <- sqldf("select businessyear,statecode, standardcomponentid, count(ISEHB) as countofisEHB from BenefitsCostSharingtestt1 
                       where ISEHB = 'Yes'
                       group by businessyear,statecode, standardcomponentid 
                       order by businessyear,statecode ")
head(planbenefits3)

unique(BenefitsCostSharingtestt1$IsStateMandate)
planbenefits4 <- sqldf("select businessyear,statecode, standardcomponentid, count(IsStateMandate) as countofisStatemandate from BenefitsCostSharingtestt1 
                       where IsStateMandate = 'Yes'
                       group by businessyear,statecode, standardcomponentid 
                       order by businessyear,statecode ")
head(planbenefits4)

########################################################################################################################

final <- sqldf("select r.businessyear, r.statecode, r.planid, r.age, r.individualrate, pb.countofbenefits
                from ratetestt1age23wd r left outer join planbenefits pb on  
                                         r.businessyear = pb.businessyear and
                                         r.statecode    = pb.statecode and 
                                         r.planid       = pb.standardcomponentid 
               ")
colnames(final)
head(final)

final <- sqldf("select r.businessyear, r.statecode, r.planid, r.age, r.individualrate, r.countofbenefits, pb2.countofiscovered 
                  from final r left outer join planbenefits2 pb2 on
                                                                  r.businessyear = pb2.businessyear and
                                                                  r.statecode    = pb2.statecode and 
                                                                  r.planid       = pb2.standardcomponentid  ")
colnames(final)
head(final)

final <- sqldf("select r.businessyear, r.statecode, r.planid, r.age, r.individualrate, r.countofbenefits,r.countofiscovered, pb2.countofisEHB 
                  from final r left outer join planbenefits3 pb2 on
                                                                  r.businessyear = pb2.businessyear and
                                                                  r.statecode    = pb2.statecode and 
                                                                  r.planid       = pb2.standardcomponentid  ")
colnames(final)
head(final)

final <- sqldf("select r.businessyear, r.statecode, r.planid, r.age, r.individualrate, r.countofbenefits, r.countofiscovered, r.countofisEHB, pb2.countofisStatemandate
                  from final r left outer join planbenefits4 pb2 on
                                                                  r.businessyear = pb2.businessyear and
                                                                  r.statecode    = pb2.statecode and 
                                                                  r.planid       = pb2.standardcomponentid  ")

final[is.na(final)] <- 0
colnames(final)
head(final)


########################################################################################

finalt1 <- final[,c(-2,-3,-4)]
colnames(finalt1)

finalt1 <- finalt1[,c(1,3,4,5,6,2)]
colnames(finalt1)

finalt1 <- finalt1[!duplicated(finalt1),]

finalt2 <- sqldf("select Businessyear, countofbenefits,countofiscovered,countofisEHB,countofisStatemandate, 
                         avg(IndividualRate) as modifiedrate from finalt1 
                         group by Businessyear,countofbenefits,countofiscovered,countofisEHB,countofisStatemandate
                         having modifiedrate > 0
                         order by Businessyear, modifiedrate
                ")
colnames(finalt2)
write.xlsx(finalt2,"A:/Projects/health-insurance-marketplace/finalt2.xlsx")

########################################################################################

train <- subset(finalt2, ( finalt2$BusinessYear == 2014 | finalt2$BusinessYear == 2015 ) )
test <-  subset(finalt2, ( finalt2$BusinessYear == 2016  ) )

model <- lm( modifiedrate~countofbenefits + countofiscovered + countofisEHB + countofisStatemandate, 
            data = train )

summary(model)

test$predict <- predict(model, test)

