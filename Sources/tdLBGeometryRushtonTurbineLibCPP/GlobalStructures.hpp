//
//  GlobalStructures.hpp
//  
//
//  Created by Niall Ó Broin on 16/02/2021.
//

#ifndef Header_GlobalStructures
#define Header_GlobalStructures

#include <stdio.h>

enum GeomPlacement {
    onSurface,
    internal,
    surfaceAndInternal,
    external
};

enum GeomMovement {
    fixed,
    rotating,
    rotatingNonUpdating,
    translating
};





template <typename T>
struct Extents{
    T x0;
    T x1;
    T y0;
    T y1;
    T z0;
    T z1;

    Extents() {
    }

    Extents(
            T x0,
            T x1,
            T y0,
            T y1,
            T z0,
            T z1
            ) {

        this-> x0 = x0;
        this-> x1 = x1;
        this-> y0 = y0;
        this-> y1 = y1;
        this-> z0 = z0;
        this-> z1 = z1;
    }

    bool containsI(T i) const {
        return i >= x0 && i <= x1;
    }
    bool containsJ(T j) const {
        return j >= y0 && j <= y1;
    }
    bool containsK(T k) const {
        return k >= z0 && k <= z1;
    }
    bool containsIK(T i, T k) const {
        return containsI(i) && containsK(k);
    }
    bool containsIJK(T i, T j, T k) const {
        return containsI(i) && containsJ(j) && containsK(k);
    }


    bool doesntContainI(T i) const {
        return !containsI(i);
    }
    bool doesntContainJ(T j) const {
        return !containsJ(j);
    }
    bool doesntContainK(T k) const {
        return !containsK(k);
    }
    bool doesntContainIK(T i, T k) const {
        return !containsIK(i, k);
    }
    bool doesntContainIJK(T i, T j, T k) const {
        return !containsIJK(i, j, k);
    }
};


template <typename T>
struct Pos2d{
    T p;
    T q;
};



template <typename T>
struct Pos3d{
    Pos3d(T i, T j, T k):i(i),j(j),k(k) {}    
    T i;
    T j;
    T k;
//
////    Pos3d(int i, int j, int k){
////        i = (T)i;
////        k = (T)j;
////        j = (T)k;
////    }
//    Pos3d(long int i, long int j, long int k){
//        i = (T)i;
//        k = (T)j;
//        j = (T)k;
//    }

    void localise(Extents<T> e){

        i -= e.x0;
        j -= e.y0;
        k -= e.z0;
    }
};


template <typename T>
struct Line2d{
    T x0;
    T y0;
    T x1;
    T y1;
};




#endif /* Header_h */
