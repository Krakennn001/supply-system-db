--========================
--|ФУНКЦИИ ДЛЯ ДИРЕКТОРА |
--========================

-- ОТЧЕТ ПО ПОСТАВЩИКАМ
DROP FUNCTION IF EXISTS dir_get_suppliers_report(VARCHAR);
CREATE OR REPLACE FUNCTION dir_get_suppliers_report(filter_type VARCHAR DEFAULT 'all')
RETURNS TABLE (
    id INT, name VARCHAR, address VARCHAR, city VARCHAR, rating INT, 
    reliability VARCHAR, total_supply_cost NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    WITH SupplierSums AS (
        SELECT sp.ID, sp.name, sp.address, sp.city, sp.rating, sp.reliability,
               COALESCE(SUM(d.price * s.detailsamount), 0)::NUMERIC AS total_cost
        FROM Suppliers sp
        LEFT JOIN Supply s ON sp.ID = s.supplierID
        LEFT JOIN Details d ON s.detailID = d.ID
        GROUP BY sp.ID, sp.name, sp.address, sp.city, sp.rating, sp.reliability
    )
    SELECT ss.ID, ss.name, ss.address, ss.city, ss.rating, ss.reliability, ss.total_cost
    FROM SupplierSums ss
    WHERE 
        (filter_type = 'all') OR
        (filter_type = 'above_avg' AND ss.rating >= (SELECT AVG(sup2.rating) FROM Suppliers sup2)) OR
        (filter_type = 'below_avg' AND ss.rating <= (SELECT AVG(sup2.rating) FROM Suppliers sup2)) OR
        (filter_type = 'max' AND ss.rating = (SELECT MAX(sup2.rating) FROM Suppliers sup2)) OR
        (filter_type = 'min' AND ss.rating = (SELECT MIN(sup2.rating) FROM Suppliers sup2))
    ORDER BY ss.ID;
END;
$$ LANGUAGE plpgsql;


-- ОТЧЕТ ПО ДЕТАЛЯМ
DROP FUNCTION IF EXISTS dir_get_details_report(VARCHAR);
CREATE OR REPLACE FUNCTION dir_get_details_report(filter_type VARCHAR DEFAULT 'all')
RETURNS TABLE (
    id INT, name VARCHAR, color VARCHAR, price INT, weight INT, 
    cheapness VARCHAR, total_supply_cost NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    WITH DetailSums AS (
        SELECT d.ID, d.name, 
               d.color::VARCHAR AS color, 
               d.price, d.weight, d.cheapness,
               COALESCE(SUM(d.price * s.detailsamount), 0)::NUMERIC AS total_cost
        FROM Details d
        LEFT JOIN Supply s ON d.ID = s.detailID
        GROUP BY d.ID, d.name, d.color, d.price, d.weight, d.cheapness
    )
    SELECT ds.ID, ds.name, ds.color, ds.price, ds.weight, ds.cheapness, ds.total_cost
    FROM DetailSums ds
    WHERE 
        (filter_type = 'all') OR
        (filter_type = 'above_avg' AND ds.price >= (SELECT AVG(d2.price) FROM Details d2)) OR
        (filter_type = 'below_avg' AND ds.price <= (SELECT AVG(d2.price) FROM Details d2)) OR
        (filter_type = 'max' AND ds.price = (SELECT MAX(d2.price) FROM Details d2)) OR
        (filter_type = 'min' AND ds.price = (SELECT MIN(d2.price) FROM Details d2))
    ORDER BY ds.ID;
END;
$$ LANGUAGE plpgsql;


-- ОТЧЕТ ПО ПРОЕКТАМ
DROP FUNCTION IF EXISTS dir_get_projects_report(VARCHAR);
CREATE OR REPLACE FUNCTION dir_get_projects_report(filter_type VARCHAR DEFAULT 'all')
RETURNS TABLE (
    id INT, name VARCHAR, city VARCHAR, budget INT, total_supply_cost NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    WITH ProjectSums AS (
        SELECT p.ID, p.name, p.city, p.budget,
               COALESCE(SUM(d.price * s.detailsamount), 0)::NUMERIC AS total_cost
        FROM Projects p
        LEFT JOIN Supply s ON p.ID = s.projectID
        LEFT JOIN Details d ON d.ID = s.detailID
        GROUP BY p.ID, p.name, p.city, p.budget
    )
    SELECT ps.ID, ps.name, ps.city, ps.budget, ps.total_cost
    FROM ProjectSums ps
    WHERE 
        (filter_type = 'all') OR
        (filter_type = 'above_avg' AND ps.budget >= (SELECT AVG(p2.budget) FROM Projects p2)) OR
        (filter_type = 'below_avg' AND ps.budget <= (SELECT AVG(p2.budget) FROM Projects p2)) OR
        (filter_type = 'max' AND ps.budget = (SELECT MAX(p2.budget) FROM Projects p2)) OR
        (filter_type = 'min' AND ps.budget = (SELECT MIN(p2.budget) FROM Projects p2))
    ORDER BY ps.ID;
END;
$$ LANGUAGE plpgsql;


-- ОБЩАЯ СУММА ВСЕХ ПОСТАВОК
DROP FUNCTION IF EXISTS dir_get_total_supplies_sum();
CREATE OR REPLACE FUNCTION dir_get_total_supplies_sum()
RETURNS NUMERIC AS $$
DECLARE total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(d.price * s.detailsamount), 0)::NUMERIC INTO total
    FROM Supply s 
    LEFT JOIN Details d ON d.ID = s.detailID;
    RETURN total;
END;
$$ LANGUAGE plpgsql;


-- СУММА ПОСТАВОК ПО ТИПУ ДЕТАЛИ
DROP FUNCTION IF EXISTS dir_get_sum_by_cheapness(VARCHAR);
CREATE OR REPLACE FUNCTION dir_get_sum_by_cheapness(p_cheapness VARCHAR)
RETURNS NUMERIC AS $$
DECLARE total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(d.price * s.detailsamount), 0)::NUMERIC INTO total
    FROM Supply s 
    LEFT JOIN Details d ON d.ID = s.detailID
    WHERE d.cheapness = p_cheapness;
    RETURN total;
END;
$$ LANGUAGE plpgsql;


-- СУММА ПОСТАВОК ПО НАДЕЖНОСТИ
DROP FUNCTION IF EXISTS dir_get_sum_by_reliability(VARCHAR);
CREATE OR REPLACE FUNCTION dir_get_sum_by_reliability(p_reliability VARCHAR)
RETURNS NUMERIC AS $$
DECLARE total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(d.price * s.detailsamount), 0)::NUMERIC INTO total
    FROM Supply s 
    LEFT JOIN Details d ON d.ID = s.detailID
    LEFT JOIN Suppliers sp ON sp.ID = s.supplierID
    WHERE sp.reliability = p_reliability;
    RETURN total;
END;
$$ LANGUAGE plpgsql;


-- СУММА ПОСТАВОК КОНКРЕТНОГО ПОСТАВЩИКА
DROP FUNCTION IF EXISTS dir_get_sum_by_supplier(VARCHAR, VARCHAR);
CREATE OR REPLACE FUNCTION dir_get_sum_by_supplier(p_name VARCHAR, p_city VARCHAR)
RETURNS NUMERIC AS $$
DECLARE total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(d.price * s.detailsamount), 0)::NUMERIC INTO total
    FROM Supply s 
    LEFT JOIN Details d ON d.ID = s.detailID
    LEFT JOIN Suppliers sp ON sp.ID = s.supplierID
    WHERE sp.name = p_name AND sp.city = p_city;
    RETURN total;
END;
$$ LANGUAGE plpgsql;