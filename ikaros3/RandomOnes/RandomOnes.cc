#include "ikaros.h"

using namespace ikaros;

#include <algorithm>
#include <random>
#include <iostream>

class RandomOnes: public Module
{
    parameter size;
    matrix input;
    matrix output;

    void Init()
    {
        Bind(size, "arraysize");
        Bind(input, "INPUT");
        Bind(output, "OUTPUT");
    }


    void Tick()
    {
        output.set(0);
        int numones = (int)input[0];
        // Generate random unique positions for 1's
        std::vector<int> positions(size);
        std::iota(positions.begin(), positions.end(), 0);
        std::random_device rd;
        std::mt19937 g(rd());
        std::shuffle(positions.begin(), positions.end(), g);
        positions.resize(numones);


        for (int pos : positions)
        {
            output[pos] = 1;
        }
    }
};

INSTALL_CLASS(RandomOnes)

