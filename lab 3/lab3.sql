-- 1. Отримати всі товари на складі
SELECT * FROM Products;

-- 2. Порахувати загальну кількість товарів на складі
SELECT SUM(quantity) AS total_stock FROM Products;

-- 3. Вибрати всі категорії товарів
SELECT * FROM Categories;

-- 4. Вибрати всі замовлення з їхніми деталями
SELECT * FROM Orders JOIN OrderDetails ON Orders.id = OrderDetails.order_id;

-- 5. Вибрати всіх клієнтів, які робили замовлення
SELECT DISTINCT Customers.name FROM Customers JOIN Orders ON Customers.id = Orders.customer_id;

-- 6. Порахувати кількість замовлень у кожного клієнта
SELECT Customers.name, COUNT(Orders.id) AS order_count FROM Customers
LEFT JOIN Orders ON Customers.id = Orders.customer_id
GROUP BY Customers.name;

-- 7. Визначити середню суму замовлення
SELECT AVG(total_amount) AS avg_order_value FROM Orders;

-- 8. Вивести найдорожчий товар
SELECT * FROM Products ORDER BY price DESC LIMIT 1;

-- 9. Вивести товари, яких залишилося менше 10 одиниць
SELECT * FROM Products WHERE quantity < 10;

-- 10. Знайти максимальну та мінімальну ціну товару
SELECT MAX(price) AS max_price, MIN(price) AS min_price FROM Products;

-- 11. Вивести замовлення, зроблені за останній тиждень
SELECT * FROM Orders WHERE order_date >= NOW() - INTERVAL '7 days';

-- 12. Знайти всіх постачальників, які постачають певний товар
SELECT Suppliers.name FROM Suppliers JOIN Products ON Suppliers.id = Products.supplier_id
WHERE Products.name = 'Назва товару';

-- 13. Використання INNER JOIN: отримати всі замовлення з деталями товарів
SELECT Orders.id, Customers.name, Products.name, OrderDetails.quantity, OrderDetails.price
FROM Orders
INNER JOIN Customers ON Orders.customer_id = Customers.id
INNER JOIN OrderDetails ON Orders.id = OrderDetails.order_id
INNER JOIN Products ON OrderDetails.product_id = Products.id;

-- 14. Використання LEFT JOIN: знайти клієнтів, які не зробили жодного замовлення
SELECT Customers.name FROM Customers
LEFT JOIN Orders ON Customers.id = Orders.customer_id
WHERE Orders.id IS NULL;

-- 15. Використання RIGHT JOIN: знайти всі товари та їхні замовлення (включаючи ті, що не замовлялися)
SELECT Products.name, OrderDetails.quantity FROM Products
RIGHT JOIN OrderDetails ON Products.id = OrderDetails.product_id;

-- 16. Використання FULL JOIN: всі клієнти та їхні замовлення
SELECT Customers.name, Orders.id FROM Customers
FULL JOIN Orders ON Customers.id = Orders.customer_id;

-- 17. Використання CROSS JOIN: всі можливі комбінації товарів та постачальників
SELECT Products.name, Suppliers.name FROM Products CROSS JOIN Suppliers;

-- 18. Використання підзапиту: знайти товари, яких немає в замовленнях
SELECT name FROM Products WHERE id NOT IN (SELECT product_id FROM OrderDetails);

-- 19. Використання EXISTS: знайти постачальників, які постачали товари
SELECT name FROM Suppliers WHERE EXISTS (SELECT 1 FROM Products WHERE Products.supplier_id = Suppliers.id);

-- 20. Використання NOT EXISTS: знайти постачальників, які не постачали жодного товару
SELECT name FROM Suppliers WHERE NOT EXISTS (SELECT 1 FROM Products WHERE Products.supplier_id = Suppliers.id);

-- 21. Використання UNION: всі імена клієнтів та постачальників
SELECT name FROM Customers UNION SELECT name FROM Suppliers;

-- 22. Використання INTERSECT: імена, які зустрічаються і серед клієнтів, і серед постачальників
SELECT name FROM Customers INTERSECT SELECT name FROM Suppliers;

-- 23. Використання EXCEPT: клієнти, які не є постачальниками
SELECT name FROM Customers EXCEPT SELECT name FROM Suppliers;

-- 24. Використання CTE: середня ціна товарів у кожній категорії
WITH AvgPrice AS (
    SELECT category_id, AVG(price) AS avg_price FROM Products GROUP BY category_id
)
SELECT Categories.name, AvgPrice.avg_price FROM Categories
JOIN AvgPrice ON Categories.id = AvgPrice.category_id;

-- 25. Використання віконних функцій: ранжування замовлень за сумою
SELECT id, customer_id, total_amount, RANK() OVER (ORDER BY total_amount DESC) AS rank
FROM Orders;

-- 26. Вивести кількість замовлень кожного клієнта за останній місяць
SELECT customer_id, COUNT(*) FROM Orders
WHERE order_date >= NOW() - INTERVAL '1 month'
GROUP BY customer_id;

-- 27. Порахувати кількість товарів у кожній категорії
SELECT category_id, COUNT(*) FROM Products GROUP BY category_id;

-- 28. Вивести товари, які мають більше одного постачальника
SELECT id FROM Products GROUP BY id HAVING COUNT(supplier_id) > 1;

-- 29. Список товарів, які ніколи не були продані
SELECT name FROM Products WHERE id NOT IN (SELECT product_id FROM OrderDetails);

-- 30. Найдорожчі замовлення за місяць
SELECT * FROM Orders WHERE order_date >= NOW() - INTERVAL '1 month' ORDER BY total_amount DESC LIMIT 5;

-- 31. Визначити, які клієнти витратили найбільше грошей
SELECT customer_id, SUM(total_amount) FROM Orders GROUP BY customer_id ORDER BY SUM(total_amount) DESC;

-- 32. Отримати 3 найпопулярніші товари за кількістю замовлень
SELECT product_id, COUNT(*) FROM OrderDetails GROUP BY product_id ORDER BY COUNT(*) DESC LIMIT 3;

-- 33. Вивести клієнтів, які не замовляли більше 6 місяців
SELECT * FROM Customers WHERE id NOT IN (SELECT customer_id FROM Orders WHERE order_date >= NOW() - INTERVAL '6 months');

-- 34. Визначити найактивнішого постачальника
SELECT supplier_id, COUNT(*) FROM Products GROUP BY supplier_id ORDER BY COUNT(*) DESC LIMIT 1;

-- 35. Вивести всі рухи товарів зі складу
SELECT * FROM StockMovements;

-- 36. Порахувати кількість повернених товарів
SELECT SUM(quantity) FROM StockMovements WHERE movement_type = 'IN';

-- 37. Визначити товари, які найбільше відвантажувалися
SELECT product_id, SUM(quantity) FROM StockMovements WHERE movement_type = 'OUT' GROUP BY product_id ORDER BY SUM(quantity) DESC;

-- 38. Вивести клієнтів, які зробили більше 5 замовлень
SELECT customer_id FROM Orders GROUP BY customer_id HAVING COUNT(id) > 5;

-- 39. Порахувати загальну вартість всіх замовлень
SELECT SUM(total_amount) FROM Orders;

-- 40. Визначити кількість товарів, що були оновлені за останній місяць
SELECT COUNT(*) FROM Products WHERE last_updated >= NOW() - INTERVAL '1 month';
