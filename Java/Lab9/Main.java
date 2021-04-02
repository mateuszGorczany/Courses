import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Arrays;

public class Main
{

    public static void main(String[] args)
    {
        InputHandler.handle(args);
    }
}

class InputHandler
{
    public static void handle(String[] args)
    {
        try
        {
            if (args.length == 0)
            {
                throw new NoReflectionMethod("Nie podano nic do obliczenia!");
            }

            var arguments = splitArgs(args[0]);
            if (arguments.length != 2 && arguments.length != 3)
                throw new IncorrectNumberOfReflectionMethodArguments("Zla liczba argumentow funkcji! Podaj jedna lub dwie liczby.");

            Class cls = Class.forName("java.lang.Math");

            if (arguments.length == 2)
            {
                Method function = cls.getDeclaredMethod(arguments[0], double.class);
                System.out.println(function.invoke(cls, Double.parseDouble(arguments[1])));
            }
            if (arguments.length == 3)
            {
                Method function = cls.getDeclaredMethod(arguments[0], new Class[]{double.class, double.class});
                System.out.println(function.invoke(cls, Double.parseDouble(arguments[1]), Double.parseDouble(arguments[2])));
            }
        } catch (NoSuchMethodException err)
        {
            System.err.println("Nie ma takiej metody!");
        } catch (InvocationTargetException err)
        {
            System.err.println("Nie podano nic do obliczenia!");
        } catch (NumberFormatException err)
        {
            System.err.println("Argumenty muszą być liczbami!");
        } catch (ArrayIndexOutOfBoundsException err)
        {
            System.err.println("Zla liczba argumentow funkcji! Podaj jedna lub dwie liczby.");
        } catch (ClassNotFoundException
                | IllegalAccessException
                | IncorrectNumberOfReflectionMethodArguments
                | NoReflectionMethod err)
        {
            System.err.println(err.getMessage());
        }
    }

    public static String[] splitArgs(String arg)
    {
        return Arrays.stream(arg.split("[\\s+(),]")).filter(w -> w.isEmpty() == false).toArray(String[]::new);
    }
}


class NoReflectionMethod extends Exception
{
    public NoReflectionMethod(String error)
    {
        super(error);
    }
}

class IncorrectNumberOfReflectionMethodArguments extends Exception
{
    public IncorrectNumberOfReflectionMethodArguments(String error)
    {
        super(error);
    }
}