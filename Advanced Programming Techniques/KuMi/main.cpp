/*
    Polecenia znajdują się w pliku task.h, 
    po ich odpowiednim wykonaniu plik main powinien się skompilować
    ZWRÓĆ UWAGĘ NA ZAKOMENTOWANY KOD W ĆWICZENIACH 4 I 5

    Kompilacja w standardzie C++17:
        MSVC: cl main.cpp /std:c++17
        GCC: g++ -std=c++17 -o main.exe main.cpp 
        CLang: clang++ -std=c++17 -o main.exe main.cpp

    Rozwiązanie w pliku task.h proszę umieścić w stworzonym przez siebie folderze(imie_nazwisko)
    w zakładce Pliki

    Wyjście docelowe:
___1___

>Hello World!
>Hello World but longer !
>This one should also work just fine.
77

___2___

Floating 0
Non-Floating 0

___3___

key = Element 1 value = 0
key = Element 2 value = 1
key = Element 3 value = 13.37
key = Element 4 value = 3.14

Hidden element
Hidden element
Element 4, 3.14

___4___

A string

___5___

A String
A String
A String

SPACJE, NOWE LINIE, I ZNAKI INTERPUNKCYJNE SĄ KWESTIĄ KOSMETYCZNĄ
JAK SIE KOMUŚ NIE BĘDZIE PODOBAĆ MOŻNA SOBIE ZMIENIĆ
*/
#include "task.h"

int main()
{
    // 1
    std::cout << "___1___\n\n";


    std::vector<std::string> arr3{"Hello ", "World", "!\n"}; 
    std::vector<std::string> arr5{"Hello ", "World ", "but ", "longer ", "!\n"};
    std::vector<std::string> arr7{"This ", "one ", "should ", "also ", "work ", "just ", "fine.\n"};
    int arr[5]{1, 2, 3, 4, 5};

    std::cout << addEverything(arr3[0], arr3[1], arr3[2]);
    std::cout << addEverything(arr5[0], arr5[1], arr5[2], arr5[3], arr5[4]);
    std::cout << addEverything(arr7[0], arr7[1], arr7[2], arr7[3], arr7[4], arr7[5], arr7[6]);
    std::cout << addEverything(arr[0], arr[1], arr[2], arr[3], arr[4]);
    std::cout << "\n";
    ///////////////////////////////////
    // 2
    std::cout << "\n___2___\n\n";


    std::cout << compareEverything(1.0, 3.0) << "\n";
    std::cout << compareEverything(3, 1) << "\n";
    ///////////////////////////////////

    // 3
    std::cout << "\n___3___\n\n";


    std::vector<OversizedVecElement> vec{
        {"Element 1", 0.0, true},
        {"Element 2", 1.0, false}, 
        {"Element 3", 13.37, false}, 
        {"Element 4", 3.14, true}
    };

    std::vector<OversizedVecElement> vec2;
    improvedVectorHandling(vec);

    vec.erase(vec.begin());
    improvedVectorHandling(vec);

    copyAndPrintVector(vec, vec2);
    ///////////////////////////////////

    // 4
    std::cout << "\n___4___\n\n";

    // ODKOMENTUJ PO DEKLARACJI STRUKTURY I FUNKCJI
    std::any a1 = Smart{"A string"};
    castAndOutSmart(a1);

    ///////////////////////////////////

    // 5
    std::cout << "\n___5___\n\n";


    char charArr[9] = {'A', ' ', 'S', 't', 'r', 'i', 'n', 'g', '\0'};
    std::string str = "A String";
    std::string_view strView{str};

    // Wywołania funkcji w obecnym kształcie, ZAKOMENTUJ
    std::cout << doSomethingToString(charArr) << "\n";
    std::cout << doSomethingToString(str.c_str()) << "\n";
    std::cout << doSomethingToString(std::string(strView).c_str()) << "\n";
    
    // Docelowe wywołania, ODKOMENTUJ by sprawdzić czy działa
    std::cout << doSomethingToString(charArr) << "\n";
    std::cout << doSomethingToString(str) << "\n";
    std::cout << doSomethingToString(strView) << "\n";
    ///////////////////////////////////
    return 0;
}