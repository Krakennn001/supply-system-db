-- Перечисление цветов
CREATE TYPE colors AS ENUM ('белый', 'черный', 'красный', 'синий', 'серый', 'зеленый', 'желтый', 'оранжевый', 'коричневый', 'фиолетовый');
-- Создание таблицы "Детали"
CREATE TABLE Details
(
	ID SERIAL PRIMARY KEY,
	Name VARCHAR(50),
	Color colors,
	Price INT ,
	Weight INT,
	Cheapness VARCHAR(10) GENERATED ALWAYS AS (
		CASE
			WHEN Price < 1000 THEN 'дешевый'
			ELSE 'дорогой'
		END
	) STORED
);
-- Создание таблицы "Поставщики"
CREATE TABLE Suppliers
(
	ID SERIAL PRIMARY KEY,
	Address VARCHAR(50),
	City VARCHAR(50),
	Rating INT,
	Reliability VARCHAR(10) GENERATED ALWAYS AS (
		CASE
			WHEN Rating < 6 THEN 'ненадежный'
			ELSE 'надежный'
		END
	) STORED,
	Name VARCHAR(50)
);
-- Создание таблицы "Проекты"
CREATE TABLE Projects
(
	ID SERIAL PRIMARY KEY,
	Address VARCHAR(50),
	City VARCHAR(50),
	Deadlines DATE,
	Budget INT,
	SupplySum INT,
	Name VARCHAR(50)
);
-- Создание таблицы "Поставки"
CREATE TABLE Supply
(
	Date DATE,
	DetailsAmount INT,
	SupplyCost INT,
	DetailID INT,
	SupplierID INT,
	ProjectID INT
);