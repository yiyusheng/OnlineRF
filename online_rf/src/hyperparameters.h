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

#ifndef HYPERPARAMETERS_H_
#define HYPERPARAMETERS_H_

#include <string>
using namespace std;

typedef enum {
    EXPONENTIAL, LOGIT
} LOSS_FUNCTION;

typedef enum {
    WEAK_ORF, WEAK_LARANK
} WEAK_LEARNER;

class Hyperparameters {
 public:
    Hyperparameters();
    Hyperparameters(const string& confFile, double negP, int trainie, const string& outP);

    // Forest
    int numRandomTests;
    int counterThreshold;
    int maxDepth;
    int numTrees;

    // Linear LaRank
    double larankC;

    // Boosting
    int numBases;
    WEAK_LEARNER weakLearner;

    // Online MCBoost
    double shrinkage;
    LOSS_FUNCTION lossFunction;

    // Online MCLPBoost
    double C;
    int cacheSize;
    double nuD;
    double nuP;
    double annealingRate;
    double theta;
    int numIterations;

    // Experimenter
    int findTrainError;
    int numEpochs;

    // Data
    string trainData;
    string trainLabels;
    string trainSnids;
    int trainIndStart;
    int trainIndEnd;
    string testData;
    string testLabels;
    string testSnids;
    int testIndStart;
    int testIndEnd;

    // Output
    string savePath;
    int verbose;

    // Para
    double negPoisson;
    string outputPrefix;
};

#endif /* HYPERPARAMETERS_H_ */
