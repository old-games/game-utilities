#pragma once

#include <vector>
using namespace std;

template <class T>
class CAtlArray:public vector<T>{
public:
	void Add(T obj){
		push_back(obj);
	}

	unsigned int GetCount(){
		return size();
	}

	void RemoveAll(){
		clear();
	}
};