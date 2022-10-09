--zad1

with 
Products
as
(
SELECT 
    SalesOrderID As SOid, 
    Det.ProductID As PRid, 
    OrderQty As qty,
    LineTotal As total, 
    Prod.Name As ProductName 
FROM Sales.SalesOrderDetail Det 
JOIN Production.Product Prod  ON Det.ProductID = Prod.ProductID
),
Customer
as
(
	SELECT SalesOrderID, p.FirstName, p.LastName, a.AddressLine1, EmailAddress
	FROM Sales.SalesOrderHeader soh
	JOIN Sales.Customer c ON c.CustomerID = soh.CustomerID
	JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
	JOIN Person.BusinessEntityAddress bea ON bea.BusinessEntityID = p.BusinessEntityID
	JOIN Person.Address a ON a.AddressID = bea.AddressID
	join Person.EmailAddress em on em.BusinessEntityID = p.BusinessEntityID
)

select
-- proszę odkomentować poniższe, jeśli REGEX nie jest wykonywany, bo program się zatnie
--	TOP 100 
	ProductName, 
	SalesOrderID, 
	qty, 
	total,
	FirstName + ' ' + LastName as name, 
	AddressLine1,
	EmailAddress
from Products
join Customer on SOid = Customer.SalesOrderID
where ProductName like 'Road%'


-- zad2. 


with EmployeeCTE(Employee, ManagerID, EmployeeID)
as
(
-- miało być tylko nazwisko, jeśli jednak potrzebne też imie to:
-- SELECT LastName + ' ' + FirstName as Employee, ManagerID, EmployeeID
SELECT LastName as Employee, ManagerID, EmployeeID
FROM HumanResources.Employee
JOIN Person.Contact ON HumanResources.Employee.ContactID = Person.Contact.ContactID
) 
select EmployeeCTE.Employee, e.Employee as Manager from EmployeeCTE
join EmployeeCTE e on EmployeeCTE.ManagerID = e.EmployeeID
order by EmployeeCTE.EmployeeID asc


--- zad 3

-- rozw 1:

declare 
@pagesize tinyint,
@pagenum tinyint
;

set @pagesize = 5;
set @pagenum = 4;

with 
Customers(SalesOrderID, BusinessEntityID, LastName, SubTotal)
as
(
	SELECT SalesOrderID, p.BusinessEntityID, p.LastName, soh.SubTotal 
	FROM Sales.SalesOrderHeader soh 
	JOIN Sales.Customer c ON c.CustomerID = soh.CustomerID
	JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
	JOIN Person.BusinessEntityAddress bea ON bea.BusinessEntityID = p.BusinessEntityID
	JOIN Person.Address a ON a.AddressID = bea.AddressID
),
CustomersSpendings(LastName, TotalSpendings, BusinessEntityID)
as 
(
	select 
		LastName,
		SUM(SubTotal) as TotalSpendings, 
		BusinessEntityID 
	from Customers
	group by LastName, BusinessEntityID
),
CustomerRanking(LastName, TotalSpendings, BusinessEntityID, Rank)
as
(
	select
		LastName,
		TotalSpendings,
		BusinessEntityID,
		ROW_NUMBER() over (order by TotalSpendings desc) as Rank
	from CustomersSpendings
)


select TOP 20
	LastName, 
	TotalSpendings,
	BusinessEntityID,
	(@pagenum - 2) as page
from CustomerRanking
where Rank between((@pagenum - 3) * @pagesize) + 1
and (@pagenum -2)* @pagesize
go

-- rozw 2 (ładniejsze):

declare 
@ntile tinyint
;

set @ntile = 4;

with 
Customers(SalesOrderID, BusinessEntityID, LastName, SubTotal)
as
(
	SELECT SalesOrderID, p.BusinessEntityID, p.LastName, soh.SubTotal 
	FROM Sales.SalesOrderHeader soh 
	JOIN Sales.Customer c ON c.CustomerID = soh.CustomerID
	JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
	JOIN Person.BusinessEntityAddress bea ON bea.BusinessEntityID = p.BusinessEntityID
	JOIN Person.Address a ON a.AddressID = bea.AddressID
),
CustomersSpendings(LastName, TotalSpendings, BusinessEntityID)
as 
(
	select TOP 20
		LastName,
		SUM(SubTotal) as TotalSpendings, 
		BusinessEntityID 
	from Customers
	group by LastName, BusinessEntityID
	order by TotalSpendings desc
),
Ranking as
(
	select 
		LastName,
		BusinessEntityID,
		TotalSpendings,
		NTILE(@ntile) over (order by TotalSpendings desc) as page
	from CustomersSpendings
)

select * from Ranking
where page = 2
go
