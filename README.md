# 🛒 Store Sales Analysis Using SQL

## 📌 Project Description

Performed store sales data analysis using SQL by cleaning raw data and generating business insights.
Identified top-selling products, revenue trends, customer spending patterns, and cancellation rates to support data-driven decision-making.

The project demonstrates:
- Data Cleaning
- Duplicate Removal
- Null Value Handling
- Data Standardization
- Business Problem Solving using SQL
- Revenue & Customer Analysis

---

# 📂 Step 1: Creating Table

```sql
create table store(
transaction_id varchar(15),
customer_id varchar(15),
customer_name varchar(30),
customer_age int,
gender varchar(15),
product_id varchar(15),
product_name varchar(15),
product_category varchar(15),
quantiy int,
prce float,
payment_mode varchar(15),
purchase_date date,
time_of_purchase time,
status varchar(15)
);

-- Making copy of table
select * into sales from store;
```

---

# 🧹 Step 2: Data Cleaning

## 1️⃣ Checking Duplicate Records

```sql
select transaction_id,count(*)
from sales
group by transaction_id
having count(transaction_id)>1;
```

### Removing Duplicates (PostgreSQL)

```sql
DELETE FROM sales
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM sales
    GROUP BY transaction_id
);
```

---

## 2️⃣ Correcting Column Names

```sql
alter table sales
rename column quantiy to quantity;

alter table sales
rename column prce to price;
```

---

## 3️⃣ Checking Data Types

```sql
select column_name,data_type
from information_schema.columns
where table_name='sales';
```

---

## 4️⃣ Checking Null Values

```sql
SELECT *
FROM sales 
WHERE transaction_id IS NULL
OR customer_id IS NULL
OR customer_name IS NULL
OR customer_age IS NULL
OR gender IS NULL
OR product_id IS NULL
OR product_name IS NULL
OR product_category IS NULL
OR quantity IS NULL
OR payment_mode IS NULL
OR purchase_date IS NULL
OR status IS NULL
OR price IS NULL;
```

### Removing Null Records

```sql
delete from sales
where transaction_id is null;
```

---

## 5️⃣ Standardizing Gender Column

```sql
update sales
set gender = (
case 
    when gender='Male' then 'M'
    else 'F'
end);
```

---

## 6️⃣ Cleaning Payment Mode

```sql
update sales
set payment_mode='Credit Card'
where payment_mode='CC';
```

---

# 📊 Business Insights & SQL Analysis

---

## 1️⃣ Top 5 Most Selling Products

```sql
select product_name,sum(quantity) as total_quantity
from sales
where status='delivered'
group by product_name
order by total_quantity desc
limit 5;
```

### Business Impact:
- Helps prioritize stock
- Boosts sales through promotions

---

## 2️⃣ Most Frequently Cancelled Products

```sql
select product_name,count(*) as cancellation_count
from sales
where status='cancelled'
group by product_name
order by cancellation_count desc
limit 5;
```

### Business Impact:
- Identifies poor-performing products
- Reduces revenue loss

---

## 3️⃣ Peak Purchase Time

```sql
select 
 case 
   when extract(hour from time_of_purchase) between 0 and 5 then 'NIGHT'
   when extract(hour from time_of_purchase) between 6 and 11 then 'MORNING'
   when extract(hour from time_of_purchase) between 12 and 17 then 'AFTERNOON'
   when extract(hour from time_of_purchase) between 18 and 23 then 'EVENING'
 end as time_of_day,
 count(*) as total_orders
from sales
group by time_of_day
order by total_orders desc;
```

### Business Impact:
- Optimizes staffing
- Improves promotional timing

---

## 4️⃣ Top 5 Highest Spending Customers

```sql
select customer_id,customer_name,
'₹ '|| to_char(sum(price*quantity), 'FM99,99,99,999') as total_spent
from sales
group by customer_id,customer_name
order by sum(price*quantity) desc
limit 5;
```

### Business Impact:
- Identifies VIP customers
- Supports loyalty programs

---

## 5️⃣ Highest Revenue Product Category

```sql
select product_category,
sum(price*quantity) as revenue
from sales
group by product_category
order by revenue desc
limit 1;
```

### Business Impact:
- Focus on high-performing categories
- Improve supply chain strategy

---

## 6️⃣ Cancellation Rate per Category

```sql
SELECT 
    product_category,
    COUNT(CASE WHEN status = 'cancelled' THEN 1 END) * 100.0 / COUNT(*) AS cancelled_percent
FROM sales
GROUP BY product_category
ORDER BY cancelled_percent DESC;
```

### Business Impact:
- Reduces dissatisfaction
- Improves product quality

---

## 7️⃣ Most Preferred Payment Mode

```sql
select payment_mode,count(*) as total_transactions
from sales
group by payment_mode
order by total_transactions desc;
```

### Business Impact:
- Improves payment system efficiency

---

## 8️⃣ Age Group Purchasing Behavior

```sql
select 
case when customer_age between 18 and 25 then '18-25'
     when customer_age between 26 and 35 then '26-35'
     when customer_age between 36 and 50 then '36-50'
     else '51+'
end as age_group,
sum(price*quantity) as total_purchase
from sales
group by age_group
order by total_purchase desc;
```

### Business Impact:
- Targeted marketing campaigns
- Personalized recommendations

---

## 9️⃣ Monthly Sales Trend

```sql
select to_char(purchase_date,'YYYY-MM') as year_month,
sum(price*quantity) as total_sales,
sum(quantity) as total_quantity
from sales
group by year_month
order by year_month;
```

### Business Impact:
- Identifies seasonal trends
- Helps inventory planning

---

## 🔟 Gender-Based Product Preferences

```sql
select
    product_category,
    sum(case when gender = 'M' then 1 else 0 end) as male,
    sum(case when gender = 'F' then 1 else 0 end) as female
from sales
group by product_category
order by product_category;
```

### Business Impact:
- Enables gender-focused marketing
- Improves personalization

---

# 📌 Key Learnings

- Data cleaning is essential before analysis
- SQL can solve real business problems
- Window functions and aggregation are powerful tools
- Business insights can drive better decision-making

---

# ✅ Conclusion

This project transforms raw store sales data into actionable business insights using SQL.

It demonstrates:
- Strong data cleaning skills
- Analytical thinking
- Business-focused SQL queries
- Real-world problem solving

