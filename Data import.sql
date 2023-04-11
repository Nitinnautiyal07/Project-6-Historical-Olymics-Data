create table athlete_events2(
ID int,`Name` varchar(300),Sex varchar(10),
Age int,Height int,Weight int,
Team varchar(300),NOC varchar(300),Games varchar(300),
`Year` int,Season varchar(300),City varchar(300),
Sport varchar(300),`Event` varchar(300),Medal varchar(300)
);
load data  infile "F:\athlete_events.csv"  into table athlete_events2
FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\'
lines terminated by '\r\n'
ignore 1 lines
(ID,`Name`,Sex,Age,Height,Weight,Team,NOC,Games,`Year`,Season,City,Sport,`Event`,Medal);
drop table athlete_events

