
library(dplyr)
library(openxlsx)
library(ROracle)
library(geosphere)

flights=read.xlsx("Flight list.xlsx")
drv <- dbDriver("Oracle")
con <- dbConnect(drv, "PRUTEST", "test", dbname='//porape5.ops.cfmu.eurocontrol.be:1521/pe5')

APT_data <- dbGetQuery(con, "SELECT * FROM SP_AIRPORT_INFO")
Circle_data<- dbGetQuery(con, "SELECT *
  FROM FSD.ALL_FT_CIRCLE_PROFILE
WHERE     airspace_id = 'L40'
AND (   (    SAM_ID = 209362678
             AND lobt >= '24-jul-2017'
             AND lobt < '25-jul-2017')
        OR (    SAM_ID = 209844536
                AND lobt >= '08-aug-2017'
                AND lobt < '09-aug-2017')
        OR (    SAM_ID = 217395397
                AND lobt >= '26-apr-2018'
                AND lobt < '27-apr-2018')
        OR (    SAM_ID = 210164233
                AND lobt >= '17-aug-2017'
                AND lobt < '18-aug-2017')
        OR (    SAM_ID = 220516056
                AND lobt >= '10-jul-2018'
                AND lobt < '11-jul-2018')
        OR (    SAM_ID = 210655794
                AND lobt >= '01-sep-2017'
                AND lobt < '02-sep-2017')
        OR (    SAM_ID = 213622811
                AND lobt >= '10-dec-2017'
                AND lobt < '11-dec-2017'))
AND model_type = 'CPF'")

dbDisconnect(con)

ARP_LAT=filter(APT_data, ICAO_CODE=="LIRN") %>% 
  select(ARP_LAT) %>% 
  as.numeric()

ARP_LON=filter(APT_data, ICAO_CODE=="LIRN") %>% 
  select(ARP_LON) %>% 
  as.numeric()

Circle_data=mutate(Circle_data, Bearing=bearingRhumb(c(ARP_LON, ARP_LAT), cbind(Circle_data$ENTRY_LON, Circle_data$ENTRY_LAT)))

Saved=write.xlsx(Circle_data, "Circle data.xlsx")
