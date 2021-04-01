#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <gsl/gsl_linalg.h>
#include <gsl/gsl_vector.h>

#define n 7
#define IT_MAX 12

void fill_matrix(gsl_matrix *A, int n_)
{
    for( int i = 0; i < n_; ++i)
    {
        for( int  j = 0; j < n_; ++j)
        {
            /*A[i][j] = 1/sqrt(2+abs(i-j)); */
            gsl_matrix_set(A, i, j, 1/sqrt(2+abs(i-j)) );

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

void matrix_fprintf(FILE *file, gsl_matrix *A, int n_)
{
    for ( int i = 0; i < n_; ++i)
    {
        for ( int j = 0; j<n_; ++j)
            fprintf(file, "%e\t", gsl_matrix_get(A, i, j));
        fprintf(file, "\n");
    }

}

void matrix_fprintf_latex(gsl_matrix *A, int n_)
{
    FILE *file = fopen("matrix_latex.txt", "wt");
    for ( int i = 0; i < n_; ++i)
    {
        for ( int j = 0; j<n_; ++j)
        {
            if(j < n_-1)
                fprintf(file, "%.4f\t&\t", gsl_matrix_get(A, i, j));
            if(j == n_-1)
            {
                fprintf(file, "%.4f\t \\\\", gsl_matrix_get(A, i, j));
            }
        }
        fprintf(file, "\n");
    }
    fclose(file);
}


void save_lambdas(gsl_matrix* A)
{
    FILE* file = fopen("lambdas.txt", "wt");
    for(int i = 0; i < IT_MAX; ++i)
    {
        fprintf(file, "%d\t", i);
        for(int j = 0; j<n; ++j)
        {
            fprintf(file, "%e\t", gsl_matrix_get(A, i, j));
        }
        fprintf(file, "\n");
    }
    fclose(file);
}

void lambdas_algorithm(gsl_matrix* A, gsl_matrix* W, gsl_matrix* X, int n_)
{
    gsl_matrix_memcpy(W, A);

    gsl_matrix *x_k_MATRIX = gsl_matrix_alloc(n_, 1);
    gsl_matrix *x_k_MATRIX_Transpose = gsl_matrix_alloc(1, n);
    gsl_matrix *to_Substr = gsl_matrix_calloc(n_, n_);
    gsl_matrix *lambdasMatrix = gsl_matrix_calloc(IT_MAX, n_);

    gsl_vector *x_k = gsl_vector_alloc(n_);
    gsl_vector *x_k_plus_1 = gsl_vector_alloc(n_);

    
    // double *lambdas = malloc( n_*sizeof(double));

    printf("Eigenvalues: \n");
    for ( int k = 0; k < n_; ++k)
    {
        double lambda = 0;
        gsl_vector_set_all(x_k, 1.);
        gsl_vector_set_all(x_k_plus_1, 0.);
        gsl_matrix_set_zero(x_k_MATRIX);
        gsl_matrix_set_zero(to_Substr);

        for ( int i = 1; i <= IT_MAX; ++i)
        {
            gsl_blas_dgemv(CblasNoTrans, 1.0, W, x_k, 0.0, x_k_plus_1);

            double numerator = 0, denumerator = 0;
            gsl_blas_ddot(x_k_plus_1, x_k, &numerator);
            gsl_blas_ddot(x_k, x_k, &denumerator);

            // lambdas[i-1] = numerator/denumerator;
            gsl_matrix_set(lambdasMatrix, i-1, k, numerator/denumerator);

            double norm = gsl_blas_dnrm2(x_k_plus_1);
            gsl_vector_memcpy(x_k, x_k_plus_1);
            gsl_vector_scale(x_k, 1.0/norm);
        }

        gsl_matrix_set_col(X, k, x_k); // Macierz wynikowa

        gsl_matrix_set_col(x_k_MATRIX, 0.0, x_k);
        gsl_matrix_set_row(x_k_MATRIX_Transpose, 0.0, x_k);

        gsl_blas_dgemm(CblasNoTrans, CblasNoTrans, 1.0, x_k_MATRIX, x_k_MATRIX_Transpose, 0.0, to_Substr);
        
        gsl_matrix_scale(to_Substr, gsl_matrix_get(lambdasMatrix, IT_MAX-1, k)/*lambdasMatrix[IT_MAX-1][k]*/);
        gsl_matrix_sub(W, to_Substr);

        save_lambdas(lambdasMatrix);
        printf("Lambda[%d] = %f\n", k, gsl_matrix_get(lambdasMatrix, IT_MAX-1, k));
    }
    printf("\n");


    gsl_matrix_free(to_Substr);
    gsl_matrix_free(x_k_MATRIX);
    gsl_matrix_free(x_k_MATRIX_Transpose);
    gsl_matrix_free(lambdasMatrix);
    gsl_vector_free(x_k);
    gsl_vector_free(x_k_plus_1);
    // return lambdas;
}

int main()
{
    gsl_matrix *A = gsl_matrix_calloc(n, n);
    gsl_matrix *W = gsl_matrix_calloc(n, n);
    gsl_matrix *X = gsl_matrix_calloc(n, n);
    gsl_matrix *D = gsl_matrix_calloc(n, n);
    gsl_matrix *temp = gsl_matrix_calloc(n, n);

    fill_matrix(A, n);
    print_matrix(A, n);

    lambdas_algorithm(A, W, X, n);

    printf("Macierz X =\n");
    print_matrix(X, n);

    gsl_blas_dgemm(CblasNoTrans, CblasNoTrans, 1.0, A, X, 0.0, temp);
    gsl_matrix_transpose(X); // Wektor X się zmienia!
    gsl_blas_dgemm(CblasNoTrans, CblasNoTrans, 1.0, X, temp, 0.0, D);

    print_matrix(D, n);

    FILE* file = fopen("D.txt", "wt");
    matrix_fprintf(file, D, n);
    // matrix_fprintf_latex(D, n);
    fclose(file);

    gsl_matrix_free(A);
    gsl_matrix_free(W);
    gsl_matrix_free(X);
    gsl_matrix_free(D);
    gsl_matrix_free(temp);
    
    return 0;
}