CREATE OR REPLACE VIEW ЭкономистДетали("Название", "Цена", "Цвет", "Вес", "Дешевизна")
AS
SELECT
	d.Name,
	d.Price,
	d.Color,
	d.Weight,
	d.Cheapness
FROM Details d
ORDER BY d.Price DESC, d.Name ASC, d.Color ASC, d.Weight ASC;

CREATE OR REPLACE VIEW ЭкономистПроекты("Название", "Город", "Адрес", "Бюджет")
AS
SELECT
	p.Name,
	p.City,
	p.Address,
	p.Budget
FROM Projects p
ORDER BY p.City ASC, p.Name ASC, p.Budget DESC;

CREATE OR REPLACE VIEW ЭкономистПоставщики("Название", "Город", "Адрес", "Рейтинг", "Надежность")
AS
SELECT
	s.Name,
	s.City,
	s.Address,
	s.Rating,
	s.Reliability
FROM Suppliers s
ORDER BY s.City ASC, s.Name ASC, s.Rating DESC;

CREATE OR REPLACE VIEW ЭкономистПоставки("Название детали", "Цвет детали",
"Дешевизна детали", "Название поставщика", "Город поставщика", "Надежность поставщика",
"Количество деталей", "Вес поставки", "Стоимость поставки")
AS
SELECT
	d.Name,
	d.Color,
	d.Cheapness,
	sr.Name,
	sr.City,
	sr.Reliability,
	s.DetailsAmount,
	d.Weight * s.DetailsAmount,
	s.SupplyCost
FROM Supply s
LEFT JOIN Details d
	ON s.DetailID = d.id
LEFT JOIN Suppliers sr
	ON s.SupplierID = sr.id
ORDER BY d.Name ASC, sr.Name ASC, s.SupplyCost DESC, d.Weight * s.DetailsAmount DESC;

CREATE OR REPLACE VIEW ДиректорДетали("Название", "Цена", "Цвет", "Дешевизна")
AS
SELECT
	d.Name,
	d.Price,
	d.Color,
	d.Cheapness
FROM Details d
ORDER BY d.Price DESC, d.Name ASC;

CREATE OR REPLACE VIEW ДиректорПроекты("Название", "Город", "Бюджет")
AS
SELECT
	p.Name,
	p.City,
	p.Budget
FROM Projects p
ORDER BY p.Budget DESC, p.City ASC, p.Name ASC;

CREATE OR REPLACE VIEW ДиректорПоставщики("Название", "Город", "Надежность")
AS
SELECT
	s.Name,
	s.City,
	s.Reliability
FROM Suppliers s
ORDER BY s.Reliability ASC, s.City ASC, s.Name ASC;

CREATE OR REPLACE VIEW ДиректорПоставки("Название детали", "Цвет детали",
"Дешевизна детали", "Название поставщика", "Город поставщика", "Надежность поставщика",
"Количество деталей", "Вес поставки", "Стоимость поставки")
AS
SELECT
	d.Name,
	d.Color,
	d.Cheapness,
	sr.Name,
	sr.City,
	sr.Reliability,
	s.DetailsAmount,
	s.DetailsAmount * d.Weight,
	s.SupplyCost
FROM Supply s
LEFT JOIN Details d
	ON s.DetailID = d.id
LEFT JOIN Suppliers sr
	ON s.SupplierID = sr.id
ORDER BY d.Cheapness ASC, sr.City ASC, sr.Reliability ASC, sr.City ASC, d.Name ASC, sr.Name ASC,
s.SupplyCost DESC, s.DetailsAmount * d.Weight DESC;