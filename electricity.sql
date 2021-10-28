-- Initial Look at the Data
select  * 
from GlobalElectricity..Electricity_Production_By_Sourc$ as prod
order by Year

--Check for missing values
select * 
from GlobalElectricity..Electricity_Production_By_Sourc$ 
where Entity is null
--There is no missing values in entity columns
--I changed the column name entity to country on the columns tab in object explorer
select * 
from GlobalElectricity..Electricity_Production_By_Sourc$ 
where Year is null
--There is no missing values in Year column

select * 
from GlobalElectricity..Electricity_Production_By_Sourc$ 
where [Electricity from coal (TWh)] is null

-- in the return of query, I saw that there are null values in electricity production columns
-- i replace null cells with 0 

update GlobalElectricity..Electricity_Production_By_Sourc$ 
set [Electricity from coal (TWh)]= isnull([Electricity from coal (TWh)],0)
from GlobalElectricity..Electricity_Production_By_Sourc$ as prod
where prod.[Electricity from coal (TWh)] is null

update GlobalElectricity..Electricity_Production_By_Sourc$ 
set [Electricity from gas (TWh)]= isnull([Electricity from gas (TWh)],0)
from GlobalElectricity..Electricity_Production_By_Sourc$ as prod
where prod.[Electricity from gas (TWh)] is null

update GlobalElectricity..Electricity_Production_By_Sourc$ 
set [Electricity from hydro (TWh)]= isnull([Electricity from hydro (TWh)],0)
from GlobalElectricity..Electricity_Production_By_Sourc$ as prod
where prod.[Electricity from hydro (TWh)] is null

update GlobalElectricity..Electricity_Production_By_Sourc$ 
set [Electricity from other renewables (TWh)] = isnull([Electricity from other renewables (TWh)],0)
from GlobalElectricity..Electricity_Production_By_Sourc$ as prod
where prod.[Electricity from other renewables (TWh)] is null

update GlobalElectricity..Electricity_Production_By_Sourc$ 
set [Electricity from solar (TWh)]= isnull([Electricity from solar (TWh)],0)
from GlobalElectricity..Electricity_Production_By_Sourc$ as prod
where prod.[Electricity from solar (TWh)] is null

update GlobalElectricity..Electricity_Production_By_Sourc$ 
set [Electricity from oil (TWh)]= isnull([Electricity from oil (TWh)],0)
from GlobalElectricity..Electricity_Production_By_Sourc$ as prod
where prod.[Electricity from oil (TWh)] is null

update GlobalElectricity..Electricity_Production_By_Sourc$ 
set [Electricity from wind (TWh)]= isnull([Electricity from wind (TWh)],0)
from GlobalElectricity..Electricity_Production_By_Sourc$ as prod
where prod.[Electricity from wind (TWh)] is null

update GlobalElectricity..Electricity_Production_By_Sourc$ 
set [Electricity from nuclear (TWh)]= isnull([Electricity from nuclear (TWh)],0)
from GlobalElectricity..Electricity_Production_By_Sourc$ as prod
where prod.[Electricity from nuclear (TWh)] is null

--check if there is a null left
select*
from GlobalElectricity..Electricity_Production_By_Sourc$
where [Electricity from coal (TWh)] is null or
	[Electricity from gas (TWh)] is null or
	[Electricity from hydro (TWh)] is null or
	[Electricity from other renewables (TWh)] is null or
	[Electricity from solar (TWh)] is null or
	[Electricity from wind (TWh)] is null

	-- No, there is no null cell left
--Change and simplify the name of electricity source columns
use GlobalElectricity;
GO
exec sp_rename 'Electricity_Production_By_Sourc$.Electricity from coal (TWh)','Coal','column';
GO

use GlobalElectricity;
GO
exec sp_rename 'Electricity_Production_By_Sourc$.Electricity from gas (TWh)','Gas','column';
GO

use GlobalElectricity;
GO
exec sp_rename 'Electricity_Production_By_Sourc$.Electricity from hydro (TWh)','Hydro','column';
GO

use GlobalElectricity;
GO
exec sp_rename 'Electricity_Production_By_Sourc$.Electricity from other renewables (TWh)','Renewables','column';
GO

use GlobalElectricity;
GO
exec sp_rename 'Electricity_Production_By_Sourc$.Electricity from solar (TWh)','Solar','column';
GO

use GlobalElectricity;
GO
exec sp_rename 'Electricity_Production_By_Sourc$.Electricity from oil (TWh)','Oil','column';
GO

use GlobalElectricity;
GO
exec sp_rename 'Electricity_Production_By_Sourc$.Electricity from wind (TWh)','Wind','column';
GO

use GlobalElectricity;
GO
exec sp_rename 'Electricity_Production_By_Sourc$.Electricity from nuclear (TWh)','Nuclear','column';
GO

--Create a total production column
alter table	GlobalElectricity..Electricity_Production_By_Sourc$
ADD total_production float

select Coal+Gas+Hydro+Nuclear+Oil+Renewables+Solar+Wind as total_production
from GlobalElectricity..Electricity_Production_By_Sourc$

--Which years included in the data
select distinct year
from GlobalElectricity..Electricity_Production_By_Sourc$
order by 1

-- I want to work with last 21 years data so i will remove anything before 2000
delete from GlobalElectricity..Electricity_Production_By_Sourc$ 
where year < 2000

--I want to remove dublicate rows if there is any
--I will use CTE

with DubTableCTE as(
select *,
row_number() over (
partition by country, coal, gas, hydro, solar, oil, nuclear, renewables order by year ) row_num
from GlobalElectricity..Electricity_Production_By_Sourc$
)
delete 
from DubTableCTE
where row_num > 2
			
-------------
--how many rows do i have now?
select COUNT(*)
from GlobalElectricity..Electricity_Production_By_Sourc$

--how many countries I am analyzing
select count(distinct Country)
from GlobalElectricity..Electricity_Production_By_Sourc$

-- top 10 electricity producer countries
select top(10) country, round(sum(Coal+Gas+Hydro+Renewables+Solar+Oil+Wind+Nuclear),0)/21 as total_production
from GlobalElectricity..Electricity_Production_By_Sourc$
where Code is not null and Country !='World'
group by Country
order by total_production desc

-- Which country has the Highest coal electricity production based on average coal elec prodcution in the last 21 years
select top(10) country, round(avg(Coal),0) as ave_coal_pro
from GlobalElectricity..Electricity_Production_By_Sourc$
where Code is not null and Country !='World'
group by country
order by ave_coal_pro desc

-- Yearly total production
select country, year, round(sum(Coal+Gas+Hydro+Renewables+Solar+Oil+Wind+Nuclear),0) as ave_tot_pro
from GlobalElectricity..Electricity_Production_By_Sourc$
where Code is not null and Country !='World'
group by country, year
order by ave_tot_pro desc
--Generate values for total_production column
--it was giving me double of total production therefore i multiplied it with 0.5
update GlobalElectricity..Electricity_Production_By_Sourc$ 
set total_production = t2.tp
from GlobalElectricity..Electricity_Production_By_Sourc$ t1
	inner join(select country, year, sum(Coal+Gas+Hydro+Renewables+Solar+Oil+Wind+Nuclear)*0.5 as tp
	from GlobalElectricity..Electricity_Production_By_Sourc$ 
	group by country, year) as t2
	on t2.year=t1.year and t2.Country=t1.Country

-- Average Yearly production over the last 21 years
select country, round(sum(Coal+Gas+Hydro+Renewables+Solar+Oil+Wind+Nuclear)/21,0) as ave_tot_pro
from GlobalElectricity..Electricity_Production_By_Sourc$
where Code is not null and Country !='World'
group by country
order by ave_tot_pro desc

-- Countries who heavyly rely on coal electricity production
select country, sum(Coal) as coal_production, 100*(round(sum(coal)/sum(Coal+Gas+Hydro+Renewables+Solar+Oil+Wind+Nuclear),2)) as coal_percentage
from GlobalElectricity..Electricity_Production_By_Sourc$
where Code is not null and Country !='World' and Coal!=0 and Gas!=0 and Hydro!=0 and Renewables!=0
group by country
order by coal_percentage desc

--Create a green column
alter table	GlobalElectricity..Electricity_Production_By_Sourc$
ADD Green nvarchar(255)

--Create a renew percentage column
alter table	GlobalElectricity..Electricity_Production_By_Sourc$
ADD renew_percentage float 


-- Countries who heavyly rely on green resources for electricity production
select country, 100*(round(sum(Renewables+Solar+Nuclear)/sum(Coal+Gas+Hydro+Renewables+Solar+Oil+Wind+Nuclear),2)) as rp


------------------
--Generate values for renew_percentages 
update GlobalElectricity..Electricity_Production_By_Sourc$ 
set renew_percentage = t2.greenpercentage
from GlobalElectricity..Electricity_Production_By_Sourc$ t1
	inner join(select country, year, round(100*(sum(Renewables+Solar+Nuclear)/sum(total_consumption+0.00000001)),2) as greenpercentage
	from GlobalElectricity..Electricity_Production_By_Sourc$
	group by country, year) as t2
	on t2.year=t1.year and t2.Country=t1.Country

	--Generate values for green column
update GlobalElectricity..Electricity_Production_By_Sourc$
set Green = case when renew_percentage > 50 Then 'Green'
		else 'Not Green'
		end
from GlobalElectricity..Electricity_Production_By_Sourc$

--let's start working on electricity consumption data now
select * from GlobalElectricity..energy$

--countries who are in energy deficit (their consumption is higher than their production)
select p.country, p.year, p.total_production, p.renew_percentage, c.primaryenergyconsumption
	from GlobalElectricity..Electricity_Production_By_Sourc$ p
	inner join GlobalElectricity..energy$ c
	on p.Country=c.Entity and p.year=c.Year
	where c.primaryenergyconsumption > p.total_production