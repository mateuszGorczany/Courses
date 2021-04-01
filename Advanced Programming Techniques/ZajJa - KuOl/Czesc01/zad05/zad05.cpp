#include <iostream>
#include <list>
#include <iterator>

void printContainer(std::list<int> list, const char *delim=" ")
{
    std::copy(std::begin(list), std::end(list), std::ostream_iterator<double>{std::cout, delim});
    std::cout << '\n';
}

using namespace std;
int main()
{
    list<int> l1 = {9,8,7,1,2,3,4,5,6};
    printContainer(l1);

    back_insert_iterator<list<int>> insert_iter(l1);
    list<int> l2 = {10,11,12};
    copy(begin(l2), end(l2), back_inserter(l1));
    printContainer(l1);

    list<int> l3 = {13,14,15};
    copy(begin(l3), end(l3), inserter(l1, next(begin(l1), 7)));
    printContainer(l1);

    auto r_iter = next(begin(l1), 2);
    (*r_iter) = 18;
    (*++r_iter) = 17;
    (*++r_iter) = 16;
    printContainer(l1);

    return 0;
}