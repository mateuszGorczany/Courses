import java.util.Arrays;

public class Main
{

    public static void main(String[] args)
    {
        if (args.length == 0)
            throw new InputError("No input provided.");

        String[] arguments = Arrays.stream(args[0].split("")).filter(w -> w.isEmpty() == false).toArray(String[]::new);
        String translated = new ONPtranslator(arguments).result();
        System.out.println(translated);
    }
}

class Stack<T>
{
    private final T[] stack;
    private int size = 0;
    private final int maxSize;

    Stack(int maxStackSize)
    {
        stack = (T[]) new Object[maxStackSize];
        maxSize = maxStackSize;
    }

    public boolean isEmpty()
    {
        return size == 0;
    }

    public boolean isFull()
    {
        return size == maxSize;
    }


    public void push(T x) throws StackOverflowError
    {
        if (isFull())
            throw new StackOverflowError("Maximum capacity reached.");

        stack[size] = x;
        ++size;
    }

    public T pop() throws StackUnderFlowException
    {
        if (isEmpty())
            throw new StackUnderFlowException("Stack has 0 size.");

        T tmp = stack[size-1];
        stack[size -1] = size -1 == 0 ? tmp : null;
        --size;

        return tmp;
    }

    public String toString()
    {
        String buffer = new String();
        for(int i = 0; i < size - 1; ++i)
            buffer += stack[i].toString() + ", ";

        buffer += stack[size-1].toString();
        return buffer;
    }

}


class StackUnderFlowException extends RuntimeException
{
    public StackUnderFlowException(String errorMessage)
    {
        super(errorMessage);
    }
}

class InputError extends RuntimeException
{
    public InputError(String errorMessage)
    {
        super(errorMessage);
    }
}

class StackNotEmpty extends RuntimeException
{
    public StackNotEmpty(String errorMessage)
    {
        super(errorMessage);
    }
}


class ONPtranslator
{
    private final String[] args;
    private String translation;

    ONPtranslator(String[] arguments)
    {
        args = arguments;
        translate();
    }

    private void translate()
    {
        Stack<String> stack = new Stack<String>(args.length);
        for (String symbol: args)
        {
            if( !ONPtranslator.isOperator(symbol))
            {
                stack.push(symbol);
            }
            else
            {
                String a, b;
                try
                {
                    a = stack.pop();
                    b = stack.pop();
                    stack.push("(" + b + symbol + a + ")");
                }
                catch (Exception error)
                {
                    System.err.println("BLAD DANYCH WEJSCIOWYCH! Na stosie jest za malo elementow, zeby wykonac operacje!");
                    System.exit(1);
                }
            }
        }

        translation = stack.pop();
        try
        {
            if (!stack.isEmpty())
            {
                throw new StackNotEmpty(
                        "BLAD DANYCH WEJSCIOWYCH! Koniec algorytmu, a stos nie jest pusty: "
                                + stack.toString()
                                + ", "
                                + translation);
            }
        }
        catch (StackNotEmpty error)
        {
            System.err.println(error.getMessage());
            System.exit(1);
        }
    }

    private static boolean isNumeric(String string)
    {
        try
        {
            Double.parseDouble(string);
            return true;
        }
        catch (NumberFormatException error)
        {
            return false;
        }
    }

    private static boolean isOperator(String symbol)
    {
        return symbol.equals("+") || symbol.equals("-") || symbol.equals("*") || symbol.equals("/");
    }

    public String result()
    {
        return translation;
    }
}