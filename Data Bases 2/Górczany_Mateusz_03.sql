-- zadanie 1

select p.LastName, st.Name, count(SubTotal) NoOrders from Sales.Customer sc
inner join Sales.SalesTerritory st on st.TerritoryID = sc.TerritoryID
inner join Person.Person as p on p.BusinessEntityID = sc.PersonID
inner join Sales.SalesOrderHeader as s on s.CustomerID = sc.CustomerID
group by GROUPING sets((st.Name, p.LastName))
order by NoOrders desc

-- zadanie 2
select shift Zmiana, Production Produkcja, [Information Services] Informacje, Marketing Reklama, [Research and Development] Badania from
(
select d.Name dep, s.Name shift, s.ShiftID [sid] from HumanResources.Employee e
join HumanResources.EmployeeDepartmentHistory h on h.BusinessEntityID = e.BusinessEntityID
join HumanResources.Department d on d.DepartmentID = h.DepartmentID
join HumanResources.Shift s on s.ShiftID = h.ShiftID
where h.EndDate IS NULL
) t
pivot (
	count([sid])
	for dep in
	(
		[Production],
		[Marketing],
		[Information Services],
		[Research and Development]

	)
) as pivot_table

-- using case
select 
	shift Zmiana, 
	count(case when department = 'Production' then department end) Produkcja, 
	count(case when department = 'Information Services' then department end) Informacje, 
	count(case when department = 'Marketing' then department end) Reklama, 
	count(case when department = 'Research and Development' then department end) Badania 
from
(
select d.Name department, s.Name shift, s.ShiftID [sid] from HumanResources.Employee e
join HumanResources.EmployeeDepartmentHistory h on h.BusinessEntityID = e.BusinessEntityID
join HumanResources.Department d on d.DepartmentID = h.DepartmentID
join HumanResources.Shift s on s.ShiftID = h.ShiftID
where h.EndDate is null
) as ps
group by shift


-- zadanie 3 

CREATE TABLE dbo.Target(ID int, Nazwa varchar(64),Cena int
    CONSTRAINT Target_PK PRIMARY KEY(ID));

CREATE TABLE dbo.Source(ID int,Nazwa varchar(64),Cena int
    CONSTRAINT Source_PK PRIMARY KEY(ID));
GO 
INSERT dbo.Target(ID,Nazwa,Cena) VALUES(100,'Volvo', 200000);
INSERT dbo.Target(ID,Nazwa,Cena) VALUES(101,'Cadillac',100000);
INSERT dbo.Target(ID,Nazwa,Cena) VALUES(102,'Citroen',50000);
GO 
INSERT dbo.Source(ID,Nazwa,Cena) VALUES(103,'Ford',80000);
INSERT dbo.Source(ID,Nazwa,Cena) VALUES(104,'Chevrolet',70000);
INSERT dbo.Source(ID,Nazwa,Cena) VALUES(100,'Audi',180000);
GO
--Właściwy przykład z pewnymi atrakcjami.
BEGIN TRAN;
CREATE TABLE #Rejestr
(
	[akcja] varchar(50),
	new_ID int, 
	new_Nazwa varchar(64),
	new_Cena int,
	old_ID int,
	old_Nazwa varchar(64),
	old_Cena int 
);

MERGE Target AS T USING Source AS S 
ON (T.ID =S.ID)
WHEN NOT MATCHED BY TARGET AND S.Nazwa LIKE'C%'
    THEN INSERT(ID,Nazwa,Cena) VALUES(S.ID,S.Nazwa,S.Cena)
WHEN MATCHED 
    THEN UPDATE SET T.Nazwa = S.Nazwa, T.Cena = S.Cena
WHEN NOT MATCHED BY SOURCE AND T.Nazwa LIKE'C%'
    THEN DELETE
OUTPUT $action as akcja, inserted.*, deleted.*
into #Rejestr([akcja], new_ID, new_Nazwa, new_Cena,
						old_ID, old_Nazwa, old_Cena);
						
select * from #Rejestr;
ROLLBACK TRAN;
GO

