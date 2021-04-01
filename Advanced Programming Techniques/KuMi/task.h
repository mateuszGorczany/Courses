#include <iostream>
#include <string>
#include <initializer_list>
#include <string_view>
#include <vector>
#include <map>
#include <set>
#include <typeinfo>
#include <any>
#include <cstring>

// 1 (1 pkt)
// Napisz JEDNĄ funkcję szablonową addEverything wykorzystując Fold Expressions
// tak aby wywołania w mainie były poprawne oraz by na początku każdego
// wyniku pojawiło się '>' a następnie dodane elementy oraz by działa dla innych typów wbudowanych np. int
// działanie na liczbach nie musi "mieć sensu", musi tylko działać
// auto addEverything(std::string s1, std::string s2, std::string s3) {return "";}
// auto addEverything(std::string s1, std::string s2, std::string s3, std::string s4, std::string s5) {return "";}
// auto addEverything(std::string s1, std::string s2, std::string s3, std::string s4, std::string s5, std::string s6, std::string s7) {return "";}
// auto addEverything(int i1, int i2, int i3, int i4, int i5) {return "";}

template <typename ...Args>
auto addEverything(Args &&...args) { return  ('>' + ... +args) ; }
// 2 (3 pkt)
template<class T>
constexpr T absT(T arg) 
{
    return arg > 0 ? arg : -arg;
}

template <class T>
constexpr auto precision_threshold = T(0.000001);

// Zastąp deklaracje dwóch funkcji szablonowych compareEverything,
// sprawdzających równość dwóch liczb zarówno dla typów stało- jak i zmiennoprzecinkowych,
// za pomocą jednej wykorzystując constexpr if oraz dwie powyższe deklaracje
// *** zmiany typu is_floating_point od standardu 17 pozwalają skrócić kod o 5 znaków ***


template<class T>
constexpr auto
compareEverything(T a, T b)
{
    if constexpr (std::is_floating_point<T>::value)
    {
        std::cout << "Floating ";
        return absT<T>(a - b) < precision_threshold<T>;
    }   
    else
    {
        std::cout << "Non-Floating ";
        return a == b;
    }
}


// 3 (3 pkt)
struct OversizedVecElement
{
    OversizedVecElement(std::string_view _sv, double _d, bool _b) : sv{_sv}, d{_d}, b{_b} {};
    std::string_view sv;
    double d;
    bool b;
};

// Uprość funkcję improveVectorHandling za pomocą if-init i structured bindings
// tak by pozbyć się strzałek i kropek 
void improvedVectorHandling(std::vector<OversizedVecElement>& v)
{
    if (const auto &[sv, d, b] = *v.begin(); b)
    {
        std::cout << "key = " << sv << " value = " << d << "\n";
    }
    else
    {
        for(const auto &[sv, d, b] : v)
        {
            std::cout << "key = " << sv << " value = " << d << "\n";
        }
    }
}

// Popraw przeładowanie operatora<< korzystając If-init statements i structured bindings
// aby zwiekszyc czytelnosc
std::ostream& operator<<(std::ostream& os, const OversizedVecElement& el)
{
    if (const auto &[sv, d, b] = el;  b)
        os << sv << ", " << d;
    else
        os << "Hidden element";
    return os;
}

// Popraw funkcję copyAndPrintVector wykorzystując
// If-init statements i structured bindings oraz zmiany w funkcjach bibliotecznych,
// tak aby realizowała swoją funkcjonalność w jednej pętli
void copyAndPrintVector(std::vector<OversizedVecElement>& v1, std::vector<OversizedVecElement>& v2)
{
    for(const auto &element: v1)
    {
        std::cout << v2.emplace_back(element) << '\n';
    }
}

// 4 (2 pkt)
// Napisz strukturę/klasę szablonową Smart pozwalającą na zainicjalizowanie 
// obiektu jej typu za pomocą łańucha znaków typu const char* np. "A String"
// z wykorzystaniem Class Template Argument Deduction Guides
// Struktura ma jedno pole typu T o nazwie t
// i jest agregatem

//Formal definition from the C++ standard (C++03 8.5.1 §1):
//  An aggregate is an array or a class (clause 9) with NO USER-DECLARED CONSTRUCTORS (12.1),
//  no private or protected non-static data members (clause 11),
//  no base classes (clause 10),
//  and no virtual functions (10.3).

template<typename T>
struct Smart
{
    T t;
};

template <typename T>
Smart(T) -> Smart<T>;

// Wypełnij funkcję castAndOutSmart tak aby wypisywała 
// pole t struktury Smart wykorzystując rzutowanie typu std::any
// z implementacją bloku try/catch do przechwycenia błędnego rzutowania
void castAndOutSmart(std::any a)
{
    try 
    {
        std::cout << std::any_cast<Smart<const char *>>(a).t << '\n';
    }
    catch (const std::bad_any_cast &err)
    {
        puts(err.what());
    }

}

// 5 (1 pkt)
// Popraw funkcję doSomethingToString korzystając z std::string_view
// i funkcji substr() oraz find() tak aby realizowała identyczną funkcjonalność
// ale dla podanych w mainie zakomentowanych wywołań
const std::string_view doSomethingToString(const std::string_view &s)
{
    return s.substr(s.find('A'));
}