library(maptools)
library(maps)
library(rgdal)
library(sp)

## Ce script est très proche de anonymize_trip_zip. La principale distinction est la conversion de coordonées (
cleanlines <- function(points)
 {
   bad <- with(points, pickup_longitude > 180| pickup_longitude < -180| pickup_latitude < -90|pickup_latitude >90|dropoff_longitude > 180| dropoff_longitude < -180| dropoff_latitude < -90|dropoff_latitude >90 | is.na(pickup_longitude) | is.na(pickup_latitude) | is.na(dropoff_longitude) | is.na(dropoff_latitude) )
   points <- points[!bad,]
 }

zone.map <-readOGR("taxi_zones.shp",layer="taxi_zones")
onlyzone.map <- zone.map[,c(4,5)]


##Le systéme de coorédonées utilisé pour les zones de taxi n'est pas le GPS, il s'agit d'un autre systéme. 
## Cette focntion effectue la conversion entre les deux systémes de coorédonées Swiss grid (CH1903) to GPS (WGS84)
set_chi_coordinate <-function(taxi_file) {
        proj4string(taxi_file) <- CRS("+proj=longlat +datum=WGS84")
        taxi_chi <- spTransform(taxi_file,CRS("+proj=lcc +lat_1=40.66666666666666 +lat_2=41.03333333333333 +lat_0=40.16666666666666 +lon_0=-74 +x_0=300000 +y_0=0 +datum=NAD83 +units=us-ft +no_defs +ellps=GRS80 +towgs84=0,0,0"))
	taxi_chi 
}

replace_with_zone <- function(input_file, output_file)
 {
	taxi_pickup <- read.csv(input_file)
	drops <- c("vendor_id","rate_code","store_and_fwd_flag","payment_type","fare_amount","surcharge","mta_tax","tip_amount","tolls_amount","total_amount")
	taxi_pickup <- cleanlines(taxi_pickup[,!(names(taxi_pickup) %in% drops)])
	taxi_dropoff = taxi_pickup
	coordinates(taxi_pickup) = ~pickup_longitude+pickup_latitude
	taxi_pickup_chi <-set_chi_coordinate(taxi_pickup)
	zone.pickup <- over(taxi_pickup_chi,onlyzone.map)
	taxi_pickup <- NULL
	coordinates(taxi_dropoff) = ~dropoff_longitude+dropoff_latitude
	taxi_dropoff_chi <-set_chi_coordinate(taxi_dropoff)
	zone.dropoff <- over(taxi_dropoff_chi, onlyzone.map)
	
	names(zone.pickup)[1]<-"ZONE_PICKUP"
        taxi_dropoff$zone_up<-zone.pickup
	names(zone.dropoff)[1]<-"ZONE_DROPOFF"
        taxi_dropoff$zone_off<-zone.dropoff 
	
	write.csv(taxi_dropoff, output_file)
}


for (i in 1:12 ) {
	input_file <- paste("Trips/yellow_tripdata_2013-", i, ".csv", sep = "")
	output_file <- paste("taxi_zone_", i, ".csv", sep = "") 
	replace_with_zone(input_file,output_file)
}




