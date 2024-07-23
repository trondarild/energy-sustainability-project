#include "ikaros.h"

using namespace ikaros;
#include <algorithm>
#include <random>
#include <map>
#include <iostream>
class SampleCompare: public Module
{
    parameter debugmode;
    matrix output;
    matrix choice;
    matrix input1;
    matrix input2;
    matrix effort;

    void Init()
    {
        Bind(debugmode, "debugmode");
        Bind(input1, "INPUT1");
        Bind(input2, "INPUT2");
        Bind(effort, "EFFORT");
        Bind(output, "OUTPUT");
        Bind(choice, "CHOICE");
    }


    void Tick()
    {
        int size1 = input1.size();
        int size2 = input2.size();

        output.set(0);

        std::random_device rd;
        std::mt19937 g(rd());
        //std::cout << "0.3)";
        // Maps to store sampled values with their indices
        std::map<int, int> samples1;
        std::map<int, int> samples2;

        // Draw samples and store in maps
        for (int i = 0; i < effort[0]; ++i) {
            int index1 = std::uniform_int_distribution<>(0, size1 - 1)(g);
            int index2 = std::uniform_int_distribution<>(0, size2 - 1)(g);
            //std::cout << "1.1)";
            samples1[index1] = input1[index1];
            samples2[index2] = input2[index2];
            //std::cout << "1.2)";
        }

        // Sum the sampled values
        int count1 = 0;
        int count2 = 0;
        for (const auto& sample : samples1) {
            count1 += sample.second;
        }
        for (const auto& sample : samples2) {
            count2 += sample.second;
        }

        if (count1 > count2) {
            choice[0] = 1;
            output.copy(input1);
            
        } else if (count2 > count1) {
            choice[0] = 2;
            output.copy(input2);
            
        } else {
            choice[0] = 0;
        }
    

        if(debugmode)
        {
            input1.print("input1");
            input2.print("input2");
            effort.print("effort");
            
        }
    }
};

INSTALL_CLASS(SampleCompare)

