import java.util.Random;
import java.util.Scanner;

public class Main
{
    public static void main(String[] args)
    {
        Scanner scanner = new Scanner(System.in);
        int nx = handleInput(scanner);
        Game game = new Game(scanner, nx, nx, 0.3);
        game.play();
        scanner.close();
    }

    public static int handleInput(Scanner scanner)
    {
        return askingLoop(scanner);
    }

    public static int askingLoop(Scanner scanner)
    {
        int input;
        while(true)
        {
            try
            { input = takeInput(scanner); }
            catch (Exception e)
            { continue; }

            break;
        }

        return input;
    }

    public static int takeInput(Scanner scanner) throws OptionNotRecognizedException
    {
        System.out.println("Podaj liczbe calkowita wieksza od 1:");
        Integer input;
        try
        {
            String n = scanner.nextLine();
            input = Integer.parseInt(n);
            if (input == null)
                throw new OptionNotRecognizedException("BLAD: Podaj liczbe calkowita!");
            if (input <= 1)
                throw new OptionNotRecognizedException("BLAD: Zbyt mala wartosc nx: " + input + "!");
        }
        catch (OptionNotRecognizedException e)
        {
            System.err.println(e.getMessage());
            throw e;
        }
        catch (NumberFormatException e)
        {
            System.err.println("BLAD: Podaj liczbe calkowita!");
            throw e;
        }

        return input;
    }

}

class Game extends Board
{
    private Option option;
    Scanner scanner;
    int i;
    int j;

    Game(Scanner _scanner, int nx, int ny, double p)
    {
        super(nx, ny, p);
        scanner = _scanner;
        option = null;
        i = ny-2;
        j = 1;
        System.out.println("Dostepne opcje:");
        System.out.println(Option.EXIT.toString());
        System.out.println(Option.RESET.toString());
        System.out.println(Option.UP.toString());
        System.out.println(Option.LEFT.toString());
        System.out.println(Option.DOWN.toString());
        System.out.println(Option.RIGHT.toString());
    }


    public void step(CheckStep check) throws WallException
    {

        if(check.test(board, i, j, option.getDirection()))
        {
            board[i][j] = ' ';
            i = i-option.getDirection().getY();
            j = j+option.getDirection().getX();
            board[i][j] = 'o';

            if(i == 0 && j == (int) Math.floor(board[1].length/2.0))
            {
                print();
                System.out.println("Wygrana!");
                System.exit(0);
            }
            print();
        }
        else
        {
            throw new WallException("Próba wejścia w przeszkodę.");
        }
    }

    public void play()
    {
        print();
        while(true)
        {
            getInput();
            try
            {
                CheckStep check = new CheckStep()
                {
                    @Override
                    public boolean test(char[][] board, int i0, int j0, Direction dir) throws WallException
                    {
                        int i_new = i0 - dir.getY();
                        int j_new = j0 + dir.getX();

                        if(i_new > board[0].length - 1
                        || j_new > board[1].length - 1
                        || i_new < 0
                        || j_new < 0)
                        { throw new WallException("Próba wyjścia poza planszę"); }

                        var pos = board[i_new][j_new];
                        return pos == ' ' || pos == '-';
                    }
                };

                if(option == null)                  { throw new OptionNotRecognizedException("Niepoprawny klawisz"); }
                if(option.equals(Option.LEFT))      { step(check); continue; }
                if(option.equals(Option.RIGHT))     { step(check); continue; }
                if(option.equals(Option.UP))        { step(check); continue; }
                if(option.equals(Option.DOWN))      { step(check); continue; }
                if(option.equals(Option.EXIT))      { System.out.println("Wychodzenie z gry..."); break; }

                if(option.equals(Option.RESET))     { fillX(); i = board[0].length-2; j = 1; print(); }
            }
            catch (WallException err)
            { System.err.println(err.getMessage()); }
            catch(OptionNotRecognizedException err)
            { System.err.println(err.getMessage());}

        }
    }

    private void getInput()
    {
        System.out.println("Krok:");
        handleInput(scanner.next().charAt(0));
    }

    private void handleInput(char character)
    {
        if(character == 'q')    { option = Option.EXIT; return; }
        if(character == 'r')    { option = Option.RESET; return; }
        if(character == 'w')    { option = Option.UP; return; }
        if(character == 'a')    { option = Option.LEFT; return; }
        if(character == 's')    { option = Option.DOWN; return; }
        if(character == 'd')    { option = Option.RIGHT; return; }

        option = null;
    }
}

enum Direction
{
    LEFT(-1, 0),
    RIGHT(1,0),
    UP(0,1),
    DOWN(0,-1);

    private final int x;
    private final int y;

    Direction(int _x, int _y)
    {
        x = _x;
        y = _y;
    }

    @Override
    public String toString()
    {
        return  "[" + x + ','+ y + ']';
    }

    public int getX()
    {
        return x;
    }

    public int getY()
    {
        return y;
    }
}

enum Option
{
    RESET('r', "Reset the game", null),
    LEFT('a', "Turn left", Direction.LEFT),
    RIGHT('d', "Turn right", Direction.RIGHT),
    UP('w', "Go up", Direction.UP),
    DOWN('s', "Go down", Direction.DOWN),
    EXIT('e', "Exit", null);

    private final char selectedChar;
    private final String description;
    private final Direction direction;

    Option(char _selectedChar, String _description, Direction _direction)
    {
        selectedChar = _selectedChar;
        description = _description;
        direction = _direction;
    }

    @Override
    public String toString()
    {
        if(direction != null)
        {

            return "'" + selectedChar +
                    "'" + " opcja " + name()
                    + ", opis: " + description
                    + ", wektor przesuniecia: "
                    + direction.toString();
        }
        return "'"+ selectedChar +
               "'" + " opcja " + name()
               + ", opis: " + description;
    }

    public String getDescription()
    {
        return description;
    }

    public Direction getDirection()
    {
        return direction;
    }

}
interface CheckStep {
    boolean test(char[][] board, int i0, int j0, Direction dir) throws  WallException;
}

class Board
{
    protected char[][] board;
    private final double p;

    Board(int nx, int ny, double probability)
    {
        board = new char[ny][nx];
        p = probability;
        this.fillX();
    }

    protected void fillX()
    {
        Random random = new Random();
        for(int i = 0; i < board[0].length; ++i)
        {
            for(int j = 0; j < board[1].length; ++j)
            {
                board[i][j] = ' ';
                if(random.nextDouble() < p) { board[i][j] = 'X'; }
            }
        }

        board[board[1].length-2][1] = 'o';
        board[0][board[1].length/2] = '-';
    }

    void print()
    {
        for (int i = 0; i < board[0].length; i++)
        {
            for (int j = 0; j < board[1].length; j++)
            {
                System.out.print(board[i][j]);
            }
        System.out.println();
        }

    }
}


/// LAB 8

class OptionNotRecognizedException extends Exception
{
    public OptionNotRecognizedException(String errorMessage)
    {
        super(errorMessage);
    }
}


class WallException extends Exception
{
    public WallException(String errorMessage)
    {
        super(errorMessage);
    }
}