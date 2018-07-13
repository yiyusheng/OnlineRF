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

#include <iostream>
#include <libconfig.h++>

#include "hyperparameters.h"

using namespace std;
using namespace libconfig;

Hyperparameters::Hyperparameters(const string& confFile,\
    double negP, double thre, int nw,\
    int trainie, int testie) {
    cout << "Loading config file: " << confFile << " ... ";

    Config configFile;
    configFile.readFile(confFile.c_str());

    int tmp;

    // Forest
    maxDepth = configFile.lookup("Forest.maxDepth");
    numRandomTests = configFile.lookup("Forest.numRandomTests");
    counterThreshold = configFile.lookup("Forest.counterThreshold");
    numTrees = configFile.lookup("Forest.numTrees");

    // LaRank
    larankC = configFile.lookup("LaRank.larankC");

    // Boosting
    numBases = configFile.lookup("Boosting.numBases");
    tmp = configFile.lookup("Boosting.weakLearner");
    weakLearner = (WEAK_LEARNER) tmp;

    // Online MCBoost
    shrinkage = configFile.lookup("Boosting.shrinkage");
    tmp = configFile.lookup("Boosting.lossFunction");
    lossFunction = (LOSS_FUNCTION) tmp;

    // Online MCLPBoost
    C = configFile.lookup("Boosting.C");
    cacheSize = configFile.lookup("Boosting.cacheSize");
    nuD = configFile.lookup("Boosting.nuD");
    nuP = configFile.lookup("Boosting.nuP");
    theta = configFile.lookup("Boosting.theta");
    annealingRate = configFile.lookup("Boosting.annealingRate");
    numIterations = configFile.lookup("Boosting.numIterations");

    // Experimenter
    findTrainError = configFile.lookup("Experimenter.findTrainError");
    numEpochs = configFile.lookup("Experimenter.numEpochs");

    // Data
    trainData = (const char *) configFile.lookup("Data.trainData");
    trainLabels = (const char *) configFile.lookup("Data.trainLabels");
    trainSnids = (const char *) configFile.lookup("Data.trainSnids");
    trainTime = (const char *) configFile.lookup("Data.trainTime");
    trainIndStart = configFile.lookup("Data.trainIndStart");
    trainIndEnd = configFile.lookup("Data.trainIndEnd");
    testData = (const char *) configFile.lookup("Data.testData");
    testLabels = (const char *) configFile.lookup("Data.testLabels");
    testSnids = (const char *) configFile.lookup("Data.testSnids");
    testTime = (const char *) configFile.lookup("Data.testTime");
    testIndStart = configFile.lookup("Data.testIndStart");
    testIndEnd = configFile.lookup("Data.testIndEnd");
    
    // Output
    savePath = (const char *) configFile.lookup("Output.savePath");
    verbose = configFile.lookup("Output.verbose");

    // Regression and convenient experiment
    if(negP!=0)negPoisson = negP;
    if(thre!=0)threshold = thre;
    if(nw!=0)nWin = nw;
    if(trainie!=0)trainIndEnd = trainie;
    if(testie!=0)testIndEnd = testie;

    cout << "Done." << endl;
}
