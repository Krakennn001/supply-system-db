-- HASH индекс
CREATE INDEX idx_projects_city ON projects USING HASH(city);
-- B-tree индекс
CREATE INDEX idx_projects_budget ON projects(budget);
CREATE INDEX idx_supply_cost ON supply(supplycost);
CREATE INDEX idx_suppliers_rating ON suppliers(rating);
CREATE INDEX idx_details_price ON details(price);
