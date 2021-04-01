#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#define eps 1e-8

double f1(double x)
{
    return log(x*x*x*x*x + 3.*x*x + x + 9.);
}

double f2(double x)
{
    return x*x*x*x*x*x;
}


double F(double x_1, double x_2, double (*f)(double))
{
    return ( f(x_2) - f(x_1) )/(x_2 - x_1);
}

double F_(double x_1, double x_2, double x_3, double (*f)(double))
{
    return ( F(x_2, x_3, f) - F(x_1, x_2, f) )/(x_3 - x_1);
}

int find_farthest(double *x_1, double *x_2, double *x_3, double x_m)
{
    if( fabs(*x_1 - x_m) < eps) { return 0; }
    if( fabs(*x_2 - x_m) < eps) { return 0; }
    if( fabs(*x_3 - x_m) < eps) { return 0; }

    if( fabs(x_m - *x_1) > fabs(x_m - *x_2) &&  fabs(x_m - *x_1) > fabs(x_m - *x_3)  )
    {
        *x_1 = x_m;
        return 1;
    }

    if( fabs(x_m - *x_2) > fabs(x_m - *x_1) &&  fabs(x_m - *x_2) > fabs(x_m - *x_3)  )
    {
        *x_2 = x_m;
        return 1;
    }

    if( fabs(x_m - *x_3) > fabs(x_m - *x_1) &&  fabs(x_m - *x_3) > fabs(x_m - *x_2)  )
    {
        *x_3 = x_m;
        return 1;
    }

}

double calculate_x_m(double x_1, double x_2, double x_3, double (*f)(double))
{
    return (x_1+x_2)/2.0 - F(x_1, x_2, f)/(2.*F_(x_1, x_2, x_3, f));
}

double calculate_x_2(double x_1, double h)
{
    return x_1 + h;
}

double calculate_x_3(double x_1, double h)
{
    return x_1 + 2.*h;
}

void plot_values(double (*f)(double), double x_min, double x_max, double dx, const char *filename)
{
    FILE *file = fopen(filename, "wt");
    double x = x_min;
    while (x <= x_max)
    {
        fprintf(file, "%f\t%f\n", x, f(x));
        x += dx;
    }

}

void do_calculations(double x_1,
                     double h,
                     double (*f)(double),
                     unsigned int n,
                     const char *filename)
{
    double x_2 = calculate_x_2(x_1, h);
    double x_3 = calculate_x_3(x_1, h);
    double x_m = 0;

    FILE *file = fopen(filename, "wt");
    for(int i = 0; i < n; ++i)
    {

        x_m = calculate_x_m(x_1, x_2, x_3, f);
        fprintf(file, "%d\t%f\t%f\t%f\t%f\t%f\t%f\t\n", i+1,
                                                      x_1,
                                                      x_2,
                                                      x_3,
                                                      x_m,
                                                      F(x_1, x_2, f),
                                                      F_(x_1, x_2, x_3, f));

        if(!find_farthest(&x_1, &x_2, &x_3, x_m))
            break;
    }
}

int main()
{
    double h = 0.01;

    do_calculations(-0.5, h, f1, 10, "danef1_1.txt");
    do_calculations(-0.9, h, f1, 10, "danef1_2.txt");
    do_calculations(1.5, h, f2, 100, "danef2_1.txt");


    plot_values(f1, -1.5, 1., 0.01, "f1.txt");
    // plot_values(f1, -1.5, 1., 0.01, "f2.txt");

    return 0;
}