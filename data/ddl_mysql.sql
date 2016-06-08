drop database PPR;

create database PPR;

use PPR;

create table PPR_IMP (
  dateOfSale VARCHAR(16),
  address    VARCHAR(128),
  postalCode VARCHAR(32),
  county     VARCHAR(64),
  price      VARCHAR(32),
  notFullMarketPrice VARCHAR(16),
  vatExclusive       VARCHAR(16),
  description        VARCHAR(128),
  propertySize       VARCHAR(128)
);

create table PPR_FULL (
  dateOfSale DATE,
  address    VARCHAR(128),
  postalCode VARCHAR(32),
  county     VARCHAR(64),
  price      DECIMAL(10,2),
  notFullMarketPrice VARCHAR(16),
  vatExclusive       VARCHAR(16),
  description        VARCHAR(128),
  propertySize       VARCHAR(128)
);

INSERT INTO PPR_FULL
  (dateOfSale, address, postalCode, county, price, notFullMarketPrice, vatExclusive, description, propertySize)
SELECT STR_TO_DATE(dateOfSale,'%d/%m/%Y'), address, postalCode, county, REPLACE(price, ',',''), notFullMarketPrice, vatExclusive, description, propertySize
FROM PPR_IMP;


  (dateOfSale, address, postalCode, county, price, notFullMarketPrice, vatExclusive, description, propertySize)


-- --ignore-lines=1
mysqlimport --fields-terminated-by=, --fields-enclosed-by='"' --local -u root -p PPR PPR_IMP.csv



select (YEAR(dateOfSale) - 2010) * 4 + QUARTER(dateOfSale), county, count(*), avg(price), min(price), max(price)
from PPR_FULL
where lower(county) like 'meath%' or lower(county) like 'kildare%'
GROUP BY (YEAR(dateOfSale) - 2010) * 4 + QUARTER(dateOfSale), county
order by 1,2,3;


select YEAR(dateOfSale) yr, QUARTER(dateOfSale) qrt, (YEAR(dateOfSale) - 2010) * 4 + QUARTER(dateOfSale) totqrt, county, count(*), avg(price), min(price), max(price)
from PPR_FULL
where lower(county) like 'meath%' or lower(county) like 'kildare%'
GROUP BY YEAR(dateOfSale), QUARTER(dateOfSale), (YEAR(dateOfSale) - 2010) * 4 + QUARTER(dateOfSale), county
order by 1,2,5;


select YEAR(dateOfSale) yr, QUARTER(dateOfSale) qrt, (YEAR(dateOfSale) - 2010) * 4 + QUARTER(dateOfSale) totqrt, county, count(*), avg(price), min(price), max(price)
from PPR_FULL
where lower(county) like 'meath%' or lower(county) like 'kildare%'
GROUP BY YEAR(dateOfSale), QUARTER(dateOfSale), (YEAR(dateOfSale) - 2010) * 4 + QUARTER(dateOfSale), county
order by 1,2,5;



LOAD DATA LOCAL INFILE 'PPR_FULL'  
INTO TABLE PPR_FULL FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
(@date,INSTRUCTIONS)
SET date = STR_TO_DATE(@date,'%d/%m/%Y');

FIELDS ENCLOSED BY '"'



SELECT AVG(val) FROM (
SELECT x.val FROM
data x, data y GROUP BY x.val HAVING
((SUM(SIGN(1-SIGN(y.val-x.val))))>=floor((COUNT(*)+1)/2)) and
((SUM(SIGN(1+SIGN(y.val-x.val))))>=floor((COUNT(*)+1)/2)));


SELECT AVG(val) FROM (
SELECT x.val FROM
data x, data y GROUP BY x.val HAVING
((SUM(SIGN(1-SIGN(y.val-x.val))))>=floor((COUNT(*)+1)/2)) and
((SUM(SIGN(1+SIGN(y.val-x.val))))>=floor((COUNT(*)+1)/2)));

SET @R:=0;select val from (select val,(@R:=@R+1) r from table order by val asc) t where r=((select count(*)+1 from table) DIV 2);

CREATE PROCEDURE getmean() 
SELECT * FROM examples;


