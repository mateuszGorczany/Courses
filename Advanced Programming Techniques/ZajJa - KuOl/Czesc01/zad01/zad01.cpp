#include <iostream>
#include <set>
#include <map>
#include <algorithm>

using namespace std;
using zabytkizer = multimap<string, string>;


void printZabytki(const zabytkizer &zab, const string &city)
{
    const auto &zabytkies = zab.equal_range(city);
    std::cout << city << ": ";
    for (auto it = zabytkies.first; it != zabytkies.second; ++it)
        cout << it->second << ", ";

    cout << '\n';
}

void printMiasta(const zabytkizer &zab)
{
    set<string> cities;
    transform(begin(zab), end(zab), inserter(cities, begin(cities)), [](auto const  &pairToCpy)
    {
        return pairToCpy.first;
    });

    for (auto city = make_reverse_iterator(end(cities)); 
         city != make_reverse_iterator(begin(cities)); 
         ++city)
        cout << *city << '\n';
}
/*
*/

void countZabytki(const zabytkizer &zab, const string &city)
{
    const auto &zabytkies = zab.equal_range(city);
    cout << city << ": "  << distance(zabytkies.first, zabytkies.second)   << '\n';
}

int main()
{
    zabytkizer zab1{
        {"Warszawa", "Gruzy"},
        {"Warszawa", "Syrenka"},
        {"Warszawa", "Pomnik smoleński"},
        {"Kraków", "Zamek"}, 
        {"Kraków", "Kopiec"}, 
        {"Kraków", "Dziury w drogach"},
        {"Wrocław", "Krasnale"},
        {"Wrocław", "Torowiska dla tramwajów"}
        };

    puts("1: ");
    printZabytki(zab1, "Kraków");
    puts("\n2:");
    printMiasta(zab1);
    puts("\n3:");
    countZabytki(zab1, "Kraków");
    return 0;
}