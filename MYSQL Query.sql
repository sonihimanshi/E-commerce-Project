create database olist;
use olist;

## KPI 1: Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics
## KPI 2:Number of Orders with review score 5 and payment type as credit card.
## KPI 3: Average number of days taken for order_delivered_customer_date for pet_shop
## KPI 4: Average price and payment values from customers of sao paulo city
## KPI 5: Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.

select * from  olist_customers_dataset;
select * from olist_geolocation_dataset;
select * from olist_order_items_dataset;
select * from olist_order_payments_dataset;
select* from olist_order_reviews_dataset;
select * from  olist_orders_dataset;
select * from olist_products_dataset;
select * from olist_sellers_dataset;
select * From product_category_name_translation;

##-------KPI 1-------##
## Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics

select kpi1.day_end, concat(round(kpi1.total_pmt/(select sum(payment_value) from 
olist_order_payments_dataset)*100,2), "%" )as perc_pmtvalue
from 
(select ord.day_end, sum(pmt.payment_value) as total_pmt
from olist_order_payments_Dataset as pmt join
(select distinct(order_id), case when weekday(order_purchase_timestamp) in (5,6) then "Weekend"
else "Weekday" end as Day_End from olist_orders_dataset) as ord on ord.order_id=pmt.order_id group by ord.day_end)
as kpi1;

-------- # KPI 2--------
## Number of Orders with review score 5 and payment type as credit card.

select count(pmt.order_id)
as total_orders from olist_order_payments_dataset as pmt  inner join
olist_order_reviews_dataset as rev on pmt.order_id = rev.order_id 
where
rev.review_score = 5
and pmt.payment_type = "credit_card";

-------- # KPI 3----------
## Average number of days taken for order_delivered_customer_date for pet_shop

select prod.product_category_name,
round(avg(datediff(ord.order_delivered_customer_date , ord.order_purchase_timestamp)),0)
as avg_delivery_date
from olist_orders_dataset as ord join
(Select product_id , order_id , product_category_name from
olist_products_dataset join olist_order_items_dataset using (product_id)) as prod
on ord.order_id = prod.order_id where prod.product_category_name= "pet_shop" group by prod.product_category_name;

--------- # KPI 4 (A)------
## Average price from customers of sao paulo city

Select cust.customer_city,round(avg(pmt_price.price),0) as avg_price
from olist_customers_dataset as cust
join (select pymnt.customer_id,pymnt.payment_value,item.price from olist_order_items_dataset as item join
(Select ord.order_id,ord.customer_id,pmt.payment_value from olist_orders_dataset as ord
join olist_order_payments_dataset as pmt on ord.order_id=pmt.order_id) as pymnt
on item.order_id=pymnt.order_id) as pmt_price on cust.customer_id=pmt_price.customer_id where cust.customer_city="sao paulo";


-------- # KPI 4(B)------
## Payment values from customers of sao paulo city

Select cust.customer_city,round(avg(pmt.payment_value),0) as avg_payment_value 
from olist_customers_dataset cust inner join olist_orders_dataset ord 
on cust.customer_id=ord.customer_id inner join
olist_order_payments_dataset as pmt on ord.order_id=pmt.order_id 
where customer_city="sao paulo";

-------- # KPI 5--------
## Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.

Select rw.review_score,
round(avg(datediff(ord.order_delivered_customer_date,ord.order_purchase_timestamp)),0) 
as avg_Shipping_Days
from olist_orders_dataset as ord join olist_order_reviews_dataset rw on 
rw.order_id=ord.order_id group by rw.review_score order by rw.review_score;