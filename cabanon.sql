
(pas de sujet)
TOUBIANA Vincent
jeu. 29/12/2016 10:37
Inbox; Sent Items
À :
TOUBIANA Vincent;
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
FROM nyc_trip_zip j) to '/data/CabAnon/Intermediate/PSQL_OUTPUT/fullest_zip.csv' With CSV;
 
create table nyc_trip_full ( NUMBER bigint, ZCTA_PICKUP char(5), Pickup_Datetime timestamp, Pickup_5 timestamp, Count_P_5 integer, Pickup_15 timestamp,Count_P_15 integer, Pickup_30 timestamp,Count_P_30 integer,  Pickup_60 timestamp,Count_P_60 integer, ZCTA_DROPOFF char(5),Dropoff_Datetime timestamp,Dropoff_5 timestamp, Count_D_5 integer, Dropoff_15 timestamp,Count_D_15 integer, Dropoff_30 timestamp,Count_D_30 integer,  Dropoff_60 timestamp,Count_D_60 integer, Passenger_Count smallint, Trip_Distance double precision,Pickup_Longitude float, Pickup_Latitude float, Dropoff_Longitude float,Dropoff_Latitude float);
 
COPY nyc_trip_full FROM '/data/CabAnon/Intermediate/PSQL_OUTPUT/fullest_zip.csv' DELIMITER ',' CSV;
 
## N enregistrer que les que les parcours pour lesquels au minimum 10 sont partis à un même moment (idem pour l arrivée)""
copy(SELECT ZCTA_PICKUP, Pickup_5, Count_P_5 , ZCTA_DROPOFF, Dropoff_5, Count_D_5, Passenger_Count, Trip_Distance
FROM nyc_trip_full
WHERE ZCTA_PICKUP!= 'NA' AND ZCTA_DROPOFF != 'NA' AND Count_P_5 > 10 AND Count_D_5 > 10 AND  (ZCTA_PICKUP, Pickup_5 , ZCTA_DROPOFF, Dropoff_5) IN 
(SELECT ZCTA_PICKUP, Pickup_5 , ZCTA_DROPOFF, Dropoff_5 FROM nyc_trip_full j GROUP BY j.ZCTA_PICKUP, j.Pickup_5 , j.ZCTA_DROPOFF, j.Dropoff_5 HAVING count(NUMBER) >2)
ORDER BY Pickup_Datetime) to '/data/CabAnon/Intermediate/PSQL_OUTPUT/nyc_trip_k_10_5_l_2_sorted.csv' DELIMITER ',' CSV HEADER;


create table nyc_trip_zip_k_10_5_l_2 ( ZCTA_PICKUP char(5),  Pickup_5 timestamp, Count_P_5 integer, ZCTA_DROPOFF char(5),Dropoff_5 timestamp,Count_D_5 integer, Passenger_Count smallint, Trip_Distance double precision);


COPY nyc_trip_zip_k_10_5_l_2 FROM '/data/CabAnon/Intermediate/PSQL_OUTPUT/nyc_trip_k_10_5_l_2_sorted.csv' DELIMITER ',' CSV HEADER;

copy(SELECT ZCTA_PICKUP, Pickup_5 , ZCTA_DROPOFF,Dropoff_5, Passenger_Count,Trip_Distance
FROM nyc_trip_zip_k_10_5_l_2
WHERE '2013-01-01 00:00:00' <= Pickup_5 AND Pickup_5 < '2013-01-01 00:30:00') to '/data/CabAnon/Intermediate/PSQL_OUTPUT/k_10_5_l_2_date_01_01_13_00:00.csv' DELIMITER ',' CSV HEADER;


for i in `seq 0 23`; do sudo -u postgres psql -c "copy(SELECT ZCTA_PICKUP, Pickup_5 , ZCTA_DROPOFF,Dropoff_5, Passenger_Count,Trip_Distance
FROM nyc_trip_zip_k_10_5_l_2
WHERE '2013-01-01 0"$i":00:00' <= Pickup_5 AND Pickup_5 < '2013-01-01 0"$i":30:00') to '/data/CabAnon/Intermediate/PSQL_OUTPUT/k_10_5_l_2_date_01_01_13_0"$i":00.csv' DELIMITER ',' CSV HEADER;";
done;

for i in `seq 10 23`; do sudo -u postgres psql -c "copy(SELECT ZCTA_PICKUP, Pickup_5 , ZCTA_DROPOFF,Dropoff_5, Passenger_Count,Trip_Distance
FROM nyc_trip_zip_k_10_5_l_2
WHERE '2013-01-01 "$i":00:00' <= Pickup_5 AND Pickup_5 < '2013-01-01 "$i":30:00') to '/data/CabAnon/Intermediate/PSQL_OUTPUT/k_10_5_l_2_date_01_01_13_0"$i":00.csv' DELIMITER ',' CSV HEADER;";
done;

####### Get column for anonymized dataset ###########

for i in `seq 0 23`; do j=$((i+1)); sudo -u postgres psql -c "copy(SELECT ZCTA_PICKUP, Pickup_5 , ZCTA_DROPOFF,Dropoff_5, Passenger_Count,Trip_Distance
FROM nyc_trip_zip_k_10_5_l_2
WHERE '2013-01-01 0"$i":00:00' <= Pickup_5 AND Pickup_5 < '2013-01-01 0"$i":30:00') to '/data/CabAnon/Intermediate/PSQL_OUTPUT/k_10_5_l_2_date_01_01_13_"$i":00.csv' DELIMITER ',' CSV HEADER;";
done;


for i in `seq 0 23`; do j=$((i+1)); sudo -u postgres psql -c "copy(SELECT ZCTA_PICKUP, Pickup_5, ZCTA_DROPOFF, Dropoff_5 
FROM nyc_trip_zip_k_10_5_l_2
WHERE '2013-01-01 0"$i":30:00' <= Pickup_5 AND Pickup_5 < '2013-01-01 0"$j":00:00') to '/data/CabAnon/Intermediate/PSQL_OUTPUT/k_10_5_l_2_date_01_01_13_"$i":30.csv' DELIMITER ',' CSV HEADER;";
done;



####### Get all columns for anonymized dataset ###########

for i in `seq 0 23`; do j=$((i+1)); sudo -u postgres psql -c "copy(SELECT ZCTA_PICKUP, Pickup_5 , ZCTA_DROPOFF,Dropoff_5, Passenger_Count,Trip_Distance
FROM nyc_trip_zip_k_10_5_l_2
WHERE '2013-01-01 0"$i":00:00' <= Pickup_5 AND Pickup_5 < '2013-01-01 0"$i":30:00') to '/data/CabAnon/Intermediate/PSQL_OUTPUT/k_10_5_l_2_date_01_01_13_"$i":00.csv' DELIMITER ',' CSV HEADER;";
done;


for i in `seq 0 23`; do j=$((i+1)); sudo -u postgres psql -c "copy(SELECT ZCTA_PICKUP, Pickup_5 , ZCTA_DROPOFF,Dropoff_5, Passenger_Count,Trip_Distance
FROM nyc_trip_zip_k_10_5_l_2
WHERE '2013-01-01 0"$i":30:00' <= Pickup_5 AND Pickup_5 < '2013-01-01 0"$j":00:00') to '/data/CabAnon/Intermediate/PSQL_OUTPUT/k_10_5_l_2_date_01_01_13_"$i":30.csv' DELIMITER ',' CSV HEADER;";
done;

####### Get all columns for full dataset ###########

for i in `seq 0 23`; do j=$((i+1)); sudo -u postgres psql -c "copy(SELECT Pickup_Datetime, Pickup_Longitude , Pickup_Latitude, Dropoff_Datetime, Dropoff_Longitude, Dropoff_Latitude
FROM nyc_trip_full
WHERE '2013-01-01 0"$i":30:00' <= Pickup_Datetime AND Pickup_Datetime < '2013-01-01 0"$j":00:00') to '/data/CabAnon/Intermediate/PSQL_OUTPUT/full_date_01_01_13_"$i":30.csv' DELIMITER ',' CSV HEADER;";
done;

for i in `seq 0 23`; do j=$((i+1)); sudo -u postgres psql -c "copy(SELECT Pickup_Datetime, Pickup_Longitude , Pickup_Latitude, Dropoff_Datetime, Dropoff_Longitude, Dropoff_Latitude
FROM nyc_trip_full
WHERE '2013-01-01 0"$i":0:00' <= Pickup_Datetime AND Pickup_Datetime < '2013-01-01 0"$i":30:00') to '/data/CabAnon/Intermediate/PSQL_OUTPUT/full_date_01_01_13_"$i":00.csv' DELIMITER ',' CSV HEADER;";
done;


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
FROM nyc_trip_zoned j
WHERE j < 50) to '/data/postgresql/fullest_test_zone.csv' With CSV;



for i in `seq 1 12`; do sudo -u postgres psql -c "copy (SELECT j.NUMBER, j.ZONE_ID_PICKUP,
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
FROM nyc_trip_zoned_"$i" j
WHERE j.NUMBER < 50) to '/home/sei/CabAnon/Intermediate/fullest_test_zone"$i".csv' With CSV;";
done;
 

 
psql -c "SELECT j.NUMBER, j.ZONE_ID_PICKUP,
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
FROM nyc_trip_zoned j;"

create table nyc_trip_zoned_full (NUMBER bigint, ZONE_ID_PICKUP char(5), Pickup_Datetime timestamp, Pickup_5 timestamp, Count_P_5 integer, Pickup_15 timestamp,Count_P_15 integer, Pickup_30 timestamp,Count_P_30 integer,  Pickup_60 timestamp,Count_P_60 integer,ZONE_ID_DROPOFF char(5),Dropoff_Datetime timestamp,Dropoff_5 timestamp, Count_D_5 integer, Dropoff_15 timestamp,Count_D_15 integer, Dropoff_30 timestamp,Count_D_30 integer,  Dropoff_60 timestamp,Count_D_60 integer, Passenger_Count smallint, Trip_Distance double precision,ZONE_PICKUP char(70),ZONE_DROPOFF char(70),Pickup_Longitude float, Pickup_Latitude float, Dropoff_Longitude float,Dropoff_Latitude float);

for i in `seq 1 12`; do  sed 's/\,TRUE//g' fullest_test_zone$i.csv | sed 's/\"//g' | sudo -u postgres psql -c "COPY nyc_trip_zoned_full FROM stdin DELIMITER ',' CSV HEADER"; done

copy(SELECT ZONE_ID_PICKUP, ZONE_PICKUP, Pickup_Datetime , Pickup_5 ,Count_P_5, ZONE_ID_DROPOFF, ZONE_DROPOFF, Dropoff_Datetime ,Dropoff_5, Count_D_5, Passenger_Count,Trip_Distance
FROM nyc_trip_zoned_full
WHERE ZONE_ID_PICKUP!= 'NA' AND ZONE_ID_DROPOFF != 'NA' AND Count_P_5 > 10 AND Count_D_5 > 10 AND  (ZONE_ID_PICKUP, Pickup_5 , ZONE_ID_DROPOFF, Dropoff_5) IN 
(SELECT j.ZONE_ID_PICKUP, j.Pickup_5, j.ZONE_ID_DROPOFF, j.Dropoff_5 FROM nyc_trip_zoned_full j GROUP BY j.ZONE_ID_PICKUP, j.Pickup_5, j.ZONE_ID_DROPOFF, j.Dropoff_5 HAVING count(j.NUMBER) >1)
ORDER BY Pickup_Datetime) to '/home/sei/CabAnon/Intermediate/PSQL_OUTPUT/nyc_zone_k_10_5_l_2_sorted.csv' DELIMITER ',' CSV HEADER;


copy(SELECT ZONE_ID_PICKUP, ZONE_PICKUP, Pickup_Datetime , Pickup_5 ,Count_P_5, ZONE_ID_DROPOFF, ZONE_DROPOFF, Dropoff_Datetime ,Dropoff_5, Count_D_5, Passenger_Count,Trip_Distance
FROM nyc_trip_zoned_full
WHERE ZONE_ID_PICKUP!= 'NA' AND ZONE_ID_DROPOFF != 'NA' AND Count_P_5 > 10 AND Count_D_5 > 10 AND  (ZONE_ID_PICKUP, Pickup_5 , ZONE_ID_DROPOFF, Dropoff_5) IN 
(SELECT j.ZONE_ID_PICKUP, j.Pickup_5, j.ZONE_ID_DROPOFF, j.Dropoff_5 FROM nyc_trip_zoned_full j GROUP BY j.ZONE_ID_PICKUP, j.Pickup_5, j.ZONE_ID_DROPOFF, j.Dropoff_5 HAVING count(j.NUMBER) >1)
ORDER BY Pickup_Datetime) to '/home/sei/CabAnon/Intermediate/PSQL_OUTPUT/nyc_zone_k_10_5_l_2_sorted.csv' DELIMITER ',' CSV HEADER;

copy(SELECT ZONE_ID_PICKUP, ZONE_PICKUP, Pickup_Datetime , Pickup_5 ,Count_P_5, ZONE_ID_DROPOFF, ZONE_DROPOFF, Dropoff_Datetime ,Dropoff_5, Count_D_5, Passenger_Count,Trip_Distance
FROM nyc_zone_k_10_5
WHERE ZONE_ID_PICKUP!= 'NA' AN
ORDER BY Pickup_Datetime) to '/home/sei/CabAnon/Intermediate/PSQL_OUTPUT/nyc_zone_k_10_5_sorted.csv' DELIMITER ',' CSV HEADER;

Creer les fichier csv taxiwi_zip a en utilisant anonymize_trip.R

##Créer la table des zip codes
create table nyc_trip_zip (NUMBER bigint, Pickup_Datetime timestamp, Dropoff_Datetime timestamp, Passenger_Count smallint, Trip_Distance double precision, Pickup_Longitude float, Pickup_Latitude float, Dropoff_Longitude float, Dropoff_Latitude float, ZCTA_PICKUP char(5), ZCTA_DROPOFF char(5));
#cat taxi_with_zip-*.csv | psql -c 'COPY nyc_trip_zip FROM stdin CSV HEADER'
for i in `seq 1 12`; do  sed 's/\,TRUE//g' taxi_with_zip_$i.csv | sed 's/\"//g' | sudo -u postgres psql -c "COPY nyc_trip_zip FROM stdin DELIMITER ',' CSV HEADER"; done
 
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
FROM nyc_trip_zip j) to '/data/CabAnon/Intermediate/PSQL_OUTPUT/fullest_zip.csv' With CSV;



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
FROM nyc_trip_zip j
WHERE j < 500) to '/data/REBU/PSQL_Output/fullest_zip.csv' With CSV;


## N enregistrer que les que les parcours pour lesquels au minimum 10 sont partis à un même moment (idem pour l arrivée)""
copy(SELECT ZCTA_PICKUP, Pickup_Datetime , Pickup_30 , Count_P_30, ZCTA_DROPOFF ,Dropoff_Datetime ,Dropoff_30, Count_D_30
FROM nyc_trip_full
WHERE ZCTA_PICKUP *ZCTA_DROPOFF != 0 AND Count_P_30 > 10 AND Count_D_30 > 10
ORDER BY Pickup_Datetime) to '/data/REBU/PSQL_Output/nyc_trip_k_10_30_sorted.csv' With CSV;

## N enregistrer que les que les parcours pour lesquels au minimum 10 sont partis à un même moment (idem pour l arrivée)""
copy(SELECT ZCTA_PICKUP, Pickup_Datetime , Pickup_5 , ZCTA_DROPOFF, Dropoff_Datetime ,Dropoff_5, Passenger_Count,Trip_Distance
FROM nyc_trip_full
WHERE ZCTA_PICKUP!= 'NA' AND ZCTA_DROPOFF != 'NA' AND Count_P_5 > 10 AND Count_D_5 > 10 AND  (ZCTA_PICKUP, Pickup_5 , ZCTA_DROPOFF, Dropoff_5) IN 
(SELECT ZCTA_PICKUP, Pickup_5 , ZCTA_DROPOFF, Dropoff_5 FROM nyc_trip_full GROUP BY (ZCTA_PICKUP, Pickup_5 , ZCTA_DROPOFF, Dropoff_5) HAVING count(NUMBER) >2)
ORDER BY Pickup_Datetime) to '/data/REBU/PSQL_Output/nyc_trip_k_10_5_l_2_sorted.csv' DELIMITER ',' CSV HEADER;
 
SELECT j.NUMBER, j.Pickup_Datetime, j.Dropoff_Datetime, j.Passenger_Count, j.Trip_Time, j.Trip_Distance, j.Pickup_Longitude, j.Pickup_Latitude, j.Dropoff_Longitude, j.Dropoff_Latitude, j.ZCTA_PICKUP, j.ZCTA_DROPOFF,concat_ws(':', date_trunc('hour',pickup_datetime), (extract(minute FROM pickup_datetime)::int / 15 * 15)),(SELECT COUNT(NUMBER) FROM nyc_trip_anonymized i WHERE i.NUMBER = j.NUMBER GROUP BY ZCTA_PICKUP,date_trunc('hour',pickup_datetime), (extract(minute FROM pickup_datetime)::int / 10 * 10) ORDER BY COUNT(NUMBER))
FROM nyc_trip_anonymized j
WHERE j.NUMBER < 50
 
SELECT j.NUMBER, j.Pickup_Datetime, j.Dropoff_Datetime, j.Passenger_Count, j.Trip_Time, j.Trip_Distance, j.Pickup_Longitude, j.Pickup_Latitude, j.Dropoff_Longitude, j.Dropoff_Latitude, j.ZCTA_PICKUP, j.ZCTA_DROPOFF,concat_ws(':', date_trunc('hour',pickup_datetime), (extract(minute FROM pickup_datetime)::int / 15 * 15))
FROM nyc_trip_anonymized j
WHERE j.NUMBER < 50
 
 
create table nyc_trip_full ( NUMBER bigint, ZCTA_PICKUP char(5), Pickup_Datetime timestamp, Pickup_5 timestamp, Count_P_5 integer, Pickup_15 timestamp,Count_P_15 integer, Pickup_30 timestamp,Count_P_30 integer,  Pickup_60 timestamp,Count_P_60 integer, ZCTA_DROPOFF char(5),Dropoff_Datetime timestamp,Dropoff_5 timestamp, Count_D_5 integer, Dropoff_15 timestamp,Count_D_15 integer, Dropoff_30 timestamp,Count_D_30 integer,  Dropoff_60 timestamp,Count_D_60 integer, Passenger_Count smallint, Trip_Distance double precision,Pickup_Longitude float, Pickup_Latitude float, Dropoff_Longitude float,Dropoff_Latitude float);
 
 
 
 
COPY nyc_trip_full FROM '/data/REBU/PSQL_Output/fullest_zip.csv' DELIMITER ',' CSV;
create table nyc_trip_zip (NUMBER bigint, Pickup_Datetime timestamp, Dropoff_Datetime timestamp, Passenger_Count smallint, Trip_Distance double precision, Pickup_Longitude float, Pickup_Latitude float, Dropoff_Longitude float, Dropoff_Latitude float, ZCTA_PICKUP char(5), ZCTA_DROPOFF char(5));
