#include "stdio.h"
#include <gsl/gsl_linalg.h>
#include <gsl/gsl_vector.h>


int main()
{   
    int N = 4;
    gsl_matrix* A = gsl_matrix_calloc(N,N);
    gsl_matrix* A_inv = gsl_matrix_calloc(N,N);
    gsl_matrix* result = gsl_matrix_calloc(N,N);
    gsl_matrix* arka = gsl_matrix_calloc(N,N);

    gsl_permutation* p = gsl_permutation_calloc(N);
    gsl_vector* b = gsl_vector_calloc(N);
    gsl_vector* x = gsl_vector_calloc(N);

    gsl_matrix *B;
    gsl_matrix *BT;

    double delta = 2;
    double det_U = 1;

    for(int i = 0; i<N; ++i)
    {
        for(int j = 0; j<N; ++j)
        {
            gsl_matrix_set(A,i,j,1/((double)i+(double)j+delta));
        }
    }

    gsl_matrix_memcpy(arka, A);

    int signum;
    gsl_linalg_LU_decomp(A, p, &signum);

    for(int i =0; i<N;++i)
    {
        det_U = det_U*gsl_matrix_get(A,i,i);
        printf("%f ", gsl_matrix_get(A,i,i));
    }
    printf("\n");    
    printf("%e\n", det_U);

    for(int i =0; i<N;++i)
    {
            gsl_vector_set_zero(b);
//            gsl_vector_set_zero(x);
            gsl_vector_set(b, i, 1);
            gsl_linalg_LU_solve(A, p, b, x);
//            gsl_matrix_memcpy(A,arka);
        for(int j = 0; j<N;++j)
        {
            gsl_matrix_set(A_inv,i,j, gsl_vector_get(x, j));
        }

    }

    for(int i = 0; i <N; ++i)
    {
        for(int j = 0; j<N; ++j)
        {
            printf("%f ", gsl_matrix_get(A_inv,i,j));
        }
        printf("\n");
    }

    gsl_blas_dgemm(CblasNoTrans,CblasNoTrans,1.0,arka,A_inv, 0.0, result);

    printf("\n Iloczyn macierzy A*A_inv\n\n");
    for(int i = 0; i <N; ++i)
    {
        for(int j = 0; j<N; ++j)
        {
            printf("%e ", gsl_matrix_get(result,i,j));
        }
        printf("\n");
    }

    double d = gsl_matrix_max(arka);
    double d2 = gsl_matrix_max(A_inv);
    double uwar = d*d2;

    printf("\nUwarunkowanie: %lf\n", uwar);

    gsl_matrix_free(arka);
    gsl_permutation_free(p);
    gsl_matrix_free(A);
    gsl_vector_free(x);
    gsl_vector_free(b);
    gsl_matrix_free(A_inv);
    gsl_matrix_free(result);
    return 0;
}
