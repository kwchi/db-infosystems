-- Створення користувачів
CREATE ROLE admin_user WITH LOGIN PASSWORD 'admin_pass' SUPERUSER;
CREATE ROLE moderator_user WITH LOGIN PASSWORD 'moderator_pass' CREATEDB;
CREATE ROLE regular_user WITH LOGIN PASSWORD 'user_pass';

-- Надання прав доступу
GRANT ALL PRIVILEGES ON DATABASE warehouse_management TO admin_user;
GRANT CONNECT ON DATABASE warehouse_management TO moderator_user;
GRANT CONNECT ON DATABASE warehouse_management TO regular_user;

-- Створення таблиць
CREATE TABLE Categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE Suppliers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contact_info VARCHAR(255)
);

CREATE TABLE Products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category_id INT REFERENCES Categories(id) ON DELETE SET NULL,
    supplier_id INT REFERENCES Suppliers(id) ON DELETE SET NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    quantity INT NOT NULL CHECK (quantity >= 0),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contact_info VARCHAR(255)
);

CREATE TABLE Orders (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES Customers(id) ON DELETE SET NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0)
);

CREATE TABLE OrderDetails (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES Orders(id) ON DELETE CASCADE,
    product_id INT REFERENCES Products(id) ON DELETE CASCADE,
    quantity INT NOT NULL CHECK (quantity > 0),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0)
);

CREATE TABLE StockMovements (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES Products(id) ON DELETE CASCADE,
    movement_type VARCHAR(3) CHECK (movement_type IN ('IN', 'OUT')),
    quantity INT NOT NULL CHECK (quantity > 0),
    movement_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Заповнення таблиць тестовими даними
INSERT INTO Categories (name) VALUES ('Електроніка'), ('Меблі'), ('Одяг');
INSERT INTO Suppliers (name, contact_info) VALUES
('Samsung', 'samsung@example.com'),
('IKEA', 'ikea@example.com'),
('Nike', 'nike@example.com');

INSERT INTO Products (name, category_id, supplier_id, price, quantity) VALUES
('Телевізор', 1, 1, 1000.00, 10),
('Стіл', 2, 2, 250.00, 5),
('Кросівки', 3, 3, 120.00, 20);

INSERT INTO Customers (name, contact_info) VALUES
('Олександр', 'alex@example.com'),
('Марина', 'marina@example.com');

INSERT INTO Orders (customer_id, total_amount) VALUES (1, 1120.00), (2, 250.00);

INSERT INTO OrderDetails (order_id, product_id, quantity, price) VALUES
(1, 1, 1, 1000.00),
(1, 3, 1, 120.00),
(2, 2, 1, 250.00);

INSERT INTO StockMovements (product_id, movement_type, quantity) VALUES
(1, 'OUT', 1),
(3, 'OUT', 1),
(2, 'OUT', 1);

-- SQL-запити для аналізу
-- Вибірка всіх даних з таблиці Products
SELECT * FROM Products;

-- Вибірка з умовою (товари, яких залишилося менше 10)
SELECT * FROM Products WHERE quantity < 10;

-- Сортування (товари за спаданням ціни)
SELECT * FROM Products ORDER BY price DESC;

-- Групування (кількість товарів у кожній категорії)
SELECT category_id, COUNT(*) FROM Products GROUP BY category_id;

-- Об'єднання таблиць (список замовлень із клієнтами)
SELECT o.id, c.name AS customer, o.total_amount FROM Orders o
JOIN Customers c ON o.customer_id = c.id;

-- Використання агрегатних функцій
SELECT COUNT(*) FROM Orders;
SELECT AVG(total_amount) FROM Orders;
SELECT SUM(total_amount) FROM Orders;

-- Унікальні значення в категоріях
SELECT DISTINCT name FROM Categories;

-- Максимальні та мінімальні значення ціни
SELECT MAX(price), MIN(price) FROM Products;

-- Середня кількість замовлень на клієнта
SELECT customer_id, COUNT(*) FROM Orders GROUP BY customer_id;

-- Загальна сума всіх транзакцій
SELECT SUM(total_amount) FROM Orders;

-- 1. Які товари є на складі?
SELECT p.id, p.name, p.quantity 
FROM Products p
WHERE p.quantity > 0;

-- 2. Скільки товарів було продано за останній місяць?
SELECT SUM(od.quantity) AS total_sold
FROM OrderDetails od
JOIN Orders o ON od.order_id = o.id
WHERE o.order_date >= NOW() - INTERVAL '1 month';

-- 3. Яка кількість товару була повернута на склад?
SELECT SUM(sm.quantity) AS total_returned
FROM StockMovements sm
WHERE sm.movement_type = 'IN';

-- 4. Які товари мають найбільшу кількість залишків?
SELECT id, name, quantity 
FROM Products
ORDER BY quantity DESC
LIMIT 10;

-- 5. Які товари були замовлені за останній тиждень?
SELECT DISTINCT p.id, p.name
FROM OrderDetails od
JOIN Orders o ON od.order_id = o.id
JOIN Products p ON od.product_id = p.id
WHERE o.order_date >= NOW() - INTERVAL '7 days';

-- 6. Скільки товарів закінчилися на складі за певний період?
SELECT COUNT(*) AS out_of_stock_products
FROM Products
WHERE quantity = 0;

-- 7. Які записи містять інформацію про зниження цін на товари?
SELECT *
FROM StockMovements
WHERE movement_type = 'PRICE_DROP';

-- 8. Які постачальники надали найбільше товару?
SELECT s.id, s.name, SUM(sm.quantity) AS total_supplied
FROM StockMovements sm
JOIN Products p ON sm.product_id = p.id
JOIN Suppliers s ON p.supplier_id = s.id
WHERE sm.movement_type = 'IN'
GROUP BY s.id, s.name
ORDER BY total_supplied DESC
LIMIT 10;

-- 9. Яка середня ціна на товар у категорії?
SELECT c.name AS category_name, AVG(p.price) AS avg_price
FROM Products p
JOIN Categories c ON p.category_id = c.id
GROUP BY c.name;

-- 10. Скільки товарів мають більше ніж одного постачальника?
SELECT COUNT(*) AS multiple_suppliers
FROM (
    SELECT id
    FROM Products
    GROUP BY id
    HAVING COUNT(DISTINCT supplier_id) > 1
) AS multi_suppliers;
