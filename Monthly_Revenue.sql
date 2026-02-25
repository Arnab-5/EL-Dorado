
--Monthly Revenue



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
select count(order_id) as orders,
count(distinct customer_id) as customers,
format(order_date,'yyyy-MM') as months,
sum(amount) as total_revenue,
avg(amount)as monthly_average
from orders
group by format(order_date,'yyyy-MM')
),

previous_month as(
select months,orders,customers,total_revenue,
monthly_average,
lag(total_revenue,1,0) over(order by months)as previous_revenue
from total_revenues
),

cumulative as(

select months,orders,customers,
total_revenue,previous_revenue,
monthly_average,

sum(total_revenue) over(order by months
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as cummulative_rev

from previous_month),

mom as(
select months,orders,customers,
total_revenue,previous_revenue,
monthly_average,cummulative_rev,

case 
	when previous_revenue =0 then 0
	else
		total_revenue- previous_revenue
end as MOM_Change

from cumulative

),

mom_per as (

select months,orders,customers,
total_revenue,previous_revenue,
monthly_average,cummulative_rev,
MOM_Change,

case 
	when MOM_Change =0 then 0

else	
	ROUND(100*MOM_Change/previous_revenue,2)
end as MOM_Percentage

from mom
),

rnk as (

select months,orders,customers,
total_revenue,previous_revenue,
monthly_average,cummulative_rev,
MOM_Change,MOM_Percentage,

DENSE_RANK() over(order by total_revenue desc) as RANKS
from mom_per
)



select months,orders,customers,
total_revenue,previous_revenue,
monthly_average,cummulative_rev,
MOM_Change,MOM_Percentage,RANKS

from rnk

ORDER BY months



