USE SQLPROJECT

SELECT * FROM df_orders;

SELECT MAX(sale_price) from df_orders;
---Q.1 find top 10 highest reveue generating products 
SELECT top 10 product_id, (sale_price*quantity) as Revenue
from df_orders
group by product_id,(sale_price*quantity)
order by product_id,(sale_price*quantity) desc;

---Q.3 find top 5 highest selling products in each region
with cte as(
SELECT region,product_id,SUM(sale_price) as Sale
from df_orders
group by region,product_id)
SELECT * from (
SELECT * ,
RANK()over(partition by region order by Sale desc) as RN
from cte) a
where RN <=5;

---Q.4 find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
with cte as(
SELECT year(order_date) as order_year, month(order_date) as order_month,
SUM(sale_price) as Sale
from df_orders
group by year(order_date),month(order_date)
)
SELECT order_month,
SUM(case when order_year = 2022 then Sale else 0 end) as Sale_2022,
SUM(case when order_year = 2023 then Sale else 0 end) as Sale_2023
from cte A
group by order_month;

---Q.5 for each category which month had highest sales 
with cte as(
SELECT category,format(order_date,'yyyy-MM') as order_month_year,
SUM(sale_price) as Sale
from df_orders
group by category,format(order_date,'yyyy-MM')
---order by order_month_year
) 
SELECT * from(
SELECT *, row_number() Over(partition by category order by Sale desc) as rn
from cte )A 
where rn = 1

---Q.6 Which sub category had highest growth by profit in 2023 compare to 2022 ?
with cte as (
SELECT sub_category, year(order_date) as order_year,
SUM(sale_price) as Sale 
from df_orders
group by sub_category,year(order_date)
)
,cte1 as 
(
SELECT sub_category,
SUM(case when order_year = 2022 then Sale else 0 end) as Sales_2022,
SUM(case when order_year = 2023 then Sale else 0 end) as Sales_2023
from cte
group by sub_category
)
SELECT top 1 *, (Sales_2023 - Sales_2022) 
from cte1 
order by (Sales_2023 - Sales_2022) desc;

