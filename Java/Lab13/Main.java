import java.util.ArrayList;
import java.util.Random;

public class Main
{

    public static void main(String[] args)
    {
        if (args.length != 3)
            throw new RuntimeException("Wrong number of parameters.");

        int N=0, M=0, P=0;

        try
        {
            N = Integer.parseInt(args[0]);
            M = Integer.parseInt(args[1]);
            P = Integer.parseInt(args[2]);

            if (N <=0 || M <=0 || P <=0)
                throw new RuntimeException("Wrong dimensions");
        }
        catch (RuntimeException e)
        {
            e.printStackTrace();
            System.exit(1);
        }

        Matrix A = new Matrix(N, M);
        Matrix B = new Matrix(M, P);
        Matrix C = A.multiply(B);
        System.out.println(C);

        Matrix C2 = A.multithreadedMultiply(B);
        System.out.println(C2);

        System.out.println("C equals C2?: " + C.equals(C2));
    }
}

class ElementCalculator extends Thread
{
    private final Matrix A;
    private final Matrix B;
    private final Matrix C;
    private final int i;
    private final int j;

    ElementCalculator(final Matrix A, final Matrix B, final Matrix C, int i, int j)
    {
        this.A = A;
        this.B = B;
        this.C = C;
        this.i = i;
        this.j = j;
    }

    public void run()
    {
        synchronized (C)
        {
            double Cij = 0;
            for(int k = 0; k < A.getM(); ++k)
                Cij += A.getField(i, k) * B.getField(k, j);

            C.setField(Cij, i, j);
        }
    }


}

class Matrix
{
    private final int n;
    private final int m;
    private final ArrayList<ArrayList<Double>> matrix;

    Matrix(int n, int m)
    {
        this.n = n;
        this.m = m;
        matrix = new ArrayList<>(n);

        Random random = new Random();
        for (int i = 0; i < n; ++i)
        {
            ArrayList<Double> doubleList = new ArrayList<>(m);
            for(int j = 0; j < m; ++j)
                doubleList.add(random.nextDouble());
            matrix.add(doubleList);
        }
    }

    int getN() { return n; }
    int getM() { return m; }
    void setField(double value, int i, int j) { matrix.get(i).set(j, value); }
    double getField(int i, int j) { return matrix.get(i).get(j); }


    public Matrix multiply(Matrix B)
    {
        int N = getN();
        int M = B.getN();
        int P = B.getM();
        if (getM() != B.getN())
            throw new RuntimeException("Wrong matrix dimensions. Cannot multiply.");

        Matrix C = new Matrix(N, P);

        for(int i = 0; i < N; ++i)
        {
            for(int j = 0; j < P; ++j)
            {
                double Cij = 0;
                for(int k = 0; k < M; ++k)
                    Cij += getField(i, k) * B.getField(k, j);

                C.setField(Cij, i, j);
            }

        }

        return C;
    }

    public Matrix multithreadedMultiply(Matrix B)
    {
        int N = getN();
        int P = B.getM();
        if (getM() != B.getN())
            throw new RuntimeException("Wrong matrix dimensions. Cannot multiply.");

        Matrix C = new Matrix(N, P);

        for(int i = 0; i < N; ++i)
        {
            for(int j = 0; j < P; ++j)
            {
                try
                {
                    ElementCalculator element = new ElementCalculator(this, B, C, i, j);
                    element.start();
                    element.join();
                }
                catch (InterruptedException e)
                {
                    e.printStackTrace();
                }
            }

        }

        return C;
    }

    @Override
    public boolean equals(Object obj)
    {
        if (obj == this) { return true; }
        if (!(obj instanceof Matrix)) { return false; }
        Matrix toCompare = (Matrix) obj;

        if (n != toCompare.getN() || m != toCompare.getM()) { return false; }

        for (int i = 0; i < n; ++i)
        {
            for (int j = 0; j < m; ++j)
            {
                if (Double.compare( getField(i, j), toCompare.getField(i, j) )  != 0)
                    return false;
            }
        }

        return true;
    }

    @Override
    public String toString()
    {
        StringBuilder stringMatrix = new StringBuilder();

        for (int i = 0; i < n; ++i)
        {
            stringMatrix.append(matrix.get(i).toString());
            stringMatrix.append('\n');
        }

        return stringMatrix.toString();
    }
}


