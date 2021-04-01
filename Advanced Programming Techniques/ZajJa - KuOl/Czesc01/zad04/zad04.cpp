#include <iostream>
#include <iterator>
#include <map>
#include <set>
#include <list>


// template <class T> struct less : binary_function <T,T,bool> 
template <typename T> struct comparator 
{
  bool operator() (const T& x, const T& y) const 
  {
      return std::get<0>(x) != std::get<0>(y) ? std::get<0>(x) < std::get<0>(y) : std::get<1>(x) > std::get<1>(y);
  }
};

template <typename T, typename U>
// using mymap = std::multimap<T, U, std::less<T>, std::allocator<std::tuple<const T, U>>>;
// using mymap = std::list<std::tuple<T, U>, comparator<std::tuple<T, U>>, std::allocator<std::tuple<const T, U>>>;
using mymap = std::set<std::pair<T, U>, comparator<std::pair<T, U>>>;

template <typename T, typename U>
using mymap2 = std::set<std::tuple<T, U>, comparator<std::tuple<T, U>>>;


template <typename T>
std::ostream &buffer(std::ostream &ostr, const T &containerToPrint)
{
    ostr << "[\n";

    if (!std::empty(containerToPrint))
    {
        for (auto element = std::begin(containerToPrint); 
             element != std::end(containerToPrint);
             ++element)
        {
            // ostr << "  {" << element->first << ", " << element->second << "}\n";
            ostr << " {" 
                 << std::get<0>(*element) 
                 << ", "
                 << std::get<1>(*element)
                 << "}\n";
        }
    }

    ostr << "]";
    return ostr;
}

template<typename T, typename U>
std::ostream &operator<<(std::ostream &ostr, const mymap<T, U> obj) { return buffer(ostr, obj);  }
template<typename T, typename U>
std::ostream &operator<<(std::ostream &ostr, const mymap2<T, U> obj) { return buffer(ostr, obj);  }

using namespace std;
int main()
{
    puts("Set of pairs");
    mymap<char, int> m{
        {'a', 7},
        {'a', 2},
        {'a', 1},
        {'b', 2},
        {'b', 1},
        {'c', 3},
        {'c', 5},
        {'d', 5},
        {'d', 8},
        {'c', 7}
    };

    cout << m << '\n';
    m.clear();
    puts("Po wyczyszczeniu:");
    cout << m << '\n';

    puts("Druga wersja (set of tuples):");
    mymap2<char, int> m2{
        {'a', 7},
        {'a', 2},
        {'a', 1},
        {'b', 2},
        {'b', 1},
        {'c', 3},
        {'c', 5},
        {'d', 5},
        {'d', 8},
        {'c', 7}
    };

    cout << m2 << '\n';
    m2.clear();
    puts("Po wyczyszczeniu:");
    cout << m2 << '\n';
    return 0;
}