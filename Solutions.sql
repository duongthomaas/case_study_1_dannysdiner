-- Week 1 SQL Challenge - https://8weeksqlchallenge.com/case-study-1/ 

-- 1) What is the total amount each customer spent at the restaurant?

select
    customer_id ,
    sum (price) as total_spent
from sales as s
inner join menu as m
    on s.product_id = m.product_id
group by customer_id
order by customer_id ;

-- 2) How many days has each customer visited the restaurant?

select
    customer_id ,
    count ( distinct order_date) as number_of_visits
from sales
group by customer_id ;

-- 3) What was the first item from the menu purchased by each customer?

with cte as (
    select
        customer_id ,
        order_date ,
        rank () over (partition by customer_id order by order_date asc) as rn ,
        product_name
    from sales as s
    inner join menu as m
        on s.product_id = m.product_id
)
select
    customer_id ,
    product_name
from cte
where rn = 1
group by customer_id, product_name
order by customer_id;

-- 4) What is the most purchased item on the menu and how many times was it purchased by all customers?

select top 1
    product_name ,
    count (s.product_id) as number_of_purchases
from sales as s
inner join menu as m
    on s.product_id = m.product_id
group by product_name
order by count (s.product_id) desc ;

-- 5) Which item was the most popular for each customer?

with cte as (
    select
        customer_id ,
        product_name ,
        count (product_name) as number_of_orders ,
        rank () over (partition by customer_id order by number_of_orders desc) as rn
    from sales as s
    inner join menu as m
        on s.product_id = m.product_id
    group by 
        customer_id ,
        product_name
)
select
    *
from cte
where rn = 1 ;

-- 6) Which item was purchased first by the customer after they became a member?

with cte as (
    select
        s.customer_id ,
        order_date ,
        join_date ,
        product_name ,
        rank () over (partition by s.customer_id order by order_date asc) as rnk
    from sales as s
    inner join menu as men
        on s.product_id = men.product_id
    inner join members as m
        on s.customer_id = m.customer_id
    where order_date >= join_date
)
select
    customer_id ,
    product_name
from cte
where rnk = 1 ;

-- 7) Which item was purchased just before the customer became a member?

with cte as (
    select
        s.customer_id ,
        order_date ,
        join_date ,
        product_name ,
        rank () over (partition by s.customer_id order by order_date desc) as rnk
    from sales as s
    inner join menu as men
        on s.product_id = men.product_id
    inner join members as m
        on s.customer_id = m.customer_id
    where order_date < join_date
)
select
    customer_id ,
    product_name
from cte
where rnk = 1 ;

-- 8) What is the total items and amount spent for each member before they became a member?

select
    s.customer_id ,
    count (product_name) as total_items ,
    sum (price) as total_amount
from sales as s
inner join menu as m
    on s.product_id = m.product_id
inner join members as mem
    on s.customer_id = mem.customer_id
where order_date < join_date
group by
    s.customer_id    ;

-- 9) If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select
    s.customer_id ,
    sum ( (case when product_name <> 'sushi' then price * 10 else 0 end) + 2*(case when product_name = 'sushi' then price * 10 else 0 end) ) as total_points
from sales as s
inner join menu as m
    on s.product_id = m.product_id
group by
    s.customer_id    ;

-- 10) In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

select
    s.customer_id ,
    sum (case
            when s.order_date between mem.join_date and dateadd('day', 6, mem.join_date) then price * 10 * 2
            when product_name = 'sushi' then price * 10 * 2 
            else price * 10
        end) as total_points
from sales as s
inner join menu as m
    on s.product_id = m.product_id
inner join members as mem
    on s.customer_id = mem.customer_id
where date_trunc('month', s.order_date) = '2021-01-01'
group by s.customer_id ;

