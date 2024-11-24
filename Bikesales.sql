--CREATE DATABASE Bikesales

--TO CHECK PRICE OF PRODUCT AFTER DISCOUNT

SELECT product_id, quantity, list_price, discount,
SUM(list_price  * ((1 - discount) * quantity)) OVER (PARTITION BY product_id)  AS Product_price
FROM order_items
GROUP BY product_id, quantity, list_price, discount
ORDER BY product_id

SELECT *
FROM products

--TO CHECK THE PRICE OF THE PRODUCT AFTER DISCOUNT BY CUSTOMER DETAILS

SELECT DISTINCT C.customer_id, C.first_name, C.last_name,
OI.order_id, OI.item_id, OI.quantity, list_price, discount,
(list_price  * ((1 - discount) * quantity)) 
 AS Discounted_price ,
SUM(list_price  * ((1 - discount) * quantity)) OVER (PARTITION BY C.customer_id)  AS Product_price
FROM customers C
JOIN orders O
    ON C.customer_id = O.customer_id
JOIN order_items OI
    ON O.order_id = OI.order_id
GROUP BY C.customer_id, C.first_name, C.last_name,
OI.order_id, OI.item_id, OI.quantity, list_price, discount
	ORDER BY customer_id ASC

--TO CHECK THE PRICE OF THE PRODUCT AFTER DISCOUNT BY CUSTOMER DETAILS WITH CTE


WITH CTE_CUSTOMER_DETAILS AS
(
	SELECT DISTINCT C.customer_id, C.first_name, C.last_name,
OI.order_id, OI.item_id, OI.quantity, list_price, discount,
(list_price  * ((1 - discount) * quantity)) 
 AS Discounted_price ,
SUM(list_price  * ((1 - discount) * quantity)) OVER (PARTITION BY C.customer_id)  AS Product_price
FROM customers C
JOIN orders O
    ON C.customer_id = O.customer_id
JOIN order_items OI
    ON O.order_id = OI.order_id
GROUP BY C.customer_id, C.first_name, C.last_name,
OI.order_id, OI.item_id, OI.quantity, list_price, discount
)
SELECT DISTINCT first_name,last_name, Product_price
FROM CTE_CUSTOMER_DETAILS
 ORDER BY Product_price DESC

--TOTAL NUMBER OF QUANTITY ORDERED BY PURCHASE STATUS

WITH CTE_EXAMPLE AS
( 
SELECT  C.customer_id, C.first_name, C.last_name, 
SUM(OI.quantity) AS Total_quantity
FROM customers AS C
JOIN
 orders O 
  ON C.customer_id = O.customer_id
JOIN 
order_items OI
   ON O.order_id = OI.order_id
WHERE O.order_status = 4
GROUP BY C.customer_id, C.first_name, C.last_name
 )
SELECT 
MAX(Total_quantity) Max_total_order, MIN(Total_quantity) Min_total_order,
COUNT(Total_quantity) Count_order_by_purchase, SUM(Total_quantity) Total_order_by_purchase
FROM CTE_EXAMPLE

--TOTAL NO OF ORDER STATUS

WITH CTE_EXAMPLE_6 AS
( 
SELECT  C.customer_id, C.first_name, C.last_name, 
SUM(OI.quantity) AS Total_quantity
FROM customers AS C
JOIN
 orders O 
  ON C.customer_id = O.customer_id
JOIN 
order_items OI
   ON O.order_id = OI.order_id
GROUP BY C.customer_id, C.first_name, C.last_name
 )
	SELECT 
MAX(Total_quantity) Max_qty_order, MIN(Total_quantity) Min_qty_order,
COUNT(Total_quantity) Count_qty_order, SUM(Total_quantity) Total_qty_order
FROM CTE_EXAMPLE_6


-- TOTAL PURCHASE SALE MADE BY YEAR

SELECT DISTINCT YEAR(order_date) Year_sale, SUM(Total_product_price) OVER (PARTITION BY YEAR(order_date) 
	ORDER BY YEAR(order_date) ) AS Total_purhase_sale_by_year 
	FROM
(SELECT  C.customer_id, C.first_name, C.last_name, CA.category_name, order_date, 
OI.quantity, OI.list_price, OI.discount,
ROUND(SUM(OI.list_price  * ((1 - discount) * quantity))
OVER (PARTITION BY C.customer_id), 2)  AS Total_product_price
FROM customers AS C
JOIN
 orders O 
  ON C.customer_id = O.customer_id
JOIN 
order_items OI
   ON O.order_id = OI.order_id
JOIN
products P
   ON OI.product_id = P.product_id
JOIN 
brands B
   ON P.brand_id = B.brand_id
JOIN 
categories CA
   ON P.category_id = CA.category_id
WHERE O.order_status = 4
GROUP BY C.customer_id, C.first_name, C.last_name, CA.category_name, 
order_date, OI.quantity, OI.list_price, OI.discount
) AGG_TABLE


-- TOTAL PURCHASE SALE MADE BY MONTH

SELECT DISTINCT FORMAT(order_date, 'MMMM') Month_sale, SUM(Total_sale)
OVER (PARTITION BY FORMAT(order_date, 'MMMM') 
	ORDER BY MONTH(order_date) ) AS Total_purhase_sale_by_month 
	FROM
(SELECT C.customer_id, order_date,
OI.quantity, OI.list_price, OI.discount,
ROUND(SUM(OI.list_price  * ((1 - discount) * quantity))
OVER (PARTITION BY C.customer_id), 2)  AS Total_sale
FROM customers AS C
JOIN
 orders O 
  ON C.customer_id = O.customer_id
JOIN 
order_items OI
   ON O.order_id = OI.order_id
JOIN
products P
   ON OI.product_id = P.product_id
JOIN 
brands B
   ON P.brand_id = B.brand_id
JOIN 
categories CA
   ON P.category_id = CA.category_id
WHERE O.order_status = 4
GROUP BY C.customer_id,
order_date, OI.quantity, OI.list_price, OI.discount 
) AGG_TABLE2

--THE STAFF THAT MADE THE MOST SALE

WITH CTE_STAFF AS
(
SELECT DISTINCT ST.first_name, ST.last_name
, OI.quantity, list_price, discount,
(list_price  * ((1 - discount) * quantity)) 
 AS Discounted_price ,
ROUND(SUM(list_price  * ((1 - discount) * quantity))
OVER (PARTITION BY ST.first_name)  , 2 ) AS Product_price
FROM customers C
JOIN orders O 
    ON C.customer_id = O.customer_id
JOIN order_items OI
	ON O.order_id  = OI.order_id
JOIN staffs ST
	ON O.staff_id = ST.staff_id
GROUP BY  ST.first_name, ST.last_name
, OI.quantity, list_price, discount
)
SELECT DISTINCT first_name, last_name, Product_price
FROM CTE_STAFF
ORDER BY Product_price DESC

-- TO CHECK THE MANAGER FOR EACH STAFF

SELECT St1.staff_id, St1.first_name, St1.last_name,
St2.staff_id, St2.first_name, St2.last_name
FROM staffs St1
	JOIN staffs St2
ON St1.staff_id = St2.manager_id

----TOTAL QUANTITY PRODUCE BY STORE

SELECT ST.store_id, STS.store_name, SUM(ST.quantity) AS Total_quantity_by_store
FROM stocks ST
	JOIN stores STS 
ON ST.store_id = STS.store_id
GROUP BY ST.store_id, STS.store_name
ORDER BY Total_quantity_by_store DESC

-- TOTAL PRICE OF THE PRODUCT

WITH CTE_Total_price AS
(
SELECT DISTINCT C.customer_id,
OI.quantity, OI.list_price, OI.discount,
ROUND(SUM(OI.list_price  * ((1 - discount) * quantity)) OVER (PARTITION BY C.customer_id), 2)  AS Sum_total_product_price
, ROUND(MAX(OI.list_price  * ((1 - discount) * quantity)) OVER (PARTITION BY C.customer_id), 2)  AS Max_total_product_price
, ROUND(MIN(OI.list_price  * ((1 - discount) * quantity)) OVER (PARTITION BY C.customer_id), 2)  AS Min_total_product_price
, ROUND(AVG(OI.list_price  * ((1 - discount) * quantity)) OVER (PARTITION BY C.customer_id), 2)  AS Avg_total_product_price
FROM customers AS C
JOIN
 orders O 
  ON C.customer_id = O.customer_id
JOIN 
order_items OI
   ON O.order_id = OI.order_id
WHERE O.order_status = 4
GROUP BY C.customer_id, OI.quantity, OI.list_price, OI.discount
 )
 SELECT MAX(Max_total_product_price) Max_total_product_price,
 MIN(Min_total_product_price) Min_total_product_price
, AVG(Avg_total_product_price) Avg_total_product_price, 
SUM(Sum_total_product_price)Sum_total_product_price
 FROM CTE_Total_price
 ORDER BY Max_total_product_price  

