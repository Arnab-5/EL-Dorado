--Customer Retention Analysis

create table orders (
    order_id int primary key,
    customer_id int,
    order_date date,
    amount decimal(10,2)
);


insert into orders (order_id, customer_id, order_date, amount) values
(1, 101, '2024-01-05', 1200.00),
(2, 102, '2024-01-12', 850.00),
(3, 101, '2024-02-03', 1500.00),
(4, 103, '2024-02-14', 300.00),
(5, 102, '2024-02-20', 920.00),
(6, 104, '2024-03-01', 2100.00),
(7, 101, '2024-03-15', 1800.00),
(8, 105, '2024-03-22', 450.00),
(9, 103, '2024-04-10', 670.00),
(10, 106, '2024-04-18', 990.00);


with total_revenues as(
select datefromparts(year(order_date), month(order_date), 1) as months,
customer_id,
sum(amount) as total_revenue  
from orders
group by datefromparts(year(order_date), month(order_date), 1),customer_id
),

cumulative as(

select customer_id,months,
total_revenue, 
sum(total_revenue) over(partition by customer_id order by months
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as ITV
from total_revenues

),

counts as (

select customer_id,months,
total_revenue,ITV ,

count(months) over(partition by customer_id ) as total_months,
count(months) over(partition by customer_id
order by months ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) as periodd
from 
cumulative
),

xyz as(

select customer_id,months,
total_revenue,ITV, periodd,total_months,

lag(total_revenue) over(partition by  customer_id order by months) 
 as previous_month

 from counts
),


 grow as (

select customer_id,months,
total_revenue,ITV, periodd,total_months,
previous_month,
case
	when previous_month is null then 0
	else
	ROUND(100*(total_revenue-previous_month)/previous_month,2)
end as growth_rate

from xyz

),

growth as(

select customer_id,months,
total_revenue,ITV, periodd,total_months,
previous_month,growth_rate,

Case
	when previous_month is null then 'First order'
	when previous_month < total_revenue then 'Growth'
	else
	'Decline'
end as Growth_status

from grow
)

select customer_id,months,
total_revenue,ITV, periodd,total_months,
previous_month,growth_rate,growth_status from growth

