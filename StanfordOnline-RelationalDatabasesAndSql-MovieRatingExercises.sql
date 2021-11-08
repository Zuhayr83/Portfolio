-- Find the titles of all movies directed by Steven Spielberg.
SELECT m.title from Movie as m where m.director = "Steven Spielberg"

-- Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order.
SELECT distinct mov.year 
from Movie as mov, Rating as rate 
where mov.mID = rate.mID and rate.stars >= 4
order by mov.year asc;

-- Find the titles of all movies that have no ratings.
select distinct Movie.title from Movie
where Movie.title not in 
(select distinct m.title from Movie as m, Rating as r 
where m.mID = r.mID)

-- Some reviewers didn't provide a date with their rating. 
-- Find the names of all reviewers who have ratings with a NULL value for the date.
select re.name from Reviewer as re 
where re.rID in (select distinct r.rID from Rating as r
where r.ratingDate is NULL);

-- Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. 
-- Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars.
select c.name, m.title, c.stars, c.ratingDate from 
	(Reviewer join Rating on Reviewer.rID = Rating.rID) as c 
	join Movie as m on c.mID = m.mID
order by c.name, m.title, c.stars;

-- For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie.
select name, title from 
	Movie as m 
	join Rating as r1 using (mID)
	join Rating as r2 using (rID)
	join Reviewer as re using (rID)
where r2.mID = r1.mID and r2.ratingDate > r1.ratingDate
			   and r2.stars > r1.stars;

-- For each movie that has at least one rating, find the highest number of stars that movie received. 
-- Return the movie title and number of stars. Sort by movie title.
select distinct title, MAX(stars)
from Movie join Rating using (mID) 
group by mID
having count(mID) >= 1
order by title;

-- For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. 
-- Sort by rating spread from highest to lowest, then by movie title.
select distinct title, MAX(stars) - MIN(stars) as a
from Movie join Rating using (mID) 
group by mID
having count(mID) >= 1
order by a desc, title;

-- Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. 
-- (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. 
-- Don't just calculate the overall average rating before and after 1980.)
select AVG(before.avg) - AVG(after.avg)
from (select AVG(stars) as avg 
	  from Movie join Rating using (mID) 
	  where Movie.year > 1980
	  group by mID) as after,
	  (select AVG(stars) as avg 
	  from Movie join Rating using (mID) 
	  where Movie.year < 1980
	  group by mID) as before

-- Find the names of all reviewers who rated Gone with the Wind.
select re.name from Reviewer as re where re.rID in 
(select r.rID from Rating as r, Movie as m 
where r.mID = m.mID and r.mID = 101);

--For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars.
select re.name, m.title, r.stars from Reviewer as re,
Rating as r, Movie as m 
where re.rID = r.rID and r.mID = m.mID and m.director = re.name;

-- Return all reviewer names and movie names together in a single list, alphabetized. 
-- (Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".)
select re.name from Reviewer as re 
union 
select m.title from Movie as m 
order by re.name, m.title;

-- Find the titles of all movies not reviewed by Chris Jackson.
select m.title from Movie as m where title not in
(select m.title from Movie as m, Rating as r where
 m.mID = r.mID and r.rID = 205);

 -- For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. 
 -- Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. 
 -- For each pair, return the names in the pair in alphabetical order.
 SELECT DISTINCT Re1.name, Re2.name
FROM Rating R1, Rating R2, Reviewer Re1, Reviewer Re2
WHERE R1.mID = R2.mID
AND R1.rID = Re1.rID
AND R2.rID = Re2.rID
AND Re1.name < Re2.name
ORDER BY Re1.name, Re2.name;

-- For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars.
select name, title, stars from Movie 
inner join Rating using (mID)
inner join Reviewer using (rID)
where stars in (select MIN(stars) from Rating);

-- List movie titles and average ratings, from highest-rated to lowest-rated. If two or more movies have the same average rating, list them in alphabetical order.
select title, AVG(stars) from Movie
inner join Rating using (mID)
group by mID
order by AVG(stars) desc, title

-- Find the names of all reviewers who have contributed three or more ratings. 
select re.name from Reviewer as re 
inner join Rating as r using (rID)
group by rID
having COUNT(rID) >= 3;

-- Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. 
-- Sort by director name, then movie title.
select m1.title, director from Movie as m1
join Movie as m2 using (director)
group by m1.mID
having COUNT(*) > 1
order by director, m1.title;

-- Find the movie(s) with the highest average rating. Return the movie title(s) and average rating.
select title, AVG(stars) as average 
from Movie join Rating using (mID)
group by mID
having average in (
select MAX(avg_stars) from (
(select AVG(stars) as avg_stars 
from Rating 
group by mID)));

--Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating.
select title, AVG(stars) as average 
from Movie join Rating using (mID)
group by mID
having average in (
select MIN(avg_stars) from (
(select AVG(stars) as avg_stars 
from Rating 
group by mID)));

--For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, and the value of that rating. 
-- Ignore movies whose director is NULL.
select director, title, MAX(stars) as highest
from Movie join Rating using (mID)
where director is NOT NULL 
group by director;