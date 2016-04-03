
-- curl 'https://www.propertypriceregister.ie/website/npsra/ppr/npsra-ppr.nsf/Downloads/PPR-2016.csv/$FILE/PPR-2016.csv' >PPR-2016.csv

# PostgreSQL

# Get started
https://help.ubuntu.com/community/PostgreSQL

psql

#list databases
\l


# Connect to database
\connect PPR

# list tables
\dt

# describe table
\d+ PPR_FULL

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


# Search for tables
\dt ppr*

TRUNCATE TABLE PPR_IMP;

SET CLIENT_ENCODING='LATIN9';
COPY ppr_imp FROM '/home/mjensen/development/git/irelandpropertyprices/ppri_data/PPR_IMP.csv' DELIMITER ',' CSV HEADER;

TRUNCATE TABLE PPR_FULL;

INSERT INTO PPR_FULL
  (dateOfSale, address, postalCode, county, price, notFullMarketPrice, vatExclusive, description, propertySize)
SELECT to_date(dateOfSale, 'DD/MM/YYYY'), address, postalCode, county
  , case when vatexclusive = 'Yes' then to_number(price, '99999999999999')/100*1.135
    else to_number(price, '99999999999999')/100
    end price
  , notFullMarketPrice, vatExclusive, description
  , case
    when propertysize = 'less than 38 sq metres' then 'lt38sqm'
    when propertysize like '%n%os l% n% 38 m%adar cearnach' then 'lt38sqm'
    when propertysize like '% 38 % 125 %' then 'lt125sqm'
    when propertysize = 'greater than 125 sq metres' then 'gt125sqm'
    else null
    end propertySize
FROM PPR_IMP;

# By month
select extract(year from dateOfSale) || '-' || lpad(extract(month from dateOfSale)::text, 2, '0') mth, county, count(*) no_sold, round(median(price),2) med_price, round(avg(price), 2) avg_price, min(price) min_price, max(price) max_price, sum(price) cumm_sales
from PPR_FULL
where lower(county) like '%westmeath%'
GROUP BY mth, county
order by 1,2;

# By quarter
select extract(year from dateOfSale) || '-' || extract(quarter from dateOfSale) qrt, county, count(*) no_sold, round(median(price),2) med_price, round(avg(price), 2) avg_price, min(price) min_price, max(price) max_price, sum(price) cumm_sales
from PPR_FULL
where lower(county) like '%westmeath%'
GROUP BY qrt, county
order by 1,2;


select extract(year from dateOfSale) || '-' || extract(quarter from dateOfSale) qrt, county, count(*) no_sold, round(median(price),2) med_price, round(avg(price), 2) avg_price, min(price) min_price, max(price) max_price, sum(price) cumm_sales
from PPR_FULL
where lower(address) like '%ballymahon%' and lower(county) like '%longford%'
GROUP BY qrt, county
order by 1,2;

select extract(year from dateOfSale) || '-' || extract(quarter from dateOfSale) qrt, count(*) no_sold, round(avg(price), 2) avg_price, min(price) min_price, max(price) max_price, round(median(price),2) med_price, sum(price) cumm_sales
from PPR_FULL
where lower(address) like '%ballymahon%' and lower(county) like '%longford%'
GROUP BY qrt, county
order by 1;


# By year
select date_trunc('year', dateOfSale) yr, county, count(*) no_sold, round(avg(price), 2) avg_price, min(price) min_price, max(price) max_price, round(median(price),2) med_price, sum(price) cumm_sales
from PPR_FULL
where lower(address) like '%ballymahon%' and lower(county) like '%longford%'
GROUP BY yr, county
order by 1,2;

select extract(year from dateOfSale) yr, count(*) no_sold, sum(case when vatexclusive='Yes' then 1 else 0 end) new, sum(case when vatexclusive='No' then 1 else 0 end) old, round(avg(price), 2) avg_price, min(price) min_price, max(price) max_price, round(median(price),2) med_price, sum(price) cumm_sales
from PPR_FULL
where lower(address) like '%ballymahon%' and lower(county) like '%longford%'
GROUP BY yr, county
order by 1;


with ranked_test as (
 select extract(year from dateOfSale) yr, ntile(4) over (order by price) as quartile, price from ppr_full
  where lower(address) like '%ballymahon%' and lower(county) like '%longford%'
)
select yr, quartile, min(price), max(price)
 from ranked_test
group by yr, quartile
order by 1,2;

with ranked_test as (
 select extract(year from dateOfSale) yr, ntile(10) over (order by price) as tentile, price from ppr_full
  where lower(address) like '%ballymahon%' and lower(county) like '%longford%'
)
select yr, tentile-1, min(price), max(price)
 from ranked_test
group by yr, tentile
order by 1,2;

# Not working - yet
select * from crosstab(
'with ranked_test as (
 select extract(year from dateOfSale) yr, ntile(4) over (order by price) as quartile, price from ppr_full
  where lower(address) like ''%ballymahon%'' and lower(county) like ''%longford%''
)
select yr, quartile, min(price) price
 from ranked_test
group by yr, quartile
order by 1,2')
AS ct(year text, category_1 text, category_2 text, category_3 text, category_4 text);


copy (
select date_trunc('month', dateOfSale) mth, county, count(*), round(avg(price), 2) avg, min(price) min, max(price) max, round(median(price),2) median
from PPR_FULL
where lower(county) like 'kildare%'
GROUP BY mth, county
order by 1,2,3) to '/home/mjensen/development/git/irelandpropertyprices/ppri_data/kildare_month_data.csv' DELIMITER ',' CSV HEADER;


copy (
select date_trunc('month', dateOfSale) mth, county, count(*), round(avg(price), 2) avg, min(price) min, max(price) max, round(median(price),2) median
from PPR_FULL
where lower(county) like 'meath%'
GROUP BY mth, county
order by 1,2,3) to '/home/mjensen/development/git/irelandpropertyprices/ppri_data/meath_month_data.csv' DELIMITER ',' CSV HEADER;

create table county as select row_number() over (order by county) cid, county cname from ppr_full group by county order by 1;

# X
copy (
select
  extract('epoch' from dateofsale) epoch,
  c.cid,
  case
    when propertysize is null then 0 
    when propertysize = '' then 0 
    when propertysize = 'less than 38 sq metres' then 1
    when propertysize like '%n%os l% n% 38 m%adar cearnach' then 1
    when propertysize = 'greater than or equal to 38 sq metres and less than 125 sq metres' then 2
    when propertysize like 'n%os m% n% n% less than 38 sq metres%adar cearnach agus n%os l n% 125 m%adar cearnach' then 2
    when propertysize = 'greater than 125 sq metres' then 3
    else 4
  end propertysize
  from ppr_full p, county c
 where p.county = c.cname
 order by dateofsale, address
) to '/home/mjensen/development/git/irelandpropertyprices/octave/X.txt' DELIMITER ',' CSV;


# y
copy (
select
  price  from ppr_full p
 order by dateofsale, address
) to '/home/mjensen/development/git/irelandpropertyprices/octave/y.txt' DELIMITER ',' CSV;

# Export of cleaned up data set
copy (
select
  *  from ppr_full
 order by dateofsale, address
) to '/home/mjensen/development/git/irelandpropertyprices/ppri_data/PPR_CLEAN.csv' DELIMITER ',' CSV;


# Amazon ML: Export of cleaned up data set
copy (
select dateofsale,county,price,notfullmarketprice,vatexclusive,description,propertysize
     from ppr_full
 order by dateofsale, address
) to '/home/mjensen/development/git/irelandpropertyprices/ppri_data/PPR_CLEAN_AML.csv' DELIMITER ',' CSV;



# R

con <- dbConnect(PostgreSQL(), user= "mjensen", password="xxx", dbname="PPR")

rs <- dbSendQuery(con, "select * from ppr_full")
out <- dbApply(rs, INDEX = "Agent", FUN = function(x, grp) quantile(x$DATA, names=FALSE))

data = dbReadTable(con, "ppr_full")

attach(data)

plot(factor(county),price)



