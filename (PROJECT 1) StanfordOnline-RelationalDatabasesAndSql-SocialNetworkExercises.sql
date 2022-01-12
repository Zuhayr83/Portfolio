-- Find the names of all students who are friends with someone named Gabriel.
select h.name from Highschooler as h where h.ID in
(select f.ID2 from Friend as f 
where f.ID1 in (select h.ID from Highschooler as h where
			   h.name = 'Gabriel'));

-- For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade, and the name and grade of the student they like.
select h1.name, h1.grade, h2.name, h2.grade 
from Highschooler as h1
join Likes as l ON h1.ID = l.ID1
join Highschooler as h2 ON h2.ID = l.ID2
where (h1.grade - h2.grade) >= 2;

-- For every pair of students who both like each other, return the name and grade of both students. 
-- Include each pair only once, with the two names in alphabetical order.
SELECT H1.name, H1.grade, H2.name, H2.grade
FROM Highschooler H1, Highschooler H2, Likes L1, Likes L2
WHERE (H1.ID = L1.ID1 AND H2.ID = L1.ID2) AND (H2.ID = L2.ID1 AND H1.ID = L2.ID2) AND H1.name < H2.name
ORDER BY H1.name, H2.name;

-- Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades.
-- Sort by grade, then by name within each grade.
select h.name, h.grade from Highschooler as h where h.ID not in 
(select h.ID from Highschooler as h, Likes as l 
where h.ID = l.ID1 or h.ID = l.ID2)
order by h.grade, h.name;

-- For every situation where student A likes student B, but we have no information about whom B likes (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades.
SELECT H1.name, H1.grade, H2.name, H2.grade
FROM Highschooler H1, Likes L, Highschooler H2
where H1.id = L.id1 and H2.id = L.id2 and H2.id not in
(select L.id1 from Likes as L);

-- Find names and grades of students who only have friends in the same grade. 
-- Return the result sorted by grade, then by name within each grade.
select h1.name, h1.grade from Highschooler
as h1 where h1.ID not in(
select h1.ID from Highschooler as h1, Friend as f, 
Highschooler as h2
where h1.ID = f.ID1 and h2.ID = f.ID2 and h1.grade <> h2.grade)
order by h1.grade, h1.name;

-- For each student A who likes a student B where the two are not friends, find if they have a friend C in common (who can introduce them!). 
--  For all such trios, return the name and grade of A, B, and C.
SELECT DISTINCT H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
FROM Highschooler H1, Likes, Highschooler H2, Highschooler H3,Friend F1,Friend F2
WHERE H1.ID = Likes.ID1 and Likes.ID2 = H2.ID and
  H2.ID not in (select ID2 from Friend where ID1 = H1.ID) and
  H1.ID = F1.ID1 and F1.ID2 = H3.ID and
  H3.ID = F2.ID1 and F2.ID2 = H2.ID;

-- Find the difference between the number of students in the school and the number of different first names.
select st.sNum-nm.nNum from 
(select count(*) as sNum from Highschooler) as st,
(select count(distinct name) as nNum from Highschooler) as nm;

-- Find the name and grade of all students who are liked by more than one other student.
select h1.name, h1.grade from Highschooler as h1, Likes as l1 
where h1.ID = l1.ID2 
group by h1.ID
having COUNT(*) > 1;

-- For every situation where student A likes student B, but student B likes a different student C, return the names and grades of A, B, and C.
SELECT DISTINCT H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
FROM Highschooler H1, Likes l1, Highschooler H2, Highschooler H3, Likes l2
WHERE H1.ID in (select h1.ID from Highschooler as h1, Highschooler as h2,
				Likes as l1 where 
				h1.ID = l1.ID1 and h2.ID = l1.ID2)
and H2.ID in (select h2.ID from Highschooler as h2, Highschooler as h3,
				Likes as l1 where 
				h2.ID = l1.ID1 and h3.ID = l1.ID2)
and l1.ID1 = H1.ID and l1.ID2 = H2.ID and l2.ID1 = H2.ID and l2.ID2 = H3.ID
and l2.ID2 <> H1.ID;

-- Find those students for whom all of their friends are in different grades from themselves.
-- Return the students' names and grades.
select distinct h1.name, h1.grade from Highschooler h1 where
h1.name not in (select h1.name from Highschooler h1, Friend f, Highschooler h2
where h1.ID = f.ID1 and h2.ID = f.ID2 and h1.ID <> h2.ID 
and h1.grade = h2.grade);

-- What is the average number of friends per student? (Your result should be just one number.)
select AVG(avge) from(select COUNT(*) as avge from friend as f
group by ID1);

-- Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra. 
-- Do not count Cassandra, even though technically she is a friend of a friend.
SELECT COUNT(*)
FROM Friend
WHERE ID1 IN (
  SELECT ID2
  FROM Friend
  WHERE ID1 IN (
    SELECT ID
    FROM Highschooler
    WHERE name = 'Cassandra'
  )
);

-- It's time for the seniors to graduate. Remove all 12th graders from Highschooler.
delete from Highschooler as h where grade = 12;

-- If two students A and B are friends, and A likes B but not vice-versa, remove the Likes tuple.
delete from likes
where id1 in (select likes.id1 
              from friend join likes using (id1) 
              where friend.id2 = likes.id2) 
      and not id2 in (select likes.id1 
                      from friend join likes using (id1) 
                      where friend.id2 = likes.id2);

-- For all cases where A is friends with B, and B is friends with C, add a new friendship for the pair A and C. 
-- Do not add duplicate friendships, friendships that already exist, or friendships with oneself. 
-- (This one is a bit challenging; congratulations if you get it right.)
insert into friend
select f1.id1, f2.id2
from friend f1 join friend f2 on f1.id2 = f2.id1
where f1.id1 <> f2.id2
except
select * from friend



				
