#include <stdio.h>
#include <math.h>
#include "/opt/NR/numerical_recipes.c/nrutil.h"
#include "/opt/NR/numerical_recipes.c/nrutil.c"
#include "/opt/NR/numerical_recipes.c/gaussj.c"

int m = 4;

double f(double x,
         double a0,
         double a1,
         double a2)
{
    return a0 + a1*x + a2*x*x;
}


double g(double x,
         double a0,
         double a1,
         double a2)
{
    return exp(f(x, a0, a1, a2));
}

double noise()
{
    double alpha = 0.1;
    double X = rand()/(RAND_MAX+1.0);
    double del = alpha*(X-0.5);
    return 1.+del;
}

double g2(double x,
          double a0,
          double a1,
          double a2)
{
    return g(x, a0, a1, a2)*noise();
}

double F(double x, float **b)
{
    double sum = 0;
    for(int i = 1; i <=m; ++i)
    {
        sum += b[i][1]*pow(x, i-1);
    }
    return sum;
}

double G(double x, float **b)
{
    return exp(F(x, b));
}

float **matrix_G(float **x, int n)
{
    float **mG = matrix(1, m, 1, m);
    double sum = 0;

    for(int i = 1; i <= m; ++i)
    {
        for(int k = 1; k <= m; ++k)
        {
            for(int j = 1; j <= n; ++j)
            {
                sum += pow(x[j][1], i+k-2);
            }

            mG[i][k] = sum;
            sum = 0;
        }
    }

    return mG;
}

void wypisz(float **A, int n)
{
    for (int i = 1; i < n+1; ++i){
		for (int j = 1; j < n+1; ++j){
			printf( "%.2lf\t", A[i][j]);
		}
		printf( "\n");
	}
}

void wypisz_vec(float **A,
                int n,
                float h)
{
    for(int i =1; i<n+1; ++i)
    {
        printf( "%f\t%.6lf\n", (i-1)*h, A[i][1] );
    }
}

void fill_vector(float **vec,
                 int n,
                 float x_0,
                 float h,
                 float delta)
{
    for(int i = 1; i <= n; ++i)
    {
        vec[i][1] = x_0 - 3.f*delta + (i-1)*h;
    }
}

void calculate_values(float **y,
                      float **x,
                      int n,
                      double a0,
                      double a1,
                      double a2,
                      int condition)
{
    if(condition == 0)
    {
        for(int i = 1; i <= n; ++i)
        {
            y[i][1] = f(x[i][1], a0, a1, a2);
        }
    }
    else
    {
        for(int i = 1; i <= n; ++i)
        {
            y[i][1] = f(x[i][1], a0, a1, a2)*noise();
        }
    }

}

float **calculate_r(float **x, float **y, int n)
{
    float **r = matrix(1, m, 1, 1);
    double sum = 0;

    for(int k = 1; k <= m; ++k)
    {
        for(int j = 1; j <= n; ++j)
        {
            sum += y[j][1]*pow(x[j][1], k-1);
        }

        r[k][1] = sum;
        sum = 0;
    }

    return r;
}


void CalculateCurveG(double (*func)(double, double, double, double),
                     double x_0,
                     double delta,
                     double a0,
                     double a1,
                     double a2,
                     float **b,
                     const char *filename)
{
    double x = x_0-3.*delta;
    double stop = x_0 + 3.*delta;
    FILE *file = fopen(filename, "wt");
    double step = 0.01;

    while(x <= stop)
    {
        fprintf(file, "%f\t%f\t%f\n", x, func(x, a0, a1, a2), G(x, b));
        x += step;
    }

    fclose(file);
}


void CalculateCurveG2(double (*func)(double, double, double, double),
                      double x_0,
                      double delta,
                      double a0,
                      double a1,
                      double a2,
                      int n,
                      float **b,
                      float **x_,
                      float **y,
                      const char *filename,
                      const char *filenameApprox)
{
    double x = x_0-3.*delta;
    double stop = x_0 + 3.*delta;
    FILE *file = fopen(filename, "wt");
    double dx = 0.01;

    for(int i = 1; i <= n; ++i)
    {
        fprintf(file, "%f\t%f\n", x_[i][1], exp(y[i][1]));
    }

    fclose(file);

    FILE *fileappr = fopen(filenameApprox, "wt");
    x = x_0 - 3.*delta;
    while(x <= stop)
    {
        fprintf(fileappr, "%f\t%f\n", x, G(x, b));
        x += dx;
    }
    fclose(fileappr);
}



void calculate_G_with_respecto_to_nodes(double (*func)(double, double, double, double),
                                        double x_0,
                                        double delta,
                                        int n,
                                        const char *filename,
                                        const char *filenameAppr,
                                        const char *nodesFilename,
                                        int condition)
{
    float h = 6*delta/((float)(n-1));
    float dx = 0.01;
    float **x = matrix(1,n,1,1);
    float **y = matrix(1,n,1,1);

    double a[3] = {-x_0*x_0/2./(delta*delta),
                   x_0/(delta*delta),
                   -1./2./(delta*delta)};

    fill_vector(x, n, x_0, h, delta);

    condition == 0 ? calculate_values(y, x, n, a[0], a[1], a[2], 0)
                   : calculate_values(y, x, n, a[0], a[1], a[2], 1);

    float **mG = matrix_G(x, n);
    float **r = calculate_r(x, y, n);

    gaussj(mG, m, r, 1);
    condition == 0 ? CalculateCurveG(func, x_0, delta, a[0], a[1], a[2], r, filename)
                   : CalculateCurveG2(func, x_0, delta, a[0], a[1], a[2], n, r, x, y, filename, filenameAppr);

    FILE *file = fopen(nodesFilename, "wt");
    for(int i = 0; i < m; ++i)
    {
        i<3 ? fprintf(file, "%f\t%f\n", a[i], r[i+1][1])
            : fprintf(file, "%f\t%e\n", 0., r[i+1][1]);
    }

    fclose(file);

    free_matrix(r, 1, m, 1, 1);
    free_matrix(x, 1, n, 1, 1);
    free_matrix(y, 1, n, 1, 1);
    free_matrix(mG, 1, m ,1 , m);
}

int main()
{
    double delta = 4.;
    int n_surveys = 4;
    double x_0 = 2.f;

    int n[4] = {11,
                21,
                51,
                101};

    const char Gfiles[4][20] = {"g1N11.txt",
                                "g1N21.txt",
                                "g1N51.txt",
                                "g1N101.txt"};

    const char Gcoefs[4][20] =  {"g1N11coef.txt",
                                "g1N21coef.txt",
                                "g1N51coef.txt",
                                "g1N101coef.txt"};

    const char G2files[4][20] = {"g2N11.txt",
                                 "g2N21.txt",
                                 "g2N51.txt",
                                 "g2N101.txt"};

    const char G2filesAppr[4][20] = {"g2N11Appr.txt",
                                     "g2N21Appr.txt",
                                     "g2N51Appr.txt",
                                     "g2N101Appr.txt"};

    const char G2coefs[4][20] = {"g2N11coef.txt",
                                 "g2N21coef.txt",
                                 "g2N51coef.txt",
                                 "g2N101coef.txt"};


    int checker = 0;
    for(int i = 0; i < n_surveys; ++i)
    {
        if(i == 3 && checker == 0)
        {
            i = 0;
            checker = 1;
        }

        checker == 0 ? calculate_G_with_respecto_to_nodes(g, x_0, delta, n[i], Gfiles[i], "", Gcoefs[i], 0)
                     : calculate_G_with_respecto_to_nodes(g2, x_0, delta, n[i], G2files[i], G2filesAppr[i], G2coefs[i], 1);
    }

}
