networkrate <- sqldf("select N.businessyear, N.statecode, N.Issuerid, N.networkname, R.planid, R.rateeffectivedate, R.rateexpirationdate, R.RatingareaId, R.Age, R.Individualrate 
                     from networktestt1 n inner join ratetestt1 r on n.issuerid = r.issuerid ")


