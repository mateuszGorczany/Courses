#include <stdio.h>
#include <stdlib.h>
#include <math.h>

double gen_1(
    long int m
)
{
    static long int x = 10;
    int a = 17;
    x = (a*x) % m;
    return x/(m+1.);
}

double gen_1Prim(
    long int m
)
{
    static long int x = 10;
    int a = 85;
    x = (a*x) % m;
    return x/(m+1.);
}

double gen_2(
    long int m
)
{
    static const int a1 = 1176;
    static const int a2 = 1476;
    static const int a3 = 1776;

    static long int X_1 = 10;
    static long int X_2 = 10;
    static long int X_3 = 10;

    long int arka = X_1;

    X_1 = (a1*X_1+a2*X_2+a3*X_3) % (m);
    X_3 = X_2;
    X_2 = arka;

    return X_1/(m+1.);
}

void write_u(int N,
             int e,
             double (*generator)(long int),
             const char *filename)
{
    long int m = pow(2, e) - 1;
    double *U = malloc(N*sizeof(double));

    for(int i = 0; i < N; ++i)
    {
        U[i] = generator(m);
    }

    FILE *file = fopen(filename, "wt");
    for(int i = 0; i < N-4; ++i)
    {
        fprintf(file, "%f\t%f\t%f\t%f\n", U[i], U[i+1], U[i+2], U[i+3]);
    }
    fclose(file);

    free(U);
}


void write_u_3(int N, long int m, const char *filename)
{
    double *U = malloc(N*sizeof(double));

    for(int i = 0; i < N; ++i)
    {
        U[i] = gen_2(m);
    }

    FILE *file = fopen(filename, "wt");
    for(int i = 0; i < N-4; ++i)
    {
        fprintf(file, "%f\t%f\t%f\t%f\n", U[i], U[i+1], U[i+2], U[i+3]);
    }
    fclose(file);

    free(U);
}


double **generate_vectors(int N, long int m, const char *filename)
{
    double **vectors = calloc(N, sizeof(double*));
    for(int i = 0; i < N; ++i)
    {
        vectors[i] = calloc(3, sizeof(double));
    }

    FILE *file = fopen(filename, "wt");
    double len = 0;
    double u1 = 0;
    double u2 = 0;
    double u3 = 0;
    double u4 = 0;
    double u5 = 0;

    for(int i = 0; i < N; ++i)
    {
        u1 = gen_2(m);
        u2 = gen_2(m);
        u3 = gen_2(m);
        u4 = gen_2(m);
        u5 = gen_2(m);

        vectors[i][0] = sqrt(-2*log(1-u1))*cos(2*M_PI*u2);
        vectors[i][1] = sqrt(-2*log(1-u1))*sin(2*M_PI*u2);
        vectors[i][2] = sqrt(-2*log(1-u3))*cos(2*M_PI*u4);

        len = sqrt( vectors[i][0]*vectors[i][0]
                  + vectors[i][1]*vectors[i][1]
                  + vectors[i][2]*vectors[i][2]);

        vectors[i][0] /= len;
        vectors[i][1] /= len;
        vectors[i][2] /= len;

        fprintf(file, "%f\t%f\t%f\n",
         vectors[i][0],
         vectors[i][1],
         vectors[i][2]);

         len = 0;
    }
    fclose(file);

    return vectors;
}

void save_density(int *nj, int K, double delta, const char *filename)
{
    double Rj = 0;
    double Rj_1 = 0;
    double Vj = 0;
    double Vj_1 = 0;
    double gj = 0;

    FILE *file = fopen(filename, "wt");
    for(int i = 0; i < K; ++i)
    {
        Rj = delta*(i+1.);
        Rj_1 = delta*i;
        Vj = 4./3. * M_PI * pow(Rj,3);
        Vj_1 = 4./3. * M_PI * pow(Rj_1,3);
        gj = nj[i]/(Vj-Vj_1);

        fprintf(file, "%d\t%d\t%e\n", i, nj[i], gj);
    }
    fclose(file);
}

double **sphere(
    double **vectors,
    int N,
    long int m,
    const char *filename,
    const char *densFilename
)
{
    FILE *file = fopen(filename, "wt");
    int K = 10;
    int *nj = calloc(K, sizeof(int));
    double len = 0;
    double si = 0;
    double delta = 1./(double)K;

    for(int i = 0; i < N; ++i)
    {
        si = pow(gen_2(m), 1./3.);

        vectors[i][0] *= si;
        vectors[i][1] *= si;
        vectors[i][2] *= si;

        fprintf(file, "%f\t%f\t%f\n",
                vectors[i][0],
                vectors[i][1],
                vectors[i][2]);
        si = 0;
        len = len = sqrt( vectors[i][0]*vectors[i][0]
                  + vectors[i][1]*vectors[i][1]
                  + vectors[i][2]*vectors[i][2]);

        nj[(int)(len/delta)]++;
        len = 0;
    }
    fclose(file);

    save_density(nj, K, delta, densFilename);

    for(int i = 0; i < N; ++i)
    {
        free(vectors[i]);
    }
    free(vectors);
    free(nj);
}



int main()
{
    int N = 2000;

    write_u(N, 13, gen_1, "U_1.txt");
    write_u(N, 13, gen_1Prim,"U_2.txt");

    long int m = pow(2, 32) - 5;
    write_u_3(N, m, "U_3.txt");
    double **vectors = generate_vectors(N, m, "Vectors.txt");
    sphere(vectors, N, m, "filled_sphere2000.txt", "2000_dens.txt");
 
    N = 10000;
    vectors = generate_vectors(N, m, "Vectors2.txt");
    sphere(vectors, N, m, "filled_sphere10_4.txt", "10_4_dens.txt");

    N = 10000000;
    vectors = generate_vectors(N, m, "Vectors3.txt");
    sphere(vectors, N, m, "filled_sphere10_7.txt", "10_7_dens.txt");

    return 0;
}
