//
//	RandomOnes.cc		This file is a part of the IKAROS project
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

#include "RandomOnes.h"

// use the ikaros namespace to access the math library
// this is preferred to using math.h

using namespace ikaros;
#include <algorithm>
#include <random>
#include <iostream>
void
RandomOnes::Init()
{
    Bind(size, "size");
	Bind(debugmode, "debug");    
    input_array = GetInputArray("INPUT");
    input_array_size = GetInputSize("INPUT");
    output_array = GetOutputArray("OUTPUT");
    output_array_size = GetOutputSize("OUTPUT");
    
    internal_array = create_array(10);
}



RandomOnes::~RandomOnes()
{
    // Destroy data structures that you allocated in Init.
    destroy_array(internal_array);
}



void
RandomOnes::Tick()
{
	
    set_array(output_array, 0, output_array_size);
    
    // TODO expand to handle array of inputs
    int numones = (int)input_array[0];

    // Generate random unique positions for 1's
    std::vector<int> positions(size);
    std::iota(positions.begin(), positions.end(), 0);
    std::random_device rd;
    std::mt19937 g(rd());
    std::shuffle(positions.begin(), positions.end(), g);
    positions.resize(numones);


    for (int pos : positions)
    {
        output_array[pos] = 1;
    }
    
    if(debugmode)
	{
		// print out debug info
        std::cout << "size: " << size << "\n";
        std::cout << "positions: ";
        for (int pos : positions)
            std::cout << pos << " ";
    
        std::cout << "output array size: " << output_array_size << "\n";
        std::cout << "\n";

	}
    
}



// Install the module. This code is executed during start-up.

static InitClass init("RandomOnes", &RandomOnes::Create, "Source/UserModules/RandomOnes/");

