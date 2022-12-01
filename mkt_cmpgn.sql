-- View entire data set 
SELECT * FROM Project.mkt;

-- WHO DO WE TARGET?
-- Re-group customers by education (UG-1316, PG-481, basic-419)
select education, count(ID) as 'No of Customers', 
case 
when education in ('graduation', '2n cycle') then 'UG'
when education in ('masters' ,'PhD') then 'PG'
else 'Basic'
end as 'EDLevel'
from project.mkt
group by education
order by 2 desc;

-- Customers by relationship status (relationship- 1430, single- 786)
select marital_status, Count(ID),
case
when marital_status in('absurd', 'alone', 'divorced', 'single', 'widow', 'yolo') then 'Single'
when marital_status in('married', 'together') then 'Relationship'
else 'null'
end as 'relationship status'
from project.mkt
group by Marital_status
order by 2 asc;

-- No_ of customers with children (kidhome-1120, teenhome-979 total 2019 0f 2216)
select kidhome, teenhome, ID,
case
when kidhome > 0 then (select sum(kidhome) from project.mkt) 
when teenhome > 0 then (select sum(teenhome) from project.mkt)
else 'no children'
end as 'offspring'
from project.mkt
order by ID asc;

-- No_ customers with both a kid and teen at home (398 of 2099)
select kidhome, teenhome, ID 
from project.mkt
where kidhome and teenhome = 1; 


-- WHAT DO OUR CUSTOMERS BUY AND WHERE
-- Customers purchases by education (store purchases are the highest followed by web and then catalogue)
select education, avg(numwebpurchases), avg(numcatalogpurchases), avg(numstorepurchases) 
from project.mkt
group by education;

-- Customer purchases by marital status [most customers shop in store, although outliers (absurd{cat 7.5}, (yolo(web 7)]
select marital_status, avg(numwebpurchases), avg(numcatalogpurchases), avg(numstorepurchases) 
from project.mkt
group by marital_status;

-- Deal purchases by marital status (people in a relationship shop deals more 467 vs 252 combined avg)
-- (2.3)
select avg(NumDealsPurchases) from project.mkt;

-- No_ of customers who purchased deals more than the average no of times 
select count(NumDealsPurchases), marital_status
from project.mkt
where numDealsPurchases > (select avg(NumDealsPurchases) from project.mkt)
group by marital_status;

-- Deal purchases by education this indicates the higher the level the higher number of deal purchases 
select avg(NumDealsPurchases), education
from project.mkt
group by education;

-- 719 customers shops deals 3 or more times 
select ID, NumDealspurchases
from project.mkt
where numDealsPurchases > (select avg(NumDealsPurchases) from project.mkt);


 -- Product purchases by education[ find highest selling products (wines are the highest selling products followed by meat,gold,fish and fruits)
select education, avg(mntwines), avg(mntfruits), avg(mntmeatproducts),
avg(mntfishproducts), avg(mntsweetproducts),avg(mntgoldprods)
from project.mkt group by education; 

-- Product purchases by customer marital status (absurd had the highest avg purchases overall)
select marital_status, avg(mntwines), avg(mntfruits), avg(mntmeatproducts),
avg(mntfishproducts), avg(mntsweetproducts),avg(mntgoldprods)
from project.mkt group by marital_status;


-- Find customers to send promotions to encourage purchase on least selling products 
-- avg no_ of fruit purchases (26)
select avg(mntfruits)
from project.mkt;

-- No_ of customers who purchased fruits below the avg num of fruit purchases 1581 
select ID, mntfruits
from project.mkt
where mntfruits <= (select avg(mntfruits) from project.mkt)
order by mntfruits asc;

-- Promotion resposes (333)
select ID,acceptedcmp1, acceptedcmp2, acceptedcmp3, acceptedcmp4, acceptedcmp5, response
from project.mkt 
where response > 0;


-- WHAT DO OUR CUSTOMWERS EARN ?
-- Income by education (outlier (basic 20k) UG and PG are within same range avg 50k)
select education, avg(income)
from project.mkt 
group by education;  

-- customers earning above average income (1084 OF 2216 earn above avg income )
select ID, Income from project.mkt 
where income > (select avg(income) from project.mkt)
order by income desc;

-- RFM analysis (recency, freqency and monetary) 

Select ID, recency, 
sum(numwebpurchases + numstorepurchases + numcatalogpurchases)"frequency" , 
sum( mntwines + mntfruits +mntmeatproducts + mntfishproducts + mntsweetproducts + mntgoldprods)"Monetary" 
from project.mkt
group by ID, recency
order by ID;

Select ID,
sum( mntwines + mntfruits +mntmeatproducts + mntfishproducts + mntsweetproducts + mntgoldprods)"Monetary" 
from project.mkt
group by ID;

-- Customer 11110 0 in frequency but has made purchases in meat, fruit and wines

-- To calculate RFM score 
-- To calculate recency, frequency and monetary score,  group in percentiles and give a score.
select ID, Recency,  
case
when recency between 0 and 5 then 5
when recency between 21 and 40 then 4
when recency between 41 and 60 then 3
when recency between 61 and 80 then 2
when recency between 81 and 100 then 1 
else 0
end as 'recency score',
case
when sum(numwebpurchases + numstorepurchases + numcatalogpurchases) between 0 and 5 then 1
when sum(numwebpurchases + numstorepurchases + numcatalogpurchases) between 6 and 10 then 2
when sum(numwebpurchases + numstorepurchases + numcatalogpurchases) between 11 and 15 then 3
when sum(numwebpurchases + numstorepurchases + numcatalogpurchases) between 16 and 20 then 4
when sum(numwebpurchases + numstorepurchases + numcatalogpurchases) between 21 and 25 then 5
else 5.5
end as 'frequency score',
case 
when sum( mntwines + mntfruits +mntmeatproducts + mntfishproducts + mntsweetproducts + mntgoldprods) between 0 and 500 then 1
when sum( mntwines + mntfruits +mntmeatproducts + mntfishproducts + mntsweetproducts + mntgoldprods) between 501 and 1000 then 2
when sum( mntwines + mntfruits +mntmeatproducts + mntfishproducts + mntsweetproducts + mntgoldprods) between 1001 and 1500 then 3
when sum( mntwines + mntfruits +mntmeatproducts + mntfishproducts + mntsweetproducts + mntgoldprods) between 1501 and 2000 then 4
when sum( mntwines + mntfruits +mntmeatproducts + mntfishproducts + mntsweetproducts + mntgoldprods) between 2001 and 2550 then 5
else 'outlier'
end as 'Monetary score'
from project.mkt
group by ID,recency
order by ID;






