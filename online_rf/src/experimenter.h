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

#ifndef EXPERIMENTER_H
#define EXPERIMENTER_H

#include "classifier.h"
#include "data.h"
#include "utilities.h"

void train(Classifier* model, DataSet& dataset, Hyperparameters& hp);
vector<Result> test(Classifier* model, DataSet& dataset, Hyperparameters& hp);
vector<Result> trainAndTest(Classifier* model, DataSet& dataset_tr, DataSet& dataset_ts, Hyperparameters& hp);

string compError(const vector<Result>& results, const DataSet& dataset, Hyperparameters& hp, ofstream& file);
void dispErrors(const vector<string>& errors);

#endif // EXPERIMENTER_H
