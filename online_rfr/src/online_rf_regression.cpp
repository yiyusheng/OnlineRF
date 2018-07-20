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

#include "online_rf_regression.h"
#include <iomanip>

RandomTestR::RandomTestR(const int& numClasses, const int& numFeatures, const VectorXd &minFeatRange, const VectorXd &maxFeatRange) :
    m_trueCount(0.0), m_falseCount(0.0), 
    m_numClasses(&numClasses),
    m_trueCost(0.0), m_falseCost(0.0){ 
    m_feature = randDouble(0, numFeatures + 1);
    m_threshold = randDouble(minFeatRange(m_feature), maxFeatRange(m_feature));
}

void RandomTestR::update(const Sample& sample) {
    updateStats(sample, eval(sample));
}
    
bool RandomTestR::eval(const Sample& sample) const {
    return (sample.x(m_feature) > m_threshold) ? true : false;
}
    
double RandomTestR::score() const {
    return m_trueCost + m_falseCost + 1e-16;
}

bool RandomTestR::isValidSplit() const {
    return m_trueValueY.size()>0 && m_falseValueY.size()>0;
}
    
pair<vector<const Sample*>, vector<const Sample*> > RandomTestR::getStats() const {
    return pair<vector<const Sample*>, vector<const Sample*> > (m_trueValueY, m_falseValueY);
}

void RandomTestR::updateTest(){
  double trueSum=0,trueAve=0,falseSum=0,falseAve=0;

  for (int i=0;i<m_trueCount;i++){
    trueSum += m_trueValueY[i]->yr;
  }
  trueAve = trueSum/m_trueCount;
  for(int i=0; i < m_trueCount; i++){
    m_trueCost += (m_trueValueY[i]->yr-trueAve)*(m_trueValueY[i]->yr-trueAve);
  }

  for (int i=0;i<m_falseCount;i++){
    falseSum += m_falseValueY[i]->yr;
  }
  falseAve = falseSum/m_falseCount;
  for(int i=0; i < m_falseCount; i++){
    m_falseCost += (m_falseValueY[i]->yr-falseAve)*(m_falseValueY[i]->yr-falseAve);
  }
}

void RandomTestR::updateStats(const Sample& sample, const bool& decision) {
    if (decision) {
        m_trueValueY.push_back(&sample);
        m_trueCount += sample.w;
        //cout << "[RandomTestR::updateStats]\tTrue\t" << m_trueValueY.size() << '\t' << m_falseValueY.size() << endl;
    } else {
        m_falseValueY.push_back(&sample);
        m_falseCount += sample.w;
        //cout << "[RandomTestR::updateStats]\tFalse\t" << m_trueValueY.size() << '\t' << m_falseValueY.size() << endl;
    }
}    

int RandomTestR::trueCount() const{
  return m_trueValueY.size();
}

int RandomTestR::falseCount() const{
  return m_falseValueY.size();
}

OnlineNodeR::OnlineNodeR(const Hyperparameters& hp, const int& numClasses, const int& numFeatures, const VectorXd& minFeatRange, const VectorXd& maxFeatRange, 
                       const int& depth) :
    m_numClasses(&numClasses), m_depth(depth), m_isLeaf(true), m_hp(&hp), m_label(-1),
    m_counter(0.0), m_parentCounter(0.0),
    m_minFeatRange(&minFeatRange), m_maxFeatRange(&maxFeatRange) {
    m_rootNode = this;
    // Creating random tests
    for (int nTest = 0; nTest < hp.numRandomTests; nTest++) {
        m_onlineTests.push_back(new RandomTestR(numClasses, numFeatures, minFeatRange, maxFeatRange));
    }
}
    
OnlineNodeR::OnlineNodeR(const Hyperparameters& hp, const int& numClasses, const int& numFeatures, const VectorXd& minFeatRange, const VectorXd& maxFeatRange, 
                       const int& depth, vector<const Sample*> parentStats, OnlineNodeR* rootNode) :
    m_numClasses(&numClasses), m_depth(depth), m_isLeaf(true), m_hp(&hp), m_label(-1),
    m_counter(0.0), m_parentCounter(parentStats.size()), m_valueY(parentStats),
    m_minFeatRange(&minFeatRange), m_maxFeatRange(&maxFeatRange) {
      double sum_valueY = 0;
      const int sizeY = m_valueY.size();
      for(int i=0;i < sizeY;i++){
        sum_valueY += m_valueY[i]->yr;
      };
      m_label =  sum_valueY / m_valueY.size(); 
      m_rootNode = rootNode;

    // Creating random tests
    for (int nTest = 0; nTest < hp.numRandomTests; nTest++) {
        m_onlineTests.push_back(new RandomTestR(numClasses, numFeatures, minFeatRange, maxFeatRange));
    }

    // Update test by inherited samples.
    for (int i=0;i < m_parentCounter;i++){
      for (vector<RandomTestR*>::iterator itr = m_onlineTests.begin(); itr != m_onlineTests.end(); ++itr) {
          (*itr)->update(*m_valueY[i]);
      }   
    }
    
}
    
OnlineNodeR::~OnlineNodeR() {
    if (!m_isLeaf) {
        delete m_leftChildNode;
        delete m_rightChildNode;
        delete m_bestTest;
    } else {
        for (int nTest = 0; nTest < m_hp->numRandomTests; nTest++) {
            delete m_onlineTests[nTest];
        }
    }
}
    
void OnlineNodeR::update(const Sample& sample) {
    m_counter += sample.w;

    if (m_isLeaf) {
        // Update online tests
        timeval tp0,tp1,tp2,tp3,tp4;
        gettimeofday(&tp0,NULL);
        for (vector<RandomTestR*>::iterator itr = m_onlineTests.begin(); itr != m_onlineTests.end(); ++itr) {
            (*itr)->update(sample);
        }

        // Update the label
        m_valueY.push_back(&sample);
	m_label = (m_label*(m_counter-1)+sample.yr)/m_counter;

        gettimeofday(&tp1,NULL);
        // Decide for split
        if (shouldISplit()) {
            m_isLeaf = false;

            // Find the best online test
            int nTest = 0, minIndex = 0;
            double minScore = 1e100, score;
            for (vector<RandomTestR*>::const_iterator itr(m_onlineTests.begin()); itr != m_onlineTests.end(); ++itr, nTest++) {
                (*itr)->updateTest();
                score = (*itr)->score();
                //cout << score << "\t" << (*itr)->trueCount() << "-" << (*itr)->falseCount() << endl;
                if (score < minScore) {
                    minScore = score;
                    minIndex = nTest;
                }
            }
            gettimeofday(&tp2,NULL);
            m_bestTest = m_onlineTests[minIndex];
            for (int nTest = 0; nTest < m_hp->numRandomTests; nTest++) {
                if (minIndex != nTest) {
                    delete m_onlineTests[nTest];
                }
            }
            gettimeofday(&tp3,NULL);

            // Split
            pair<vector<const Sample*>, vector<const Sample*> > parentStats = m_bestTest->getStats();
            m_rightChildNode = new OnlineNodeR(*m_hp, *m_numClasses, m_minFeatRange->rows(), *m_minFeatRange, *m_maxFeatRange, m_depth + 1,
                                              parentStats.first,m_rootNode);
            m_leftChildNode = new OnlineNodeR(*m_hp, *m_numClasses, m_minFeatRange->rows(), *m_minFeatRange, *m_maxFeatRange, m_depth + 1,
                                             parentStats.second,m_rootNode);
            gettimeofday(&tp4,NULL);
            /*
            cout << "[OnlineNodeR::update:split]\t runtime eslapse: \t ";
            cout << (tp1.tv_sec - tp0.tv_sec + (tp1.tv_usec - tp0.tv_usec)/ 1e6) << "\t" << \
                    (tp2.tv_sec - tp1.tv_sec + (tp2.tv_usec - tp1.tv_usec)/ 1e6) << "\t" << \
                    (tp3.tv_sec - tp2.tv_sec + (tp3.tv_usec - tp2.tv_usec)/ 1e6) << "\t" << \
                    (tp4.tv_sec - tp3.tv_sec + (tp4.tv_usec - tp3.tv_usec)/ 1e6) << "\t" << \
            endl;
            cout << "\n[######OnlineNodeR::update:split######]\t score:\t" << m_bestTest->score() <<  "\tindex:" <<  minIndex << endl;
            m_rootNode->print();
            */
        }
        /*
        cout << "[OnlineNodeR::update:nosplit]\t runtime eslapse: \t ";
        cout << (tp1.tv_sec - tp0.tv_sec + (tp1.tv_usec - tp0.tv_usec)/ 1e6) << "\t" << \
        endl;
        */
    } else {
        if (m_bestTest->eval(sample)) {
            m_rightChildNode->update(sample);
        } else {
            m_leftChildNode->update(sample);
        }
    }
}

void OnlineNodeR::eval(const Sample& sample, Result& result) {
    if (m_isLeaf) {
        if (m_counter + m_parentCounter) {
            result.predictionR = m_label;  // average y in this node [york-20180704]  
        } else {
            result.predictionR = 0;  // default y in this node [york-20180704]
        }
    } else {
        if (m_bestTest->eval(sample)) {
            m_rightChildNode->eval(sample, result);
        } else {
            m_leftChildNode->eval(sample, result);
        }
    }
}

bool OnlineNodeR::shouldISplit() const {
    bool isExistValidSplit = false;
    for (vector<RandomTestR*>::const_iterator itr(m_onlineTests.begin()); itr != m_onlineTests.end(); ++itr) {
        if ((*itr)->isValidSplit()){
	    isExistValidSplit = true;
	    break;
	}
    }

    if ((!isExistValidSplit) || (m_depth >= m_hp->maxDepth) || (m_counter < m_hp->counterThreshold)) {
        return false;
    } else {
        return true;
    }
}

OnlineTreeR::OnlineTreeR(const Hyperparameters& hp, const int& numClasses, const int& numFeatures, 
                       const VectorXd& minFeatRange, const VectorXd& maxFeatRange) :
    Classifier(hp, numClasses) {
    m_rootNode = new OnlineNodeR(hp, numClasses, numFeatures, minFeatRange, maxFeatRange, 0);
    m_name = "OnlineTreeR";
}

void OnlineNodeR::print() {
  if (!m_isLeaf){
    /*
    cout << setprecision(4) << "[Node]\t\tdepth:" << m_depth <<\
      "\tm_label:" << m_label << \
      "\tnode_counter_all:" << m_counter+m_parentCounter <<\
      "\tnode_counter_split:" << m_valueY.size() << \
      "\tbest_test_split:" << m_bestTest->trueCount() << '\t' << m_bestTest->falseCount() << endl;
      */
    m_leftChildNode->print();
    m_rightChildNode->print();
  }else{
    cout << setprecision(4) << "[LeafNode]\tdepth:" << m_depth <<\
      "\tm_label:" << m_label << \
      "\tnode_counter_all:" << m_counter+m_parentCounter <<\
      "\tnode_counter_split:" << m_valueY.size() << endl;
  }
}

OnlineTreeR::~OnlineTreeR() {
    delete m_rootNode;
}
    
void OnlineTreeR::update(Sample& sample) {
    m_rootNode->update(sample);
}

void OnlineTreeR::eval(Sample& sample, Result& result) {
    m_rootNode->eval(sample, result);
}


OnlineRFR::OnlineRFR(const Hyperparameters& hp, const int& numClasses, const int& numFeatures, const VectorXd& minFeatRange, const VectorXd& maxFeatRange) :
    Classifier(hp, numClasses), m_counter(0.0), m_oobe(0.0) {
    m_negPoisson = hp.negPoisson;
    OnlineTreeR *tree;
    for (int nTree = 0; nTree < hp.numTrees; nTree++) {
        tree = new OnlineTreeR(hp, numClasses, numFeatures, minFeatRange, maxFeatRange);
        m_trees.push_back(tree);
    }
    m_name = "OnlineRFR";
}

OnlineRFR::~OnlineRFR() {
    for (int nTree = 0; nTree < m_hp->numTrees; nTree++) {
        delete m_trees[nTree];
    }
}
    
void OnlineRFR::update(Sample& sample) {
    m_counter += sample.w;
    Result result(*m_numClasses), treeResult;

    int numTries = 0;
    for (int nTree = 0; nTree < m_hp->numTrees; nTree++) {
        if (sample.yr != 0) {
            numTries = poisson(1.0);
        }
        if (sample.yr == 0) {
            if(m_negPoisson==0)m_negPoisson=0.05;
            numTries = poisson(m_negPoisson);
        }
        if (numTries) {
            //cout << "[OnlineRFR::update]\tSample_id:" << sample.id << "\tsample.y:" << sample.yr << "\tnumTries:" << numTries << endl;
            for (int nTry = 0; nTry < numTries; nTry++) {
                m_trees[nTree]->update(sample);
            }
            m_trees[nTree]->eval(sample, treeResult);
        } else {
            m_trees[nTree]->eval(sample, treeResult);
            result.predictionR += treeResult.predictionR;
        }
    }

    result.predictionR /= m_hp->numTrees;
    m_oobe += (sample.yr-result.predictionR)*(sample.yr-result.predictionR);
}

void OnlineRFR::eval(Sample& sample, Result& result) {
    Result treeResult;
    for (int nTree = 0; nTree < m_hp->numTrees; nTree++) {
        m_trees[nTree]->eval(sample, treeResult);
        result.predictionR += treeResult.predictionR;
    }
    result.predictionR /= m_hp->numTrees;
}
