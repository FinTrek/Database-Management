-- 1. Which are the top 5 area codes with declining profits in terms of percentage and how
-- much did the profits decline for these 5 area codes? This comparison should be done on
-- an annual basis including all the products.
CREATE or replace View firstprod AS(
select areacode, sum(profit) profit2012
from  factcoffee
where extract(year from factdate) = 2012
group by areacode);

Create or replace view secondprod as(
select areacode, sum(profit) profit2013
from  factcoffee
where extract(year from factdate) = 2013
group by areacode);

SELECT firstprod.areacode, round(((profit2013 - profit2012) / profit2012) * 100,2) percentprofit, profit2012, profit2013
FROM firstprod FULL JOIN secondprod ON firstprod.areacode = secondprod.areacode
order by percentprofit
FETCH FIRST 5 ROWS WITH TIES;

SELECT firstprod.areacode, round(((profit2013 - profit2012) / profit2012) * 100,2) percentprofit, profit2012, profit2013
FROM firstprod FULL JOIN secondprod ON firstprod.areacode = secondprod.areacode
order by firstprod.areacode
FETCH FIRST 5 ROWS WITH TIES;

-- 2. Which 5 states have the highest marketing expenses as a percentage of sales? This
-- comparison should be done on an annual basis including all the products.
CREATE or replace View state2012 AS(
select statecoffee.state, statecoffee.stateid, sum(marketing) marketing2012, sum(sales) sales2012
from statecoffee, factcoffee, areacoffee
where statecoffee.stateid = areacoffee.stateid
    and areacoffee.areacode = factcoffee.areacode
    and extract(year from factdate) = 2012
group by statecoffee.state, statecoffee.stateid);

CREATE or replace View state2013 AS(
select statecoffee.state, statecoffee.stateid, sum(marketing) marketing2013, sum(sales) sales2013
from statecoffee, factcoffee, areacoffee
where statecoffee.stateid = areacoffee.stateid
    and areacoffee.areacode = factcoffee.areacode
    and extract(year from factdate) = 2013
group by statecoffee.state, statecoffee.stateid);

CREATE or replace View marketstate AS(
SELECT state2012.state, state2012.stateid, round(marketing2012/sales2012, 2) marketcost2012, round(marketing2013/sales2013, 2) marketcost2013
FROM state2012 FULL JOIN state2013 ON state2012.state = state2013.state
order by marketcost2012 desc 
FETCH FIRST 5 ROWS WITH TIES);

SELECT state2012.state, state2012.stateid, round(marketing2012/sales2012, 3) marketcost2012, round(marketing2013/sales2013, 3) marketcost2013
FROM state2012 FULL JOIN state2013 ON state2012.state = state2013.state
order by marketcost2012 desc
FETCH FIRST 5 ROWS WITH TIES;

SELECT state2012.state, state2012.stateid, round(marketing2012/sales2012, 3) marketcost2012, round(marketing2013/sales2013, 3) marketcost2013
FROM state2012 FULL JOIN state2013 ON state2012.state = state2013.state
order by state
FETCH FIRST 5 ROWS WITH TIES;

-- 3. In each of these 5 states, find the top 10 area codes in terms of the spend on marketing
-- expenses relative to others?
select marketstate.state, marketstate.stateid, areacoffee.areacode, factarea.summarketing, marketrank 
from marketstate join areacoffee on marketstate.stateid = areacoffee.stateid
    join (select factcoffee.areacode, sum(marketing) summarketing, areacoffee.stateid,
        rank() over (partition by areacoffee.stateid order by sum(marketing) desc) marketrank
        from factcoffee, areacoffee
        where factcoffee.areacode = areacoffee.areacode
        group by factcoffee.areacode, areacoffee.stateid) factarea on areacoffee.areacode = factarea.areacode
where marketrank <= 10
order by marketstate.state, areacoffee.areacode;

-- 4. In each market, which products have the greatest increase in profits? This comparison
-- should be done on an annual basis including all the products.
CREATE or replace View profitview2012 AS(
select statecoffee.market, prodcoffee.product, sum(profit) profit2012
from factcoffee inner join areacoffee on factcoffee.areacode = areacoffee.areacode
    inner join prodcoffee on prodcoffee.productid = factcoffee.productid
    inner join statecoffee on statecoffee.stateid = areacoffee.stateid
where extract(year from factdate) = 2012
group by statecoffee.market, prodcoffee.product);

CREATE or replace View profitview2013 AS(
select statecoffee.market, prodcoffee.product, sum(profit) profit2013
from factcoffee inner join areacoffee on factcoffee.areacode = areacoffee.areacode
    inner join prodcoffee on prodcoffee.productid = factcoffee.productid
    inner join statecoffee on statecoffee.stateid = areacoffee.stateid
where extract(year from factdate) = 2013
group by statecoffee.market, prodcoffee.product);

SELECT profitview2012.market, profitview2012.product, profit2012, profit2013, round(((profit2013 - profit2012)/ profit2012) * 100, 5) profitchange 
FROM profitview2012 JOIN profitview2013 ON profitview2012.market = profitview2013.market 
    and profitview2012.product = profitview2013.product
order by profitview2012.market, profitview2012.product;

-- 5. All the budgeted numbers are expected targets for 2012 and 2013. Identify the top 5
-- states for the year 2012 that have higher actual numbers relative to budgeted numbers
-- for profits and sales.
CREATE or replace View budget2012 AS(
select state, sum(budgetprofit) sumbudgetprofit, sum(budgetsales) sumbudgetsales, sum(profit) sumprofit, sum(sales) sumsales
from statecoffee inner join areacoffee on statecoffee.stateid = areacoffee.stateid
    inner join factcoffee on factcoffee.areacode = areacoffee.areacode
where extract(year from factdate) = 2012
group by state);

select state, (sumprofit - sumbudgetprofit) diffprofit, sumprofit, sumbudgetprofit, (sumsales - sumbudgetsales) diffsales, sumsales, sumbudgetsales
from budget2012
order by state;