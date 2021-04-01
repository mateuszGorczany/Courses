#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <gsl/gsl_linalg.h>
#include <gsl/gsl_vector.h>


double f(double x){ return 1/(1+x*x); }

void fill_nodes_steadily(gsl_vector *x, int n, double range)
{
    double val = 0;
    for(int i = 0; i < n+1; ++i)
    {
        gsl_vector_set(x, i, -range + i*2*range/(double)n);
    }
}

void fill_optimal_nodes(gsl_vector *x, int n, double min, double max)
{
    double val = 0;
    for(int i = 0; i < n + 1; ++i)
    {
        val = 1./2. * ( (max - min)
                        * cos( M_PI * (2*i+1.) / (2.*n+2.) )
                        +(max+min)
                      );
        gsl_vector_set(x, i, val);
    }
}

void print_vector(gsl_vector *x, int n)
{
    for( int i = 0; i < n; ++i)
    {
        printf("%f\n", gsl_vector_get(x, i));
    }
}

void save_nodes(const char *filename, gsl_vector *x, gsl_vector *f_x, int n)
{
    FILE *file = fopen(filename, "wt");
    for( int i = 0; i < n + 1; ++i)
    {
        fprintf(file, "%f\t%f\n", gsl_vector_get(x, i), gsl_vector_get(f_x, i));
    }
    fclose(file);
}

void calculate_f_x(gsl_vector *f_x, gsl_vector *x, double (*f)(double), int n)
{
    for( int i = 0; i < n; ++i)
    {
        gsl_vector_set(f_x, i, f(gsl_vector_get(x, i)));
    }
}

void interpolation(gsl_matrix *F, gsl_vector *x, int n)
{
    double val = 0;
    for(int j = 1; j <= n; ++j)
    {
        for(int i = j; i <=n; ++i)
        {
            val = (gsl_matrix_get(F, i, j -1) - gsl_matrix_get(F, i-1, j-1)) / (gsl_vector_get(x, i) - gsl_vector_get(x, i-j));
            gsl_matrix_set(F, i, j, val);
        }
    }
}
void print_matrix(gsl_matrix *A, int n_)
{
    for( int i = 0; i < n_; ++i)
    {
        for( int  j = 0; j < n_; ++j)
        {
            printf("%f ",  gsl_matrix_get(A, i, j)/*A[i][j]*/);
        }
        printf("\n");
    }

    printf("\n");
}

double polynomial_product(double x, gsl_vector *x_nodes, int j)
{
    double product = 1.;
    for(int i = 0; i < j; ++i)
    {
        product *= (x - gsl_vector_get(x_nodes, i));
    }
    return product;
}

double W_n_single_value(double x, gsl_matrix *F, gsl_vector *x_nodes, int n)
{
    double value = 0;
    for(int i = 0; i < n; ++i)
        value += gsl_matrix_get(F, i, i)*polynomial_product(x, x_nodes, i);

    return value;
}

void W_n(double min, double max, gsl_matrix *F, gsl_vector *x_nodes, int n, const char *filename)
{
    double dx = 0.02;
    double x = min;

    FILE *file = fopen(filename, "wt");

    while(x < max)
    {
        fprintf(file, "%f\t%f\t%f\n", x, W_n_single_value(x, F, x_nodes, n), f(x));
        x+=dx;
    }
    fclose(file);
}


void do_operations(int n, double min, double max, const char *filename, const char *filename_nodes, int optimal)
{

    gsl_vector *x = gsl_vector_calloc(n+1);
    gsl_vector *f_x = gsl_vector_calloc(n+1);
    gsl_matrix *F = gsl_matrix_calloc(n+1, n+1);

    if (optimal == 1)
        fill_optimal_nodes(x, n, min, max);
    else
        fill_nodes_steadily(x, n, max);

    calculate_f_x(f_x, x, f, n+1);
    gsl_matrix_set_col(F, 0, f_x);
    interpolation(F, x, n);

    W_n(min, max, F, x, n, filename);
    save_nodes(filename_nodes, x, f_x, n);

    gsl_vector_free(x);
    gsl_vector_free(f_x);
    gsl_matrix_free(F);
}

int main()
{
    double min, max;
    min = -5.;
    max = 5.;

    int n, ifoptimal;
    ifoptimal = 0;

    n = 5;
    do_operations(n, min, max, "output_5.txt", "nodes_5.txt", ifoptimal);

    ///////////
    n = 10;
    do_operations(n, min, max, "output_10.txt", "nodes_10.txt", ifoptimal);

    ///////////
    n = 15;
    do_operations(n, min, max, "output_15.txt", "nodes_15.txt", ifoptimal);

    ///////////
    n = 20;
    do_operations(n, min, max, "output_20.txt", "nodes_20.txt", ifoptimal);

    //////// OPTIMAL //////////
    ifoptimal = 1;

    n = 5;
    do_operations(n, min, max, "output_5opt.txt", "nodes_5opt.txt", ifoptimal);
    ///////////

    n = 10;
    do_operations(n, min, max, "output_10opt.txt", "nodes_10opt.txt", ifoptimal);
    //////////

    n = 15;
    do_operations(n, min, max, "output_15opt.txt", "nodes_15opt.txt", ifoptimal);
    ///////////

    n = 20;
    do_operations(n, min, max, "output_20opt.txt", "nodes_20opt.txt", ifoptimal);
}