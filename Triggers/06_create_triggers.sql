CREATE OR REPLACE FUNCTION CHECK_SUPPLIER_RELIABILITY()
RETURNS TRIGGER AS
$$
DECLARE
	supplier_rating INT;
	detail_price INT;
BEGIN
	SELECT price INTO detail_price FROM details d WHERE d.id = NEW.detailid;
	SELECT rating INTO supplier_rating FROM suppliers s WHERE s.id = NEW.supplierid;
	IF (detail_price >= 1000 AND supplier_rating < 6) THEN
		RAISE EXCEPTION USING
            MESSAGE = 'Нарушение правила поставщика',
            DETAIL = format('Ненадежный поставщик (рейтинг %s) дорогой детали (цена %s)',
                          supplier_rating, detail_price),
            HINT = 'Выберите поставщика с рейтингом >= 6 для дорогих деталей';
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION CHECK_SUPPLY_WEIGHT()
RETURNS TRIGGER AS
$$
DECLARE
	detail_weight INT;
BEGIN
	SELECT weight INTO detail_weight FROM details d WHERE d.id = NEW.detailid;
	IF (detail_weight * NEW.detailsamount) > 1500 THEN
		RAISE EXCEPTION USING
            MESSAGE = 'Нарушение правила поставки',
            DETAIL = format('Тяжелая поставка (%sкг). Максимальный вес: 1.500кг',
                          detail_weight * NEW.detailsamount),
            HINT = 'Уменьшите количество деталей в поставке';
	END IF;
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION CHECK_SUPPLIES_BUDGET()
RETURNS TRIGGER AS
$$
DECLARE
	project_id INT;
	project_budget INT;
	supplies_sum INT;
BEGIN
	SELECT NEW.projectid INTO project_id;
	SELECT budget INTO project_budget FROM projects p WHERE p.id = project_id;
	
	SELECT SUM(d.price * s.detailsamount) INTO supplies_sum
	FROM supply s
	JOIN details d ON s.detailid = d.id
	GROUP BY s.projectid
	HAVING s.projectid = project_id;

	IF supplies_sum > project_budget THEN
		RAISE EXCEPTION USING
            MESSAGE = 'Нарушение правила проекта',
            DETAIL = format('Проект %s (стоимость %s) превысил бюджет (%s))',
                          project_id, supplies_sum, project_budget),
            HINT = 'Используйте более дешевую поставку';
	END IF;
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION SET_DETAIL_CHEAPNESS()
RETURNS TRIGGER AS
$$
BEGIN
	IF NEW.price < 1000 THEN NEW.cheapness := 'дешевый';
	ELSE NEW.cheapness := 'дорогой';
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION SET_SUPPLIER_RELIABILITY()
RETURNS TRIGGER AS
$$
BEGIN
	IF NEW.rating < 6 THEN NEW.reliability := 'ненадежный';
	ELSE NEW.reliability := 'надежный';
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION SET_SUPPLY_COST()
RETURNS TRIGGER AS
$$
DECLARE
	detail_price INT;
BEGIN
	SELECT price INTO detail_price FROM details d WHERE d.id = NEW.detailid;
	NEW.supplycost := (detail_price * NEW.detailsamount);

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TRIGGER_CHECK_RELIABILITY
BEFORE INSERT OR UPDATE ON supply
FOR EACH ROW
EXECUTE FUNCTION CHECK_SUPPLIER_RELIABILITY();

CREATE TRIGGER TRIGGER_CHECK_WEIGHT
BEFORE INSERT OR UPDATE ON supply
FOR EACH ROW
EXECUTE FUNCTION CHECK_SUPPLY_WEIGHT();

CREATE TRIGGER TRIGGER_CHECK_BUDGET
BEFORE INSERT OR UPDATE ON supply
FOR EACH ROW
EXECUTE FUNCTION CHECK_SUPPLIES_BUDGET();

CREATE TRIGGER TRIGGER_SET_CHEAPNESS
BEFORE INSERT OR UPDATE ON details
FOR EACH ROW
EXECUTE FUNCTION SET_DETAIL_CHEAPNESS();

CREATE TRIGGER TRIGGER_SET_RELIABILITY
BEFORE INSERT OR UPDATE ON suppliers
FOR EACH ROW
EXECUTE FUNCTION SET_SUPPLIER_RELIABILITY();

CREATE TRIGGER TRIGGER_SET_SUPPLYCOST
BEFORE INSERT OR UPDATE ON supply
FOR EACH ROW
EXECUTE FUNCTION SET_SUPPLY_COST();