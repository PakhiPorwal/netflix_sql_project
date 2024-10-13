DROP TABLE IF EXISTS netflix;
create table netflix
(
	show_id	VARCHAR(6),
	type	VARCHAR(10),
	title	VARCHAR(150),
	director	VARCHAR(208),
	casts	VARCHAR(1000),
	country	VARCHAR(150),
	date_added	VARCHAR(50),
	release_year	INT,
	rating	VARCHAR(10),
	duration	VARCHAR(15),
	listed_in	VARCHAR(100),
	description VARCHAR(250)
);
-- (1) No. of movies vs TV Shows
SELECT COUNT(*) as No_of_Movies FROM netflix WHERE type='Movie';
SELECT COUNT(*) as No_of_TVshows FROM netflix WHERE type='TV Show';
--0r better way
Select type, COUNT(*) as total_content from netflix GROUP BY type

-- (2) Find most common rating for Movies & TV shows
SELECT type, rating FROM
( 
  SELECT type, rating, COUNT(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
	FROM netflix 
	GROUP BY type, rating
) as t1
WHERE ranking = 1

-- (3) List all movie released in a specific year
SELECT * FROM netflix
 WHERE type = 'Movie'
 AND release_year = '2020'


-- (4) Find top 5 countries with more content on Netflix

SELECT 
	UNNEST(STRING_TO_ARRAY(country,',')) as New_Country,
	Count(*) as Total_Content --Instead of *, any column like show_id, title can be used
FROM netflix 
GROUP BY 1
Order By 2 DESC
Limit 5;

-- (5) Identify the longest movie
SELECT title, MAX(duration)
FROM netflix
	WHERE type = 'Movie'
	GROUP BY 1
	ORDER BY 2 ASC

-- SELECT title, CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) AS duration_in_minutes
-- FROM netflix
-- WHERE type = 'Movie'
-- GROUP BY title
-- ORDER BY duration_in_minutes ASC;

-- (6) Find Content Added in the Last 5 Years

SELECT * FROM netflix
	WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - Interval '5 years'

-- (7) Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT * FROM netflix
	WHERE director ILIKE '%Rajiv Chilaka%'

-- 8. List All TV Shows with More Than 5 Seasons
--SELECT SPLIT_PART('Apple Banana Cherry', ' ', 4)

SELECT * FROM netflix
	WHERE type= 'TV Show'
	AND SPLIT_PART(duration, ' ', 1)::numeric > 5

--9. Count the Number of Content Items in Each Genre
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(show_id)
	FROM netflix
	GROUP BY 1

--10.Find each year and the average numbers of content release in India on netflix.
SELECT EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as new_year,
	COUNT(*) as yearly_content,
	ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric*100,2) as yearly_average
	FROM netflix
	WHERE country='India'
	GROUP BY 1
	ORDER BY yearly_average DESC
	LIMIT 5

--11. List All Movies that are Documentaries
SELECT * FROM netflix 
	WHERE listed_in ILIKE '%documentaries%'

--12. Find All Content Without a Director
SELECT * FROM netflix
	WHERE director IS null

--13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT * FROM netflix
	WHERE casts ILIKE '%Salman Khan%'
	AND release_year > EXTRACT(YEAR FROM CURRENT_DATE)-10

--14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT 
UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
COUNT (*) as total_content
FROM netflix WHERE country ILIKE '%india%'
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 10

--15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT category,
	COUNT(*) as content_count
	FROM
	(SELECT *, 
	CASE 
		WHEN description ILIKE '% KIll%' OR
		description ILIKE '%Violence%'
		THEN 'Bad_Content'
		ELSE 'Good_Content'
	END category 
	FROM netflix 
	) as Categorized_Content
GROUP BY category

