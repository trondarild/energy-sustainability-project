//
//	BatteryMeter.cc		This file is a part of the IKAROS project
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

#include "BatteryMeter.h"

// use the ikaros namespace to access the math library
// this is preferred to using math.h

using namespace ikaros;

#include <IOKit/IOKitLib.h>
#include <IOKit/ps/IOPowerSources.h>
#include <IOKit/ps/IOPSKeys.h>

void
BatteryMeter::Init()
{
    // Bind(parameter, "parameter1");
	Bind(debugmode, "debug");    

    
    current_capacity_array = GetOutputArray("CURRENT_CAPACITY");
    current_capacity_array_size = GetOutputSize("CURRENT_CAPACITY");
    time_to_empty_array = GetOutputArray("TIME_TO_EMPTY");
    current_array = GetOutputArray("CURRENT");

    internal_array = create_array(1);
}



BatteryMeter::~BatteryMeter()
{
    // Destroy data structures that you allocated in Init.
    destroy_array(internal_array);
}



void
BatteryMeter::Tick()
{
	int currentCapacity;
    int maxCapacity;
    int timeToEmpty;
    float powerDrain;
    float current;
    GetBatteryInfo(currentCapacity, maxCapacity, timeToEmpty, powerDrain, current);
    current_capacity_array[0] = (float) currentCapacity;
    time_to_empty_array[0] = (float) timeToEmpty;
    current_array[0] = (float) current;

    if(debugmode)
	{
		// print out debug info
        std::cout << "BatteryMeter::Tick(): " << "maxcapacity: " << maxCapacity << "; currentcapacity: " << currentCapacity << "; timeToEmpty: " << timeToEmpty << "; powerdrain: " << powerDrain << "\n";;

	}
}

void  
BatteryMeter::GetBatteryInfo(int &rcurrentCapacity, int &rmaxCapacity, int &rtimeToEmpty, float &rpowerDrain, float &rcurrent) {
    CFTypeRef powerSourcesInfo = IOPSCopyPowerSourcesInfo();
    CFArrayRef powerSourcesList = IOPSCopyPowerSourcesList(powerSourcesInfo);
    //std::cout << "1) ";
    if (CFArrayGetCount(powerSourcesList) == 0) {
        CFRelease(powerSourcesInfo);
        CFRelease(powerSourcesList);
        return; // No power source found
    }
    //std::cout << "2) ";
    CFDictionaryRef powerSource = (CFDictionaryRef)CFArrayGetValueAtIndex(powerSourcesList, 0);
    CFNumberRef currentCapacityRef = (CFNumberRef)CFDictionaryGetValue(powerSource, CFSTR(kIOPSCurrentCapacityKey));
    CFNumberRef maxCapacityRef = (CFNumberRef)CFDictionaryGetValue(powerSource, CFSTR(kIOPSMaxCapacityKey));
    CFNumberRef timeToEmptyRef = (CFNumberRef)CFDictionaryGetValue(powerSource, CFSTR(kIOPSTimeToEmptyKey));
    CFNumberRef currentRef = (CFNumberRef)CFDictionaryGetValue(powerSource, CFSTR(kIOPSCurrentKey));
    //std::cout << "3) ";
    int currentCapacity;
    int maxCapacity;
    int timeToEmpty;
    float powerDrain = -1.f;
    float current;
    CFNumberGetValue(currentCapacityRef, kCFNumberIntType, &currentCapacity);
    CFNumberGetValue(maxCapacityRef, kCFNumberIntType, &maxCapacity);
    CFNumberGetValue(currentRef, kCFNumberFloatType, &current);
    bool hasTimeToEmpty = CFNumberGetValue(timeToEmptyRef, kCFNumberIntType, &timeToEmpty);
    // std::cout << "4) " << "current: " << current << "\n";
    CFRelease(powerSourcesInfo);
    CFRelease(powerSourcesList);

    if (hasTimeToEmpty && timeToEmpty > 0) {
        float batteryPercentage = (float)currentCapacity / maxCapacity * 100;
        powerDrain = batteryPercentage / timeToEmpty; // Power drain in percentage per hour
    }
    
    rcurrentCapacity = currentCapacity; 
    rmaxCapacity = maxCapacity; 
    rtimeToEmpty = timeToEmpty; 
    rpowerDrain = powerDrain;    
    rcurrent = current;
    //return -1.0f; // Unable to determine power drain
}

// Install the module. This code is executed during start-up.

static InitClass init("BatteryMeter", &BatteryMeter::Create, "Source/UserModules/BatteryMeter/");

