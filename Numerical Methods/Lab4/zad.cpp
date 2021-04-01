#include <gsl/gsl_eigen.h> 
#include <gsl/gsl_complex.h> 
#include <gsl/gsl_complex_math.h> 
#include <cmath>
#include <stdio.h>


void print_matrix(gsl_matrix* A, int n)
{
    for (int i = 0; i < n; ++i){
		for (int j = 0; j < n; ++j){
			printf( "%e\t", gsl_matrix_get(A, i,j));
		}
		printf( "\n");
	}
}

void print_vec(double* lambda, int n)
{
    for(int i = 0; i<n; ++i)
    {
        printf( "%d\t%.6lf\n", i, sqrt(lambda[i]) );
    }
}

void clear_lambda(double* lambda)
{
    for(int i = 0; i < 6; ++i)
        lambda[i] = 0;
}

void print_eigVals(FILE* file, double* lambda, int alfa)
{
    fprintf(file, "%d\t%e\t%e\t%e\t%e\t%e\t%e\n", alfa, sqrt(abs(lambda[0])), sqrt(abs(lambda[1])), sqrt(abs(lambda[2])), sqrt(abs(lambda[3])), sqrt(abs(lambda[4])), sqrt(abs(lambda[5])));
}

void print_eigValsCo(double* lambda, int alfa)
{
    printf( "%d\t%e\t%e\t%e\t%e\t%e\t%e\n", alfa, (lambda[0]), (lambda[1]), (lambda[2]), (lambda[3]), (lambda[4]), (lambda[5]));
}

double p(double x, double alfa)
{
    return (1.0+(4.0*alfa*x*x));
}

double x_i(int i, double L, double dx)
{
    return -L/2.0 + dx * ((double)i+1.0); 
}

void Print_eigVectors(gsl_matrix_complex* evec, double L, double dx, int alfa)
{
    FILE* file;
    if( alfa == 0)
        file = fopen("EigenVectorsA0.txt", "wt");
    else if( alfa == 100)
        file = fopen("EigenVectorsA100.txt", "wt");
    else
        return;

    for(int i = 0; i < 200; ++i)
    {
        fprintf(file, "%e\t", x_i(i, L, dx));
        for( int j = 0; j < 6; ++j)
        {
            fprintf(file, "%e\t", GSL_REAL( gsl_matrix_complex_get(evec, i, j) ) );
        }
        fprintf(file, "\n");
    }
    fclose(file);
}

void Print_eigVectors2(gsl_matrix_complex* evec, double L, double dx, int alfa)
{
    FILE* file;
    if( alfa == 0)
        file = fopen("EigenVectorsAZero.txt", "wt");
    else if( alfa == 100)
        file = fopen("EigenVectorsA100.txt", "wt");
    else
        return;

    for(int i = 0; i < 200; ++i)
    {
        fprintf(file, "%f\t", x_i(i, L, dx));
        for(int j = 0; j < 6; ++j)
        {
            fprintf(file, "%f\t", GSL_REAL( gsl_matrix_complex_get(evec, i, j) ) );
        }
        fprintf(file, "\n");
    }
    fclose(file);
}

void fill_matrix(gsl_matrix* A, int n, double dx, double alfa, double L, int N)
{
    double diag;
    double x;
    for( int i = 0; i < n; ++i)
    {
        {
            x = x_i(i, L, dx);
            diag = (double)N/( p(x,alfa) * dx * dx );
            gsl_matrix_set(A, i, i, 2*diag);
            if( i < n-1)
            {
                gsl_matrix_set(A, i, i+1, -diag);
                gsl_matrix_set(A, i+1, i, -diag);
            }
        }
    }
}

int main()
{
    int n = 200;
    double L = 10.0;
    int N = 1; 

    double dx = (double)L/((double)n+1.0);
    double alfa = 0.0;
    // Wektor wartości własnych
    double lambda[6];

    gsl_matrix* A = gsl_matrix_calloc(n,n);
    gsl_vector_complex* eval = gsl_vector_complex_calloc(n);
    gsl_matrix_complex* evec = gsl_matrix_complex_calloc(n,n);

    gsl_eigen_nonsymmv_workspace* w = gsl_eigen_nonsymmv_alloc(n);
 
    alfa = 100.0;
    for(int i = 0; i < 2; ++i)
    {
        gsl_eigen_nonsymmv_workspace* w2 = gsl_eigen_nonsymmv_alloc(n);

        gsl_matrix_set_zero(A);
        gsl_matrix_complex_set_zero(evec);
        gsl_vector_complex_set_zero(eval);

        fill_matrix(A, n, dx, alfa, L, N);
        gsl_eigen_nonsymmv(A, eval, evec, w2);
        gsl_eigen_nonsymmv_sort(eval, evec, GSL_EIGEN_SORT_ABS_ASC);
        Print_eigVectors(evec, L, dx, alfa);
        
        gsl_eigen_nonsymmv_free(w2);
        alfa = 0.0;
    }

    alfa = 0.0;
    FILE* file = fopen("Eigenvalues.txt", "wt");
    while(alfa <= 100)
    {
        clear_lambda(lambda);
        gsl_matrix_set_zero(A);
        gsl_matrix_complex_set_zero(evec);
        gsl_vector_complex_set_zero(eval);

        fill_matrix(A, n, dx, alfa, L, N);
        gsl_eigen_nonsymmv(A, eval, evec, w);
        gsl_eigen_nonsymmv_sort(eval, evec, GSL_EIGEN_SORT_ABS_ASC);

        for(int i = 0; i < 6; ++i)
            lambda[i] = GSL_REAL( gsl_vector_complex_get(eval, i) );
        
        print_eigVals(file, lambda, alfa);

        alfa += 2;
    }
    fclose(file);


    gsl_matrix_free(A);
    gsl_vector_complex_free(eval);
    gsl_matrix_complex_free(evec);
    gsl_eigen_nonsymmv_free(w);

    return 0;
}


