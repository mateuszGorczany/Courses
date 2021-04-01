#include <map>
#include <unordered_map>
#include <vector>
#include <iostream>
#include <ctime>
#include <cstdlib>
#include "myMap.h"

const int ITER = 1e+5;
std::vector<int> keys;
std::vector<double> values;

void prepare()
{
    srand(time(NULL));
    int it = ITER;

    keys.reserve(ITER);
    values.reserve(ITER);

    while(it--)
    {
        keys.push_back(rand() % ITER);
        values.push_back(static_cast<double>(rand() % ITER)/ITER);
    }
}

template<typename Cont>
void task()
{
    clock_t start = clock();
    Cont map;
    int it = ITER;
    for(int i = 0; i < ITER; ++i)
        map[keys[i]] = values[i];

    std::cout << map.size() << std::endl;

    auto res1 = map.find(0);
    auto res2 = map.find(1);
    auto res3 = map.find(ITER-1);
    if (res1 != map.end()) {
        std::cout << "Znaleziono klucz " << res1->first << " z wartoscia " << res1->second << std::endl;
    } 
    else{
        std::cout << "Nie znaleziono klucza " << 0 << std::endl;
    }
    if (res2 != map.end()) {
        std::cout << "Znaleziono klucz " << res2->first << " z wartoscia " << res2->second << std::endl;
    } 
    else{
        std::cout << "Nie znaleziono klucza " << 1 << std::endl;
    }
    if (res3 != map.end()) {
        std::cout << "Znaleziono klucz " << res3->first << " z wartoscia " << res3->second << std::endl;
    } 
    else{
       std::cout << "Nie znaleziono klucza " << ITER-1 << std::endl;
    }

    clock_t stop = clock();
    double score = static_cast<double>(stop-start)/CLOCKS_PER_SEC;
    std::cout << "Czas: " << score << "s" << std::endl;
    /*
    */
}

int main()
{
    prepare();
    std::cout << "======= map =======\n";
    task<std::map<int, double>>();
    std::cout << "======= unordered_map =======\n";
    task<std::unordered_map<int, double>>();
    std::cout << "======= myMap =======\n";
    task<myMap<int, double>>();
    return 0;
}

/***
 --- Przykladowy wynik (powolnie, ale poprawnie) ---
======= map =======
63159
Znaleziono klucz 0 z wartoscia 0.80672
Znaleziono klucz 1 z wartoscia 0.53147
Nie znaleziono klucza 99999
Czas: 0.109192s
======= unordered_map =======
63159
Znaleziono klucz 0 z wartoscia 0.80672
Znaleziono klucz 1 z wartoscia 0.53147
Nie znaleziono klucza 99999
Czas: 0.053926s
======= myMap =======
63159
Znaleziono klucz 0 z wartoscia 0.80672
Znaleziono klucz 1 z wartoscia 0.53147
Nie znaleziono klucza 99999
Czas: 36.7261s
***/