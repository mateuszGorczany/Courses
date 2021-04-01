#include <stdio.h>

// biblioteki:

double g_1(double x)
{
    return 1./(x*sqrt(x*x-1.));
}

double g_2(double x)
{
    return log(x)*exp(-x*x);
}

double g_3(double x)
{
    return sin(2.*x)*exp(-2.*x);
}


double c_leg(int n, double (*f)(double), double start, double stop)
{
    float *x = vector(1, n);
    float *w = vector(1, n);
    gauleg(start, stop, x, w, n);

    double sum = 0;
    for(int i = 1; i <= n; ++i)
    {
        sum += w[i] * f(x[i]);
    }

    free_vector(w, 1, n);
    free_vector(x, 1, n);

    return sum;
}

double c_her(int n)
{
    float *x = vector(1, n);
    float *w = vector(1, n);
    gauher(x, w, n);

    double sum = 0;
    for(int i = 1; i <= n; ++i)
    {
        sum += w[i] * log(fabs(x[i]));
    }

    free_vector(w, 1, n);
    free_vector(x, 1, n);

    return sum/2.;
}

void calc_cher(unsigned int MAX_N)
{
    FILE *f = fopen("c2her.txt", "wt");
    for(int n = 2; n <= MAX_N; n+=2)
    {
        fprintf(f, "%d\t%f\n", n, fabs(-0.8700577-c_her(n)));
    }
    fclose(f);
}

double c_lag(int n, double (*function)(double))
{
    float *x = vector(1, n);
    float *w = vector(1, n);
    gaulag(x, w, n, 0);

    double sum = 0;
    for(int i = 1; i <= n; ++i)
    {
        sum += w[i] * function(x[i]);
    }

    free_vector(w, 1, n);
    free_vector(x, 1, n);

    return sum;
}

void plot_f(
    double start,
    double stop,
    double step,
    double (*f)(double),
    const char *filename)
{
    double x = start;
    FILE *file = fopen(filename, "wt");
    while(x <= stop)
    {
        fprintf(file, "%f\t%f\n", x, f(x));
        x+=step;
    }
    fclose(file);
}

void calc_cleg(
    unsigned int MAX_N,
    const char *filename,
    double I,
    double start,
    double stop,
    double (*function)(double))

{
    FILE *f = fopen(filename, "wt");
    for(int n = 2; n <= MAX_N; ++n)
    {
        fprintf(f, "%d\t%f\n", n, fabs(I - c_leg(n, function, start, stop)));
    }
    fclose(f);
}

void calc_clag(
    unsigned int MAX_N,
    const char *filename,
    double I,
    double (*function)(double))

{
    FILE *f = fopen(filename, "wt");
    for(int n = 2; n <= MAX_N; ++n)
    {
        fprintf(f, "%d\t%f\n", n, fabs(I - c_lag(n, function)));
    }
    fclose(f);
}

int main()
{
    calc_cleg(100, "c1.txt", M_PI/3., 1, 2, g_1);
    calc_cher(100);
    calc_cleg(100, "c2leg.txt", -0.8700577, 0, 5, g_2);
    plot_f(0.01, 2.5, 0.01, g_2, "f2plot.txt");
    calc_clag(10, "c3lag.txt", 2./13., g_3);


    return 0;
}