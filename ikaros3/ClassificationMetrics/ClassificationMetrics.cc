#include "ikaros.h"

using namespace ikaros;
#include <vector>
#include <deque>
class ClassificationMetrics: public Module
{
    parameter windowlength;
    matrix input1;
    matrix input2;
    matrix classification;
    matrix energy;
    matrix effort;
    matrix metricenergy;
    matrix metriceffort;
    matrix correctratio;

    std::deque<int> classifications; // Store classification results
    std::deque<float> efforts; // Store effort values
    std::deque<float> energies; // Store energy values


    void Init()
    {
        Bind(windowlength, "windowlength");
        
        Bind(input1, "INPUT1");
        Bind(input2, "INPUT2");
        Bind(classification, "CLASSIFICATION");
        Bind(energy, "ENERGY");
        Bind(effort, "EFFORT");
        Bind(metricenergy, "METRICENERGY");
        Bind(metriceffort, "METRICEFFORT");
        Bind(correctratio, "CORRECTRATIO");
    }


    void Tick()
    {
        int classification_val = CheckClassification(classification[0],
                                        input1,
                                        input2); // Current classification result (1 if correct, 0 if incorrect)
        

        // Update the moving window with new values
        UpdateWindow(classification_val, effort[0], energy[0]);

        // Compute metrics for effort and energy
        metriceffort[0] = ComputeMetric(classifications, efforts);
        metricenergy[0] = ComputeMetric(classifications, energies);

        // Set the output        
        correctratio[0] = std::accumulate(classifications.begin(), classifications.end(), 0) / (float)windowlength;
        
    }

    int CheckClassification(float aclassification, matrix &array1, matrix &array2)
    {
        float sum1 = array1.sum();
        float sum2 = array2.sum();
        int retval = 0;
        float classification = 0;
        if (sum1 > sum2) classification=1;
        else if(sum1 < sum2) classification = 2;
        if (classification == aclassification && aclassification != 0) retval = 1;
        return retval;
    }

    void UpdateWindow(int classification, float effort, float energy)
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

    float ComputeMetric(const std::deque<int>& classifications, const std::deque<float>& values)
    {
        int correctClassifications = std::accumulate(classifications.begin(), classifications.end(), 0);
        float totalValues = std::accumulate(values.begin(), values.end(), 0.0f);

        return totalValues > 0 ? static_cast<float>(correctClassifications) / totalValues : 0.0f;
    }
};

INSTALL_CLASS(ClassificationMetrics)

