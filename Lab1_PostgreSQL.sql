CREATE DATABASE restaurant_db;

CREATE TABLE menu_categories (
	id SERIAL PRIMARY KEY
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dishes (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES menu_categories(id) ON DELETE SET NULL
);

CREATE TABLE orders (
	id SERIAL PRIMARY KEY,
	dish_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (dish_id) REFERENCES dishes(id) ON DELETE CASCADE
);

INSERT INTO menu_categories (name) VALUES ('Гарячі страви'), ('Супи'), ('Десерти');

INSERT INTO dishes (name, price, category_id) VALUES
('Борщ', 120.00, 8),
('Стейк', 250.00, 7),
('Чізкейк', 100.00, 9);

INSERT INTO orders (dish_id, quantity) VALUES
(7, 2),
(8, 1),
(9, 3);

SELECT d.id, d.name, d.price, c.name AS category
FROM dishes d
LEFT JOIN menu_categories c ON d.category_id = c.id;

SELECT o.id, d.name AS dish, o.quantity, o.order_date
FROM orders o
JOIN dishes d ON o.dish_id = d.id;

UPDATE dishes SET price = 270.00 WHERE name = 'Стейк';

UPDATE dishes SET category_id = 2 WHERE name = 'Чізкейк';

DELETE FROM orders WHERE id = 1;

DELETE FROM dishes WHERE name = 'Борщ';