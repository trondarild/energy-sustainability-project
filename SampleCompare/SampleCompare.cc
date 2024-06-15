//
//	SampleCompare.cc		This file is a part of the IKAROS project
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

#include "SampleCompare.h"

// use the ikaros namespace to access the math library
// this is preferred to using math.h

using namespace ikaros;

#include <algorithm>
#include <random>
#include <map>
#include <iostream>
void
SampleCompare::Init()
{

    //std::cout << "init start\n";
	Bind(debugmode, "debug");    

    input_array1 = GetInputArray("INPUT1");
    input_array2 = GetInputArray("INPUT2");
    input_array_size1 = GetInputSize("INPUT1");
    input_array_size2 = GetInputSize("INPUT2");
    // TODO error if not same size
    effort_array = GetInputArray("EFFORT");
    effort_array_size = GetInputSize("EFFORT");

    output_array = GetOutputArray("OUTPUT");
    output_array_size = GetOutputSize("OUTPUT");
    choice_array = GetOutputArray("CHOICE");


    internal_array = create_array(10);
    //std::cout << "init end\n";
}



SampleCompare::~SampleCompare()
{
    // Destroy data structures that you allocated in Init.
    destroy_array(internal_array);
}



void
SampleCompare::Tick()
{
    
    int size1 = input_array_size1;
    int size2 = input_array_size2; 
    //std::cout << "0.1)";
    set_array(output_array, 0, output_array_size);
    int effort = static_cast<int>(effort_array[0]);
    //std::cout << "0.2)";
    // Random device and generator
    std::random_device rd;
    std::mt19937 g(rd());
    //std::cout << "0.3)";
    // Maps to store sampled values with their indices
    std::map<int, int> samples1;
    std::map<int, int> samples2;

    //std::cout << "1)";

    // Draw samples and store in maps
    for (int i = 0; i < effort; ++i) {
        int index1 = std::uniform_int_distribution<>(0, size1 - 1)(g);
        int index2 = std::uniform_int_distribution<>(0, size2 - 1)(g);
        //std::cout << "1.1)";
        samples1[index1] = input_array1[index1];
        samples2[index2] = input_array2[index2];
        //std::cout << "1.2)";
    }
    //std::cout << "2)";

    // Sum the sampled values
    int count1 = 0;
    int count2 = 0;
    for (const auto& sample : samples1) {
        count1 += sample.second;
    }
    for (const auto& sample : samples2) {
        count2 += sample.second;
    }
    //std::cout << "3)";

    // Determine the output based on the counts
    if (count1 > count2) {
        choice_array[0] = 1;
        copy_array(output_array, input_array1, input_array_size1);
    } else if (count2 > count1) {
        choice_array[0] = 2;
        copy_array(output_array, input_array2, input_array_size1);
    } else {
        
        choice_array[0] = 0;
    }
    //std::cout << "4)";
	if(debugmode)
	{
		print_array("input_array1", input_array1, input_array_size1);
        print_array("input_array2", input_array2, input_array_size2);
        print_array("effort_array1", effort_array, effort_array_size);
	}
    //std::cout << "tick end\n";
}



// Install the module. This code is executed during start-up.

static InitClass init("SampleCompare", &SampleCompare::Create, "Source/UserModules/SampleCompare/");

