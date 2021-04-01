#include <iostream>
#include <set>

using kontener = std::set<double>;

std::ostream &operator<<(std::ostream &ostr, const kontener &containerToPrint)
{
    ostr << "{ ";

    if (!std::empty(containerToPrint))
    {
        for (auto element = std::begin(containerToPrint); element != --std::end(containerToPrint); ++element)
            ostr << *element << ", ";
        ostr << *--std::end(containerToPrint);
    }

    ostr << " }";
    return ostr;
}

int main()
{
    //using kontener = ...
    kontener K = {0.5, 3.4, 2.2, 1.8, 0.5, 5.8, 4.1, 4.0, 2.2};
    
    std::cout << "Kontener: ";
    std::cout << K << '\n';
    //

    K.insert(3.4);
    std::cout << "Po wstawieniu 3.4: ";
    std::cout << K << '\n';
    //
    

    std::cout << "Liczby z przedziału (1, 4]: ";
    for (auto element = K.lower_bound(1); element != K.upper_bound(4); ++element)
        std::cout << *element << ' ';
    std::cout << '\n';
}

/*Wyjście:
Kontener: 0.5 1.8 2.2 3.4 4 4.1 5.8 
Po wstawieniu 3.4: 0.5 1.8 2.2 3.4 4 4.1 5.8 
Liczby z przedziału (1, 4]: 1.8 2.2 3.4 4
*/
