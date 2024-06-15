//
//	ClassificationMetrics.cc		This file is a part of the IKAROS project
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
//  This example is intended as a starting point for writing new Ikaros modules
//  The example includes most of the calls that you may want to use in a module.
//  If you prefer to start with a clean example, use he module MinimalModule instead.
//

#include "ClassificationMetrics.h"

// use the ikaros namespace to access the math library
// this is preferred to using math.h

using namespace ikaros;


void
ClassificationMetrics::Init()
{
    Bind(windowlength, "windowlength");
	Bind(debugmode, "debug");    

    input_array1 = GetInputArray("INPUT1");
    input_array2 = GetInputArray("INPUT2");
    input_array_size = GetInputSize("INPUT1");
    classification_array = GetInputArray("CLASSIFICATION");
    energy_array = GetInputArray("ENERGY");
    effort_array = GetInputArray("EFFORT");

    metricenergy_array = GetOutputArray("METRICENERGY");
    metricenergy_array_size = GetOutputSize("METRICENERGY");
    metriceffort_array = GetOutputArray("METRICEFFORT");
    metriceffort_array_size = GetOutputSize("METRICEFFORT");
    correctratio_array = GetOutputArray("CORRECTRATIO");

    internal_array = create_array(10);
}



ClassificationMetrics::~ClassificationMetrics()
{
    // Destroy data structures that you allocated in Init.
    destroy_array(internal_array);
}



void
ClassificationMetrics::Tick()
{
    int classification = CheckClassification(classification_array[0],
                                        input_array1,
                                        input_array2); // Current classification result (1 if correct, 0 if incorrect)
    float effort = effort_array[0]; // Current effort value
    float energy = energy_array[0]; // Current energy spent

    // Update the moving window with new values
    UpdateWindow(classification, effort, energy);

    // Compute metrics for effort and energy
    float metriceffort = ComputeMetric(classifications, efforts);
    float metricenergy = ComputeMetric(classifications, energies);

    // Set the output
    metricenergy_array[0] = metricenergy;
    metriceffort_array[0] = metriceffort;
    correctratio_array[0] = std::accumulate(classifications.begin(), classifications.end(), 0) / (float)windowlength;
	if(debugmode)
	{
		// print out debug info
	}
}

int 
ClassificationMetrics::CheckClassification(float aclassification, float *array1, float *array2)
{
    float sum1 = sum(array1, input_array_size);
    float sum2 = sum(array2, input_array_size);
    int retval = 0;
    float classification = 0;
    if (sum1 > sum2) classification=1;
    else if(sum1 < sum2) classification = 2;
    if (classification == aclassification && aclassification != 0) retval = 1;
    return retval;
}

void 
ClassificationMetrics::UpdateWindow(int classification, float effort, float energy)
{
    if (classifications.size() >= windowlength) {
        classifications.pop_front();
        efforts.pop_front();
        energies.pop_front();
    }
    classifications.push_back(classification);
    efforts.push_back(effort);
    energies.push_back(energy);
}

// Compute the metric as the sum of correct classifications divided by the sum of values
float 
ClassificationMetrics::ComputeMetric(const std::deque<int>& classifications, const std::deque<float>& values)
{
    int correctClassifications = std::accumulate(classifications.begin(), classifications.end(), 0);
    float totalValues = std::accumulate(values.begin(), values.end(), 0.0f);

    return totalValues > 0 ? static_cast<float>(correctClassifications) / totalValues : 0.0f;
}


// Install the module. This code is executed during start-up.

static InitClass init("ClassificationMetrics", &ClassificationMetrics::Create, "Source/UserModules/ClassificationMetrics/");

