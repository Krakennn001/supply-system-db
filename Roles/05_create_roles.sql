CREATE USER Economist WITH NOLOGIN;
CREATE USER Director WITH NOLOGIN;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE suppliers, supply TO Economist;
GRANT SELECT ON TABLE details, projects, "ЭкономистДетали",
"ЭкономистПоставки", "ЭкономистПоставщики", "ЭкономистПроекты" TO Economist;

GRANT EXECUTE ON FUNCTION 
    eco_get_suppliers(VARCHAR), 
    eco_get_details(VARCHAR), 
    eco_get_projects(VARCHAR, INT, INT), 
    eco_get_supplies(VARCHAR, VARCHAR, INT, INT) 
TO Economist;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE suppliers, details, projects TO Director;
GRANT SELECT, DELETE ON TABLE supply, "ДиректорДетали",
"ДиректорПоставки", "ДиректорПоставщики", "ДиректорПроекты" TO Director;

GRANT EXECUTE ON FUNCTION 
    dir_get_suppliers_report(VARCHAR), 
    dir_get_details_report(VARCHAR), 
    dir_get_projects_report(VARCHAR), 
    dir_get_total_supplies_sum(), 
    dir_get_sum_by_cheapness(VARCHAR), 
    dir_get_sum_by_reliability(VARCHAR), 
    dir_get_sum_by_supplier(VARCHAR, VARCHAR) 
TO Director;

REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;

CREATE USER Andrey WITH LOGIN PASSWORD '123' IN ROLE Economist;
CREATE USER Vyacheslav WITH LOGIN PASSWORD '321' IN ROLE Director;