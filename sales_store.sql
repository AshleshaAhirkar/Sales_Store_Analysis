--Steps
--1.Download datasets from kaggle
--2.import data
--3.data cleaning
--4.Solving Business Insights Questions
--5.Uploading this project into GitHub profile

create table store(
transaction_id varchar(15),
customer_id	varchar(15),
customer_name varchar(30),
customer_age int,
gender varchar(15),
product_id varchar(15),
product_name varchar(15),
product_category varchar(15),
quantiy	int,
prce float,
payment_mode varchar(15),
purchase_date date,
time_of_purchase time,
status varchar(15)
)

select * into sales from store  --making copy of store 


select * from store
select * from sales  --copy

--Data cleaning
--step 1:to check for duplicate

select transaction_id,count(*)
from sales
group by transaction_id
having count(transaction_id)>1

"TXN855235"
"TXN240646"
"TXN342128"
"TXN981773"


--another way
with cte as(
select *,
  row_number() over(partition by transaction_id order by transaction_id) as row_num
  from sales
)
select * from cte
where transaction_id in ('TXN855235','TXN240646','TXN342128','TXN981773')

--delete duplicate rows

--sql server
-- with cte as(
-- select *,
--   row_number() over(partition by transaction_id order by transaction_id) as row_num
--   from sales
-- )
-- delete from cte
-- where row_num=2

--see
SELECT *
FROM sales
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM sales
    GROUP BY transaction_id
);

--delete
DELETE FROM sales
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM sales
    GROUP BY transaction_id
);


--Step 2:Correction of headers
alter table sales
rename column quantiy to quantity;

alter table sales
rename column prce to price;


--Step 3:To check Datatype
select column_name,data_type
from information_schema.columns
where table_name='sales'
--  and column_name='quantity'

--Step 4:To Check Null Values

--to check null count

CREATE OR REPLACE FUNCTION null_count_per_column(p_table TEXT)
RETURNS TABLE(col_name TEXT, null_count BIGINT)
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT c.column_name
        FROM information_schema.columns c
        WHERE c.table_name = p_table
    LOOP
        col_name := r.column_name;

        EXECUTE format(
            'SELECT COUNT(*) FROM %I WHERE %I IS NULL',
            p_table,
            r.column_name
        )
        INTO null_count;

        RETURN NEXT;
    END LOOP;
END;
$$;

SELECT * FROM null_count_per_column('sales');


--treating null values
SELECT *
FROM sales 
WHERE transaction_id IS NULL
OR
customer_id IS NULL
OR
customer_name IS NULL
OR
customer_age IS NULL
OR
gender IS NULL
OR
product_id IS NULL
OR
product_name IS NULL
OR
product_category IS NULL
OR
quantity IS NULL
or
payment_mode is null
or
purchase_date is null
or 
status is null
or 
price is null

--deleting the outlier---->almost saare he values null hai 
delete from sales
where transaction_id is null

select * from sales
where customer_name='Ehsaan Ram'

update sales 
set customer_id='CUST9494'
where transaction_id='TXN977900'

select * from sales
where customer_name='Damini Raju'

update sales 
set customer_id='CUST1401'
where transaction_id='TXN985663'

select *
from sales
where customer_id='CUST1003'

update sales
set customer_name='Mahika Saini' , customer_age=35 , gender='Male'
where transaction_id='TXN432798'


select * from sales

--Step 5: Data Cleaning of gender and payment_mode
--Cleaning gender column

select distinct gender
from sales

update sales
set gender=(
case when gender='Male' then 'M'
else 'F'
end)

-- update sales
-- set gender='M'
-- where gender='Male'

--cleaning payment_mode column
select distinct payment_mode
from sales

update sales
set payment_mode='Credit Card'
where payment_mode='CC'


----------------------------------------------------------------
--Data Analysis--
--1. What are the top 5 most selling products by quantity?
select product_name,total
from (
select product_name,sum(quantity) as total,
row_number() over( order by sum(quantity) desc) as rnk
from sales
where status='delivered'
group by product_name
)
where rnk<=5

select product_name,sum(quantity) as cnt_prod
from sales
where status='delivered'
group by product_name
order by cnt_prod desc
limit 5

--Business Problem: We don't know which products are most in demand.

--Business Impact: Helps prioritize stock and boost sales through targeted promotions.

-----------------------------------------------------------------------------------------------------------

--2. Which products are most frequently cancelled?
select product_name,count(*) as cnt
from sales
where status='cancelled'
group by product_name
order by cnt desc
limit 5

--Business Problem: Frequent cancellations affect revenue and customer trust.

--Business Impact: Identify poor-performing products to improve quality or remove from catalog.

-----------------------------------------------------------------------------------------------------------

--3. What time of the day has the highest number of purchases?
select 
 case 
   when extract(hour from time_of_purchase) between 0 and 5 then 'NIGHT'
   when extract(hour from time_of_purchase) between 6 and 11 then 'MORNING'
   when extract(hour from time_of_purchase) between 12 and 17 then 'AFTERNOON'
   when extract(hour from time_of_purchase) between 18 and 23 then 'EVENING'
end as time_of_day,
count(*) as total_orders
from sales
group by
 case
   when extract(hour from time_of_purchase) between 0 and 5 then 'NIGHT'
   when extract(hour from time_of_purchase) between 6 and 11 then 'MORNING'
   when extract(hour from time_of_purchase) between 12 and 17 then 'AFTERNOON'
   when extract(hour from time_of_purchase) between 18 and 23 then 'EVENING'
 end
 order by total_orders desc

 --Business Problem Solved: Find peak sales times.

--Business Impact: Optimize staffing, promotions, and server loads.
-----------------------------------------------------------------------------------------------------------

--4. Who are the top 5 highest spending customers?
select customer_id,customer_name,concat('₹ ',to_char(sum(price*quantity), 'FM99,99,99,999')) as total
from sales
group by customer_id,customer_name
order by sum(price*quantity) desc
limit 5

select customer_id,customer_name,'₹ '|| to_char(sum(price*quantity), 'FM99,99,99,999') as total
from sales
group by customer_id,customer_name
order by sum(price*quantity) desc
limit 5

--mysql
--concat('₹ ', format(sum(price*quantity), 0))

--Business Problem Solved: Identify VIP customers.

--Business Impact: Personalized offers, loyalty rewards, and retention.

-----------------------------------------------------------------------------------------------------------

--5. Which product categories generate the highest revenue?
select product_category,concat('₹ ' ,to_char(sum(price*quantity),'FM99,99,99,999')) as revenue
from sales
group by product_category
order by sum(price*quantity) desc
limit 1

select product_category,revenue
from(
select product_category,sum(price*quantity) as revenue,
dense_rank() over(order by sum(price*quantity) desc ) as rnk
from sales
group by product_category
)
where rnk=1

--Business Problem Solved: Identify top-performing product categories.

--Business Impact: Refine product strategy, supply chain, and promotions.
--allowing the business to invest more in high-margin or high-demand categories.

-----------------------------------------------------------------------------------------------------------

--6. What is the return/cancellation rate per product category?
--cancellation
SELECT 
    product_category,
    to_char(
        COUNT(CASE WHEN status = 'cancelled' THEN 1 END) * 100.0 / COUNT(*),
        'FM999.000'
    ) || ' %' AS cancelled_percent
FROM sales
GROUP BY product_category
ORDER BY cancelled_percent DESC;

--return
SELECT 
    product_category,
    concat(to_char(count(case when status='returned' then 1 end)*100.0/count(*),'FM999.000'),' %') as returned_percent
FROM sales
GROUP BY product_category
ORDER BY returned_percent desc

--Business Problem Solved: Monitor dissatisfaction trends per category.


---Business Impact: Reduce returns, improve product descriptions/expectations.
--Helps identify and fix product or logistics issues.

-----------------------------------------------------------------------------------------------------------

--7. What is the most preferred payment mode?
select payment_mode,count(*) as cnt
from sales
group by payment_mode
order by cnt desc
-- limit 1

select payment_mode,cnt
from(
select payment_mode,count(*) as cnt,
dense_rank() over(order by count(*) desc) rnk
from sales
group by payment_mode
)
-- where rnk=1

--Business Problem Solved: Know which payment options customers prefer.

--Business Impact: Streamline payment processing, prioritize popular modes.

-----------------------------------------------------------------------------------------------------------

--8. How does age group affect purchasing behavior?
select min(customer_age),max(customer_age)
from sales

select 
case when customer_age between 18 and 25 then '18-25'
     when customer_age between 26 and 35 then '26-35'
	 when customer_age between 36 and 50 then '36-50'
	 else '51+'
end as customer_age,
concat('₹ ',to_char(sum(price*quantity),'FM999,999,999')) as total_purchase
from sales
group by case when customer_age between 18 and 25 then '18-25'
     when customer_age between 26 and 35 then '26-35'
	 when customer_age between 36 and 50 then '36-50'
	 else '51+'
end
order by sum(price*quantity) desc

--Business Problem Solved: Understand customer demographics.

--Business Impact: Targeted marketing and product recommendations by age group.

-----------------------------------------------------------------------------------------------------------

--9. What’s the monthly sales trend?
-- select * from sales

--Method 1
select to_char(purchase_date,'YYYY-MM') as year_month,concat('₹',to_char(sum(price*quantity),'FM999,999,999')) as total_sales,
sum(quantity) as total_quantity
from sales
group by to_char(purchase_date,'YYYY-MM')
order by year_month

--Method 2
select extract(year from purchase_date) as Year,
        extract(month from purchase_date) as Month,
concat('₹',to_char(sum(price*quantity),'FM999,999,999')) as total_sales,
sum(quantity) as total_quantity
from sales
group by extract(year from purchase_date),
        extract(month from purchase_date) 
order by Month

select extract(month from purchase_date) as Month,
concat('₹',to_char(sum(price*quantity),'FM999,999,999')) as total_sales,
sum(quantity) as total_quantity
from sales
group by extract(month from purchase_date) 
order by Month

--Business Problem: Sales fluctuations go unnoticed.

--Business Impact: Plan inventory and marketing according to seasonal trends.

-----------------------------------------------------------------------------------------------------------

--10. Are certain genders buying more specific product categories?
select * from sales

--method 1
select gender,product_category,count(product_name) as total_purchase
from sales
group by gender,product_category
order by gender;

--method 2
select
    product_category,
    count(*) filter (where gender = 'M')   as male,
    count(*) filter (where gender = 'F') as female
from sales
group by product_category
order by product_category;

--method 3
select
    product_category,
    sum(case when gender = 'M' then 1 else 0 end)   as male,
    sum(case when gender = 'F' then 1 else 0 end) as female
from sales
group by product_category
order by product_category;

--Business Problem Solved: Gender-based product preferences.

--Business Impact: Personalized ads, gender-focused campaigns.

