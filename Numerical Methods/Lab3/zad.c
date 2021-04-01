#include "stdio.h"
#include "math.h"
#include "stdio.h"
#include "time.h"

void printVec(float* ptr, int n)
{
    for(int i =0; i<n; ++i)
    {
        printf("%f %f\n", 0.04*i, ptr[i]);
    }
}

void copyVec(float* dest, float* src, int n)
{
    for(int i = 0; i<n;++i)
    {
        dest[i] = src[i];
    }
}

void fillVec(float* ptr, float val, int start, int stop)
{
    for(int i =start; i<stop; ++i )
    {
        ptr[i] = val;
    }
}

int checkConv(float* vec1, float* vec2, int n, float eps)
{
    float sum1 = 0;
    float sum2 = 0;
    for(int i=0; i<n;++i)
    {
        sum1 += vec1[i]*vec1[i];
        sum2 += vec2[i]*vec2[i];
    }

    if( fabs(sum2-sum1) < eps)
        return 1;
    else 
        return 0;
    

}

int main()
{
    int zarodek;
    time_t tt;
    zarodek = time(&tt);
    srand(zarodek);
    // ponizej diagonali

    int n = 1000;
    float d_0[n];
    float d_1[n];
    float d_2[n];

    d_0[0] = 1;
    d_0[1] = 1;

    d_1[0] = 0;
    d_1[1] = -1;

    d_2[0] = 0;
    d_2[0] = 0;

    // Wyrazy wolne
    float b[n];
    b[0] = 1;
    b[1] = 0;


    float omega = 1;
    float x_0 = 1;
    float v_0 = 0;
    float h = 0.02;

    float eps = 0.0001;

    // Zmiana:
    float OMEGA = 0.8;
    float Beta = 0.4;
    float F_0 = 0.1;
    // 

    for(int i = 2; i<n; ++i)
    {
        b[i] = F_0*sin(OMEGA*h*i)*h*h;
    }


    float a_1 =1;
    float a_2 = omega*omega*h*h-2-Beta*h;
    float a_3 = 1+Beta*h;

    fillVec(d_0, a_3, 2,n);
    fillVec(d_1, a_2, 2,n);
    fillVec(d_2, a_1, 2,n);

    float x_n[n];
    float x_s[n];
    fillVec(x_s, 0,0,n);

    // printVec(d_0,4);
    // printf("\n");
    // printVec(d_1,4);
    // printf("\n");
    // printVec(d_2,4);
    // printf("\n");
    // printVec(b,4);

    for(int i =0; i<n;++i)
    {
        x_n[i] = (float)(rand()%2);
        x_s[i] = 0.0;
    }
    // x_s[1] = 1;
    // x_s[2] = 2;
    
    x_s[0] = x_n[0];
    
    //printVec(x_n,n);
    // Zadanie wlasciwe (kalkulacja):
    int arka = 0;
    for(int j = 1; j< 10000; ++j)
    {
        for(int i = 0; i<n; ++i)
        {
            if(i == 0)
                x_n[i] = (1.0/d_0[i])*b[i];
            else if(i == 1)
                x_n[i] = (1.0/d_0[i])*(b[i] - d_1[i] * x_s[i-1]);
            else
                x_n[i] = ( 1.0/d_0[i] ) * ( b[i]-d_1[i]*x_s[i-1] - d_2[i]*x_s[i-2] );
            
        }
        int var = checkConv(x_n, x_s, n, eps);
        if( var == 1)
            break;
        else
        {
            copyVec(x_s,x_n,n);
        }
        //    continue;
        arka = j;
        
    }

    
    printVec(x_n, n);


//    printf("\n\n%d\n", arka);

    return 0;
}