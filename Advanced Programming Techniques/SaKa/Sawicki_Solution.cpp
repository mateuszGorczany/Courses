#include <concepts>
#include <iostream>
#include <vector>
#include <string>
#include <array>
#include <list>

/*
	Poniżej znajdują się dwa szablony funkcji - oba proste i w pełni poprawne.
	Można ich użyć bez żadnych modyfikacji w podanych w mainie przykładach, ale nie tylko w nich.
	Na pierwszy rzut oka widać, że szablony nijak nie nadają się dla wszystkich istniejących typów danych.
	Zadanie polega na tym, żeby stworzyć odpowiednie koncepty, które narzucą na podane szablony poprawne wymagania.
	Po zbudowaniu konceptów użycie szablonów nie powinno być sztucznie ograniczone - poprawne wcześniej wywołania nadal powinny być poprawne.
	Podczas wykonywania zadania przydatne mogą być static_asserty oraz koncepty znajdujące się już w bibliotece standardowej.
	Nie należy się sugerować ilością szablonów ani parametrów - poprawne rozwiązanie może się składać z dowolnej liczby dowolnie zbudowanych konceptów.
	Możemy założyć, że mało standardowe kontenery nie istnieją.

	Zadanie testowałem w Visual Studio 2019 oraz z kompilatorem g++-10.
	W żadnym z tych przypadków nie było żadnych problemów z kompilacją kodu.

	Zrealizowane zadanie powinno zawierać kompilowalny zestaw plików.
	Zestaw ten powinien oczywiście zawierać wszystkie wymagane koncepty oraz poniższe szablony w zmodyfikowanej odpowiednio wersji.
*/
template<typename T>
using ArrayElementType = std::remove_reference<decltype( *std::declval<T>() )>::type;

template<typename Container, typename Value>
concept is_convertible_to_value_stored =  requires (Container a, Value b)
{
    requires std::convertible_to<Value, typename Container::value_type>
        or  std::convertible_to<Value, ArrayElementType<Container>>;
};

template<typename Container>
concept is_container_object_stored_printable = requires(Container object)
{
    { std::cout << std::declval<typename Container::value_type>() } -> std::same_as<std::ostream &>;
};

template<typename Container>
concept is_primitive_array_object_stored_printable = requires(Container object)
{
    { std::cout << std::declval<ArrayElementType<Container>>() } -> std::same_as<std::ostream &>;
};

template<typename Container>
concept is_value_stored_printable = requires(Container object)
{
    requires is_primitive_array_object_stored_printable<Container> or is_container_object_stored_printable<Container>;
};

template<typename T, typename U>
requires is_convertible_to_value_stored<T, U> and std::is_copy_assignable<U>::value
void fill_container_with(T& vector, U object_to_store)
{
	for (auto& x : vector)
		x = object_to_store;
}

template<typename T>
requires is_value_stored_printable<T> and 
requires (T &object)
{
    std::begin(object);
    std::end(object);
}
void print_container(const T& c)
{
	for (const auto& i : c)
		std::cout << i << " ";
	std::cout << std::endl;
}

struct object
{
	object() = default;
	object(std::string _) : m{ _ } {}

	std::string m = "default";

	friend std::ostream& operator<<(std::ostream& out, const object& o)
	{
		return out << o.m;
	}
};


int main()
{
    std::vector<int> a(10);
	fill_container_with(a, 10);
	print_container(a);
	
    std::array<std::string, 5> b;
	fill_container_with(b, "thing");
	print_container(b);

	double c[15];
	fill_container_with(c, 9.9);
	print_container(c);

	std::list<object> d(3);
	fill_container_with(d, object{ "initialized_object" });
    int k = 0;
	print_container(d);

	return 0;
}
