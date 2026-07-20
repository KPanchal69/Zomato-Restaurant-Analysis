CREATE TABLE main (
    RestaurantID INT PRIMARY KEY,
    RestaurantName VARCHAR(255),
    CountryCode INT,
    City VARCHAR(100),
    Address TEXT,
    Locality VARCHAR(255),
    LocalityVerbose TEXT,
    Longitude DECIMAL(10,7),
    Latitude DECIMAL(10,7),
    Cuisines TEXT,
    Currency VARCHAR(100),
    Has_Table_booking VARCHAR(5),
    Has_Online_delivery VARCHAR(5),
    Is_delivering_now VARCHAR(5),
    Switch_to_order_menu VARCHAR(5),
    Price_range INT,
    Votes INT,
    Average_Cost_for_two DECIMAL(10,2),
    Rating DECIMAL(3,2),
    Datekey_Opening VARCHAR(20),
    Opening_Date DATE
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.4/Uploads/Main.csv'
INTO TABLE main
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
RestaurantID,
RestaurantName,
CountryCode,
City,
Address,
Locality,
LocalityVerbose,
Longitude,
Latitude,
Cuisines,
Currency,
Has_Table_booking,
Has_Online_delivery,
Is_delivering_now,
Switch_to_order_menu,
Price_range,
Votes,
Average_Cost_for_two,
Rating,
Datekey_Opening,
@Opening_Date
)
SET
Opening_Date = CASE
    WHEN @Opening_Date = '' THEN NULL
    ELSE STR_TO_DATE(@Opening_Date, '%d-%b-%y')
END;

select * from main;

select * from currency;

select * from country;

select * from date_;

#Q1 Build Data Model

select
	m.RestaurantName,
    m.City,
    co.Countryname,
    cu.USD_Rate,
    da.Year_,
    da.Quarter_,
    da.MonthName_	
from main m
left join country co
	on m.CountryCode=co.CountryID
left join currency cu
	on m.Currency=cu.Currency
left join date_ da
	on m.Datekey_Opening=da.DateKey;
    
#Q3 Average Cost into USD

select
	m.RestaurantName,
    m.Average_Cost_for_two,
    m.Currency,
    c.USD_Rate,
    Average_Cost_for_two*USD_Rate as CostUSD
from main m
join currency c
on m.Currency=c.Currency;

#Q4 Restaurants by City and Country

select
	co.Countryname,
    m.City,
    count(*) as Total_Restaurants
from main m
join country co
	on m.CountryCode=co.CountryID
group by 
	co.Countryname,
    m.City
order by
	Total_Restaurants desc;
    
#Q5. Number of Restaurants Opening based on Year, Quarter, Month

select
	d.Year_,
    d.Quarter_,
    d.Month_,
    d.MonthName_,
    count(*) as Total_Restaurants
from main m
join date_ d
	on m.Datekey_Opening=d.DateKey
group by
	d.Year_,
    d.Quarter_,
    d.Month_,
    d.MonthName_
order by
	d.Year_,
    d.Month_;
    
#Q6. Count of Restaurants based on Average Ratings

select
	Rating,
    count(*) as Total_Restaurants
from main
group by
	Rating
order by
	Rating desc;
    
#Q7. Create Price Buckets

select
	case
		when Average_Cost_for_two <= 500 then 'Budget'
        when Average_Cost_for_two <= 1000 then 'Affordable'
        when Average_Cost_for_two <= 2000 then 'Premium'
        else 'Luxury'
	end as Price_Bucket,
    count(*) as Total_Restaurants
from main
group by
	Price_Bucket
order by
	Total_Restaurants desc;
    
#Q8. Percentage of Restaurants based on Has_Table_booking

select
	Has_Table_booking,
    count(*) as Restaurants,
	round(count(*)*100/(select count(*) from main),2) as Precentage
from main
group by
	Has_Table_booking;
    
#Q9. Percentage of Restaurants based on Has_Online_delivery

select
	Has_Online_delivery,
    count(*) as Restaurants,
    round(count(*)*100/(select count(*) from main),2) as Precentage
from main
group by
	Has_Online_delivery;
    
#Q10. Develop Charts based on Cuisines, City, Ratings

#A. Top 10 Cities by Number of Restaurants

select
	City,
    count(*) as Total_Restaurants
from main
group by
	City
order by
	Total_Restaurants desc
limit 10;

#B. Top 10 Cuisines

select
	Cuisines,
    count(*) as Total_Restaurants
from main
group by
	Cuisines
order by
	Total_Restaurants desc
limit 10;

#C. Average Rating by City

select
	City,
    round(avg(Rating),2) as Average_Rating
from main
group by
	City
order by
	Average_Rating desc;
    
#Additional KPIs

#1. Average Cost for Two by City

select
	City,
    round(avg(Average_Cost_for_two),2) as Average_Cost
from main
group by
	City
order by
	Average_Cost desc;
    
#2. Top 10 Highest Rated Restaurants

select
	RestaurantName,
    City,
    Rating
from main
order by
	Rating desc
limit 10;

#3. Restaurants with Online Delivery by City

select
	City,
	sum(case when Has_Online_delivery = "Yes" then 1 else 0 end) as Online_Delivery,
    count(*) as Total_Restaurants
from main
group by
	City
order by
	Online_Delivery desc;