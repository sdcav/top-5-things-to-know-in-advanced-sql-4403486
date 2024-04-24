-- Sub queries

select *, (select AVG([Order Total]) from Red30Tech.dbo.OnlineRetailSales$) as avg_total 
from Red30Tech.dbo.OnlineRetailSales$
where [Order Total] >= 
				(select AVG([Order Total]) from Red30Tech.dbo.OnlineRetailSales$)

;
-- Sub Queries Multiple

select * from Red30Tech.dbo.SessionInfo$
select * from Red30Tech.dbo.SpeakerInfo$

select [Speaker Name], [Session Name], [Start Date], [End Date], [Room Name]
from Red30Tech.dbo.SessionInfo$
where [Speaker Name] in
						(select [Name] from Red30Tech.dbo.SpeakerInfo$
						where Organization = 'Two Trees Olive Oil')

/
select [Speaker Name], [Session Name], [Start Date], [End Date], [Room Name]
from Red30Tech.dbo.SessionInfo$ as ses
INNER JOIN (select [Name] from Red30Tech.dbo.SpeakerInfo$
						where Organization = 'Two Trees Olive Oil') as speak
ON ses.[Speaker Name] = speak.Name

/

select ProdCategory, ProdNumber, ProdName, [In Stock], (select AVG([In Stock]) from Inventory$)
from Red30Tech.dbo.Inventory$
where [In Stock] < (select AVG([In Stock]) from Red30Tech.dbo.Inventory$)

/

-- CTE writing

with avgtotal (AVG_TOTAL) as
(
	select AVG([Order Total]) as AVG_TOTAL from Red30Tech.dbo.OnlineRetailSales$)
	
	
select * from Red30Tech.dbo.OnlineRetailSales$, avgtotal
	where [Order Total] >= AVG_TOTAL

-- Recursive CTE

select * from EmployeeDirectory$

with DirectReports as (
		select [EmployeeID], [First Name], [Last Name], [Manager]
		from EmployeeDirectory$
		where EmployeeID = 42
		UNION ALL
		select e.[EmployeeID], e.[First Name], e.[Last Name], e.[Manager]
		from EmployeeDirectory$ as e
		inner join DirectReports as d on e.[Manager] = d.[EmployeeID]
)

--select * from DirectReports

select count(*) as Direct_Reports
from DirectReports as d
where d.EmployeeID != 42

-- CTE writing challenge


with Avg_In_Stock as (
	select AVG([In Stock]) as Avg_Stock from Red30Tech.dbo.Inventory$)


select ProdCategory, ProdNumber, ProdName, [In Stock] 
from Red30Tech.dbo.Inventory$
where [In Stock] < (select * from Avg_In_Stock)


-- Window functions

select CustName, count(distinct OrderNum) 
from OnlineRetailSales$
group by CustName
/
select OrderNum, OrderDate, CustName, ProdName, Quantity,
ROW_NUMBER() OVER(PARTITION BY CustName ORDER BY OrderDate DESC) as ROW_NUM
from OnlineRetailSales$

with ROW_NUMBERS as (
		select OrderNum, OrderDate, CustName, ProdName, Quantity,
ROW_NUMBER() OVER(PARTITION BY CustName ORDER BY OrderDate DESC) as ROW_NUM
from OnlineRetailSales$
)

select * from ROW_NUMBERS where ROW_NUM = 1

--- Challenge ROW_NUMBER

with ROW_NUMBERS as (
		select OrderNum, OrderDate, CustName, ProdCategory, ProdName, [Order Total],
ROW_NUMBER() OVER(PARTITION BY ProdCategory ORDER BY [Order Total] DESC) as ROW_NUM
from OnlineRetailSales$ where CustName = 'Boehm Inc.'
)

select * from ROW_NUMBERS where ROW_NUM <= 3


-- LAG() and LEAD()

--Preview data
select * from SessionInfo$
where [Room Name] = 'Room 102'
order by [Start Date] ASC

-- Query
select [Start Date], [End Date], [Session Name],

LAG([Session Name], 1) OVER (ORDER BY [Start Date] ASC) AS PreviousSession,
LAG([Start Date], 1) OVER (ORDER BY [Start Date] ASC) AS PreviousSessionStartTime, 

LEAD([Session Name], 1) OVER (ORDER BY [Start Date] ASC) AS NextSession,
LEAD([Start Date], 1) OVER (ORDER BY [Start Date] ASC) AS NextSessionStartTime 
from [Red30Tech].dbo.SessionInfo$
where [Room Name] = 'Room 102'

-- LAG/LEAD Challenge

-- preview data
select * from OnlineRetailSales$
/
-- query with CTE 
with order_by_days as (
select [OrderDate], SUM(Quantity) as Quantity_by_day
from OnlineRetailSales$
where ProdCategory = 'Drones'
group by OrderDate
)

select [OrderDate], Quantity_by_day,
LAG(Quantity_by_day,1) OVER (order by [OrderDate] ASC) as Quantity_Last_1_Order,
LAG(Quantity_by_day,2) OVER (order by [OrderDate] ASC) as Quantity_Last_2_Order,
LAG(Quantity_by_day,3) OVER (order by [OrderDate] ASC) as Quantity_Last_3_Order,
LAG(Quantity_by_day,4) OVER (order by [OrderDate] ASC) as Quantity_Last_4_Order,
LAG(Quantity_by_day,5) OVER (order by [OrderDate] ASC) as Quantity_Last_5_Order
from order_by_days


--- RANK() and DENSE_RANK() learning
-- preview data
select * from EmployeeDirectory$

-- Rank() skips values and Dense_Rank() does not 
select *, 
RANK() OVER (ORDER BY [Last Name]) as RANK_,
DENSE_RANK() OVER (ORDER BY [Last Name]) as DENSE_RANK_
from EmployeeDirectory$

-- Challenge exercise
-- preview data
select * from ConventionAttendees$

with RANKS as (
			select *, 
			--RANK() OVER (PARTITION BY [State] ORDER BY [Registration Date] ASC) as Registration_Rank,
			DENSE_RANK() OVER (PARTITION BY [State] ORDER BY [Registration Date] ASC) as Registration_Rank
			from ConventionAttendees$
)
select * from RANKS where Registration_Rank <= 3