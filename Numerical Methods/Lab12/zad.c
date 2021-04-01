#include <stdio.h>
#include <math.h>

double factorial(int u)
{
    if( u < 2) return u;
    return u*factorial(u-1);
}

double sin_x(double x, int k, int MAX_ITER)
{
    double y = 0;
    for(int i = 0; i < MAX_ITER; ++i)
    {
        y += pow(-1, i)*pow(k * x, 2*i+1)/factorial(2*i+1);
    }
    return y;
}

double f_approx(double x, int m, int k, int MAX_ITER)
{
    return pow(x, m) * sin_x(x, k, MAX_ITER);
}


double f(double x, int m, int k)
{
    return pow(x, m) * sin((double)k*x);
}

double I_sin_x_sum(double x, int m, int k, int MAX_ITER)
{
    double y = 0;
    for(int i = 0; i < MAX_ITER; ++i)
    {
        y += pow(-1, i)
            *pow((double)k*x, 2*i+m+2)
            /( pow((double)k, m + 1)
              *factorial(2*i+1)
              *(2.*(double)i + (double)m + 2.)
             );
    }
    return y;
}


double I_Simpson_sin_x(double a, double b, int m, int k, int n)
{
    double sum = 0;
    int p = (n-1)/2;
    double h = (b - a)/(double)(n-1.);

    for(int j = 1; j <= p; ++j)
    {
        sum += f( h * (2.*(double)j-2.), m, k)
             + 4.*f( h * (2.*(double)j-1.), m, k)
             + f( h * 2.*(double)j, m, k);
    }
    return h/3. * sum;
}


double I_sin_x(double a, double b, int m, int k, int MAX_ITER)
{
    return I_sin_x_sum(b, m, k, MAX_ITER) - I_sin_x_sum(a, m, k, MAX_ITER);
}

void save_Simpson(
    int m,
    int k,
    double I,
    const char *filename
)
{
    int n[5] = {11,
                21,
                51,
                101,
                201};
    FILE *file = fopen(filename, "wt");

    for(int i = 0; i < 5; ++i)
    {
        fprintf(file, "%d\t%e\n", n[i], fabs( I - I_Simpson_sin_x(0., M_PI, m, k, n[i]) ));
    }

    fclose(file);
}

void save_analytic_integrals(
    int m,
    int k,
    const char *filename
)
{
    FILE *file = fopen(filename, "wt");

    for(int l = 1; l <= 30; ++l)
    {
        fprintf(file, "%d\t%.8f\n", l, I_sin_x(0., M_PI, m, k, l));
    }
    fclose(file);
}

int main()
{
    int m[3] = {0, 1, 5};
    int k[3] = {1, 1, 5};

    double I[3] = {2.,
                   M_PI,
                   56.363569};

    const char filenames_Simpson[3][20]  = {"Simp01.txt",
                                            "Simp11.txt",
                                            "Simp55.txt"};


    const char filenames_Analytic[3][20]  = {"A01.txt",
                                             "A11.txt",
                                             "A55.txt"};

    for(int i = 0; i < 3; ++i)
    {
        save_Simpson(m[i], k[i], I[i], filenames_Simpson[i]);
        save_analytic_integrals(m[i], k[i], filenames_Analytic[i]);
    }

    return 0;
}