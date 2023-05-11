/* Question: Extract the farmer’s products that have prices above the market date’s average product cost only for
vendor having id 8  */

SELECT *
FROM 
(SELECT vendor_id,product_id,market_date,
original_price,
ROUND(AVG(original_price) OVER (PARTITION BY  market_date ORDER BY  market_date),2)  AS average_cost_product_by_market_date
FROM vendor_inventory ) AS temp
WHERE temp.vendor_id=8
AND temp.original_price> temp.average_cost_product_by_market_date
ORDER BY  temp.market_date,temp.original_price DESC


/* Question: Count how many different products each vendor brought to market on
each date, and displays that count on each row.  */

SELECT vendor_id,market_date,product_id,
COUNT(product_id) OVER ( PARTITION BY market_date,vendor_id )
FROM vendor_inventory
order by  vendor_id,market_date ,original_price desc


/* Question: Calculate the running total of the cost of items purchased by each
customer, sorted by the date and time and the product_id */

SELECT customer_id, vendor_id,
market_date,
quantity*cost_to_customer_per_qty as price,
SUM( quantity*cost_to_customer_per_qty ) 
OVER (PARTITION BY customer_id ORDER BY market_date,transaction_time,product_id ROWS UNBOUNDED PRECEDING ) as 
running_total_customer
FROM customer_purchases


/* Question: Using the vendor_booth_assignments table in the Farmer’s Market database, display each
vendor’s booth assignment for each market_date alongside their previous booth assignments. */

SELECT  vendor_id,
market_date , booth_number,
LAG(booth_number) OVER(PARTITION by vendor_id ORDER BY market_date,vendor_id) as previos_booth_number
FROM vendor_booth_assignments

/* Question: On specific market date ,determine which vendors are
new or changing booths that day, so we can contact them and ensure setup goes smoothly.
Check it for date: 2019-04-10 */

SELECT *
FROM (
SELECT vendor_id,booth_number,market_date,
LAG(booth_number) OVER (PARTITION BY vendor_id  ORDER BY market_Date,vendor_id ) as previous_booth_number
FROM vendor_booth_assignments
 ) as x
WHERE market_date="2019-04-10"
and  (x.booth_number <> x.previous_booth_number OR x.previous_booth_number IS NULL )


/* Question:  To get a profile of each  customer’s habits over time    */

SELECT customer_id,
MAX(market_date) as  last_purchase_date,
MIN(market_date) as first_purchase_date,
 DATEDIFF(MAX(market_date),MIN(market_date)) as days_between_first_last_purchase,
 COUNT(DISTINCT market_date) as count_of_purchase_dates,
 SUM( quantity * cost_to_customer_per_qty) as total_amount_spent
 FROM customer_purchases
 GROUP BY customer_id
 
/* Question: Write a query that gives us the days between each purchase a
customer makes */


SELECT *,
IFNULL(DATEDIFF(market_date, previous_purchase_date),"First Purchase") as date_diff_between_purchases
FROM (
SELECT DISTINCT customer_id,
market_date,
IFNULL(LAG(market_date) OVER( PARTITION BY customer_id order by market_date,customer_id),0) as previous_purchase_date
FROM customer_purchases  ) as x
WHERE market_date!=previous_purchase_Date

/* Question: today’s date is March 31, 2019, and the marketing director of the
farmer’s market wants to give infrequent 10  customers an incentive to return to
the market in April. */

SELECT customer_id,
COUNT(DISTINCT market_date) as count_of_market_visit_in_march
FROM customer_purchases
WHERE DATEDIFF(market_date,"2019-03-31")  < 31
GROUP BY customer_id
order by count_of_market_visit_in_march 
Limit 10

