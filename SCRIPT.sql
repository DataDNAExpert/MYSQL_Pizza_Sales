CREATE DATABASE PIZZAHUT;
SELECT * FROM pizzas;
SELECT * FROM pizza_types;
SELECT * FROM ORDERS;
SELECT * FROM ORDER_DTL;
CREATE TABLE ORDERS
(
ORDER_ID INT NOT NULL,
ORDER_DATE date NOT NULL,
ORDER_TIME TIME NOT NULL,
primary key(ORDER_ID) 
);

CREATE TABLE ORDER_DTL
(
ORDER_DETAIL_ID INT NOT NULL,
ORDER_ID INT NOT NULL,
PIZZA_ID TEXT NOT NULL,
QUANTITY INT NOT NULL,
PRIMARY KEY (ORDER_DETAIL_ID)
);


-- CTRL+ / -- COMMENTS
-- 1.Retrieve the total number of orders placed.

SELECT COUNT(ORDER_ID) AS TOTAL_ORDER FROM ORDERS;

-- 2.Calculate the total revenue generated from pizza sales.
-- O.ORDER_DETAIL_ID,O.ORDER_ID,O.PIZZA_ID,O.QUANTITY,P.price, 
-- SELECT & CTR+B = BEAUTIFY
SELECT 
    ROUND(SUM(O.QUANTITY * P.price), 2) AS TOTAL_REVENUE
FROM
    order_dtl O,
    pizzas P
WHERE
    O.PIZZA_ID = P.pizza_id;

-- 3.Identify the highest-priced pizza.
SELECT 
    pizza_types.pizza_type_id, pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY PIZZAS.PRICE DESC
LIMIT 1;

-- 4.Identify the most common pizza size ordered.

SELECT 
    pizzas.size, COUNT(ORDER_DTL.order_detail_id) AS Order_Count
FROM
    ORDER_DTL
        JOIN
    pizzas ON ORDER_DTL.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY COUNT(order_dtl.order_detail_id) DESC;

-- 5.List the top 5 most ordered pizza types along with their quantities.
SELECT 
    PT.NAME, SUM(O.QUANTITY) AS QUANTITY
FROM
    PIZZA_TYPES PT,
    order_dtl O,
    PIZZAS P
WHERE
    O.PIZZA_ID = P.PIZZA_ID
        AND P.PIZZA_TYPE_ID = PT.PIZZA_TYPE_ID
GROUP BY PT.NAME
ORDER BY QUANTITY DESC
LIMIT 5;

-- 6.Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    PT.CATEGORY, SUM(O.QUANTITY) AS QUANTITY
FROM
    PIZZA_TYPES PT,
    order_dtl O,
    PIZZAS P
WHERE
    O.PIZZA_ID = P.PIZZA_ID
        AND P.PIZZA_TYPE_ID = PT.PIZZA_TYPE_ID
GROUP BY PT.CATEGORY
ORDER BY QUANTITY DESC;

-- 7.Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(ORDER_TIME) AS 'Hour', COUNT(ORDER_ID) AS ORD_Count
FROM
    ORDERS
GROUP BY HOUR(ORDER_TIME)
ORDER BY HOUR(ORDER_TIME) ASC;

-- 8.Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    PT.CATEGORY, COUNT(PT.NAME) AS COUNT
FROM
    PIZZA_TYPES PT
GROUP BY PT.CATEGORY;

-- 9.Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(SB.QUANTITY), 0) AS AVG_QTY_PERDAY
FROM
    (SELECT 
        ORD.order_DATE, SUM(DTL.QUANTITY) AS QUANTITY
    FROM
        ORDERS ORD
    JOIN ORDER_DTL DTL ON ORD.ORDER_ID = DTL.ORDER_ID
    GROUP BY ORD.ORDER_DATE) AS SB;

-- 10.Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    PT.NAME,ROUND(SUM(O.QUANTITY * P.price), 2) AS TOTAL_REVENUE
FROM
    order_dtl O,
    pizzas P,
    pizza_types PT
WHERE
    O.PIZZA_ID = P.pizza_id
AND P.PIZZA_TYPE_ID=PT.PIZZA_TYPE_ID
group by PT.NAME
ORDER BY TOTAL_REVENUE DESC
LIMIT 3;

-- 11.Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    PT.category,
    ROUND((ROUND(SUM(O.QUANTITY * P.price), 2) / (SELECT 
                    ROUND(SUM(O.QUANTITY * P.price), 2) AS TOTAL_REVENUE
                FROM
                    order_dtl O,
                    pizzas P
                WHERE
                    O.PIZZA_ID = P.pizza_id)) * 100,
            2) AS TOTAL_REVENUE
FROM
    order_dtl O,
    pizzas P,
    pizza_types PT
WHERE
    O.PIZZA_ID = P.pizza_id
        AND P.PIZZA_TYPE_ID = PT.PIZZA_TYPE_ID
GROUP BY PT.category
ORDER BY TOTAL_REVENUE DESC;

-- 12.Analyze the cumulative revenue generated over time.

SELECT SQ.ORDER_DATE, ROUND(SQ.REVENUE,2) AS REVENUE, 
ROUND(SUM(SQ.REVENUE) OVER (order by SQ.ORDER_DATE),2) AS CUM_REVENUE 
FROM 
(SELECT O.ORDER_DATE, SUM(DTL.QUANTITY * P.price) AS REVENUE 
FROM ORDERS O , order_dtl DTL , pizzas P
WHERE 
O.ORDER_ID = DTL.ORDER_ID
AND 
DTL.PIZZA_ID=P.pizza_id
GROUP BY O.ORDER_DATE
) AS SQ;

-- 13.Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT SSQ.NAME, SSQ.category, SSQ.REVENUE FROM 

(
SELECT SQ.NAME, SQ.CATEGORY	, SQ.REVENUE , 
RANK() OVER (partition by SQ.CATEGORY ORDER BY SQ.REVENUE DESC) AS RANKING

FROM 
 
(SELECT PT.name,PT.category, ROUND(SUM(DTL.QUANTITY * P.PRICE),2) AS REVENUE FROM 
pizza_types PT , 
PIZZAS P,
order_dtl DTL
WHERE DTL.PIZZA_ID = P.PIZZA_ID
AND P.PIZZA_TYPE_ID = PT.PIZZA_TYPE_ID
GROUP BY PT.NAME, PT.category
ORDER BY PT.category,REVENUE ASC) AS SQ )
AS SSQ
WHERE SSQ.RANKING <=3


