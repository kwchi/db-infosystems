SELECT 
  EXTRACT(YEAR FROM o.order_date) AS year,
  TO_CHAR(o.order_date, 'Month') AS month,
  cat.name AS category,
  SUM(od.quantity * od.price) AS revenue
FROM orders o
JOIN orderdetails od ON od.order_id = o.id
JOIN products p ON od.product_id = p.id
JOIN categories cat ON p.category_id = cat.id
GROUP BY year, month, category
ORDER BY year, month, category;


