//
//	ClassificationMetrics.h		This file is a part of the IKAROS project
//
//    Copyright (C) 2012 <Author Name>
//
//    This program is free software; you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation; either version 2 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program; if not, write to the Free Software
//    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//
//    See http://www.ikaros-project.org/ for more information.
//

#ifndef ClassificationMetrics_
#define ClassificationMetrics_

#include "IKAROS.h"
#include <vector>
#include <deque>
class ClassificationMetrics: public Module
{
public:
    static Module * Create(Parameter * p) { return new ClassificationMetrics(p); }

    ClassificationMetrics(Parameter * p) : Module(p) {}
    virtual ~ClassificationMetrics();

    void 		Init();
    void 		Tick();
    
    int CheckClassification(float classification, float *array1, float *array2);
    void UpdateWindow(int classification, float effort, float energy);
    float ComputeMetric(const std::deque<int>& classifications, const std::deque<float>& values);

    // pointers to inputs and outputs
    // and integers to represent their sizes

    float *     input_array1;
    float *     input_array2;
    int         input_array_size;
    float *     classification_array;
    float *     energy_array;
    float *     effort_array;

    float *     metricenergy_array;
    int         metricenergy_array_size;
    float *     metriceffort_array;
    int         metriceffort_array_size;
    float *     correctratio_array;
    // internal data storage
    float *     internal_array;
    std::deque<int> classifications; // Store classification results
    std::deque<float> efforts; // Store effort values
    std::deque<float> energies; // Store energy values


    // parameter values

    int         windowlength;
	bool       	debugmode;
};

#endif