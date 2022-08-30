select * from project.dbo.Data1;

select * from project.dbo.Data2;

-- number of rows into our dataset

select count(*) from project..Data1;
select count(*) from project..Data2;

-- data set for jharkhand and bihar
select * from project..Data1 where state in ('Jharkhand' , 'Bihar'); 

-- population of india 
select sum(population) as Population from project..Data2;

-- Average growth percentage of country
select avg(growth)*100 as avg_growth from project..Data1;

-- Average growth percentage by state
select state,avg(growth)*100 as avg_growth from project..Data1 group by state;

-- Average sex ratio
select state,round(avg(Sex_Ratio) , 0) as avg_Sex_Ratio from project..Data1 group by state order by avg_Sex_Ratio desc;

-- Average literacy rate 
select state,round(avg(Literacy) , 0) as avg_Literacy from project..Data1 
group by state 
having round(avg(Literacy) , 0) > 90
order by avg_Literacy desc;

-- top 3 state showing highest growth ratio
select top 3 state,avg(growth)*100 as avg_growth from project..Data1 group by state order by avg_growth desc;

-- Bottom 3 state showing lowest growth ratio
select top 3 state,avg(growth)*100 as avg_growth from project..Data1 group by state order by avg_growth;

-- Bottom 3 sex Ratio
select top 3 state,round(avg(Sex_Ratio) , 0) as avg_Sex_Ratio from project..Data1 group by state order by avg_Sex_Ratio ;

-- top and bottom 3 state of literacy rate

drop table if exists #topstates;
create table #topstates
( state nvarchar(225),
topstate float

)

insert into #topstates
select state,round(avg(literacy) , 0) as avg_Literacy from project..Data1 
group by state order by avg_Literacy desc;

select top 3 * from #topstates order by #topstates.topstate desc;

drop table if exists #Bottomstates;
create table #Bottomstates
( state nvarchar(225),
Bottomstate float

)

insert into #Bottomstates
select state,round(avg(literacy) , 0) as avg_Literacy from project..Data1 
group by state order by avg_Literacy ;

select top 3 * from #Bottomstates order by #Bottomstates.Bottomstate ;


-- union operator to join two tables

select * from(
select top 3 * from #topstates order by #topstates.topstate desc) a

union

select * from(
select top 3 * from #Bottomstates order by #Bottomstates.Bottomstate) b ;

-- states strating with letter a
select distinct state from project..data1 where lower(state) like 'a%' or lower(state) like 'b%'

select distinct state from project..data1 where lower(state) like 'a%' and lower(state) like '%m'

-- joining both table

-- Total Males and Females

select D.State , sum(D.Males) Total_Males , sum(D.Females) Total_Females from 
(select C.District , C.State ,
 round((C.Population/(C.Sex_Ratio + 1)),0) as Males, 
 round(((C.Population * (C.Sex_Ratio))/(C.Sex_Ratio + 1)),0) as Females 
 from 
 (select A.District , A.State , A.Sex_Ratio/1000 as Sex_Ratio, B.Population 
  from 
  project..Data1 as A inner join project..Data2 as B 
  on A.District=B.District) as C) as D
group by D.State 


-- Total literacy rates

select D.State , sum(Literate_people) as Total_Literate_people , sum(Illiterate_people) as Total_Illiterate_people from 
(select C.District , C.State , round((C.Literacy_ratio * C.Population),0) as Literate_people , round((( 1 - C.Literacy_ratio)* C.Population),0) as Illiterate_people from 
(select A.District , A.State , A.Literacy/100 as Literacy_ratio, B.Population 
  from 
  project..Data1 as A inner join project..Data2 as B 
  on A.District=B.District) as C) as D
  group by D.State

-- population in previous cenaus
select sum(E.previous_census_population) , sum(E.Current_census_population) from
(select D.State ,sum(D.previous_census_population) previous_census_population, sum(D.Current_census_population) Current_census_population from
(select C.District , C.State ,round(( C.Population/(1+C.Growth)),0) previous_census_population, C.Population Current_census_population from
(select A.District , A.State , A.Growth/100 as Growth , B.Population 
  from 
  project..Data1 as A inner join project..Data2 as B 
  on A.District=B.District) as C) as D 
  group by D.State) as E



-- Population per area
select I.total_area/I.previous_census_population previous_census_population, I.total_area/I.current_census_population current_census_population from
(select G.* , H.total_area from
(select'1' as keyy,F.* from
(select sum(E.previous_census_population) previous_census_population , sum(E.current_census_population) current_census_population from
(select D.State, sum(D.previous_census_population) previous_census_population , sum(D.current_census_population) current_census_population from
(select C.District , C.State ,round((C.Population/(1 + C.Growth)),0) previous_census_population , Population current_census_population from
(select A.District , A.State , A.Growth Growth , B.Population 
  from 
  project..Data1 as A inner join project..Data2 as B 
  on A.District=B.District) C ) D
  group by D.State) E) F) G inner join 

(select '1' as keyy,Z.* from 
(select sum(Area_km2) total_area from project..Data2 ) Z ) H on G.keyy = H.keyy) I


--window
-- top 3 districts from each states with highest literacy rates
select A.* from
(select district, state , literacy, rank() over(partition by state order by literacy desc) rnk from project..data1) A
where A.rnk in (1,2,3)
order by state