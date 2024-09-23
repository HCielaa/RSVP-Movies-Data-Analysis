USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/

-- Segment 1:

-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:
SELECT (SELECT Count(*)
        FROM   director_mapping) AS Director_Mapping_Table,
       (SELECT Count(*)
        FROM   genre)            AS Genre_Table,
       (SELECT Count(*)
        FROM   movie)            AS moive_Table,
       (SELECT Count(*)
        FROM   names)            AS names_Table,
       (SELECT Count(*)
        FROM   ratings)          AS ratings_Table,
       (SELECT Count(*)
        FROM   role_mapping)     AS role_mapping_Table; 
        
#We are using this way of query and subquery to get detailed and accurate information for tables.
#We can also use Information_Schema.tables view which is quick but it only gives an estimated value not exact counts considering the tables are InnoDB tables.


-- Q2. Which columns in the movie table have null values?
-- Type your code below:

#running the below simple query we can explore the table a bit and find the columns which have null values
#from above we saw four columns country, worlwide_gross_income, langauges and production_company have null values
select *
from movie;

#From first overlook country, worlwide_gross_income, language and production_company seems to have null values
#To get exact null values for each column
SELECT Sum(Isnull(id))                    AS id_null_count,
       Sum(Isnull(title))                 AS title_null_count,
       Sum(Isnull(year))                  AS year_null_count,
       Sum(Isnull(duration))              AS duration_null_count,
       Sum(Isnull(date_published))        AS date_published_null_count,
       Sum(Isnull(country))               AS country_null_null_count,
       Sum(Isnull(worlwide_gross_income)) AS worlwide_gross_income_null_count,
       Sum(Isnull(languages))             AS languages_null_count,
       Sum(Isnull(production_company))    AS production_company_null_count
FROM   movie; 


-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+



Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

#Code for question 1 
SELECT Year,
       Count(id) AS number_of_movies
FROM   movie
GROUP  BY year; 

#code for question 2
SELECT Month(date_published) AS month_num,
       Count(id)             AS number_of_movies
FROM   movie
GROUP  BY month_num
ORDER  BY month_num; 

#Highest number of movies were produced in march month with a total of 824 movies

/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT Count(id) AS Total_Movie_Count_Year_2019
FROM   movie
WHERE  year = '2019'
       AND ( country LIKE '%USA%'
              OR country LIKE '%India%' ); #since some movies were released both in USA and India so using like. 

#USA and India released a total of 1059 movies in the year 2019

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:
SELECT DISTINCT genre AS Genre_Unique
FROM   genre; 

#Genre has around 13 unique genres

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:
SELECT genre,
       Count(id) AS total_movies
FROM   genre AS g
       INNER JOIN movie AS m
               ON g.movie_id = m.id
GROUP  BY genre
ORDER  BY total_movies DESC; 

#Drama genre has produced highest number of movies around 4285.

#For year 2019(last produced year) alone Drama genre produced around 1078 movies this was found using where clause like below:
SELECT genre,
       Count(id) AS total_movies
FROM   genre AS g
       INNER JOIN movie AS m
               ON g.movie_id = m.id
where year='2019'
GROUP  BY genre
ORDER  BY total_movies DESC; 


/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:

WITH movies_total
     AS (SELECT Count(movie_id) AS total_movie_count
         FROM   genre
         GROUP  BY movie_id
         HAVING total_movie_count = 1)
SELECT Count(total_movie_count) AS TotalMovies_1genre
FROM   movies_total;

#Out of 7997 movies, we have only 3289 movies that belong to only one genre

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)

/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT     genre,
           Round(Avg(duration),2) AS avg_duration 
FROM       genre
INNER JOIN movie
ON         movie_id=id
GROUP BY   genre
ORDER BY   avg_duration DESC;

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
WITH rank_genre
     AS (SELECT genre,
                Count(id)                          AS movie_count,
                Dense_rank()
                  OVER(
                    ORDER BY Count(movie_id) DESC) AS genre_rank
         FROM   genre
                INNER JOIN movie
                        ON movie_id = id
         GROUP  BY genre)
SELECT *
FROM   rank_genre
WHERE  genre = 'Thriller'; 
     
#From output we saw Thriller sits at rank 3 with total movies produced: 1484


/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/


-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:
SELECT Min(avg_rating)    AS min_avg_rating,
       Max(avg_rating)    AS max_avg_rating,
       Min(total_votes)   AS min_total_votes,
       Max(total_votes)   AS max_total_votes,
       Min(median_rating) AS min_median_rating,
       Max(median_rating) AS max_median_rating #Correction made here last two columns have min_median_rating so we are assuming last column is for max_median_rating
FROM   ratings; 

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too
SELECT     title,
           avg_rating,
           Dense_rank() OVER(ORDER BY avg_rating DESC) AS movie_rank
FROM       ratings                                     AS r
INNER JOIN movie                                       AS m
ON         r.movie_id=m.id limit 10;


/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!

Fan movie is indeed in top 10 movies list with average rating og 9.6 and carrying a rank of 4.

So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have
SELECT median_rating,
       Count(movie_id) AS movie_count
FROM   ratings
GROUP  BY median_rating
ORDER  BY movie_count DESC; 



/* Movies with a median rating of 7 is highest in number. 
Indeed this is true 7 median rating has a movie count of 2257.

Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:
SELECT     production_company,
           Count(id)                                   AS movie_count,
           Dense_rank() OVER (ORDER BY Count(id) DESC) AS prod_company_rank
FROM       movie                                       AS m
INNER JOIN ratings                                     AS r
ON         m.id=r.movie_id
WHERE      avg_rating>8
AND        production_company IS NOT NULL #we have put this clause because as observed during initial question we saw poroduction_company has around 528 NULL VALUES
GROUP BY   production_company limit 1;

#without putting the limit dream warrior pictures AND NATIONAL theatre live both have rank 1 WITH total_movie_count OF 3

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT g.genre,
       Count(id) AS movie_count
FROM   genre AS g
       INNER JOIN movie AS m
               ON g.movie_id = m.id
       INNER JOIN ratings AS r
               ON m.id = r.movie_id
WHERE  m.country = 'USA'
       AND Month(date_published) = 3
       AND year = 2017
       AND total_votes > 1000
GROUP  BY g.genre
ORDER  BY movie_count DESC; 

#Drama genre sits at top 1 with 16 movies released in USA in MArch, 2017 and have gotten more than 1000 votes.

-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
SELECT m.title,
       r.avg_rating,
       g.genre
FROM   movie AS m
       INNER JOIN genre AS g
               ON m.id = g.movie_id
       INNER JOIN ratings AS r
               ON m.id = r.movie_id
WHERE  title LIKE 'the%' #we want movie starting with The
       AND r.avg_rating > 8
ORDER  BY r.avg_rating DESC; 



-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:
SELECT median_rating,
       Count(id) AS total_movie_count
FROM   movie AS m
       INNER JOIN ratings r
               ON m.id = r.movie_id
WHERE  date_published BETWEEN '2018-04-01' AND '2019-04-01'
       AND median_rating = 8; 

#Total 361 movies were released between 1 April 2018 and 1 April 2019 that have median rating of 8.

-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

#Approach 1 using the languages column that is we are considering German and Italian language
WITH votes_summary AS
(
           SELECT     languages,
                      Sum(total_votes) AS total_no_of_votes
           FROM       movie            AS m
           INNER JOIN ratings          AS r
           ON         r.movie_id = m.id
           WHERE      languages LIKE '%Italian%'
           GROUP BY   languages
           UNION
           SELECT     languages,
                      Sum(total_votes) AS total_no_of_votes
           FROM       movie            AS m
           INNER JOIN ratings          AS r
           ON         r.movie_id = m.id
           WHERE      languages LIKE '%GERMAN%'
           GROUP BY   languages ), language_vote AS
(
         SELECT   languages
         FROM     votes_summary
         ORDER BY total_no_of_votes DESC limit 1)
SELECT IF (languages LIKE '%GERMAN%' , 'YES', 'NO') as answer FROM language_vote ;

#Approach 2 by using the country column that is considering german and italy country
WITH votes_summary AS
(
           SELECT     country,
                      Sum(total_votes) AS total_votes
           FROM       movie            AS m
           INNER JOIN ratings          AS r
           ON         m.id=r.movie_id
           WHERE      country = 'Germany'
           OR         country = 'Italy'
           GROUP BY   country
           ORDER BY   total_votes DESC limit 1 )
SELECT IF (country LIKE 'GERMANY' , 'YES', 'NO') as answer FROM votes_summary ;

-- Germany Country total movies released--> 106710
-- Italy total movies released--> 77965

#Either way by using country or language column, German movies get more votes than italian movies
-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/


-- Segment 3:

-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT Sum(Isnull(NAME))             AS name_nulls,
       Sum(Isnull(height))           AS height_nulls,
       Sum(Isnull(date_of_birth))    AS date_of_birth_nulls,
       Sum(Isnull(known_for_movies)) AS known_for_movies_nulls
FROM   names; 


/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

WITH top3_genre AS
(
           SELECT     genre,
                      Count(m.id) AS movie_count
           FROM       movie m
           INNER JOIN genre g
           ON         m.id = g.movie_id
           INNER JOIN ratings r
           ON         r.movie_id = m.id
           WHERE      avg_rating > 8
           GROUP BY   genre
           ORDER BY   movie_count DESC limit 3 )
SELECT     n.NAME      AS director_name,
           Count(m.id) AS movie_count
FROM       movie m
INNER JOIN director_mapping d
ON         m.id = d.movie_id
INNER JOIN names n
ON         n.id = d.name_id
INNER JOIN genre g
ON         g.movie_id = m.id
INNER JOIN ratings r
ON         m.id = r.movie_id
WHERE      g.genre IN
           (
                  SELECT genre
                  FROM   top3_genre)
AND        avg_rating > 8
GROUP BY   director_name
ORDER BY   movie_count DESC limit 3;


#James mangold, Joe Russo and Anthony Russo are three top directors who have produced movie in the top 3 genre.

/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT N.name AS actor_name,
       Count(movie_id) AS movie_count
FROM   role_mapping AS RM
       INNER JOIN movie AS m
               ON m.id = RM.movie_id
       INNER JOIN ratings AS r USING(movie_id)
       INNER JOIN names AS N
               ON N.id = RM.name_id
WHERE  r.median_rating >= 8
AND category = 'ACTOR'
GROUP  BY actor_name
ORDER  BY movie_count DESC
LIMIT  2; 

#Mammootty and Mohanlal are the top 2 actors whose movies have a median rating >=8

/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
SELECT     production_company,
           Sum(total_votes)                                  AS vote_count,
           Dense_rank() OVER(ORDER BY Sum(total_votes) DESC) AS prod_company_rank
FROM       movie                                             AS m
INNER JOIN ratings                                           AS r
ON         r.movie_id=m.id
GROUP BY   production_company limit 3;

#Marvel Studios, Twentieth Century Fox and Warner Bros are top three production companies with highest vote count

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
WITH summary_actor #getting actor details to get total number of vote, movie count and average rating of movies 
     AS (SELECT NM.NAME                                                     AS
                actor_name
                ,
                sum(total_votes) as total_votes,
                Count(R.movie_id)                                          AS
                   movie_count,
                Round(Sum(avg_rating * total_votes) / Sum(total_votes), 2) AS
                   actor_avg_rating
         FROM   movie AS M
                INNER JOIN ratings AS R
                        ON M.id = R.movie_id
                INNER JOIN role_mapping AS RM
                        ON M.id = RM.movie_id
                INNER JOIN names AS NM
                        ON RM.name_id = NM.id
         WHERE  category = 'ACTOR'
                AND country = "india"
         GROUP  BY NAME
         HAVING movie_count >= 5)
SELECT *,
       dense_Rank()
         OVER(
           ORDER BY actor_avg_rating DESC) AS actor_rank
FROM summary_actor;

#Vijay Sethupathi is a top actor with 23114 total_votes for 5 movies that had an average rating of 8.42

-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
WITH summary_actress AS
(
           SELECT     nm.NAME AS actress_name,
                      sum(total_votes) as total_votes,
                      Count(r.movie_id)                                     AS movie_count,
                      Round(Sum(avg_rating*total_votes)/Sum(total_votes),2) AS actress_avg_rating #getting weighted average
           FROM       movie                                                 AS m
           INNER JOIN ratings                                               AS r
           ON         m.id=r.movie_id
           INNER JOIN role_mapping AS rm
           ON         m.id = rm.movie_id
           INNER JOIN names AS nm
           ON         rm.name_id = nm.id
           WHERE      category = 'ACTRESS'
           AND        country = "INDIA"
           AND        languages LIKE '%HINDI%'
           GROUP BY   NAME
           HAVING     movie_count>=3 )
SELECT   *,
         dense_Rank() OVER(ORDER BY actress_avg_rating DESC) AS actress_rank
FROM     summary_actress LIMIT 5;


#Taaspsee pannu came out to be a top actress for Hindi movies who has acted in 3 movies with total vote count 18061 

/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:
WITH thriller_data #retrieve data for movies in thriller genre
     AS (SELECT title               AS movie_title,
                Round(r.avg_rating) AS avg_rating,
                movie_id
         FROM   movie AS m
                INNER JOIN ratings AS r
                        ON m.id = r.movie_id
                INNER JOIN genre AS g using(movie_id)
         WHERE  genre like 'Thriller')
SELECT *,
       CASE
         WHEN avg_rating > 8 THEN 'Superhit movies'
         WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
         WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
         ELSE 'Flop movies'
       END AS thriller_movie_category
FROM   thriller_data; 


/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:
SELECT genre,
		ROUND(AVG(duration),2) AS avg_duration,
        SUM(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration, #since we want a count upto current row
        AVG(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS 10 PRECEDING) AS moving_avg_duration
FROM movie AS m 
INNER JOIN genre AS g 
ON m.id= g.movie_id
GROUP BY genre
ORDER BY genre;


-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
-- Top 3 Genres based on most number of movies
WITH top_3_genre AS #This CTE will get us top 3 genre details
(
         SELECT   genre,
                  Count(movie_id)                                  AS movie_count,
                  Dense_rank() OVER(ORDER BY Count(movie_id) DESC) AS genre_rank
         FROM     genre
         GROUP BY genre limit 3 ) , genre_cte AS
(
           SELECT     genre,
                      year,
                      title AS movie_name,
                      CASE
                                 WHEN m.worlwide_gross_income LIKE '%INR%' THEN (RIGHT(m.worlwide_gross_income,Length(m.worlwide_gross_income)-4))/80 #This query will act upon rows that have values starting with INR, after removing INR and space the value will then be divided by 80 approx. USD value we have considered here
                                 WHEN m.worlwide_gross_income LIKE '%$%' THEN (RIGHT(m.worlwide_gross_income,Length(m.worlwide_gross_income)-2)) #This query will act upon rows that have value starting with USD and only remove the dollar symbol and space from the value
                                 ELSE m.worlwide_gross_income
                      END   AS worlwide_gross_income
           FROM       movie AS m
           INNER JOIN genre AS g
           ON         m.id=g.movie_id
           WHERE      genre IN
                      (
                             SELECT genre
                             FROM   top_3_genre) )
SELECT   genre, year, movie_name,
                  Concat('$', worlwide_gross_income)                                                 AS worlwide_gross_income, #Concatenating because in above CTE we removed both $ and INR Symbol from currency
         Dense_rank() OVER(partition BY year ORDER BY CONVERT(WORLWIDE_GROSS_INCOME, unsigned) DESC) AS movie_rank
FROM     genre_cte;



-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
SELECT     production_company,
           Count(m.id)                                AS movie_count,
           Row_number() OVER(ORDER BY Count(id) DESC) AS prod_comp_rank
FROM       movie                                      AS m
INNER JOIN ratings                                    AS r
ON         m.id=r.movie_id
WHERE      median_rating>=8
AND        production_company IS NOT NULL
AND        position(',' IN languages)>0
GROUP BY   production_company limit 2;

#From results Star Cinema and Twentieth Century Fox are top two production houses

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
SELECT     NAME                                                    AS actress_name,
           Sum(total_votes)                                        AS total_votes,
           Count(rm.movie_id)                                      AS movie_count,
           Round(Sum(avg_rating * total_votes)/Sum(total_votes),2) AS actress_avg_rating,
           Dense_rank() over(ORDER BY Count(rm.movie_id) DESC)     AS actress_rank
FROM       names                                                   AS nm
INNER JOIN role_mapping                                            AS rm
ON         nm.id=rm.name_id
INNER JOIN ratings AS r
ON         r.movie_id=rm.movie_id
INNER JOIN genre AS g
ON         r.movie_id=g.movie_id
WHERE      category='actress'
AND        avg_rating >8
AND        genre='DRAMA'
GROUP BY   nm.NAME limit 3;

#parvthy thiruvothu, susan brown and amanda lawrence are top 3 actresses who have super hit movies





/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:
WITH nextdate_published_summary AS #This CTE is aimed towards finding what is the next published date along with other values
(
           SELECT     d.name_id,
                      NAME,
                      d.movie_id,
                      duration,
                      r.avg_rating,
                      total_votes,
                      m.date_published,
                      Lead(date_published,1) over(partition BY d.name_id ORDER BY date_published,movie_id ) AS nextdate_published #to find date for consecutive order lead function is being used
           FROM       director_mapping                                                                      AS d
           INNER JOIN names                                                                                 AS n
           ON         n.id = d.name_id
           INNER JOIN movie AS m
           ON         m.id = d.movie_id
           INNER JOIN ratings AS r
           ON         r.movie_id = m.id ), top_director_summary AS
(
       SELECT *,
              Datediff(nextdate_published, date_published) AS date_difference #To calculate difference between consecutive orders
       FROM   nextdate_published_summary )
SELECT   name_id                       AS director_id,
         NAME                          AS director_name,
         Count(movie_id)               AS number_of_movies,
         Round(Avg(date_difference),2) AS avg_inter_movie_days,
         Round(Avg(avg_rating),2)               AS avg_rating,
         Sum(total_votes)              AS total_votes,
         Min(avg_rating)               AS min_rating,
         Max(avg_rating)               AS max_rating,
         Sum(duration)                 AS total_duration
FROM     top_director_summary
GROUP BY director_id
ORDER BY Count(movie_id) DESC limit 9;

#End of SQL Script





