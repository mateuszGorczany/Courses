#include <iostream>
#include <iterator>
#include <algorithm>
#include <list>

template<typename T>
std::ostream &operator<<(std::ostream &ostr, const std::list<T> &containerToPrint)
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
    std::list<int> K1 = {111, 222, 333, 444, 555};
    std::list<int> K2 = {100, 200, 300};

    std::cout << "K1: ";
    std::copy(K1.begin(), K1.end(), std::ostream_iterator<double>{std::cout, "/"});
    std::cout << '\n';

    std::cout << "K2: ";
    std::copy(K2.begin(), K2.end(), std::ostream_iterator<double>{std::cout, "/"});
    std::cout << "\n\n";

    K1.insert(std::next(std::begin(K1), 3), 666);
    std::cout << "K1: ";
    std::copy(K1.begin(), K1.end(), std::ostream_iterator<double>{std::cout, "/"});
    std::cout << "\n\n";

    K1.insert(++std::begin(K1), 777);
    std::cout << "K1: ";
    std::copy(K1.begin(), K1.end(), std::ostream_iterator<double>{std::cout, "/"});
    std::cout << "\n\n";

    K1.remove(444);
    std::cout << "K1: ";
    std::copy(K1.begin(), K1.end(), std::ostream_iterator<double>{std::cout, "/"});
    std::cout << "\n\n";

    K1.splice(--std::end(K1), K2);
    std::cout << "K1: ";
    std::copy(K1.begin(), K1.end(), std::ostream_iterator<double>{std::cout, "/"});
    std::cout << '\n';

    std::cout << "K2: ";
    std::copy(K2.begin(), K2.end(), std::ostream_iterator<double>{std::cout, "/"});
    std::cout << "\n\n";

    K1.reverse();
    std::cout << "K1: ";
    std::copy(K1.begin(), K1.end(), std::ostream_iterator<double>{std::cout, "/"});
    std::cout << '\n';
    return 0;
}