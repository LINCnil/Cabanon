library(maptools)
library(maps)


## On enléve les coordonées invalides
cleanlines <- function(points)
 {
   bad <- with(points, is.na(pickup_longitude) | is.na(pickup_latitude) | is.na(dropoff_longitude) | is.na(dropoff_latitude) )
   points <- points[!bad,]
 }

## On charge le mapping des zip codes daand zip.map
zip.map <- readShapePoly('tl_2010_36_zcta510.shp')

## On ne conserve que la colonne qui nous intéresse
onlyzip.map <- zip.map[,c(2)]


replace_with_zip <- function(input_file, output_file)
 {
	
	taxi_pickup <- read.csv(input_file)
	## Colonnes qu'on ne souhaite pas conserver
	drops <- c("vendor_id","rate_code","store_and_fwd_flag","payment_type","fare_amount","surcharge","mta_tax","tip_amount","tolls_amount","total_amount")
	taxi_pickup <- cleanlines(taxi_pickup[,!(names(taxi_pickup) %in% drops)])
	taxi_dropoff = taxi_pickup
	## On associe des coordonées à chaque trajet (ici la prise du taxi)
	coordinates(taxi_pickup) = ~pickup_longitude+pickup_latitude
	## On enregistre dans la collone zcta.pickup le zip code correspondant à chacun des trajet. La fonction Over permet de faire ce mapping
	zcta.pickup <- over(taxi_pickup,onlyzip.map)
	names(zcta.pickup)[1]<-"ZCTA_PICKUP"
	## On libére de la mémoire
	taxi_pickup <- NULL
	##On recommance pour l'arrivée 
	coordinates(taxi_dropoff) = ~dropoff_longitude+dropoff_latitude
	zcta.dropoff <- over(taxi_dropoff, onlyzip.map)
	## On concaténe les colonnes
    taxi_dropoff$zcta_up<-zcta.pickup
	names(zcta.dropoff)[1]<-"ZCTA_DROPOFF"
    taxi_dropoff$zcta_off<-zcta.dropoff 
	write.csv(taxi_dropoff, output_file)
}

## On bourcle sur les douze fichier de taxis
for (i in 10:12 ) {
	input_file <- paste("Trips/yellow_tripdata_2013-", i, ".csv", sep = "")
	output_file <- paste("taxi_with_zip_", i, ".csv", sep = "") 
	replace_with_zip(input_file,output_file)
}




