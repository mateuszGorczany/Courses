import java.util.Random;
import java.util.Scanner;

public class Main
{
    public static void main(String[] args)
    {
        Scanner scanner = new Scanner(System.in);
        Game game = new Game(scanner, 10, 10, 0.3);
        game.play();
        scanner.close();
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
        option = null;
        i = ny-2;
        j = 1;
        scanner = _scanner;
        System.out.println("Dostepne opcje:");
        System.out.println(Option.EXIT.toString());
        System.out.println(Option.RESET.toString());
        System.out.println(Option.UP.toString());
        System.out.println(Option.LEFT.toString());
        System.out.println(Option.DOWN.toString());
        System.out.println(Option.RIGHT.toString());
    }

    public void step(Direction dir, CheckStep check)
    {
        if(check.test(board, i, j, option.getDirection()))
        {
            board[i][j] = ' ';
            i = i-option.getDirection().getY();
            j = j+option.getDirection().getX();
            board[i][j] = 'o';

            if(i == 0 && j == (int) Math.floor(board[1].length/2))
            {
                System.out.println("Wygrana!");
                System.exit(0);
            }
            print();
        }
        else
        {
            System.out.println("Nie udalo sie wykonac takiego ruchu.");
        }
    }

    public void play()
    {
        print();
        while(true)
        {
            getInput();
            CheckStep check = new CheckStep()
            {
                @Override
                public boolean test(char[][] board, int i0, int j0, Direction dir)
                {
                    return board[i0 - dir.getY()][j0 + dir.getX()] == ' ';
                }
            };

            if(option == null)                  { System.out.println("Blędny klawisz"); continue; }
            if(option.equals(Option.RESET))     { fillX(); i = board[0].length-2; j = 1; print(); continue; }
            if(option.equals(Option.LEFT))      { step(option.getDirection(), check); continue; }
            if(option.equals(Option.RIGHT))     { step(option.getDirection(), check); continue; }
            if(option.equals(Option.UP))        { step(option.getDirection(), check); continue; }
            if(option.equals(Option.DOWN))      { step(option.getDirection(), check); continue; }
            if(option.equals(Option.EXIT))      { System.out.println("Wychodzenie z gry..."); break; }

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

    private int x;
    private int y;

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

    private char selectedChar;
    private String description;
    private Direction direction;

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
    boolean test(char[][] board, int i0, int j0, Direction dir);
}

class Board
{
    protected char[][] board;
    private double p;

    Board()
    {
        this(3, 3, 0.3);
    }

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
                if(i==0) { board[0][j] = 'X'; continue; }
                if(i==board[0].length-1) { board[board[0].length-1][j] = 'X'; continue; }
                if(j==board[1].length-1) { board[i][board[1].length-1]= 'X'; continue; }
                if(j==0) { board[i][0] = 'X'; continue; }

                board[i][j] = ' ';
                if(random.nextDouble() < p) { board[i][j] = 'X'; continue; }
            }
        }

        board[board[1].length-2][1] = 'o';
        board[0][board[1].length/2] = ' ';
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