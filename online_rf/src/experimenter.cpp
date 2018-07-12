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

#include <fstream>
#include <sys/time.h>

#include "experimenter.h"

void train(Classifier* model, DataSet& dataset, Hyperparameters& hp) {
    timeval startTime;
    gettimeofday(&startTime, NULL);
    
    vector<int> randIndex;
    int sampRatio = dataset.m_numSamples / 10;
    vector<double> trainError(hp.numEpochs, 0.0);
    for (int nEpoch = 0; nEpoch < hp.numEpochs; nEpoch++) {
        randPerm(dataset.m_numSamples, randIndex);
        for (int nSamp = 0; nSamp < dataset.m_numSamples; nSamp++) {
            if (hp.findTrainError) {
                Result result(dataset.m_numClasses);
                model->eval(dataset.m_samples[randIndex[nSamp]], result);
                if (result.prediction != dataset.m_samples[randIndex[nSamp]].y) {
                    trainError[nEpoch]++;
                }
            }
            
            model->update(dataset.m_samples[randIndex[nSamp]]);
            if (hp.verbose && (nSamp % sampRatio) == 0) {
                cout << "--- " << model->name() << " training --- Epoch: " << nEpoch + 1 << " --- ";
                cout << (10 * nSamp) / sampRatio << "%";
                cout << " --- Training error = " << trainError[nEpoch] << "/" << nSamp << endl;
            }
        }
    }
    
    timeval endTime;
    gettimeofday(&endTime, NULL);
    cout << "--- " << model->name() << " training time = ";
    cout << (endTime.tv_sec - startTime.tv_sec + (endTime.tv_usec - startTime.tv_usec) / 1e6) << " seconds." << endl;
}

vector<Result> test(Classifier* model, DataSet& dataset, Hyperparameters& hp) {
    timeval startTime;
    gettimeofday(&startTime, NULL);
    
    vector<Result> results;
    for (int nSamp = 0; nSamp < dataset.m_numSamples; nSamp++) {
        Result result(dataset.m_numClasses);
        model->eval(dataset.m_samples[nSamp], result);
        results.push_back(result);
    }
    
    string error = compError(results, dataset);
    if (hp.verbose) {
        cout << "--- " << model->name() << " test result: " << error << endl;
    }
    
    timeval endTime;
    gettimeofday(&endTime, NULL);
    cout << "--- " << model->name() << " testing time = ";
    cout << (endTime.tv_sec - startTime.tv_sec + (endTime.tv_usec - startTime.tv_usec) / 1e6) << " seconds." << endl;
    
    return results;
}

vector<Result> trainAndTest(Classifier* model, DataSet& dataset_tr, DataSet& dataset_ts, Hyperparameters& hp) {
    timeval startTime;
    gettimeofday(&startTime, NULL);
    
    vector<Result> results;
    vector<int> randIndex;
    int sampRatio = dataset_tr.m_numSamples / 10;
    vector<double> trainError(hp.numEpochs, 0.0);
    vector<string> testError;
    for (int nEpoch = 0; nEpoch < hp.numEpochs; nEpoch++) {
        randPerm(dataset_tr.m_numSamples, randIndex);
        for (int nSamp = 0; nSamp < dataset_tr.m_numSamples; nSamp++) {
            if (hp.findTrainError) {
                Result result(dataset_tr.m_numClasses);
                model->eval(dataset_tr.m_samples[randIndex[nSamp]], result);
                if (result.prediction != dataset_tr.m_samples[randIndex[nSamp]].y) {
                    trainError[nEpoch]++;
                }
            }
            
            model->update(dataset_tr.m_samples[randIndex[nSamp]]);
            if (hp.verbose && (nSamp % sampRatio) == 0) {
                cout << "--- " << model->name() << " training --- Epoch: " << nEpoch + 1 << " --- ";
                cout << (10 * nSamp) / sampRatio << "%";
                cout << " --- Training error = " << trainError[nEpoch] << "/" << nSamp << endl;
            }
        }
        
        results = test(model, dataset_ts, hp);
        testError.push_back(compError(results, dataset_ts));
    }
    
    timeval endTime;
    gettimeofday(&endTime, NULL);
    cout << "--- Total training and testing time = ";
    cout << (endTime.tv_sec - startTime.tv_sec + (endTime.tv_usec - startTime.tv_usec) / 1e6) << " seconds." << endl;
    
    if (hp.verbose) {
        cout << endl << "--- " << model->name() << " test result over epochs: " << endl;
        dispErrors(testError);
    }
    
    // Write the results
    string saveFile = hp.savePath + ".errors";
    ofstream file(saveFile.c_str(), ios::binary);
    if (!file) {
        cout << "Could not access " << saveFile << endl;
        exit(EXIT_FAILURE);
    }
    file << hp.numEpochs << " 1" << endl;
    for (int nEpoch = 0; nEpoch < hp.numEpochs; nEpoch++) {
        file << testError[nEpoch] << endl;
    }
    file.close();
    
    return results;
}

string compError(const vector<Result>& results, const DataSet& dataset) {
    int lables[dataset.m_numSamples][3];
    for (int nSamp = 0; nSamp < dataset.m_numSamples; nSamp++) {
        lables[nSamp][0] = dataset.m_samples[nSamp].sn_id;  //sn
        lables[nSamp][1] = dataset.m_samples[nSamp].y;      //real
        lables[nSamp][2] = results[nSamp].prediction;       //pred
    }
    int disk_result[37000][3];
    memset(disk_result, 0, sizeof(int)*37000*3);
    for (int nSamp = 0; nSamp < dataset.m_numSamples; nSamp++) {
        disk_result[lables[nSamp][0]][0]++;                 //counter of samples
        disk_result[lables[nSamp][0]][1]+=lables[nSamp][1]; //sum of y
        disk_result[lables[nSamp][0]][2]+=lables[nSamp][2]; //sum of pred
    }
    int tp = 0, totalp = 0, fp = 0, totaln = 0;
    for (int i = 0; i < 37000; i++) {
        if (disk_result[i][0] > 0) {
            if (disk_result[i][1] == 0) {
                totaln++;                                   //if sum of y==0 then sample is neg
                if (disk_result[i][2] > 0) {
                    fp++;                                   //if sum of pred>0 then false alarm
                }
            }
            if (disk_result[i][1] > 0) {
                totalp++;                                   //if sum of y>0 then sample is pos
                if (disk_result[i][2] > 0) {
                    tp++;                                   //if sum of pred>0 then true pos
                }
            }
        }
    }
    double error = fp + (totalp - tp);                      //false alarm and missing pos
    double testerror = error / (totalp + totaln);
    double fdr = tp*1.0 / totalp;
    double far = fp*1.0 / totaln;
    char resultt[100];
    sprintf(resultt, "testError->%.4f FDR->%d/%d->%.4f, FAR->%d/%d->%.4f",testerror, tp, totalp, fdr, fp, totaln, far);
    string result(resultt);
    return result;
}

void dispErrors(const vector<string>& errors) {
    for (int nSamp = 0; nSamp < (int) errors.size(); nSamp++) {
        cout << nSamp + 1 << ":\t" << errors[nSamp] << endl;
    }
}
