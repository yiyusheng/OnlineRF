// -*- C++ -*-
/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * Written (W) 2010 Amir Saffari, amir@ymer.org
 * Copyright (C) 2010 Amir Saffari, 
 *                    Institute for Computer Graphics and Vision, 
 *                    Graz University of Technology, Austria
 */

#ifndef DATA_H_
#define DATA_H_

#include <fstream>
#include <stdlib.h>
#include <iostream>
#include <vector>
#include <set>
#include <string>
#include <Eigen/Core>
#include <Eigen/Array>

using namespace std;
using namespace Eigen;

// DATA CLASSES
class Sample {
public:
    VectorXd x;
    int y;
    double yr;
    int sn_id;
    int t;
    double w;
    int id;
};

class DataSet {
 public:
    void findFeatRange();

    void load(const string& x_filename, const string& y_filename, const string& z_filename, const string& t_filename, const int& indStart, const int& indEnd);

    vector<Sample> m_samples;
    int m_numSamples;
    int m_numFeatures;
    int m_numClasses;

    VectorXd m_minFeatRange;
    VectorXd m_maxFeatRange;
};

class Result {
 public:
    Result();
    Result(const int& numClasses);

    VectorXd confidence;
    int prediction;
    double predictionR;
};

class Cache {
public:
    Cache();
    Cache(const Sample& sample, const int& numBases, const int& numClasses);

    Sample cacheSample;
    double margin;
    int yPrime; // Class with closest margin to the sample
};

#endif /* DATA_H_ */
