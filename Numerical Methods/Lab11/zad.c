// #include <stdio.h>
// #include <stdlib.h>
// #include <complex.h>
#include <math.h>

// #include "/home/mateusz/Dokumenty/MN/NR/nr.h"
#include "/opt/NR/numerical_recipes.c/nrutil.h"
#include "/opt/NR/numerical_recipes.c/nrutil.c"
#include "/opt/NR/numerical_recipes.c/realft.c"
#include "/opt/NR/numerical_recipes.c/four1.c"
#include "/opt/NR/numerical_recipes.c/sinft.c"


double X()
{
    return rand()/( RAND_MAX + 1.0 );
}

double sign(double Y)
{
    if(Y > 1./2.)  return 1;
    else           return -1;
}

double a()
{
    return 2.*sign(X())*X();
}

double calculate_y0(int i, int n)
{
    double omega = 2.*(2.*M_PI/n);
    return sin(omega*i) + sin(2.*omega*i) + sin(3.*omega*i);
}

void fill_vector(float *x, int n)
{
    for(int i = 1; i <=n; ++i)
    {
        x[i] = calculate_y0(i, n);
    }
}

void make_a_noise(float *noise, int n)
{
    for(int i = 1; i <=n; ++i)
    {
        noise[i] += a();
    }
}

void save_2functionsOutput(float *y, float *y0, int n, const char *filename)
{
    FILE *file = fopen(filename, "wt");
    for(int i = 1; i <= n; ++i)
    {
        fprintf(file, "%i\t%f\t%f\n", i, y0[i], y[i]);
    }

    fclose(file);

}

void save_functionOutput(float *y, int n, const char *filename)
{
    FILE *file = fopen(filename, "wt");
    for(int i = 1; i <= n; ++i)
    {
        fprintf(file, "%i\t%f\n", i, y[i]);
    }

    fclose(file);
}

double max_from_vector(float *y, int n)
{
    double max = 0.;
    for(int i = 1; i <= n; ++i)
    {
        if(y[i] > max)
            max = y[i];
    }
    return max;
}

void discriminate(double threshold, float *y, int n)
{
    for(int i = 1; i <=n; ++i)
    {
        if(fabs(y[i]) < threshold)
            y[i] = 0;
    }
}

void scale(float *y, int n)
{
    for(int i = 1; i <=n; ++i)
    {
        y[i] *= 2./n;
    }
}

void calculate_fourier(
    float *y,
    int k,
    int n
)
{
    sinft(y, n);
    double threshold = 0.25*max_from_vector(y, n);
    if(k == 10)
    {
        save_functionOutput(y, n, "k10_fourier.txt");
        save_functionOutput(y, 100, "k10_fourier_zoom.txt");
    }
    discriminate(threshold, y, n);
    sinft(y, n);
    scale(y, n);
}

void fft(
    int k,
    const char *filename2Plots
)
{
    int n = pow(2,k);
    float *y = vector(1, n);
    float *y0 = vector(1, n);


    fill_vector(y, n);
    fill_vector(y0, n);
    make_a_noise(y, n);
    if(k == 10) save_functionOutput(y, n, "k10_noise.txt");

    calculate_fourier(y, k, n);


    save_2functionsOutput(y, y0, n, filename2Plots);

    free_vector(y0, 1, n);
    free_vector(y, 1, n);
}



int main()
{
    fft(10, "k10.txt");
    fft(8, "k8.txt");
    fft(6, "k6.txt");

    return 0;
}
