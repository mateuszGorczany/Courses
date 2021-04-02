import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Iterator;

public class Main
{

    public static void main(String[] args)
    {
        Path path1 = InputReader.getPathFromUser("Enter first filename");
        Path path2 = InputReader.getPathFromUser("Enter second filename");
        FileHandler fh = new FileHandler(path1, path2);

        fh.addY();
        fh.saveResult();
        System.out.println("Task successfully completed.");
    }
}

class InputReader
{
    public static String getUserInput(String message)
    {
        System.out.println(message);
        BufferedReader reader = new BufferedReader(
                new InputStreamReader((System.in))
        );

        String input;

        try
        {
            input = reader.readLine();
        }
        catch (IOException e)
        {
            throw new RuntimeException(e.getMessage());
        }

        return input;
    }

    static Path getPathFromUser(String message)
    {
        return  Paths.get(getUserInput(message));
    }

}


class FileHandler
{
    ArrayList<Double> x1 = new ArrayList<>();
    ArrayList<Double> y1 = new ArrayList<>();
    ArrayList<Double> x2 = new ArrayList<>();
    ArrayList<Double> y2 = new ArrayList<>();
    ArrayList<Double> y_solution = new ArrayList<>();

    FileHandler(Path fileOnePath, Path fileTwoPath)
    {
        readFile(fileOnePath, x1, y1);
        readFile(fileTwoPath, x2, y2);
        assertXEqual();
    }

    private void readFile(Path path, ArrayList<Double> x, ArrayList<Double> y)
    {
        try (BufferedReader br = Files.newBufferedReader(path))
        {
            String line;
            while ((line = br.readLine()) != null)
            {
                String[] parts = line.split(" ");
                x.add(Double.parseDouble(parts[0]));
                y.add(Double.parseDouble(parts[1]));
            }
        }
        catch (IOException e)
        {
            throw new RuntimeException("Couldn't open the file \""
                    + path + "\". Task successfully failed.");
        }

        if (x.size() != y.size())
            throw new RuntimeException("X and Y dimensions are not the same, task successfully failed.");
    }

    private void assertXEqual()
    {
        for(int i = 0; i < x1.size(); ++i)
        {
            boolean areXValuesTheSame = Double.compare(x1.get(i), x2.get(i)) == 0;
            if (!areXValuesTheSame)
                throw new RuntimeException("X values are not the same. Task successfully failed.");
        }
    }

    public void addY()
    {
        Iterator<Double> y1_value = y1.iterator();
        Iterator<Double> y2_value = y2.iterator();

        while( y1_value.hasNext() && y2_value.hasNext() )
        {
            y_solution.add( y1_value.next() + y2_value.next() );
        }
    }

    private boolean writeResult(Path path)
    {
        try(BufferedWriter bw = Files.newBufferedWriter(path))
        {
            for(int i = 0; i < x1.size(); ++i)
            {
                bw.write(
                        x1.get(i)
                                + "\t"
                                + y_solution.get(i)
                                + "\n"
                );
            }

        }
        catch (IOException e)
        {
            e.printStackTrace();
            throw new RuntimeException("Couldn't open the file \""
                    + path + "\". Task successfully failed.");
        }

        return true;
    }

    public boolean saveResult()
    {
        Path path = InputReader.getPathFromUser("Provide new filename for resulting file");
        if (Files.exists(path))
        {
            String response = InputReader.getUserInput("File exists, override? tak/nie");
            if (response.equals("tak"))
            {
                writeResult(path);
                return true;
            }
            else if (response.equals("nie"))
            {
                saveResult();
            }
            else
            {
                throw new RuntimeException("Unknown input, task successfully failed.");
            }
        }

        writeResult(path);
        return true;
    }
}