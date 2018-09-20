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
#include <iomanip>
#include <math.h>
#include <numeric>
#include <string>
#include <sys/stat.h>
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
                if (abs(result.predictionR-dataset.m_samples[randIndex[nSamp]].yr)>0.00001) {
                    trainError[nEpoch] += (result.predictionR-dataset.m_samples[randIndex[nSamp]].yr)*(result.predictionR-dataset.m_samples[randIndex[nSamp]].yr);
                }
            }
            
            model->update(dataset.m_samples[randIndex[nSamp]]);
            if (hp.verbose && (nSamp % sampRatio) == 0) {
                cout << "--- " << model->name() << " training --- Epoch: " << nEpoch + 1 << " --- ";
                cout << (10 * nSamp) / sampRatio << "%";
                cout << " --- Training error = " << trainError[nEpoch] << "/" << nSamp \
                 << "=" << trainError[nEpoch]/nSamp <<  endl;
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
    
    // Write the results
    /*
    string saveFile = hp.savePath + "errors";
    ofstream file(saveFile.c_str(), ios::trunc);
    if (!file) {
        cout << "Could not access " << saveFile << endl;
        exit(EXIT_FAILURE);
    }
    file << "yr\tpred\tsn\ttime" << endl;
    */

    vector<Result> results;
    for (int nSamp = 0; nSamp < dataset.m_numSamples; nSamp++) {
        Result result(dataset.m_numClasses);
        model->eval(dataset.m_samples[nSamp], result);
        results.push_back(result);
        //file << setprecision(4) << dataset.m_samples[nSamp].yr << "\t" << result.predictionR <<"\t" << dataset.m_samples[nSamp].sn_id << "\t" << dataset.m_samples[nSamp].t << endl;
    }
    //file.close();
    

    // Save Result
    char str[100];
    string dir_path = hp.savePath + hp.outputPrefix +"/";
    mkdir(dir_path.c_str(),S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);

    sprintf(str,"exp_%d_%.2f",hp.trainIndEnd,hp.negPoisson);
    string file_path = dir_path+str;
    ofstream file_result(file_path.c_str(), ios::trunc);
    //ofstream file(file_path.c_str(), std::ios_base::app);
    if (!file_result) {
      cout << "Could not access " << file_path << endl;
      exit(EXIT_FAILURE);
    }
    file_result << "TrEnd\tnegP\tnWin\tthreshold\ttesterror\ttp\ttotalp\tFDR\tfp\ttotaln\tFAR\t" << endl;
    
    //Get test error
    string error;
    if(hp.testParameter){
    // experiment for the best nWin and threshold when predicting disk failure
      int a_nWin[7] = {1,3,5,10,15,30,60};
      //int a_nWin[13] = {1,2,3,5,7,10,20,30,50};
      const int n_thred = 800, demomi = 1000;
      double a_threshold[n_thred];
      for(int i=0;i<n_thred;i++)
        a_threshold[i] = (double(i))/demomi;
      for(int i=0;i < int(sizeof(a_threshold)/sizeof(double));i++){
        for(int j=0;j < int(sizeof(a_nWin)/sizeof(int));j++){
          error = compError(results, dataset, hp,file_result,a_nWin[j],a_threshold[i]);
        }
      }
    }else{
    // formal usage
      error = compError(results, dataset, hp,file_result);
    }
    file_result.close();

    if (hp.verbose) {
        cout << "--- " << model->name() << " test result: " << error << endl;
    }
    
    timeval endTime;
    gettimeofday(&endTime, NULL);
    cout << "--- " << model->name() << " testing time = ";
    cout << (endTime.tv_sec - startTime.tv_sec + (endTime.tv_usec - startTime.tv_usec) / 1e6) << " seconds." << endl;
    
    return results;
}

void sort_indexes(int* arr,int asc,int* index,int len){
  int tmp;
  for(int i=0; i<len; i++)index[i] = i;

  for(int i=len; i>0; i--){
    for(int j=0; j<i; j++){
      if((asc && arr[j] > arr[j+1]) || (!asc && arr[j] < arr[i+1])){
        tmp = arr[j];
        arr[j] = arr[j+1];
        arr[j+1] = tmp;

        tmp = index[j];
        index[j] = index[j+1];
        index[j+1] = tmp;
      }
    }
  }
}

string compError(const vector<Result>& results, const DataSet& dataset, Hyperparameters& hp,ofstream& file, int nw, double thred){

    int nWin = (nw==-1)?hp.nWin:nw;
    double threshold = (thred==-1)?hp.threshold:thred ;
    double (*sample_result)[4] = new double[dataset.m_numSamples][4];

    //dataset sort: t and sn_id
    /*
    int len = dataset.m_numSamples;
    int arr_t[len],arr_sn[len],index_t[len],index_sn[len];
    for (int nSamp=0; nSamp < len; nSamp++){
      arr_t[nSamp] = dataset.m_samples[nSamp].t;
      arr_sn[nSamp] = dataset.m_samples[nSamp].sn_id;
    }
    sort_indexes(arr_t,1,index_t,len);
    sort_indexes(arr_sn,0,index_sn,len);
    for (int nSamp = 0; nSamp < dataset.m_numSamples; nSamp++) {
      sample_result[nSamp][0] = dataset.m_samples[index_t[index_sn[nSamp]]].sn_id;
      sample_result[nSamp][1] = dataset.m_samples[index_t[index_sn[nSamp]]].t;
      sample_result[nSamp][2] = dataset.m_samples[index_t[index_sn[nSamp]]].y;
      sample_result[nSamp][3] = results[index_t[index_sn[nSamp]]].predictionR;
      cout << sample_result[nSamp][0] << '-' << sample_result[nSamp][1] << endl;
    }
    */
        
    for (int nSamp = 0; nSamp < dataset.m_numSamples; nSamp++) {
      sample_result[nSamp][0] = dataset.m_samples[nSamp].sn_id;
      sample_result[nSamp][1] = dataset.m_samples[nSamp].t;
      sample_result[nSamp][2] = dataset.m_samples[nSamp].yr;
      sample_result[nSamp][3] = results[nSamp].predictionR;
    }

    double disk_result[37000][4];
    memset(disk_result, -1, sizeof(double)*37000*4);

    int p_left = 0, nDisk=0,a1=0,b1=0;
    for (int nSamp = 1; nSamp < dataset.m_numSamples; nSamp++) {
      int smp_sn = sample_result[nSamp][0];
      if(smp_sn == sample_result[p_left][0] && nSamp != dataset.m_numSamples-1)
        continue;
      else{
        int p_right = (nSamp==dataset.m_numSamples)?nSamp+1:nSamp;
        smp_sn = sample_result[p_left][0];

        for (int i=p_left+nWin-1; i<p_right; i++){
          double sumPred = sample_result[i][3];
          double avePred = 0;

          if(i==p_left+nWin-1)nDisk++;
          for (int j=i-1; j>(i-nWin); j--){
            sumPred += sample_result[j][3];
          }
          avePred = sumPred/nWin;
          //cout << sample_result[p_left][2] << "-" << smp_sn << "-" << p_left << "-" << p_right << endl;
          //For disk
          disk_result[smp_sn][0] = 1;  //valid data
          if(avePred > threshold){
            disk_result[smp_sn][1]++;  //sample predicted as positive
            disk_result[smp_sn][2] = sample_result[p_left][2]; //real y
            disk_result[smp_sn][3] = sample_result[i][1]; //time in adavance
            break;
          }else{
            disk_result[smp_sn][1] = 0;
            disk_result[smp_sn][2] = sample_result[p_left][2];
            disk_result[smp_sn][3] = sample_result[i][1];
          }
        }
        a1 += (disk_result[smp_sn][0]==1 && disk_result[smp_sn][2]==0)?1:0;
        b1 += (disk_result[smp_sn][0]==1 && disk_result[smp_sn][2]>0)?1:0;
        //cout << nDisk << "-" << a1 << "-" << disk_result[smp_sn][2]<< "-" << b1 << "-" << a1+b1 << "-" << smp_sn <<endl;
        //cout << nDisk << "-" << a1 << "-" << b1 << "-" << a1+b1 << "-" << smp_sn <<endl;
        p_left = p_right;
      }
    }

    /*
    int a2=0,b2=0;
    for (int i=0; i<37000;i++){
      a2 += (disk_result[i][0]==1 && disk_result[i][2]==0)?1:0;
      b2 += (disk_result[i][0]==1 && disk_result[i][2]>0)?1:0;
    }
    //cout << nDisk << "-" << a2 << "-" << b2 << "-" << a2+b2 << endl;
    */
    
    

    int tp = 0, totalp = 0, fp = 0, totaln = 0;
    for (int i = 0; i < 37000; i++) {
      if (disk_result[i][0] > 0) {
        //cout << i << "-" << disk_result[i][1] << "-" << disk_result[i][2] << endl;
        if (disk_result[i][2] == 0) {
          totaln++;
          if (disk_result[i][1] > 0) {
            fp++;
          }
        }else if (disk_result[i][2] > 0) {
          totalp++;
          if (disk_result[i][1] > 0) {
            tp++;
          }
        }else{
          cout << "warning\t" << i << "-" << disk_result[i][1] << "-" << disk_result[i][2] << endl;
        }

      }
    }
    double error = fp + (totalp - tp);  // false positive and missing positive
    double testerror = error / (totalp + totaln);
    double fdr = tp*1.0 / totalp;
    double far = fp*1.0 / totaln;
    char resultt[100];
    sprintf(resultt, "testError->%.4f FDR->%d/%d->%.4f, FAR->%d/%d->%.4f",testerror, tp, totalp, fdr, fp, totaln, far);
    
    // save result by york [20180713]
    file << setprecision(4) << hp.trainIndEnd << "\t" << hp.negPoisson << "\t" <<
            nWin << "\t" << threshold << "\t" << testerror << "\t" << tp << "\t" <<
            totalp << "\t" << fdr << "\t" << fp << "\t" << totaln << "\t" <<
            far << "\t" << endl;
    // save result

    string result(resultt);
    return result;
}

void dispErrors(const vector<string>& errors) {
    for (int nSamp = 0; nSamp < (int) errors.size(); nSamp++) {
        cout << nSamp + 1 << ":\t" << errors[nSamp] << endl;
    }
}
