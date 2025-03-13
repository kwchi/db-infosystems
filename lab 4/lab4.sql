-- Створення користувацького типу ENUM для статусу товару
CREATE TYPE product_status AS ENUM ('available', 'out_of_stock', 'discontinued');

-- Додавання нового стовпця до таблиці Products
ALTER TABLE Products ADD COLUMN status product_status DEFAULT 'available';

-- Створення користувацької функції
CREATE OR REPLACE FUNCTION calculate_average_price(category_id_param INT) RETURNS NUMERIC AS $$
DECLARE
    avg_price NUMERIC;
BEGIN
    SELECT AVG(price) INTO avg_price FROM Products WHERE category_id = category_id_param;
    RETURN avg_price;
END;
$$ LANGUAGE plpgsql;

-- Перевірка її роботи
SELECT calculate_average_price(1);

-- Таблиця логування змін у замовленнях
CREATE TABLE order_log (
    log_id SERIAL PRIMARY KEY,
    order_id INT,
    operation CHAR(1), -- 'I' (Insert), 'U' (Update), 'D' (Delete)
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Функція для логування змін у таблиці Orders
CREATE OR REPLACE FUNCTION log_order_changes() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO order_log (order_id, operation)
    VALUES (NEW.id, LEFT(TG_OP, 1));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Прив’язка тригера до таблиці Orders
CREATE TRIGGER track_order_changes
AFTER INSERT OR UPDATE OR DELETE ON Orders
FOR EACH ROW
EXECUTE FUNCTION log_order_changes();

-- Автоматичне оновлення загальної вартості замовлення
CREATE OR REPLACE FUNCTION update_order_total() RETURNS TRIGGER AS $$
BEGIN
    UPDATE Orders
    SET total_amount = (SELECT SUM(price * quantity) FROM OrderDetails WHERE order_id = NEW.order_id)
    WHERE id = NEW.order_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_order_total_trigger
AFTER INSERT OR UPDATE OR DELETE ON OrderDetails
FOR EACH ROW
EXECUTE FUNCTION update_order_total();

-- Перевірка роботи
-- Додаємо нове замовлення
INSERT INTO Orders (customer_id, total_amount) VALUES (1, 0);

-- Додаємо товар у замовлення
INSERT INTO OrderDetails (order_id, product_id, quantity, price) 
SELECT 6, id, 3, price 
FROM Products 
WHERE id = 2;

-- Перевіряємо, чи оновився total_amount у Orders
SELECT * FROM Orders WHERE id = 1;

-- Перевіряємо логування змін
SELECT * FROM order_log;

-- Видалення замовлення
DELETE FROM Orders WHERE id = 1;

-- Перевірка, чи видалилось замовлення
SELECT * FROM order_log WHERE order_id = 1;

