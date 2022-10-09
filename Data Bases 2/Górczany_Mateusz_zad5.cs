using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

public partial class Mateusz_GDefinedFunctions
{
    [Microsoft.SqlServer.Server.SqlFunction]
    public static SqlInt32 get_year_diff(SqlDateTime start, SqlDateTime end)
    {
        if (start.IsNull || end.IsNull)
            return SqlInt32.Null;

        return Convert.ToInt32(Math.Floor((end.Value - start.Value).TotalDays / 365.25));
    }

    [Microsoft.SqlServer.Server.SqlFunction(DataAccess = DataAccessKind.Read)]
    public static SqlInt32 zad1(SqlInt32 BEID)
    {
        using (SqlConnection connection = new SqlConnection("context connection=true"))
        {
            connection.Open();
            SqlCommand command = new SqlCommand(
               "Select BirthDate  FROM [AdventureWorks2008].[HumanResources].[Employee] where BusinessEntityID = @ID;",
               connection
            );
            command.Parameters.Add("@ID", SqlDbType.Int).Value = BEID;

            return get_year_diff((DateTime)command.ExecuteScalar(), DateTime.Now);
        }
    }

    [Microsoft.SqlServer.Server.SqlProcedure]
    public static void zad2(SqlDateTime date, SqlInt32 min_age)
    {
        using (SqlConnection oConn = new SqlConnection("context connection=true"))
        {
            using (SqlCommand cmd = new SqlCommand(@"
                with cte as (
                        select 
                        LastName, 
                        FirstName,
                        dbo.get_year_diff(BirthDate, @date) as age
                from HumanResources.Employee e
                join Person.Person p on p.BusinessEntityID = e.BusinessEntityID
                )
                select * from cte where age >= @age",
                oConn
            ))
            {
                cmd.Parameters.Add("@age", SqlDbType.Int).Value = min_age;
                cmd.Parameters.Add("@date", SqlDbType.DateTime).Value = date;

                oConn.Open();
                SqlContext.Pipe.ExecuteAndSend(cmd);
            }
        }
    }


    [Microsoft.SqlServer.Server.SqlFunction(DataAccess = DataAccessKind.Read)]
    public static SqlString zad3(SqlDateTime date, SqlInt32 BEID)
    {
        using (SqlConnection connection = new SqlConnection("context connection=true"))
        {
            connection.Open();
            SqlCommand command = new SqlCommand(
               @"SELECT 
                	LastName + ';' 
                +	FirstName + ';' 
                +	cast(dbo.get_year_diff(BirthDate, @date) as varchar) age FROM [AdventureWorks2008].[HumanResources].[Employee] as e
                join Person.Person p on p.BusinessEntityID = e.BusinessEntityID
                where e.BusinessEntityID = @ID;",
               connection
            );
            command.Parameters.Add("@ID", SqlDbType.Int).Value = BEID;
            command.Parameters.Add("@date", SqlDbType.DateTime).Value = date;

            return (SqlString)command.ExecuteScalar().ToString();
        }
    }

    [Microsoft.SqlServer.Server.SqlProcedure]
    public static void zad4(SqlInt32 id)
    {
        using (SqlConnection oConn = new SqlConnection("context connection=true"))
        {
            using (SqlCommand cmd = new SqlCommand(@"
                select 
                    LastName + ';' +
                    MiddleName + ';' + 
                    FirstName + ';' + 
                    AddressLine1 as dane 
                FROM HumanResources.Employee e
                join Person.Person p on p.BusinessEntityID = e.BusinessEntityID
                join Person.BusinessEntity be on be.BusinessEntityID = p.BusinessEntityID
                join Person.BusinessEntityAddress bea on bea.BusinessEntityID = p.BusinessEntityID
                join Person.Address a on a.AddressID = bea.AddressID
                where e.BusinessEntityID = @id;",
                oConn
            ))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = id;

                oConn.Open();
                SqlContext.Pipe.ExecuteAndSend(cmd);
            }
        }
    }
};


