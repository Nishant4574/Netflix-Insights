-- Netfilx Project
Drop table netfilx
create table netflix(
show_id varchar(6),
type varchar(10),
title varchar(150),
director varchar(210),
casts varchar(1000),
country	varchar(150),
date_added varchar(50),
release_year int,
rating varchar(10),
duration varchar(15),
listed_in varchar(100),
description varchar(300)
);
select *from netflix
select count(*)from netflix
select Distinct type as om from netflix

-- 15 Business Problem

--1. Count the number of Movies vs TV show

select type,count(*)from netflix group by type

--2.Find the most common rating for movies and TV shows

select type,rating from
(select type,rating, count(*),Rank()Over(Partition by type order by Count(*) desc)as ranking
from netflix group by  1,2) as t1 where ranking=1;  

--3. List all movies relased in specific year (eg 2020)

select * from netflix where type= 'Movie' and release_year='2020';

--4. Find the top 5 countries with the most content on Netflix

select unnest(String_to_array(country,',')),count(show_id) from netflix group by 1 order by 2 desc

--5.Identify the longest movie

select *from netflix where type= 'Movie'and duration=(select max(duration) from netflix)

-- 6. Find contents added in the last 5 years

select *
from netflix 
where to_date(date_added,'Month DD,YYYY') >= current_date - interval'5 years'


--7 Find all the movies/TV shows director "Rajiv Chilaka"

select * from netflix where director='Rajiv Chilaka'

--8. List all TV shows with more than 5 season

select * ,split_part(duration,' ',1) as sessions
from netflix where type='TV Show'and split_part(duration,' ',1)::numeric> 5

--9. Count the number of content item in each listed_in

select 
unnest(String_To_array(listed_in,',')),
count(*) as total
from netflix
group by 1

-- 10. Find each year and the average number of content releae by India on Netflix.
-- return too 5 year with highest avg content released

select
Extract(Year From To_Date(date_added,'Month DD,YYYY'))as date,
count(*) as yearly_content,
count(*)::numeric/(select count(*)from netflix where country='India')::numeric*100 as avg

from netflix
where country='India'
group by 1

-- 11. Lsit all movies that are documentaries

select * from netflix
where listed_in ='Documentaries'

-- 12. Find all the content without director

select * from netflix where director is null


--13. Find how many movies actor 'Salman Khan' appeared in last 10 years

select * from netflix
where casts Ilike '%Salman Khan%'
and release_year > Extract(Year from current_date)-10

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India

select
unnest(String_To_Array(casts,',')),count(*)
from netflix
where country='India'
group by 1 order by 2 desc
Limit 10

--15.Categorized the content based on the presence of the keyword 'kill'
-- and 'violence' in the description field. Label content containing these keywords as 'Bad'
-- and all other content as 'Good' Count how many items fall into each category.

with new_table
as(
select  *,
case when description Ilike '%Kill%'or description Ilike '%violence%'
then 'Bad_Content' else 'Good_Content'
END Category
 from netflix
)
select category,count(*)from new_table group by 1