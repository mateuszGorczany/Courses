using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Transactions;
using System.Security.Principal;
using Microsoft.SqlServer.Server;


public partial class StoredProcedures
{
    [Microsoft.SqlServer.Server.SqlProcedure]
    public static void mg_zad1()
    {
        WindowsIdentity newIdentity = null;
        WindowsImpersonationContext newContext = null;
        try
        {
            // zmiana tozsamosci uzytkownika
            newIdentity = SqlContext.WindowsIdentity;
            newContext = newIdentity.Impersonate();
            if (newContext != null)
            {
                using (SqlConnection oConn = new SqlConnection(@"
                    Data Source=MSSQLSERVER114;
                    Initial Catalog=AdventureWorks2008;
                    User Id=labuser;
                    Password=Passw0rd;"
                    )
                )
                {
                    SqlCommand oCmd = new SqlCommand(@"SELECT * FROM 
                        AdventureWorks2008.HumanResources.Employee", oConn);
                    oConn.Open();
                    SqlDataReader oRead = oCmd.ExecuteReader(CommandBehavior.CloseConnection);
                    newContext.Undo();
                    SqlContext.Pipe.Send(oRead);
                }
            }
            else
            {
                throw new Exception("zmiana tozsamosci ");
            }
        }
        catch (SqlException ex)
        {
            SqlContext.Pipe.Send(ex.Message.ToString());
        }
        finally
        {
            if (newContext != null)
            {
                newContext.Undo();
            }
        }
    }

    [Microsoft.SqlServer.Server.SqlProcedure]
    public static void mg_zad2()
    {

        using (TransactionScope oTran = new TransactionScope())
        {
            using (SqlConnection oConn = new SqlConnection("context connection=true;"))
            {
                oConn.Open();
                SqlCommand oCmd = new SqlCommand(@"
                INSERT INTO dbo.Konta (Name, Value) VALUES 
                ('Robert', 0)",
                oConn);
                oCmd.ExecuteNonQuery();

                oCmd.CommandText = @"INSERT INTO dbo.Konta
                (Name, Value) VALUES ('Paweł', 0)";
                oCmd.ExecuteNonQuery();

                oCmd.CommandText = @"
                INSERT INTO dbo.Konta (Name, Value) VALUES 
                ('Robert', 1000)";

                oCmd.ExecuteNonQuery();
                oTran.Complete();
            }
        }
    }

    [Microsoft.SqlServer.Server.SqlProcedure]
    public static void mg_zad3(SqlInt32 from_id, SqlInt32 to_id, SqlDouble value)
    {
        using (TransactionScope oTran = new TransactionScope())
        {
            using (SqlConnection oConn = new SqlConnection("context connection=true;"))
            {
                oConn.Open();
                String cmd = "update dbo.Konta set value = value + @val where id = @id";
                SqlCommand update = new SqlCommand(cmd, oConn);
                update.Parameters.Add("@val", SqlDbType.Float).Value = value;
                update.Parameters.Add("@id", SqlDbType.Int).Value = to_id;

                int returnValue = update.ExecuteNonQuery();
                using (SqlConnection remConn = new SqlConnection(@"
                    Data Source=localhost\SQLEXPRESS;Initial Catalog=master;Integrated Security=SSPI;"
                    ))
                {
                    returnValue = 0;
                    remConn.Open();
                    SqlCommand updateRemote = new SqlCommand(cmd, remConn);
                    updateRemote.Parameters.Add("@val", SqlDbType.Float).Value = -value;
                    updateRemote.Parameters.Add("@id", SqlDbType.Int).Value = from_id;
                    returnValue = updateRemote.ExecuteNonQuery();
                }
            }
            oTran.Complete();
        }
    }

    [Microsoft.SqlServer.Server.SqlProcedure]
    public static void mg_zad4()
    {
        System.Transactions.CommittableTransaction oTran = new CommittableTransaction();
        using (SqlConnection oConn = new SqlConnection("context connection=true"))
        {
            try
            {
                SqlCommand oCmd = new SqlCommand();
                oConn.Open();
                oConn.EnlistTransaction(oTran);
                oCmd.Connection = oConn;
 
                oCmd.CommandText = @"INSERT INTO dbo.Konta
                (Name, Value) VALUES ('Anna', 0)";
                SqlContext.Pipe.ExecuteAndSend(oCmd);

                oCmd.CommandText = @"INSERT INTO dbo.Konta
                (Name, Value) VALUES ('John', 0)";
                SqlContext.Pipe.ExecuteAndSend(oCmd);

                oCmd.CommandText = @"
                INSERT INTO dbo.Konta (Name, Value) VALUES 
                ('John', 1000)";
                SqlContext.Pipe.ExecuteAndSend(oCmd);

                SqlContext.Pipe.Send("COMMITING TRANSACTION");
                oTran.Commit();
            }
            catch (SqlException ex)
            {
                SqlContext.Pipe.Send(@"ROLLING BACK TRANSACTION DUE TO THE FOLLOWING 
                ERROR " + ex.Message.ToString());

                oTran.Rollback();
            }
            finally
            {
                oConn.Close();
                oTran = null;
            }
        }
    }
};
