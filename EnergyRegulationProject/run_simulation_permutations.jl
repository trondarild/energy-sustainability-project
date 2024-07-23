using CSV
using Random
using DataFrames
function read_model_output(outname)
	# read simulated data and process
    df = DataFrame(CSV.File(outname))
    # describe(attn_df)
    for col in names(df)
        new_col = replace(col, r":0$" => "")
        rename!(df, col => new_col)
    end
    rename!(df, "T/1"=>"time")
    df = select!(df, Not("Column10"))
	return df
end

function run_model(args, outname)
    # args: string with parameters for model
    
    arg1 = "-r" 
    arg2 = "-s2000" # 
    arg3 = "Source/UserModules/EnergyRegulationProject/ClassificationMetricsExperiment_tstparams.ikg"
    # Source/UserModules/EnergyRegulationProject/ClassificationMetricsExperiment.ikg
    arg4 = args
    println(arg4)
    #read(`../ikaros/Bin/ikaros $arg2`, String)
    try
        #read(`Bin/ikaros $arg1 $arg2 $arg4 $arg3`, String)
        # Run the external process
        println(`Bin/ikaros $arg1 $arg2 $arg4 $arg3`)
        #process = run(`Bin/ikaros $arg1 $arg2 $arg4 $arg3`, wait=true)
        process = run(`Bin/ikaros $arg1 $arg2 $arg4 $arg3`, wait=true)
        
        # wait(process)  # Ensure the process completes before proceeding
    catch
        println("error in run_model")
    end
    sleep(10)
    df = read_model_output(outname)
    # ch = @_ attn_df |> last |> __.choice # get the choice
   
    return (df) # return df only for chosen, and complete data
end

# Placeholder function to run the simulation
# Replace with actual simulation call
function run_simulation(effort, vector_size, num_ones1, num_ones2)
    # set up arguments:
    #args = "effort="*string(effort)*" inputvectorsize="*string(vector_size)*
    #    " onecount1="*string(num_ones1)*" onecount2="*string(num_ones2)
    arglst = ["effort="*string(effort), "inputvectorsize="*string(vector_size),
        "onecount1="*string(num_ones1), "onecount2="*string(num_ones2)]
    fname = "data_"*join(arglst, "_")*".csv"
    path = "Source/UserModules/EnergyRegulationProject/"
    outname = fname # skip path for now
    # outname = "Source/UserModules/EnergyRegulationProject/metricsexperiment_data.txt"
    #args_b = args*" outputfilename="*"data_"*replace(args, " " => "_")*".txt"
    args_b = [(arglst...), "outputfilename="*outname]
    println(outname)
    return run_model(args_b, path*outname)
end

########

# Parameters to test
effort_values = [5, 10, 50] #, 100, 200]
vector_sizes = [1000]#, 50, 100]
num_ones_percentages = [[20,25], [20, 30], [20, 50]]#, 10, 15, 20] # use as percentages?

# Initialize an empty DataFrame to store all results
begin
    all_results = DataFrame() # clear results

    # Loop through all permutations of parameter values and run the simulations
    for effort in effort_values
        for vector_size in vector_sizes
            for ones1 in num_ones_percentages
                #for ones2 in num_ones_percentages
                    num_ones1 = Int(round(vector_size * ones1[1]/100.0))
                    num_ones2 = Int(round(vector_size * ones1[2]/100.0))
                    println("Running simulation with effort=$effort, vector_size=$vector_size, num_ones1=$num_ones1, num_ones2=$num_ones2")
                    df = run_simulation(effort, vector_size, num_ones1, num_ones2)
                    # Concatenate the data frame from this run with the overall results
                    all_results = vcat(all_results, df)
                #end
            end
        end
    end    
end

all_results
first(all_results, 20)
unique(all_results[!, "EFFORT"])
# Save the concatenated data frame to a CSV file
output_file = "Source/UserModules/EnergyRegulationProject/all_simulation_results.csv"
CSV.write(output_file, all_results)

println("All simulations complete. Results saved to $output_file")


######

# test
arglst=["effort="*string(3), "inputvectorsize="*string(3), "onecount1="*string(3), "onecount2="*string(3)]
arglst
fname = "data_"*join(arglst, "_")*".csv"
    