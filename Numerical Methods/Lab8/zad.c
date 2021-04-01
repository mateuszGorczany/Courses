#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <gsl/gsl_linalg.h>
#include <gsl/gsl_vector.h>

double f_1(double x)
{
    return 1/(1+x*x);
}

double f_2(double x)
{
    return cos(2*x);
}

void fill_c_matrix(gsl_matrix *C, size_t n)
{
    for(int i = 0; i < n; ++i)
    {
        gsl_matrix_set(C, i, i, 4);
        if(i < n-1)
            gsl_matrix_set(C, i+1, i, 1);
        if(i > 0)
        gsl_matrix_set(C, i-1, i, 1);
    }
    gsl_matrix_set(C, 0, 1, 2);
    gsl_matrix_set(C, n-1, n-2, 2);
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

void print_vector(gsl_vector *v, size_t n)
{
    for(int i = 0; i < n; ++i)
    {
        printf("%f\n", gsl_vector_get(v, i));
    }
}

gsl_vector *calculate_nodes(double x_min, double x_max, double h, int n, double (*f)(double), gsl_vector *x_wArka)
{
    gsl_vector *y_w = gsl_vector_calloc(n);
    double xx[n+6];
    double *x_w = &xx[2];

    for(int i = -2; i<=(n+3); ++i)
    {
        x_w[i] = x_min+h*(i-1);
    }

    for(int i = 0; i < n+6; ++i)
    {
        gsl_vector_set(x_wArka, i, xx[i]);
    }

    for(int i = 1; i<=n; ++i)
    {
        gsl_vector_set(y_w, i-1, f(x_w[i]));
    }
    return y_w;
}

double derivative(double x, double (*f)(double))
{
    double dx = 0.01;
    return (f(x + dx) - f(x - dx))/(2.*dx);
}

gsl_vector *solve_linear_equation(gsl_vector *b, size_t n)
{
    gsl_matrix *A = gsl_matrix_calloc(n, n);
    fill_c_matrix(A, n);
    gsl_permutation *p = gsl_permutation_alloc(n);
    gsl_vector *solution = gsl_vector_alloc(n);
    int s;
    gsl_linalg_LU_decomp(A, p, &s);
    gsl_linalg_LU_solve(A, p, b, solution);

    gsl_matrix_free(A);
    gsl_permutation_free(p);
    return solution;
}

gsl_vector *c_new(gsl_vector *c_old, double h, double alfa, double beta, int n)
{
    gsl_vector *c_new = gsl_vector_calloc(n+2);
    for(int i = 1; i <= n; ++i)
    {
        gsl_vector_set(c_new, i, gsl_vector_get(c_old, i-1));
    }
    gsl_vector_set(c_new, 0, gsl_vector_get(c_new, 2) - alfa*h/3.);
    gsl_vector_set(c_new, n+1, gsl_vector_get(c_new, n-1) +beta*h/3.);

    gsl_vector_free(c_old);

    return c_new;
}

double fi_3(double x, double x_node, double h, int n, int option)
{
    switch (option)
    {
        case 1: return (x-x_node)*(x-x_node)*(x-x_node)/(h*h*h);
        case 2: return ( h*h*h + 3*h*h*(x-x_node)+3*h*(x-x_node)*(x-x_node)-3*(x-x_node)*(x-x_node)*(x-x_node) )/(h*h*h);
        case 3: return ( h*h*h + 3*h*h*(x_node-x)+3*h*(x_node-x)*(x_node-x)-3*(x_node-x)*(x_node-x)*(x_node-x) )/(h*h*h);
        case 4: return (x_node-x)*(x_node-x)*(x_node-x)/(h*h*h);
        default: return 0;
    }

}

double s(double x, double h, gsl_vector *c, gsl_vector *x_w, int n)
{
    double sum = 0;
    int j = 2;
    for(int i = 0; i <= n+1; ++i)
    {

        if( gsl_vector_get(x_w, j-2) <= x && x < gsl_vector_get(x_w, j-1))
            sum += gsl_vector_get(c, i) * fi_3(x, gsl_vector_get(x_w, j-2), h, n, 1);

        if( gsl_vector_get(x_w, j-1) <= x && x < gsl_vector_get(x_w, j))
            sum += gsl_vector_get(c, i) * fi_3(x, gsl_vector_get(x_w, j-1), h, n, 2);

        if( gsl_vector_get(x_w, j) <= x && x < gsl_vector_get(x_w, j+1))
            sum += gsl_vector_get(c, i) * fi_3(x, gsl_vector_get(x_w, j+1), h, n, 3);

        if( gsl_vector_get(x_w, j+1) <= x && x < gsl_vector_get(x_w, j+2))
            sum += gsl_vector_get(c, i) * fi_3(x, gsl_vector_get(x_w, j+2), h, n, 4);

        if( gsl_vector_get(x_w, 0) > x || x > gsl_vector_get(x_w, n+3))
            sum += 0;
        ++j;
    }
    return sum;
}

void calculate_s_values(double x_min, double x_max, double h, gsl_vector *c, gsl_vector *x_w, int n, const char *filename, const char *nodeFilename, double (*f)(double))
{
    FILE *file = fopen(filename, "wt");
    FILE *fileNode = fopen(nodeFilename, "wt");
    double step = 0.01;
    double x = x_min;
    double y = 0;
    int i = 3;
    while(x <= x_max)
    {
        y = s(x, h, c, x_w, n);
        if(  2 < i && i <= n+2)
        {
            fprintf(fileNode, "%f\t%f\n", gsl_vector_get(x_w, i), f(gsl_vector_get(x_w, i)));
            fprintf(file, "%f\t%f\t%f\n", x, y, f(x));
        }
        else
        {
            fprintf(file, "%f\t%f\t%f\n", x, y, f(x));
        }
        ++i;
        x += step;
    }
    fclose(file);
    fclose(fileNode);
}

void calculate_interpolation(double x_min, double x_max, int n, double (*f)(double), const char *filename, const char *nodeFilename)
{
    double h = (x_max-x_min)/(n-1);
    gsl_vector *x_w = gsl_vector_calloc(n+6);
    gsl_vector *y_w = calculate_nodes(x_min, x_max, h, n, f, x_w);

    double alfa = derivative(x_min, f);
    double beta = derivative(x_max, f);
    gsl_vector_set(y_w, 0, gsl_vector_get(y_w, 0) + alfa*h/3.);
    gsl_vector_set(y_w, n-1, gsl_vector_get(y_w, n-1) - beta*h/3.);


    gsl_vector *c = solve_linear_equation(y_w, n);
    c = c_new(c, h, alfa, beta, n);

    calculate_s_values(x_min, x_max, h, c, x_w, n, filename, nodeFilename, f);

    gsl_vector_free(y_w);
    gsl_vector_free(x_w);
    gsl_vector_free(c);
}

int main()
{
    double x_min = -5, x_max = 5;
    calculate_interpolation(x_min, x_max, 5, f_1, "f1n5.txt", "f1n5nodes.txt");
    calculate_interpolation(x_min, x_max, 6, f_1, "f1n6.txt", "f1n6nodes.txt");
    calculate_interpolation(x_min, x_max, 10, f_1, "f1n10.txt", "f1n10nodes.txt");
    calculate_interpolation(x_min, x_max, 20, f_1, "f1n20.txt", "f1n20nodes.txt");

    calculate_interpolation(x_min, x_max, 6, f_2, "f2n6.txt", "f2n6nodes.txt");
    calculate_interpolation(x_min, x_max, 7, f_2, "f2n7.txt", "f2n7nodes.txt");
    calculate_interpolation(x_min, x_max, 14, f_2, "f2n14.txt", "f2n14nodes.txt");


}