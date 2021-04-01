#include <stdio.h>
#include "/opt/NR/numerical_recipes.c/nrutil.h"
#include "/opt/NR/numerical_recipes.c/nrutil.c"
#include "/opt/NR/numerical_recipes.c/gaussj.c"

void wypisz(float **A, int n)
{
    for (int i = 1; i < n+1; ++i){
		for (int j = 1; j < n+1; ++j){
			printf( "%.2lf\t", A[i][j]);
		}
		printf( "\n");
	}
}

void wypisz_vec(float **A, int n, float h)
{
    for(int i =1; i<n+1; ++i)
    {
        printf( "%f\t%.6lf\n", (i-1)*h, A[i][1] );
    }
}

int main()
{
    int n = 1000;
    float **vec = matrix(1,n,1,1);
    float **A = matrix(1,n,1,n);

    // Dane;
    float omega =1;
    float k = 0;
    float m = 0;
    float v_0 = 0;
    float h = 0.1;
    float Aa = 1;

    for( int i = 1; i < n+1; ++i)
    {
        for(int j = 1; j < n+1; ++j)
        {
            A[i][j] = 0;
        }
        vec[i][1]=0;
    }
	
    
// Wypelnianie wektora
    vec[1][1] = Aa;
    vec[2][1] = v_0 * h;

   // Wypelnanie macierzy
    A[1][1] = 1;
    A[2][1] = -1;
    A[3][1] = 1;

    for( int i =1; i< n+1; ++i)
    {
        A[i][i] = 1;
    }

    for( int i = 2; i <n; ++i)
    {
        A[i+1][i] = omega*omega*h*h -2;
    }

    for( int i= 1; i < n-1; ++i)
    {
        A[i+2][i] = 1;
    }


    A[6][6] = 1;
    A[7][6] = omega*omega*h*h -2;
    A[7][7] = 1;

//    wypisz(A, n);
//    printf("\n");
//    wypisz_vec(vec, n);

    gaussj(A,n,vec,1);

    printf("\n");

    wypisz_vec(vec, n, h);


	free_matrix(vec, 1, n, 1, 1);
	free_matrix(A, 1, n, 1, n);
    return 0;
}