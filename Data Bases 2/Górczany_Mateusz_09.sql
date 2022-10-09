-- zad1
--- nie zrozumiałem polecenia - "w dwóch kolejnych przedziałach wartości z kolumny Demographics"

with xmlnamespaces
(
	default 'http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey'
)
select 
	FirstName,
	LastName,
	Demographics.value('(/IndividualSurvey/YearlyIncome)[1]', 'varchar(250)') val
from Person.Person
where Demographics.exist('(/IndividualSurvey/YearlyIncome)[1]') = 1
order by val


--- ??? może o to chodziło? nie ma jednak w SQL-Server2008 funkcji STRING_SPLIT
with xmlnamespaces
(
	default 'http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey'
), cte as
(
select 
	FirstName,
	LastName,
	Demographics.value('(/IndividualSurvey/YearlyIncome)[1]', 'varchar(250)') val
from Person.Person
where Demographics.exist('(/IndividualSurvey/YearlyIncome)[1]') = 1
)
select 
	FirstName, 
	LastName, 
	val,	
	NTILE(2) over 
	(
		order by val
	)
from cte
-- zad2

with xmlnamespaces
(
	default 'http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey'
)
select 
	FirstName,
	LastName,
	Demographics.value('(//NumberChildrenAtHome)[1]', 'INT') 
	- Demographics.value('(//TotalChildren)[1]', 'INT') diff
from Person.Person
where Demographics.value('(//TotalChildren)[1]', 'INT') > 0
order by diff desc

-- 2 wersja
with xmlnamespaces
(
	default 'http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey'
)
select 
	FirstName,
	LastName,
	Demographics.value('(//NumberChildrenAtHome)[1]', 'INT') 
	- Demographics.value('(//TotalChildren)[1][ . > 0]', 'INT') diff
from Person.Person
order by diff desc


--zAD3

select 
	Resume.query(
	'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume";
	
	for $p in /Resume
	return
		<person>
			<Name>{data($p/Name/Name.Last)}</Name>
			<City>{data($p/Address/Addr.Location/Location/Loc.City)}</City>
			<Street>{data($p/Address/Addr.Street)}</Street>
		</person>
')
from HumanResources.JobCandidate
