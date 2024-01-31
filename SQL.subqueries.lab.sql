-- Determine the number of copies of the film "Hunchback Impossible" 
-- that exist in the inventory system.

SELECT 
COUNT(*) AS "Copies HUNCHBACK IMPOSSIBLE"
FROM inventory
JOIN film ON film.film_id=inventory.film_id
WHERE title = 'HUNCHBACK IMPOSSIBLE'


SELECT 
COUNT(*) AS "Copies HUNCHBACK IMPOSSIBLE"
FROM inventory
JOIN 
(SELECT
title, 
film_id
FROM film
WHERE title = 'HUNCHBACK IMPOSSIBLE') AS film_filtered ON film_filtered.film_id=inventory.film_id;

--List all films whose length is longer than the average length of all the films in the Sakila database.

SELECT ROUND(AVG(length), 4) FROM film;
SELECT 
*
FROM film 
WHERE length> (SELECT AVG(length) FROM film);

--3. Use a subquery to display all actors who appear in the film "Alone Trip".

SELECT * FROM film WHERE title='ALONE TRIP';

SELECT  
CONCAT(first_name,' ',last_name) AS actors
FROM actor 
JOIN film_actor ON film_actor.actor_id=actor.actor_id
WHERE film_id = (SELECT film_id FROM film WHERE title='ALONE TRIP');


--Bonus:
--1. Sales have been lagging among young families, and you want to target family movies for a promotion. 
--Identify all movies categorized as family films.


SELECT * FROM category;

SELECT title 
FROM film JOIN film_category ON film.film_id=film_category.film_id
WHERE category_id = (SELECT category_id FROM category WHERE name='Family');

-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins. 
--To use joins, you will need to identify the relevant tables and their primary and foreign keys.

SELECT * FROM country WHERE country='Canada'

SELECT * FROM city WHERE country_id=(SELECT country_id FROM country WHERE country='Canada');
SELECT * FROM address WHERE city_id IN (SELECT city_id FROM city WHERE country_id=(SELECT country_id FROM country WHERE country='Canada'));
SELECT CONCAT(first_name,' ',last_name) AS name, email FROM customer WHERE address_id IN (SELECT address_id FROM address WHERE city_id IN (SELECT city_id FROM city WHERE country_id =(SELECT country_id FROM country WHERE country = 'Canada')));

-- Determine which films were starred by the most prolific actor in the Sakila database.
-- A prolific actor is defined as the actor who has acted in the most number of films.
-- First, you will need to find the most prolific actor and then use that actor_id to
-- find the different films that he or she starred in

SELECT actor.actor_id, COUNT(film_actor.film_id) AS film_count
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id
GROUP BY actor.actor_id
ORDER BY COUNT(film_actor.film_id) DESC
LIMIT 1;




SELECT actor.actor_id, COUNT(film_actor.film_id) AS film_count
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id
GROUP BY actor.actor_id
HAVING COUNT(film_actor.film_id) = 
(SELECT
MAX(movies_count)
FROM
(SELECT actor.actor_id, COUNT(film_actor.film_id) AS movies_count
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id
GROUP BY actor.actor_id) AS grouped_movie);

SELECT actor.actor_id, COUNT(film_actor.film_id) AS movies_count
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id
GROUP BY actor.actor_id
ORDER BY movies_count DESC LIMIT 1


SELECT actor.actor_id
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id
GROUP BY actor.actor_id
HAVING COUNT(film_actor.film_id) = (SELECT MAX(movies_count)
  FROM (SELECT actor.actor_id, COUNT(film_actor.film_id) AS movies_count
    FROM actor
    JOIN film_actor ON actor.actor_id = film_actor.actor_id
    GROUP BY actor.actor_id) AS grouped_movie);

SELECT title,first_name,last_name,actor.actor_id FROM actor
JOIN film_actor ON actor.actor_id=film_actor.actor_id
JOIN film ON film.film_id=film_actor.film_id
WHERE actor.actor_id=107;

SELECT title
FROM actor
JOIN film_actor ON actor.actor_id=film_actor.actor_id
JOIN film ON film.film_id=film_actor.film_id
WHERE actor.actor_id=(SELECT actor.actor_id
FROM actor 
JOIN film_actor ON actor.actor_id=film_actor.actor_id
GROUP BY actor.actor_id
ORDER BY COUNT(film_actor.film_id) DESC
LIMIT 1);

-- Find the films rented by the most profitable customer in the Sakila database.
-- You can use the customer and payment tables to find the most profitable customer, 
-- i.e., the customer who has made the largest sum of payments.
SELECT 
    customer_id, SUM(amount)
FROM
    payment
GROUP BY customer_id;


SELECT 
    customer_id, SUM(amount)
FROM
    payment
GROUP BY customer_id
ORDER BY SUM(amount) DESC
LIMIT 1;



SELECT 
    customer_id, SUM(amount)
FROM
    payment
GROUP BY customer_id
HAVING SUM(amount) =
(SELECT
MAX(spent)
customer_id
FROM
(SELECT 
    customer_id, SUM(amount) AS spent
FROM
    payment
GROUP BY customer_id) AS grouped);

SELECT 
title
FROM
rental
JOIN inventory ON inventory.inventory_id=rental.inventory_id
JOIN film ON inventory.film_id=film.film_id
WHERE customer_id = (SELECT 
    customer_id
FROM
    payment
GROUP BY customer_id
HAVING SUM(amount) = 
(SELECT 
MAX(spent)
FROM
(SELECT 
    customer_id, SUM(amount) as spent
FROM
    payment
GROUP BY customer_id) as grouped));

SELECT 
title,payment.amount
FROM
rental
JOIN inventory ON inventory.inventory_id=rental.inventory_id
JOIN film ON inventory.film_id=film.film_id
JOIN payment ON rental.rental_id=payment.rental_id
WHERE rental.customer_id = (SELECT 
    customer_id
FROM
    payment
GROUP BY customer_id
ORDER BY SUM(amount) DESC
LIMIT 1);

-- Retrieve the client_id and the total_amount_spent of those
-- clients who spent more than the average of the total_amount spent by each client. 
-- You can use subqueries to accomplish this.


SELECT payment.customer_id,SUM(payment.amount) AS total_amount
FROM payment
GROUP BY customer_id
HAVING SUM(payment.amount)>(
SELECT
ROUND(AVG(SUM_total_amount), 4)
FROM
(SELECT payment.customer_id,SUM(payment.amount) AS SUM_total_amount
FROM payment
GROUP BY customer_id) AS grouped);







