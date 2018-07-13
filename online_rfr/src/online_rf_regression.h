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

#ifndef OnlineRFR_H_
#define OnlineRFR_H_

#include "classifier.h"
#include "data.h"
#include "hyperparameters.h"
#include "utilities.h"

class RandomTestR {
 public:
    RandomTestR(const int& numClasses, const int& numFeatures, const VectorXd &minFeatRange, const VectorXd &maxFeatRange);

    void update(const Sample& sample);

    void updateTest();
    
    bool eval(const Sample& sample) const;
    
    double score() const;
    
    pair<vector<const Sample*>, vector<const Sample*> > getStats() const;

    bool isValidSplit() const;

    int trueCount() const;

    int falseCount() const;

    double m_trueCount;
    double m_falseCount;
    
 protected:
    const int* m_numClasses;
    int m_feature;
    double m_threshold;
    

// modified by york [20180702]
//    VectorXd m_trueStats;
//    VectorXd m_falseStats;
    double m_trueCost;
    double m_falseCost;
    vector<const Sample*> m_trueValueY;
    vector<const Sample*> m_falseValueY;

// modified by york [20180702]


    void updateStats(const Sample& sample, const bool& decision);
};

class OnlineNodeR {
 public:
    OnlineNodeR(const Hyperparameters& hp, const int& numClasses, const int& numFeatures, const VectorXd& minFeatRange, const VectorXd& maxFeatRange, 
            const int& depth);
    // modified by york [201807]
    OnlineNodeR(const Hyperparameters& hp, const int& numClasses, const int& numFeatures, const VectorXd& minFeatRange, const VectorXd& maxFeatRange, 
            const int& depth, vector<const Sample*> parentStats,OnlineNodeR* rootNode);
    
    ~OnlineNodeR();
    
    void update(const Sample& sample);
    void eval(const Sample& sample, Result& result);
    void print(); //modified by york [201807]
    
 private:
    const int* m_numClasses;  // number of classes
    int m_depth;  // depth of node
    bool m_isLeaf;  // whether the node is a leaf node
    const Hyperparameters* m_hp;  // struct to store hyper parameters
    double m_label;  // index of the max classes -> value of the node york[20180704]
    double m_counter; // number of new samples except the one inherited from parent
    double m_parentCounter; // number of samples inhereted from parent
    VectorXd m_labelStats;  // vector of numbers of samples in each classes.
    vector<const Sample*> m_valueY;  // vector of y add by york[20180704]
    const VectorXd* m_minFeatRange; // feature range [down]
    const VectorXd* m_maxFeatRange; // feature range [up]
    
    OnlineNodeR* m_leftChildNode; // point of left child
    OnlineNodeR* m_rightChildNode;  // point of right child
    OnlineNodeR* m_rootNode;  // point of the root node york[20180706]
    
    vector<RandomTestR*> m_onlineTests; // point to array of tests
    RandomTestR* m_bestTest;  // point to the best tests
    
    bool shouldISplit() const;
};


class OnlineTreeR: public Classifier {
 public:
    OnlineTreeR(const Hyperparameters& hp, const int& numClasses, const int& numFeatures, const VectorXd& minFeatRange, const VectorXd& maxFeatRange);

    ~OnlineTreeR();
    
    virtual void update(Sample& sample);

    virtual void eval(Sample& sample, Result& result);
    
 private:
    OnlineNodeR* m_rootNode;
};


class OnlineRFR: public Classifier {
 public:
    OnlineRFR(const Hyperparameters& hp, const int& numClasses, const int& numFeatures, const VectorXd& minFeatRange, const VectorXd& maxFeatRange);

    ~OnlineRFR();
    
    virtual void update(Sample& sample);

    virtual void eval(Sample& sample, Result& result);
    
 protected:
    double m_counter;
    double m_oobe;
    double m_negPoisson;
    
    vector<OnlineTreeR*> m_trees;
};

#endif /* OnlineRFR_H_ */
