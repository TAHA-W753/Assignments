--Question (1)
 List customers from the state of NY who have no phone number on file. Show their first name, last name, email and city with the aliases First Name, Last Name, Email and City. Sort by last name, then first name, and return only the first 10 rows.

--Query....
SELECT TOP 10
    first_name AS [First Name],
    last_name AS [Last Name],
    email AS Email,
    city AS City
FROM sales.customers
WHERE state = 'NY'
  AND phone IS NULL
ORDER BY last_name ASC, first_name ASC;


--Question (2)

Find products with a model year of 2017 or 2018, a list price between 500 and 1500, whose name contains Trek but does not contain Kids. Show product_id, product_name, model_year and list_price, sorted by list_price from highest to lowest.

--Query....
SELECT 
    product_id,
    product_name,
    model_year,
    list_price
FROM production.products
WHERE model_year IN (2017, 2018)
  AND list_price BETWEEN 500 AND 1500
  AND product_name LIKE '%Trek%'
  AND product_name NOT LIKE '%Kids%'
ORDER BY list_price DESC;

--Question (3)

(a) List the distinct values of order_status in sales.orders. (b) List orders that have not been shipped yet, placed at store 1 or 3 during 2018. Show order_id, customer_id, store_id, order_date and required_date, sorted by order_date.

--Query....
--(a)
SELECT DISTINCT order_status
FROM sales.orders;

--(b)
SELECT 
    order_id,
    customer_id,
    store_id,
    order_date,
    required_date
FROM sales.orders
WHERE order_status <> 4
  AND store_id IN (1, 3)
  AND YEAR(order_date) = 2018
ORDER BY order_date ASC;

--Question (4)

 For order_id = 1, show one row per order line with: order_id, order_date, customer full name, product_name, brand_name, category_name, quantity, list_price, discount and line_revenue, where line_revenue = quantity * list_price * (1 - discount) from sales.order_items.

 --Query....

 SELECT 
    o.order_id,
    o.order_date,
    c.first_name + ' ' + c.last_name AS customer_full_name,
    p.product_name,
    b.brand_name,
    cat.category_name,
    oi.quantity,
    oi.list_price,
    oi.discount,
    oi.quantity * oi.list_price * (1 - oi.discount) AS line_revenue
FROM sales.orders o
INNER JOIN sales.customers c ON o.customer_id = c.customer_id
INNER JOIN sales.order_items oi ON o.order_id = oi.order_id
INNER JOIN production.products p ON oi.product_id = p.product_id
INNER JOIN production.brands b ON p.brand_name = b.brand_id -- Note: b.brand_id = p.brand_id
INNER JOIN production.categories cat ON p.category_id = cat.category_id
WHERE o.order_id = 1;

--Question (5)

--Show every staff member with their store_name and their manager's full name. Staff who have no manager must still appear, with the manager shown as 'No Manager'.

--Query ....

SELECT 
    s.first_name + ' ' + s.last_name AS staff_name,
    st.store_name,
    ISNULL(m.first_name + ' ' + m.last_name, 'No Manager') AS manager_name
FROM sales.staffs s
INNER JOIN sales.stores st ON s.store_id = st.store_id
LEFT JOIN sales.staffs m ON s.manager_id = m.staff_id;

--Question (6)

List products that have never been ordered. Show product_id, product_name, brand_name and model_year.

--Query...
SELECT 
    p.product_id,
    p.product_name,
    b.brand_name,
    p.model_year
FROM production.products p
INNER JOIN production.brands b ON p.brand_id = b.brand_id
LEFT JOIN sales.order_items oi ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;

--Question (7)
(a) Create a view sales.vw_order_line_details that returns the Q4 details for all orders, also including store_name and order_status. (b) Query the view to return all order lines from January 2018, sorted by order_date, then order_id.

--Query...

-- Q7 (a)
CREATE VIEW sales.vw_order_line_details AS
SELECT 
    o.order_id,
    o.order_date,
    o.order_status,
    st.store_name,
    c.first_name + ' ' + c.last_name AS customer_full_name,
    p.product_name,
    b.brand_name,
    cat.category_name,
    oi.quantity,
    oi.list_price,
    oi.discount,
    oi.quantity * oi.list_price * (1 - oi.discount) AS line_revenue
FROM sales.orders o
INNER JOIN sales.stores st ON o.store_id = st.store_id
INNER JOIN sales.customers c ON o.customer_id = c.customer_id
INNER JOIN sales.order_items oi ON o.order_id = oi.order_id
INNER JOIN production.products p ON oi.product_id = p.product_id
INNER JOIN production.brands b ON p.brand_id = b.brand_id
INNER JOIN production.categories cat ON p.category_id = cat.category_id;
GO

-- Q7 (b)
SELECT *
FROM sales.vw_order_line_details
WHERE YEAR(order_date) = 2018 
  AND MONTH(order_date) = 1
ORDER BY order_date ASC, order_id ASC;


--Question (8)

--(a) Create a view production.vw_product_catalog with product_id, product_name, brand_name, category_name, model_year and list_price. (b) Using only this view, return all Electric Bikes priced above 3000, sorted by price from highest to lowest.

--Query...

--(a)
CREATE VIEW production.vw_product_catalog AS
SELECT 
    p.product_id,
    p.product_name,
    b.brand_name,
    cat.category_name,
    p.model_year,
    p.list_price
FROM production.products p
INNER JOIN production.brands b ON p.brand_id = b.brand_id
INNER JOIN production.categories cat ON p.category_id = cat.category_id;
GO

---(b)
SELECT *
FROM production.vw_product_catalog
WHERE category_name = 'Electric Bikes'
  AND list_price > 3000
ORDER BY list_price DESC;

--Question (9)
--Using sales.vw_order_line_details, show the total number of distinct orders and total revenue for each store in each year. Sort by store_name, then year.

SELECT 
    store_name,
    YEAR(order_date) AS order_year,
    COUNT(DISTINCT order_id) AS total_distinct_orders,
    SUM(line_revenue) AS total_revenue
FROM sales.vw_order_line_details
GROUP BY store_name, YEAR(order_date)
ORDER BY store_name ASC, order_year ASC;

--Question (10)

-- Q10. For each brand, show the number of products and the minimum, average and maximum list price. Keep only brands with more than 10 products, sorted by average price from highest to lowest.
    
    SELECT 
    b.brand_name,
    COUNT(p.product_id) AS product_count,
    MIN(p.list_price) AS min_price,
    AVG(p.list_price) AS avg_price,
    MAX(p.list_price) AS max_price
FROM production.brands b
INNER JOIN production.products p ON b.brand_id = p.brand_id
GROUP BY b.brand_name
HAVING COUNT(p.product_id) > 10
ORDER BY avg_price DESC;

--Question (11)
--Find products whose list price is higher than the average list price of their own category. Show product_name, category_name, list_price and the category's average price.

--Query 
SELECT 
    p.product_name,
    c.category_name,
    p.list_price,
    (
        SELECT AVG(p2.list_price)
        FROM production.products p2
        WHERE p2.category_id = p.category_id
    ) AS category_avg_price
FROM production.products p
INNER JOIN production.categories c ON p.category_id = c.category_id
WHERE p.list_price > (
    SELECT AVG(p2.list_price)
    FROM production.products p2
    WHERE p2.category_id = p.category_id
);


--Question (12)

--Q12. Find customers who placed at least one order in 2016 but no orders in 2018. Show customer_id, full name, email and state. Write the query twice: once with IN / NOT IN and once with EXISTS / NOT EXISTS.

--Query

-- Method 1: Using IN / NOT IN
SELECT 
    customer_id,
    first_name + ' ' + last_name AS full_name,
    email,
    state
FROM sales.customers
WHERE customer_id IN (
    SELECT customer_id 
    FROM sales.orders 
    WHERE YEAR(order_date) = 2016
)
AND customer_id NOT IN (
    SELECT customer_id 
    FROM sales.orders 
    WHERE YEAR(order_date) = 2018
);

-- Method 2: Using EXISTS / NOT EXISTS
SELECT 
    c.customer_id,
    c.first_name + ' ' + c.last_name AS full_name,
    c.email,
    c.state
FROM sales.customers c
WHERE EXISTS (
    SELECT 1 
    FROM sales.orders o 
    WHERE o.customer_id = c.customer_id 
      AND YEAR(o.order_date) = 2016
)
AND NOT EXISTS (
    SELECT 1 
    FROM sales.orders o 
    WHERE o.customer_id = c.customer_id 
      AND YEAR(o.order_date) = 2018
);


--Question (13)

--Using two CTEs in one WITH clause, first calculate the total revenue for each store, then the average of those store totals. Return only the stores whose revenue is above the average, with store_name, total_revenue, average and the difference.

--Query...

WITH StoreRevenue AS (
    SELECT 
        st.store_name,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
    FROM sales.stores st
    INNER JOIN sales.orders o ON st.store_id = o.store_id
    INNER JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY st.store_name
),
AvgStoreRevenue AS (
    SELECT AVG(total_revenue) AS avg_revenue
    FROM StoreRevenue
)
SELECT 
    sr.store_name,
    sr.total_revenue,
    ar.avg_revenue AS average,
    sr.total_revenue - ar.avg_revenue AS difference
FROM StoreRevenue sr
CROSS JOIN AvgStoreRevenue ar
WHERE sr.total_revenue > ar.avg_revenue;


--Question (14)

Using a recursive CTE, build the staff hierarchy starting from the staff member with no manager. Show staff_id, staff full name, manager_id, level (top = 1) and a reporting path such as Fabiola Jackson > Mireya Copeland > Genna Serrano.

--Query...
WITH StaffHierarchy AS (
    -- Anchor member (top-level manager)
    SELECT 
        staff_id,
        CAST(first_name + ' ' + last_name AS VARCHAR(255)) AS staff_full_name,
        manager_id,
        1 AS level,
        CAST(first_name + ' ' + last_name AS VARCHAR(MAX)) AS reporting_path
    FROM sales.staffs
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive member
    SELECT 
        s.staff_id,
        CAST(s.first_name + ' ' + s.last_name AS VARCHAR(255)),
        s.manager_id,
        sh.level + 1,
        sh.reporting_path + ' > ' + s.first_name + ' ' + s.last_name
    FROM sales.staffs s
    INNER JOIN StaffHierarchy sh ON s.manager_id = sh.-- Q15 (a)
WITH ProductSales2017 AS (
    SELECT 
        cat.category_name,
        p.product_name,
        SUM(oi.quantity) AS total_quantity,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue,
        DENSE_RANK() OVER (
            PARTITION BY cat.category_name 
            ORDER BY SUM(oi.quantity * oi.list_price * (1 - oi.discount)) DESC
        ) AS rnk
    FROM sales.orders o
    INNER JOIN sales.order_items oi ON o.order_id = oi.order_id
    INNER JOIN production.products p ON oi.product_id = p.product_id
    INNER JOIN production.categories cat ON p.category_id = cat.category_id
    WHERE YEAR(o.order_date) = 2017
    GROUP BY cat.category_name, p.product_name
)
SELECT 
    category_name,
    product_name,
    total_quantity,
    total_revenue,
    rnk AS rank
FROM ProductSales2017
WHERE rnk <= 3
ORDER BY category_name ASC, rank ASC;

-- Q15 (b)
WITH Months AS (
    SELECT 1 AS month_num
    UNION ALL
    SELECT month_num + 1
    FROM Months
    WHERE month_num < 12
),
MonthlySales2017 AS (
    SELECT 
        MONTH(o.order_date) AS month_num,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
    FROM sales.orders o
    INNER JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE YEAR(o.order_date) = 2017
    GROUP BY MONTH(o.order_date)
)
SELECT 
    m.month_num AS month_number,
    DATENAME(MONTH, DATEFROMPARTS(2017, m.month_num, 1)) AS month_name,
    ISNULL(ms.total_orders, 0) AS total_orders,
    ISNULL(ms.total_revenue, 0) AS total_revenue
FROM Months m
LEFT JOIN MonthlySales2017 ms ON m.month_num = ms.month_num
ORDER BY m.month_num ASC;
)
SELECT 
    staff_id,
    staff_full_name,
    manager_id,
    level,
    reporting_path
FROM StaffHierarchy
ORDER BY level, reporting_path;

--Question (15)

--(a) Using a CTE with a window function, find the top 3 products by 2017 revenue within each category. Show category_name, product_name, total quantity, total revenue and rank. (b) Using a recursive CTE that generates months 1 to 12, show the total orders and total revenue for every month of 2017, with month number and month name, showing 0 for months with no sales.

--Query...

-- Q15 (a)
WITH ProductSales2017 AS (
    SELECT 
        cat.category_name,
        p.product_name,
        SUM(oi.quantity) AS total_quantity,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue,
        DENSE_RANK() OVER (
            PARTITION BY cat.category_name 
            ORDER BY SUM(oi.quantity * oi.list_price * (1 - oi.discount)) DESC
        ) AS rnk
    FROM sales.orders o
    INNER JOIN sales.order_items oi ON o.order_id = oi.order_id
    INNER JOIN production.products p ON oi.product_id = p.product_id
    INNER JOIN production.categories cat ON p.category_id = cat.category_id
    WHERE YEAR(o.order_date) = 2017
    GROUP BY cat.category_name, p.product_name
)
SELECT 
    category_name,
    product_name,
    total_quantity,
    total_revenue,
    rnk AS rank
FROM ProductSales2017
WHERE rnk <= 3
ORDER BY category_name ASC, rank ASC;

-- Q15 (b)
WITH Months AS (
    SELECT 1 AS month_num
    UNION ALL
    SELECT month_num + 1
    FROM Months
    WHERE month_num < 12
),
MonthlySales2017 AS (
    SELECT 
        MONTH(o.order_date) AS month_num,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
    FROM sales.orders o
    INNER JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE YEAR(o.order_date) = 2017
    GROUP BY MONTH(o.order_date)
)
SELECT 
    m.month_num AS month_number,
    DATENAME(MONTH, DATEFROMPARTS(2017, m.month_num, 1)) AS month_name,
    ISNULL(ms.total_orders, 0) AS total_orders,
    ISNULL(ms.total_revenue, 0) AS total_revenue
FROM Months m
LEFT JOIN MonthlySales2017 ms ON m.month_num = ms.month_num
ORDER BY m.month_num ASC;