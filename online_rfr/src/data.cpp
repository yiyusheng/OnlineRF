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

#include "data.h"

void DataSet::findFeatRange() {
    m_minFeatRange = VectorXd(m_numFeatures);
    m_maxFeatRange = VectorXd(m_numFeatures);

    double minVal, maxVal;
    for (int nFeat = 0; nFeat < m_numFeatures; nFeat++) {
        minVal = m_samples[0].x(nFeat);
        maxVal = m_samples[0].x(nFeat);
        for (int nSamp = 1; nSamp < m_numSamples; nSamp++) {
            if (m_samples[nSamp].x(nFeat) < minVal) {
                minVal = m_samples[nSamp].x(nFeat);
            }
            if (m_samples[nSamp].x(nFeat) > maxVal) {
                maxVal = m_samples[nSamp].x(nFeat);
            }
        }

        m_minFeatRange(nFeat) = minVal;
        m_maxFeatRange(nFeat) = maxVal;
    }
}
 
void DataSet::load(const string& x_filename, const string& y_filename, const string& z_filename, const string& t_filename, const int& indStart, const int& indEnd) {
    ifstream xfp(x_filename.c_str(), ios::binary);
    if (!xfp) {
        cout << "Could not open input file " << x_filename << endl;
        exit(EXIT_FAILURE);
    }
    ifstream yfp(y_filename.c_str(), ios::binary);
    if (!yfp) {
        cout << "Could not open input file " << y_filename << endl;
        exit(EXIT_FAILURE);
    }
    ifstream zfp(z_filename.c_str(), ios::binary);
    if (!zfp) {
        cout << "Could not open input file " << z_filename << endl;
        exit(EXIT_FAILURE);
    }
    ifstream tfp(t_filename.c_str(), ios::binary);
    if (!tfp) {
        cout << "Could not open input file " << t_filename << endl;
        exit(EXIT_FAILURE);
    }
    cout << "Loading data file: " << x_filename << " ... " << endl;

    // Reading the header
    int tmp;
    xfp >> m_numSamples;
    xfp >> m_numFeatures;
    yfp >> tmp;
    if (tmp != m_numSamples) {
        cout << "Number of samples in data and labels file is different" << endl;
        exit(EXIT_FAILURE);
    }
    yfp >> tmp;
    zfp >> tmp;
    if (tmp != m_numSamples) {
        cout << "Number of samples in data and sn_ids file is different" << endl;
        exit(EXIT_FAILURE);
    }
    zfp >> tmp;
    tfp >> tmp;
    if (tmp != m_numSamples) {
        cout << "Number of samples in data and time file is different" << endl;
        exit(EXIT_FAILURE);
    }
    tfp >> tmp;

    m_samples.clear();
    set<int> labels;
    set<double> labelsr;
    for (int nSamp = 0; nSamp < m_numSamples; nSamp++) {
        Sample sample;
        sample.x = VectorXd(m_numFeatures);
        sample.id = nSamp;
        sample.w = 1.0;
        yfp >> sample.yr;
        sample.y = (sample.yr>0)?1:0;
        zfp >> sample.sn_id;
        tfp >> sample.t;
        for (int nFeat = 0; nFeat < m_numFeatures; nFeat++) {
            xfp >> sample.x(nFeat);
        }
        if (nSamp >= indStart-1 && nSamp <= indEnd-1) {
            labels.insert(sample.y);
            labelsr.insert(sample.yr);
            m_samples.push_back(sample); // push sample into dataset
        }
    }
    xfp.close();
    yfp.close();
    zfp.close();
    tfp.close();
    m_numClasses = labels.size();
    m_numSamples = m_samples.size();

    // Find the data range
    findFeatRange();

    cout << "Loaded " << m_numSamples << " samples with " << m_numFeatures;
    cout << " features and " << m_numClasses << " classes." << endl;
}

Result::Result():predictionR(0.0) {
  
}

Result::Result(const int& numClasses) : confidence(VectorXd::Zero(numClasses)),predictionR(0.0) {
}

Cache::Cache() : margin(-1.0), yPrime(-1) {
}

Cache::Cache(const Sample& sample, const int& numBases, const int& numClasses) : margin(-1.0), yPrime(-1) {
    cacheSample.x = sample.x;
    cacheSample.y = sample.y;
    cacheSample.w = sample.w;
    cacheSample.id = sample.id;
}

