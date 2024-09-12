# Create a database
create database E_Commerce;
use e_commerce;


select * from olist_geolocation_dataset;
select * from olist_customers_dataset;

/*KPI 1 :- How many cities & State Are there? */

select count(distinct customer_city) as Total_No_of_cities,
	   count(distinct customer_state) as Total_No_of_State
       from olist_customers_dataset;
       
/* Observation :- Cities:- 4119 , state :- 27 */

----------------------------------------------------------------------------------------------

/* KPI 2 :- How many cities are more than 500 customers? */
select count(*) as cities_with_more_than_500_Customers
from (
      select customer_city,count(distinct customer_id) as total_customers
      from olist_customers_dataset
      group by customer_city
      having total_customers > 500
      ) as cities_above_500_customers;
      
/* Observation:- 22 cities have at least 500 customers */

-----------------------------------------------------------------------------------------------------------

/* KPI 3 :- Mention the Name of cities having more than 500 customers? */


select customer_city ,
	   count(distinct customer_id) as total_customers
       from olist_customers_dataset
       group by customer_city
       having total_customers >500;
       
------------------------------------------------------------------------------------------------------------
       
/* KPI 4 :- Which are top 10 cities having most of customers and mention that city name?*/

## View Function##

/*CREATE VIEW top_cities_customers AS
SELECT city, COUNT(DISTINCT customer_unique_id) AS total_customers
FROM olist_customers_dataset
GROUP BY city;
*/

select customer_city, total_customers
from top_10_cities
order by total_customers desc
limit 10;

/* Observation :- Cities in the top ten have at least 908 customers */

---------------------------------------------------------------------------------------------
       
 /* KPI 5 :- Which are the top ten states that have the most customers?*/   
 
/* View Function :- 
CREATE VIEW `TopTenCustomerStates` AS
SELECT customer_state, COUNT(*) AS num_customers
FROM olist_customers_dataset
GROUP BY customer_state
ORDER BY num_customers DESC
LIMIT 10;
*/

SELECT * FROM TopTenCustomerStates;

/* Observation :- States in the top ten have at least 2020 customers*/

--------------------------------------------------------------------------------------------------


/* KPI 6 :- Customer shares of the top ten Cities? */

/* 1) Find the total no of customer...*/

select count(*) as Total_Customers
from olist_customers_dataset; ### there is 99K customers

/* 2) No. of customers in top 10 cities */

SELECT customer_city, COUNT(*) AS num_customers
FROM olist_customers_dataset
GROUP BY customer_city
ORDER BY num_customers DESC
LIMIT 10;

/* 3) Calculate the percentage of customer in the top ten cities*/

with top_ten_customers as (
	select count(*) as num_customers
    from olist_customers_dataset
    group by customer_city
    order by count(*) desc
    limit 10
)
select concat(round((sum(num_customers)*100.0)/(select count(*) 
	from olist_customers_dataset)),'%') as percentage_top_ten
    from top_ten_customers;
    
/* Observation :- * There is maximum 35% shares are belonging in top ten cities.
				  * The top ten cities only account for more than 35 percents of the customer base 
*/

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

/* KPI 7 :- Customer shares of the top ten states */

-- Calculate the total number of customers
SELECT COUNT(*) AS total_customers
FROM customers;

-- Calculate the number of customers in each state
SELECT state, COUNT(*) AS num_customers
FROM olist_customers_dataset
GROUP BY cuatomer_state
ORDER BY num_customers DESC;

-- Calculate the percentage of customers in the top ten states
WITH top_ten_states AS (
    SELECT customer_state, COUNT(*) AS num_customers
    FROM olist_customers_dataset
    GROUP BY customer_state
    ORDER BY COUNT(*) DESC
    LIMIT 10
)
SELECT concat(ROUND((SUM(num_customers) * 100.0) / (SELECT COUNT(*) FROM olist_customers_dataset), 2),'%') AS percentage_top_ten
FROM top_ten_states;

/* Observation:- The top ten states account for over 90 percents of the customer base */

-----------------------------------------------------------------------------------------------------------------------------------------------------
/* KPI 8 :- How many sellers are there?*/

select* from olist_sellers_dataset;
select* from olist_products_dataset;

select count(distinct seller_id) as Total_no_sellers,
	   count(distinct Seller_city) as No_distinct_seller_city,
       count(distinct seller_state) as no_distinct_seller_state
	from olist_sellers_dataset;
    
    /* Observation :- 3,095 sellers, 611 cities, and 23 states */

-------------------------------------------------------------------------------------------------------

/*  KPI 8 :- Which are the top ten cities that have the most sellers? */

select Seller_city,
	   count(distinct Seller_id) as No_of_seller
	from olist_sellers_dataset
    group by seller_city
    order by No_of_seller desc
    limit 10;
    
    /* observation :- ities in the top ten have at least 40 sellers */

--------------------------------------------------------------------------------------------
   
/* KPI 9 :- Seller shares of the top ten cities */

with top_ten_customers as (
	select count(*) as num_customers
    from olist_sellers_dataset
    group by seller_city
    order by count(*) desc
    limit 10
)
select concat(round((sum(num_customers)*100.0)/(select count(*) 
	from olist_sellers_dataset)),'%') as percentage_top_ten
    from top_ten_customers;

/*  Observation :- The top ten cities account for approximately 41 percents of the seller base */

-----------------------------------------------------------------------------------------------------
/* KPI 10 :- Seller shares of the top ten State */

WITH top_ten_states AS (
    SELECT seller_state, COUNT(*) AS num_customers
    FROM olist_sellers_dataset
    GROUP BY seller_state
    ORDER BY COUNT(*) DESC
    LIMIT 10
)
SELECT concat(ROUND((SUM(num_customers) * 100.0) / (SELECT COUNT(*) FROM olist_sellers_dataset), 2),'%') AS percentage_top_ten
FROM top_ten_states;

/* Observation :- The top ten states account for more than 98 percents of the seller base */ 

 #----------------------------------------------------------------------------------------------------------------------------------------------
 /* KPI 11 :- What is the delivery rate? */
 select* from olist_orders_dataset;
WITH delivery_rate AS ( 
    SELECT 
        order_status,
        COUNT(order_status) AS status_count
    FROM olist_orders_dataset
    GROUP BY order_status
)
SELECT 
    order_status,
    status_count,
    ROUND(status_count / SUM(status_count) OVER() * 100, 2)  AS status_rate
FROM delivery_rate
ORDER BY status_count DESC;

/* Observation :- The overall successful delivery rate is more than 97 percents */ 

------------------------------------------------------------------------------------------------------------------
/* KPI 12 :- Avg Review score */
select * from olist_order_reviews_dataset;
select avg(review_score) as Avg_Review_Score from olist_order_reviews_dataset;
/* Observation :- 4.0143 is the avg reviwe score */ 

------------------------------------------------------------------------------------------------------------------

# KPI 13:- total amt by payment method 
select payment_type ,sum(payment_value) AS payment_value from olist_order_payments_dataset
group by payment_type
;

---------------------------------------------------------------------------------------------------------------------
-- DATA CLEANING
alter table olist_order_reviews_dataset
drop review_comment_message,
drop review_comment_title,
drop review_creation_date,
drop review_answer_timestamp;

-- KPI 14:- . Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics
SELECT
    CASE 
        WHEN dayname(order_purchase_timestamp) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    round(sum(payment_value),2) AS total_payments
FROM
    olist_orders_dataset
INNER JOIN 
	olist_order_payments_dataset
USING
	(order_id)
GROUP BY 
	CASE 
        WHEN dayname(order_purchase_timestamp) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END;
 
 ------------------------------------------------------------------------------------------------------------
 
-- KPI 15 :- . Number of Orders with review score 5 and payment type as credit card.

SELECT (select 5 ) as Review_Score,
	(SELECT 'credit_card') as CardType,
    (SELECT COUNT(*)
FROM olist_order_reviews_dataset
INNER JOIN olist_order_payments_dataset using(order_id)
WHERE review_score = 5 and payment_type = 'credit_card') as Number_of_Orders;

---------------------------------------------------------------------------------------------------------------------

-- KPI 16:- . Average price and payment values from customers of sao paulo city

SELECT round(avg(price)) as average_price,
		round(avg(payment_value)) as average_payment_value
FROM olist_order_items_dataset
INNER JOIN olist_order_payments_dataset using(order_id)
WHERE order_id IN (
		SELECT order_id
        FROM olist_orders_dataset 
        WHERE customer_id IN (
			SELECT customer_id
            FROM olist_customers_dataset
            WHERE customer_city = 'Sao Paulo')
);

-----------------------------------------------------------------------------------------------------------------------------------
 # KP1 17
		-- TOTAL RREVENUE --
select format(sum(payment_value),2) as TOTAL_REVENUE from olist_order_payments_dataset;

#KPI 2
     -- TOTAL PROFIT
SELECT 
format(sum((p.payment_value-(O.price+O.freight_value))),2) as Total_profit
FROM olist_order_items_dataset O
JOIN olist_order_payments_dataset p
USING (order_id);

----------------------------------------------------------------------------------------------------------------------------------------

#KPI 18
    -- REVIEW SCORE VS SHIPPING DAYS 
select distinct  review_score,
avg(datediff(order_estimated_delivery_date,order_delivered_carrier_date)) as Average_shipping_days ,
count(datediff(order_estimated_delivery_date,order_delivered_carrier_date)) as count_shipping_days
 from 
olist_order_reviews_dataset
inner join olist_orders_dataset o
using (order_id)
group by 1
order by 1;

----------------------------------------------------------------------------------------------------------------

# KPI 19
   -- TOTAL REVIEW  AND PROFIT YEAR WISE\

SELECT 
year(shipping_limit_date) as Year,
format(sum((p.payment_value-(O.price+O.freight_value))),2) as Total_profit,
format(sum(payment_value),2)  as TOTAL_REVENUE 
FROM olist_order_items_dataset O
JOIN olist_order_payments_dataset p
USING (order_id)
group by year
order by year asc ;

--------------------------------------------------------------------------------------------------------------------

#KPI 20
     -- TOTAL PAYMENT RATIO PAYMENT METHOD WISE 
     
     select payment_type,format(sum(payment_value),2) as TOTAL_REVENUE from olist_order_payments_dataset
     group by payment_type;
	