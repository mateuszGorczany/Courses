#pragma once
#include <vector>
#include <iostream>
#include <memory>
// Cieknie 

template<typename Key_type, 
         typename Map_value_type, 
         typename Allocator=std::allocator< std::pair<Key_type, Map_value_type> >
        >
class myMap
{
public:

    using value_type = std::pair<Key_type, Map_value_type>;
    using size_type = std::size_t;

    myMap(const Allocator &alloc=Allocator()) 
    :   container{nullptr},
        allocator{alloc},
        n_elements{0},
        batch_size{10},
        n_batches{1}
    {
        container = std::allocator_traits<Allocator>::allocate(allocator, batch_size);
    }

    ~myMap()
    {
        std::allocator_traits<Allocator>::deallocate(allocator, container, allocated_size());
    }

    void reallocate()
    {
        size_type old_size = allocated_size();
        ++n_batches;
        value_type *tmp = container;
        size_type new_size = allocated_size();

        container = std::allocator_traits<Allocator>::allocate(allocator, new_size);
        for (size_type i = 0; i < old_size; ++i)
            container[i] = std::move(tmp[i]);

        std::allocator_traits<Allocator>::deallocate(allocator, tmp, old_size);
    }

    Map_value_type &operator [](const Key_type &key)
    {
        for (size_type i = 0; i < n_elements; ++i)
        {
            if (container[i].first == key)
                return container[i].second;
        }

        ++n_elements;
        bool is_out_of_space = n_elements == allocated_size();
        if (is_out_of_space)
            reallocate();

        size_type position = n_elements - 1;
        std::allocator_traits<Allocator>::construct(allocator, container + position, value_type());
        container[position].first = key;

        return container[position].second;
    }


    class iterator
    {
    public:
        using pointer = value_type *;
        using reference = value_type &;

        iterator() = default;
        iterator(pointer ptr) : ptr{ptr} {}
        pointer operator ->()                       { return ptr; }
        reference operator *()                      { return *ptr; }
        iterator operator ++()                      { iterator tmp = *this; ++ptr; return tmp; }
        iterator &operator ++(int junk)             { ++ptr; return *this; }
        bool operator ==(const iterator &rhs) const { return ptr == rhs.ptr; }
        bool operator !=(const iterator &rhs) const { return ptr != rhs.ptr; }

    private:
        pointer ptr{nullptr};
    };

    class const_iterator
    {
    public:
        using pointer = value_type *;
        using reference = value_type &;

        const_iterator() = default;
        const_iterator(pointer ptr) : ptr{ptr} {}
        pointer operator ->() const                         { return ptr; }
        reference operator *() const                        { return *ptr; }
        const_iterator operator ++()                        { const_iterator tmp = *this; ++ptr; return tmp; }
        const_iterator &operator ++(int junk)               { ++ptr; return *this; }
        bool operator ==(const const_iterator &rhs) const   { return ptr == rhs.ptr; }
        bool operator !=(const const_iterator &rhs) const   { return ptr != rhs.ptr; }

    private:
        pointer ptr{nullptr};
    };

    iterator begin()    { return iterator(container); }
    iterator end()      { return iterator(container + n_elements); }
    iterator c_begin()  { return const_iterator(container); }
    iterator c_end()    { return const_iterator(container + n_elements); }
    size_type size()    { return n_elements; }
    
    iterator find(const Key_type &key)
    {
        for (size_type i = 0; i < n_elements; ++i)
        {
            if (container[i].first == key)
                return iterator(container + i);

        }

        return iterator();
    }

private:
    size_type allocated_size() { return n_batches * batch_size; }

    value_type *container   {nullptr};
    Allocator allocator     {Allocator()};
    size_type n_elements    {0};
    size_type batch_size    {10};
    size_type n_batches     {1};
};
