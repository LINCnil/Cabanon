Anonymization

Group by zip_code hour of pick_up , hour of drop, drop

Anonymization algorithm:
Group by 5 minutes, 
	For those where there are only 1
		Group by 15 minutes
			For those where there are only 1
				Group by half an hour
					Four those where there are only one
						Group by one hour
							keep the results

Do the same for the drop
	keep the trip ID as the union
		we have a k-anonymized dataset !!
		

##Créer la table SQL (depuis psql)
create table nyc_trip_zoned (NUMBER bigint, Pickup_Datetime timestamp, Dropoff_Datetime timestamp, Passenger_Count smallint,Trip_Distance double precision,Pickup_Longitude float, Pickup_Latitude float, Dropoff_Longitude float, Dropoff_Latitude float,ZONE_PICKUP char(70),ZONE_ID_PICKUP char(5),ZONE_DROPOFF char(70),ZONE_ID_DROPOFF char(5));

## Remplire la table à partire des CSV (faire depuis le bash)
for i in `seq 1 12`; do  sed 's/\,TRUE//g' taxi_zone_$i.csv | sed 's/\"//g' | psql -c "COPY nyc_trip_zoned FROM stdin DELIMITER ',' CSV HEADER"; done

##Grouper les trajets avec la granulzaité taxi zone en regroupant les trajets par 5, 15, 30 et 60 mins##
copy(SELECT j.NUMBER, j.ZONE_ID_PICKUP, 
j.Pickup_Datetime, 
concat_ws(':', substring(date_trunc('hour',pickup_datetime)::text from 0 for 14), LPAD((extract(minute FROM pickup_datetime)::int / 5 * 5)::text ,2,'0'),'00') AS PICKUP_5, COUNT(NUMBER) OVER ( PARTITION BY ZONE_ID_PICKUP,date_trunc('hour',pickup_datetime), (extract(minute FROM pickup_datetime)::int / 5 * 5)) AS COUNT_P_5,
concat_ws(':', substring(date_trunc('hour',pickup_datetime)::text  from 0 for 14), LPAD((extract(minute FROM pickup_datetime)::int / 15 * 15)::text ,2,'0'),'00') AS PICKUP_15, COUNT(NUMBER) OVER ( PARTITION BY ZONE_ID_PICKUP,date_trunc('hour',pickup_datetime), (extract(minute FROM pickup_datetime)::int / 15 * 15)) AS COUNT_P_15,
concat_ws(':', substring(date_trunc('hour',pickup_datetime)::text  from 0 for 14), LPAD((extract(minute FROM pickup_datetime)::int / 30 * 30)::text ,2,'0'),'00') AS PICKUP_30, COUNT(NUMBER) OVER ( PARTITION BY ZONE_ID_PICKUP,date_trunc('hour',pickup_datetime), (extract(minute FROM pickup_datetime)::int / 30 * 30)) AS COUNT_P_30,
date_trunc('hour',pickup_datetime) AS PICKUP_HOUR, COUNT(NUMBER) OVER ( PARTITION BY ZONE_ID_PICKUP,date_trunc('hour',pickup_datetime)) AS COUNT_P_HOUR,
j.ZONE_ID_DROPOFF,
j.Dropoff_Datetime, 
concat_ws(':', substring(date_trunc('hour',Dropoff_Datetime)::text  from 0 for 14), LPAD((extract(minute FROM Dropoff_Datetime)::int / 5 * 5)::text ,2,'0'),'00') AS DROP_5, COUNT(NUMBER) OVER ( PARTITION BY ZONE_ID_DROPOFF,date_trunc('hour',Dropoff_Datetime), (extract(minute FROM Dropoff_Datetime)::int / 5 * 5)) AS COUNT_D_5,
concat_ws(':', substring(date_trunc('hour',Dropoff_Datetime)::text  from 0 for 14), LPAD((extract(minute FROM Dropoff_Datetime)::int / 15 * 15)::text ,2,'0'),'00') AS DROP_15, COUNT(NUMBER) OVER ( PARTITION BY ZONE_ID_DROPOFF,date_trunc('hour',Dropoff_Datetime), (extract(minute FROM Dropoff_Datetime)::int / 15 * 15)) AS COUNT_D_15,
concat_ws(':', substring(date_trunc('hour',Dropoff_Datetime)::text  from 0 for 14), LPAD((extract(minute FROM Dropoff_Datetime)::int / 30 * 30)::text ,2,'0'),'00') AS DROP_30, COUNT(NUMBER) OVER ( PARTITION BY ZONE_ID_DROPOFF,date_trunc('hour',Dropoff_Datetime), (extract(minute FROM Dropoff_Datetime)::int / 30 * 30)) AS COUNT_D_30,
date_trunc('hour',Dropoff_Datetime) AS DROP_HOUR, COUNT(NUMBER) OVER ( PARTITION BY ZONE_ID_DROPOFF,date_trunc('hour',Dropoff_Datetime)) AS COUNT_D_HOUR,
j.Passenger_Count, j.Trip_Distance,j.ZONE_PICKUP, j.ZONE_DROPOFF, j.Pickup_Longitude, j.Pickup_Latitude, j.Dropoff_Longitude, j.Dropoff_Latitude
FROM nyc_trip_zoned j) to '/data/postgresql/fullest_zone.csv' With CSV;



##Créer la table des zip codes
create table nyc_trip_zip (NUMBER bigint, Pickup_Datetime timestamp, Dropoff_Datetime timestamp, Passenger_Count smallint, Trip_Distance double precision, Pickup_Longitude float, Pickup_Latitude float, Dropoff_Longitude float, Dropoff_Latitude float, ZCTA_PICKUP char(5), ZCTA_DROPOFF char(5));
cat taxi_with_zip-*.csv | psql -c 'COPY nyc_trip_zip FROM stdin CSV HEADER'

## Grouper les trajets avec la granulzaité zip code en regroupant les trajets par 5, 15, 30 et 60 mins##
copy(SELECT j.NUMBER, j.ZCTA_PICKUP, 
j.Pickup_Datetime, 
concat_ws(':', substring(date_trunc('hour',pickup_datetime)::text from 0 for 14), LPAD((extract(minute FROM pickup_datetime)::int / 5 * 5)::text ,2,'0'),'00') AS PICKUP_5, COUNT(NUMBER) OVER ( PARTITION BY ZCTA_PICKUP,date_trunc('hour',pickup_datetime), (extract(minute FROM pickup_datetime)::int / 5 * 5)) AS COUNT_P_5,
concat_ws(':', substring(date_trunc('hour',pickup_datetime)::text  from 0 for 14), LPAD((extract(minute FROM pickup_datetime)::int / 15 * 15)::text ,2,'0'),'00') AS PICKUP_15, COUNT(NUMBER) OVER ( PARTITION BY ZCTA_PICKUP,date_trunc('hour',pickup_datetime), (extract(minute FROM pickup_datetime)::int / 15 * 15)) AS COUNT_P_15,
concat_ws(':', substring(date_trunc('hour',pickup_datetime)::text  from 0 for 14), LPAD((extract(minute FROM pickup_datetime)::int / 30 * 30)::text ,2,'0'),'00') AS PICKUP_30, COUNT(NUMBER) OVER ( PARTITION BY ZCTA_PICKUP,date_trunc('hour',pickup_datetime), (extract(minute FROM pickup_datetime)::int / 30 * 30)) AS COUNT_P_30,
date_trunc('hour',pickup_datetime) AS PICKUP_HOUR, COUNT(NUMBER) OVER ( PARTITION BY ZCTA_PICKUP,date_trunc('hour',pickup_datetime)) AS COUNT_P_HOUR,
j.ZCTA_DROPOFF,
j.Dropoff_Datetime, 
concat_ws(':', substring(date_trunc('hour',Dropoff_Datetime)::text  from 0 for 14), LPAD((extract(minute FROM Dropoff_Datetime)::int / 5 * 5)::text ,2,'0'),'00') AS DROP_5, COUNT(NUMBER) OVER ( PARTITION BY ZCTA_DROPOFF,date_trunc('hour',Dropoff_Datetime), (extract(minute FROM Dropoff_Datetime)::int / 5 * 5)) AS COUNT_D_5,
concat_ws(':', substring(date_trunc('hour',Dropoff_Datetime)::text  from 0 for 14), LPAD((extract(minute FROM Dropoff_Datetime)::int / 15 * 15)::text ,2,'0'),'00') AS DROP_15, COUNT(NUMBER) OVER ( PARTITION BY ZCTA_DROPOFF,date_trunc('hour',Dropoff_Datetime), (extract(minute FROM Dropoff_Datetime)::int / 15 * 15)) AS COUNT_D_15,
concat_ws(':', substring(date_trunc('hour',Dropoff_Datetime)::text  from 0 for 14), LPAD((extract(minute FROM Dropoff_Datetime)::int / 30 * 30)::text ,2,'0'),'00') AS DROP_30, COUNT(NUMBER) OVER ( PARTITION BY ZCTA_DROPOFF,date_trunc('hour',Dropoff_Datetime), (extract(minute FROM Dropoff_Datetime)::int / 30 * 30)) AS COUNT_D_30,
date_trunc('hour',Dropoff_Datetime) AS DROP_HOUR, COUNT(NUMBER) OVER ( PARTITION BY ZCTA_DROPOFF,date_trunc('hour',Dropoff_Datetime)) AS COUNT_D_HOUR,
j.Passenger_Count, j.Trip_Distance, j.Pickup_Longitude, j.Pickup_Latitude, j.Dropoff_Longitude, j.Dropoff_Latitude
FROM nyc_trip_zip j) to '/data/postgresql/fullest_zip.csv' With CSV;


## N enregistrer que les que les parcours pour lesquels au minimum 10 sont partis à un même moment (idem pour l arrivée)""
copy(SELECT ZCTA_PICKUP, Pickup_Datetime , Pickup_30 , Count_P_30, ZCTA_DROPOFF ,Dropoff_Datetime ,Dropoff_30, Count_D_30
FROM nyc_trip_full
WHERE ZCTA_PICKUP *ZCTA_DROPOFF != 0 AND Count_P_30 > 10 AND Count_D_30 > 10) to '/data/postgresql/nyc_trip_k_10_30.csv' With CSV;

SELECT j.NUMBER, j.Pickup_Datetime, j.Dropoff_Datetime, j.Passenger_Count, j.Trip_Time, j.Trip_Distance, j.Pickup_Longitude, j.Pickup_Latitude, j.Dropoff_Longitude, j.Dropoff_Latitude, j.ZCTA_PICKUP, j.ZCTA_DROPOFF,concat_ws(':', date_trunc('hour',pickup_datetime), (extract(minute FROM pickup_datetime)::int / 15 * 15)),(SELECT COUNT(NUMBER) FROM nyc_trip_anonymized i WHERE i.NUMBER = j.NUMBER GROUP BY ZCTA_PICKUP,date_trunc('hour',pickup_datetime), (extract(minute FROM pickup_datetime)::int / 10 * 10) ORDER BY COUNT(NUMBER))
FROM nyc_trip_anonymized j
WHERE j.NUMBER < 50

SELECT j.NUMBER, j.Pickup_Datetime, j.Dropoff_Datetime, j.Passenger_Count, j.Trip_Time, j.Trip_Distance, j.Pickup_Longitude, j.Pickup_Latitude, j.Dropoff_Longitude, j.Dropoff_Latitude, j.ZCTA_PICKUP, j.ZCTA_DROPOFF,concat_ws(':', date_trunc('hour',pickup_datetime), (extract(minute FROM pickup_datetime)::int / 15 * 15))
FROM nyc_trip_anonymized j
WHERE j.NUMBER < 50


create table nyc_trip_full ( NUMBER bigint, ZCTA_PICKUP integer, Pickup_Datetime timestamp, Pickup_5 timestamp, Count_P_5 integer, Pickup_15 timestamp,Count_P_15 integer, Pickup_30 timestamp,Count_P_30 integer,  Pickup_60 timestamp,Count_P_60 integer, ZCTA_DROPOFF integer,Dropoff_Datetime timestamp,Dropoff_5 timestamp, Count_D_5 integer, Dropoff_15 timestamp,Count_D_15 integer, Dropoff_30 timestamp,Count_D_30 integer,  Dropoff_60 timestamp,Count_D_60 integer, Passenger_Count smallint, Trip_Time integer, Trip_Distance double precision,Pickup_Longitude float, Pickup_Latitude float, Dropoff_Longitude float,Dropoff_Latitude float);




COPY nyc_trip_full FROM '/tmp/full_sql_test.csv' DELIMITER ',' CSV;
create table nyc_trip_zip (NUMBER bigint, Pickup_Datetime timestamp, Dropoff_Datetime timestamp, Passenger_Count smallint, Trip_Distance double precision, Pickup_Longitude float, Pickup_Latitude float, Dropoff_Longitude float, Dropoff_Latitude float, ZCTA_PICKUP char(5), ZCTA_DROPOFF char(5));


