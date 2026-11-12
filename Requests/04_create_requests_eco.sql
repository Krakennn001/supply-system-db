--=========================
--|ФУНКЦИИ ДЛЯ ЭКОНОМИСТА |
--=========================

DROP FUNCTION IF EXISTS eco_get_suppliers(VARCHAR);
CREATE OR REPLACE FUNCTION eco_get_suppliers(p_reliability VARCHAR DEFAULT 'все')
RETURNS SETOF "ЭкономистПоставщики" AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM "ЭкономистПоставщики"
    WHERE (p_reliability = 'все') OR ("Надежность" = p_reliability);
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS eco_get_details(VARCHAR);
CREATE OR REPLACE FUNCTION eco_get_details(p_cheapness VARCHAR DEFAULT 'все')
RETURNS SETOF "ЭкономистДетали" AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM "ЭкономистДетали"
    WHERE (p_cheapness = 'все') OR ("Дешевизна" = p_cheapness);
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS eco_get_projects(VARCHAR, INT, INT);
CREATE OR REPLACE FUNCTION eco_get_projects(
    p_city VARCHAR DEFAULT NULL, 
    p_min_budget INT DEFAULT NULL, 
    p_max_budget INT DEFAULT NULL
)
RETURNS SETOF "ЭкономистПроекты" AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM "ЭкономистПроекты"
    WHERE (p_city IS NULL OR "Город" = p_city)
      AND (p_min_budget IS NULL OR "Бюджет" >= p_min_budget)
      AND (p_max_budget IS NULL OR "Бюджет" <= p_max_budget);
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS eco_get_supplies(VARCHAR, VARCHAR, INT, INT);
CREATE OR REPLACE FUNCTION eco_get_supplies(
    p_cheapness VARCHAR DEFAULT NULL,
    p_reliability VARCHAR DEFAULT NULL,
    p_min_cost INT DEFAULT NULL,
    p_max_cost INT DEFAULT NULL
)
RETURNS SETOF "ЭкономистПоставки" AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM "ЭкономистПоставки"
    WHERE (p_cheapness IS NULL OR "Дешевизна детали" = p_cheapness)
      AND (p_reliability IS NULL OR "Надежность поставщика" = p_reliability)
      AND (p_min_cost IS NULL OR "Стоимость поставки" >= p_min_cost)
      AND (p_max_cost IS NULL OR "Стоимость поставки" <= p_max_cost);
END;
$$ LANGUAGE plpgsql;