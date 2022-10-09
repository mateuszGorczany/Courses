--zadanie 1

create function dbo.udf_first(@ID int, @separator char)
returns nvarchar(150)
as 
begin
return
(
select 
'"' + FirstName + '"' + @separator
+ '"' + LastName + '"' + @separator
+ '"' + EmailAddress + '"' + @separator
+  '"' + City + '"' 
from Person.EmailAddress EA
join Person.BusinessEntity BE on EA.BusinessEntityID = BE.BusinessEntityID
join Person.BusinessEntityAddress BEA on BEA.BusinessEntityID = BE.BusinessEntityID
join Person.Address A on BEA.AddressID = A.AddressID
join Person.Person P on P.BusinessEntityID = BE.BusinessEntityID
where P.BusinessEntityID = @ID
);
end

-- przykład
select dbo.udf_first(6, ';');


--zadanie 2
create function dbo.udf_second(@P int, @N int)
returns table as 
return 
(
    with cte as 
    (
        select 
        LastName,
        FirstName,
	    EmailAddress,
	    city,
	    NTILE(@P) OVER (order by city, LastName) as tile
    from Person.EmailAddress EA
    join Person.BusinessEntity BE on EA.BusinessEntityID = BE.BusinessEntityID
    join Person.BusinessEntityAddress BEA on BEA.BusinessEntityID = BE.BusinessEntityID
    join Person.Address A on BEA.AddressID = A.AddressID
    join Person.Person P on P.BusinessEntityID = BE.BusinessEntityID
    )
    select LastName, FirstName, EmailAddress, city from cte where tile = @N
);

select * from dbo.udf_second(2,2);


--zadanie 3

-- poniższe dane nie reprezentują "customer", ale "sales Person", wobec czego wykonanie 
-- zadania bez modyfikacji zapytania nie jest możliwe. 
-- W wyniku nie ma nazwiska odbiorcy, lecz jest nazwisko osoby sprzedającej

create function dbo.udf_third(@LAST_NAME varchar(30))
returns table as 
return 
(
select 
    FirstName + ' ' + LastName name, 
    OrderDate,
    SubTotal,
    Status,
    DueDate,
    ShipDate,
    TaxAmt,
    Comment,
    SOH.ModifiedDate
from Person.EmailAddress EA
join Person.BusinessEntity BE on EA.BusinessEntityID = BE.BusinessEntityID
join Person.BusinessEntityAddress BEA on BEA.BusinessEntityID = BE.BusinessEntityID
join Person.Address A on BEA.AddressID = A.AddressID
join Person.Person P on P.BusinessEntityID = BE.BusinessEntityID
join HumanResources.Employee Emp on P.BusinessEntityID = Emp.BusinessEntityID
join Sales.SalesPerson SP on SP.BusinessEntityID = Emp.BusinessEntityID
join Sales.SalesOrderHeader SOH on SOH.SalesPersonID = SP.BusinessEntityID
where LastName = @LAST_NAME
);

select * from dbo.udf_third('Jiang');

--zadanie 4

-- nie potrafiłem zdecydować, o które chodzi, więc napisałem oba

-- podział względem sumy cen sprzedanych itemów
create function dbo.udf_fourth(@limit int)
returns table as 
return
(
select distinct top (@limit) Emp.BusinessEntityID, FirstName, LastName, SalesYTD, AddressLine1 from Person.EmailAddress EA
join Person.BusinessEntity BE on EA.BusinessEntityID = BE.BusinessEntityID
join Person.BusinessEntityAddress BEA on BEA.BusinessEntityID = BE.BusinessEntityID
join Person.Address A on BEA.AddressID = A.AddressID
join Person.Person P on P.BusinessEntityID = BE.BusinessEntityID
join HumanResources.Employee Emp on P.BusinessEntityID = Emp.BusinessEntityID
join Sales.SalesPerson SP on SP.BusinessEntityID = Emp.BusinessEntityID
join Sales.SalesOrderHeader SOH on SOH.SalesPersonID = SP.BusinessEntityID
order by SalesYTD desc
);


-- podział względem ilości sprzedanych zamówień
alter function dbo.udf_fourth(@limit int)
returns table as 
return
(
select top (@limit)
    FirstName, 
    LastName,
    count(SalesOrderID) salesCount,
    JobTitle,
    HireDate,
    EmailAddress,
    AddressLine1,
    AddressLine2,
    BirthDate,
    Gender
from Person.EmailAddress EA
join Person.BusinessEntity BE on EA.BusinessEntityID = BE.BusinessEntityID
join Person.BusinessEntityAddress BEA on BEA.BusinessEntityID = BE.BusinessEntityID
join Person.Address A on BEA.AddressID = A.AddressID
join Person.Person P on P.BusinessEntityID = BE.BusinessEntityID
join HumanResources.Employee Emp on P.BusinessEntityID = Emp.BusinessEntityID
join Sales.SalesPerson SP on SP.BusinessEntityID = Emp.BusinessEntityID
join Sales.SalesOrderHeader SOH on SOH.SalesPersonID = SP.BusinessEntityID
group by 
    FirstName, 
    LastName, 
    EmailAddress, 
    AddressLine1, 
    AddressLine2, 
    BE.BusinessEntityID,
    JobTitle,
    BirthDate,
    Gender,
    HireDate
order by salesCount desc
);


-- użycie:
select * from dbo.udf_fourth(17);

--zadanie 5
create view rand_view as select RAND() as value; 

create function dbo.udf_fifth(@start int, @end int)
returns Date
as 
begin
declare @random_value int;
set @random_value = FLOOR((select value from rand_view) *(@end-@start+1))+@start;
return DATEADD(day, @random_value, cast(GETDATE() as date));
end;

-- użycie
select dbo.udf_fifth(1,2);
