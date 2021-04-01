#include <stdlib.h>
#include <stdio.h>
#include <complex.h>

#define n 4
#define IT_MAX 20

void zero_vector(complex double *x, size_t n_)
{
    for(int i = 0; i < n_; ++i)
        x[i] = 0. +0.I;
}

void fill_vector(double complex *v)
{
    v[0] = 16. + 8.I;
    v[1] = -20. + 14.I;
    v[2] = 4. - 8.I;
    v[3] = -4. + 1.I;
    v[4] = 1. + 0.I;
}

/// a <- b
void copy_vector(complex double *a, complex double *b)
{
    for(int i = 0; i < n+1; ++i)
        a[i] = b[i];
}

void print_vector(complex double *z, int n_)
{
    for(int i = 0; i < n_; ++i)
        printf("%f + i%f\n", creal(z[i]), cimag(z[i]) );
}


double complex *recursive_b_j(double complex *b, double complex *a, double complex z_j, int l)
{
    if (l == 0) return b;
    b[l-1] = a[l] + z_j*b[l];
    return recursive_b_j(b, a, z_j, l-1);
}

double complex calculate_R_J(double complex *a, double complex *b, const double complex z_j, int l)
{
    b[l] = 0.0 + 0.I;
    b = recursive_b_j(b, a, z_j, l);
    return a[0] + z_j*b[0];
}

void save_matrix(double complex **z, const char *filename)
{
    FILE *file = fopen(filename, "wt");
    for(int i = n-1; i>=0; --i)
    {
        for(int j = 0; j<IT_MAX; ++j)
        {
            fprintf(file, "%f \t%f\n", creal(z[i][j]), cimag(z[i][j]));
        }
    }
    fclose(file);
}

void newton(double complex *a, double complex *b, double complex *c, double complex z_0, const char *filename)
{
    double complex R = 0. + 0.I;
    double complex R_prim = 0. + 0.I;
    double complex **z = malloc(n*sizeof(double complex*));
    for ( int i = 0; i < n; ++i)
        z[i] = calloc(IT_MAX, sizeof(double complex));

    for(int l = n; l >=1; --l)
    {
        z[l-1][0] = z_0;
        for(int j = 1; j<IT_MAX; ++j)
        {
            R = calculate_R_J(a, b, z[l-1][j-1], l);
            R_prim = calculate_R_J(b, c, z[l-1][j-1], l-1);
            z[l-1][j] = z[l-1][j-1] - R/R_prim;
        }
        copy_vector(a, b);
    }
    save_matrix(z, filename);
    for(int i = 0; i < n; ++i)
        free(z[i]);
    free(z);
}

int main()
{
    double complex *a = malloc((n+1)*sizeof(double complex));
    double complex *b = malloc((n+1)*sizeof(double complex));
    double complex *c = malloc(n*sizeof(double complex));

    fill_vector(a);
    newton(a, b, c, 0.0+0.I, "output1.txt");
    fill_vector(a);
    zero_vector(b, n+1);
    zero_vector(b, n);
    newton(a, b, c, -10 -10.I, "output2.txt");

    free(c);
    free(b);
    free(a);
}