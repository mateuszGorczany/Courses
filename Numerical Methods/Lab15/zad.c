#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define true 1
#define false 0

double gen_random()
{
    return rand()/(RAND_MAX+1.);
}

double Vn1(double x1, double x2, double sigma)
{
    return sigma * sqrt(-2*log(x1))*cos(2.*M_PI*x2);
}

double Vn2(double x1, double x2, double sigma)
{
    return sigma * sqrt(-2*log(x1))*sin(2.*M_PI*x2);
}

double maxwell(
    double sigma,
    double V
)
{
    return sqrt(2./M_PI)*1./pow(sigma, 3)*V*V*exp(-V*V/(2.*sigma*sigma));
}

double Vn(
    double V1,
    double V2,
    double V3
)
{
    return sqrt(V1*V1+V2*V2+V3*V3);
}

double *draw(double sigma, long int N)
{
    double *V_n = calloc(N, sizeof(double));

    double x1 = 0,
           x2 = 0,
           x3 = 0,
           x4 = 0,
           V1 = 0,
           V2 = 0,
           V3 = 0,
           V4 = 0;

    srand(1);

    for(int i  = 0; i < N; ++i)
    {
        x1 = gen_random();
        x2 = gen_random();
        x3 = gen_random();
        x4 = gen_random();

        V1 = Vn1(x1, x2, sigma);
        V2 = Vn2(x1, x2, sigma);
        V3 = Vn1(x3, x4, sigma);
        V4 = Vn2(x4, x4, sigma);

        V_n[i] = Vn(V1, V2, V3);
    }

    return V_n;
}

double sum_array(double *V, unsigned int N)
{
    double sum = 0;
    for(unsigned int i = 0; i < N; ++i)
    {
        sum += V[i];
    }
    return sum;
}

double *square_array(double *V, unsigned int N)
{
    double *V_prim = calloc(N, sizeof(double));

    for(unsigned int i = 0; i < N; ++i)
    {
        V_prim[i] = V[i]*V[i];
    }

    return V_prim;
}



double mean(double *V, long int N)
{
    return 1./N * sum_array(V, N);
}

double s(
    double *V,
    double *V2,
    long int N
)
{
    double V_sum = sum_array(V, N);
    double V_ = 1./(double)N * V_sum*V_sum;
    double V2_sum = sum_array(V2, N);
    double scalar = 1./(N*(N-1.));

    return sqrt(scalar * (V2_sum - V_));
}

void save_f_V(
    double sigma,
    double *V_n,
    long int N,
    const char *filename
)
{
    FILE *file = fopen(filename, "wt");
    for(long int i = 0; i < N; ++i)
    {
        fprintf(file, "%f\t%f\n", V_n[i], maxwell(sigma, V_n[i]));
    }
    fclose(file);
}

void phi_i(
    long int *n,
    long int Nl,
    double delta_V,
    int n_bars,
    const char *filename
)
{
    double phi = 0;
    FILE *file = fopen(filename, "wt");
    for (size_t i = 0; i < n_bars; ++i)
    {
        phi = (double)n[i]/(double)Nl/delta_V;
        fprintf(file, "%ld\t%f\n", i, phi);
    }
    fclose(file);
}

double *statistics(
    double *stats,
    double *Vn,
    long int N,
    unsigned int free_)
{
    stats[0] = mean(Vn, N);

    double *V_2 = square_array(Vn, N);
    stats[1] = s(Vn, V_2, N);
    if(free_)
        free(Vn);

    stats[2] = mean(V_2, N);

    double *V_4 = square_array(V_2, N);
    stats[3] = s(V_2, V_4, N);
    free(V_4);
    free(V_2);
}

double *count(
    double sigma,
    long int N,
    const char *filenameHist,
    const char *filenameF_V
)
{
    unsigned int len = 30;
    double numerator = 5.*sigma;
    double delta_V = numerator / (double)len;
    long int *n = calloc(len, sizeof(long int));
    double *V_n = draw(sigma, N);
    int j = 0;
    for(long int i = 0; i < N; ++i)
    {
        j = (int)(V_n[i]/delta_V);
        if(V_n[i] < numerator && j < len)
            n[j]++;
    }

    double *stats = calloc(4, sizeof(double));
    save_f_V(sigma, V_n, N, filenameF_V);
    statistics(stats, V_n, N, true);

    phi_i(n, N, delta_V, len, filenameHist);
    free(n);

    return stats;
}

void save_statistics(
    double **stats,
    int n_stats,
    double sigma
)
{
    double Vsr2 = 3.*sigma*sigma;
    double Vsr = sqrt(8./M_PI)*sigma;

    FILE *file = fopen("statistics.txt", "wt");
    for(int i = 0; i < n_stats; ++i)
    {
        fprintf(file, "%f\t%f\t%f\t%f\n", stats[i][0],
                                          stats[i][1],
                                          stats[i][2],
                                          stats[i][3]);
    }
    fprintf(file, "%f\t%f\t%f\t%f\n", Vsr, 0., Vsr2, 0.);

    fclose(file);

}

int main()
{
    double u = 1.66e-27;
    double m = 40.*u;
    double k = 1.38e-23;
    double T = 100;
    double sigma = sqrt(k*T/m);

    double **n_statistics = calloc(4, sizeof(double*));
    int n_stats = 4;

    long int Nl = 1e3;
    n_statistics[0] = count(sigma, Nl, "H1e3.txt", "F1e3.txt");
    Nl = 1e4;
    n_statistics[1] = count(sigma, Nl, "H1e4.txt", "F1e4.txt");
    Nl = 1e5;
    n_statistics[2] = count(sigma, Nl, "H1e5.txt", "F1e5.txt");
    Nl = 1e6;
    n_statistics[3] = count(sigma, Nl, "H1e6.txt", "F1e6.txt");

    save_statistics(n_statistics, n_stats, sigma);

    for(int i = 0; i < n_stats; ++i)
        free(n_statistics[i]);
    free(n_statistics);

    return 0;
}