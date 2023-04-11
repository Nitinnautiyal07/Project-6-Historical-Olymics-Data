create table athlete_events(
ID int,`Name` varchar(300),Sex varchar(10),
Age int,Height int,Weight int,
Team varchar(300),NOC varchar(300),Games varchar(300),
`Year` int,Season varchar(300),City varchar(300),
Sport varchar(300),`Event` varchar(300),Medal varchar(300)
);
load data  infile "F:\athlete_events.csv"  into table athlete_events
FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\'
lines terminated by '\r\n'
ignore 1 lines
(ID,`Name`,Sex,Age,Height,Weight,Team,NOC,Games,`Year`,Season,City,Sport,`Event`,Medal);


##1 How Many olympics games have been held?

select count(distinct(games)) as no_of_total_games_held from athlete_events;

##2 List down all Olympics games held so far.

Select distinct(games) as All_games_held from athlete_events;

##3 Mention the total no of nations who participated in each olympics game?

select games,count(distinct (team)) as total_participants from athlete_events
group by games;

##4 Which year saw the highest and lowest no of countries participating in olympics?

select * from (
select `year`,count(distinct(NOC)) as no_of_countries from athlete_events
group by `year`
order by no_of_countries asc limit 1
) a
UNION
select * from (
select `year`,count(distinct(NOC)) as no_of_countries  from athlete_events
group by `year`
order by no_of_countries desc limit 1
) b;

##5  Which nation has participated in all of the olympic games?

with Ttl_games as
(
select count(distinct(games)) as total_games from athlete_events 
),
countries as
(
select games, nr.region as country from athlete_events ae
join noc_regions nr
on nr.noc=ae.noc
group by games,country
),
countries_part as
(
select country,count(country) as total_games_participated from countries
group by country
)
select c.*
      from countries_part c
      join Ttl_games t
      on t.total_games = c.total_games_participated
     ;

##6  Identify the sport which was played in all summer olympics

with game as
(
select count(distinct(games)) as total_games_summer from athlete_events
where season ="Summer"
),
sport as
(
select distinct sport,games from athlete_events
where season ="Summer"
order by games
),
ABCD as
(
select sport,count(games) as total_games from sport
group by games
)
select * from ABCD a
join game g
on a.total_games=g.total_games_summer;

##7  Which Sports were just played only once in the olympics?

with CTE1 as
(
select distinct games,sport  from athlete_events
),
cte2 as
(
select sport,count(sport) as no_of_times_played from CTE1
group by sport
)
select cte2.*, CTE1.games from cte2
join CTE1
on CTE1.sport = cte2.sport
where cte2.no_of_times_played = 1
order by CTE1.sport;

##8  Fetch the total no of sports played in each olympic games

select Year,Games as olympic_games,count(distinct sport) as total_sports_played from athlete_events
group by olympic_games
order by year;

##9  Fetch details of the oldest athletes to win a gold medal

with medal as
(
select Name,Sex,Age,Height,Weight,Team,Games,Year,Season,City,Sport,Event,rank() over(order by age desc) as rnk from athlete_events
where Medal="Gold"
order by age 
)
select * from medal where rnk=1;

##10  Find the Ratio of male and female athletes participated in all olympic games?

With MF_ratio as
(
select * from 
(select count(sex) as total_males  from athlete_events where sex="M") m
cross join
(select count(sex) as total_females from athlete_events where sex="F") f
)
select total_males,total_females,round((total_males/total_females),1) as male_to_female_participation_ratio from MF_ratio;

##11  Fetch the top 5 athletes who have won the most gold medals

select Name,count(medal) as Goldmedal_won  from athlete_events 
where medal="Gold"
group by Name
order by Goldmedal_won desc limit 5;

#OR 

with CTE1 as
(
select Name,count(medal) as Goldmedal_won  from athlete_events 
where medal="Gold"
group by Name
),
cte2 as (
select *, dense_rank() over ( order by goldmedal_won desc) as rnk from cte1
)
select * from cte2 where rnk<6;

##12  Fetch the top 5 athletes who have won the most medals (gold/silver/bronze)

select team,name,count(medal) as medals_won from athlete_events
where medal in ("Gold","Silver","Bronze")
group by name,team
order by medals_won desc limit 5;

#OR 

with cte1 as(
select team,name,count(medal) as medals_won from athlete_events
where medal in ("Gold","SIlver","Bronze")
group by name
order by medals_won desc limit 5
),
cte2 as
( select *,dense_rank () over(order by medals_won desc) as rnk from cte1)
select team,name,medals_won from cte2
where rnk <6;


##13  Fetch the top 5 most successful countries in olympics, success is defined by no of medals won

with cte1 as
(
select NOC as country_code,count(medal) as medals_won from athlete_events
where medal in ("Gold","Silver","Bronze")
group by country_code
order by medals_won 
),
cte2 as (
select t.country_code,n.region as country_name,t.medals_won from cte1 t
join noc_regions n
on n.noc=t.country_code
)
select * from cte2
order by medals_won desc limit 5;

##14  List down total gold, silver and broze medals won by each country

with cte1 as
(
select A.country,A.Gold_medal_won,B.Silver_medal_won,C.Bronze_medal_won from (
select NOC as country,count(medal) as Gold_medal_won from athlete_events
where medal="Gold"
group by country) as A
join
(select NOC as country,count(medal) as Silver_medal_won from athlete_events
where medal="Silver"
group by country) as B
on A.country=B.Country
join (select NOC as country,count(medal) as Bronze_medal_won from athlete_events
where medal="Bronze"
group by country) as C
on B.country=C.country
),
region as(
select  q.region as Country_name,p.Gold_medal_won,p.Silver_medal_won,p.Bronze_medal_won from cte1 p
join noc_regions q
on q.NOC=p.country
group by country_name
)
select * from region;

##15  List down total gold, silver and broze medals won by each country corresponding to each olympic games

select A.country,A.Gold_medal_won,B.Silver_medal_won,C.Bronze_medal_won,A.Games from (
select team as country,Games,count(medal) as Gold_medal_won from athlete_events
where medal="Gold"
group by country,Games) as A
join
(select team as country,Games,count(medal) as Silver_medal_won from athlete_events
where medal="Silver"
group by country,Games) as B
on A.country=B.Country
join (select team as country,Games,count(medal) as Bronze_medal_won from athlete_events
where medal="Bronze"
group by country,Games) as C;

##16  Identify which country won the most gold, most silver and most bronze medals in each olympic games

select A.country,A.Gold_medal_won,B.Silver_medal_won,C.Bronze_medal_won from (
select team as country,count(medal) as Gold_medal_won from athlete_events
where medal="Gold"
group by country
order by Gold_medal_won desc limit 1) as A
join
(select team as country,count(medal) as Silver_medal_won from athlete_events
where medal="Silver"
group by country
order by Silver_medal_won desc limit 1) as B
on A.country=B.Country
join (select team as country,count(medal) as Bronze_medal_won from athlete_events
where medal="Bronze"
group by country
order by Bronze_medal_won desc limit 1) as C;

##17  Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games

with cte1 as (
select A.country_code,A.game,Gold_medal_won,Silver_medal_won,Bronze_medal_won from (
select NOC as country_code,games as game ,count(medal) as Gold_medal_won from athlete_events
where medal="Gold"
group by country_code) as A
join
(select NOC as country_code,games as game,count(medal) as Silver_medal_won from athlete_events
where medal="Silver"
group by country_code) as B
on A.country_code=B.Country_code
join (select NOC as country_code,games as game,count(medal) as Bronze_medal_won from athlete_events
where medal="Bronze"
group by country_code) as C
on B.country_code=C.country_code),
cte2 as
(
select country_code,k.region as country_name,game,Gold_medal_won,Silver_medal_won,Bronze_medal_won from cte1 a
join NOC_regions k
on a.country_code=k.noc
)
select *,sum(Gold_medal_won+Silver_medal_won+Bronze_medal_won) as total_medal_won from cte2
group by country_name,game
order by total_medal_won desc limit 1;

##18  Which countries have never won gold medal but have won silver/bronze medals?

with cte1 as
(
select NOC as country_code from athlete_events 
WHERE Medal <>"Gold"
AND Medal<>"NA"
),
cte2 as (
select t.country_code,n.region as country_name from cte1 t
join noc_regions n
on n.noc=t.country_code
)
select * from cte2;

##19  In which Sport/event, India has won highest medals

select NOC,sport,count(medal) as total_medals_won from athlete_events
where NOC="IND" AND
medal in ("Gold","Silver","Bronze")
group by NOC,sport
order by total_medals_won desc limit 1;

##20  Break down all olympic games where india won medal for Hockey and how many medals in each olympic games

select NOC,Games,count(medal) as total_medals_won from athlete_events
where NOC="IND" AND
Sport="Hockey" AND
medal != "NA"
group by NOC,Games
order by total_medals_won desc limit 1;
