using CSV
using DataFrames
using Plots
using StatsPlots
# Read the tab-separated file
path = "Source/UserModules/EnergyRegulationProject/"
#datafile = "metricsexperiment_data.txt"
datafile = "all_simulation_results.csv"
df = CSV.read(path*datafile, DataFrame, delim=',')

# Print the first few rows of the dataframe to verify the contents
println(first(df, 5))

# Remove the postfix ":0" from column names if present
for col in names(df)
    new_col = replace(col, r":0$" => "")
    rename!(df, col => new_col)
end

# Plot distributions of the columns
function plot_distributions(df)
    # Plot Effort vs Correct Ratio
    plot1 = plot(df.EFFORT, df.CORRECTRATIO, 
                 title="Effort vs Correct Ratio",
                 xlabel="Effort",
                 ylabel="Correct Ratio",
                 seriestype=:scatter,
                 legend=false,
                 size=(800, 600))

    # Plot Energy vs Correct Ratio
    plot2 = plot(df.ENERGY, df.CORRECTRATIO,
                 title="Energy vs Correct Ratio",
                 xlabel="Energy",
                 ylabel="Correct Ratio",
                 seriestype=:scatter,
                 legend=false,
                 size=(800, 600))

    # Plot Input Vector Size vs Correct Ratio
    plot3 = plot(df.INPUTVECTORSIZE, df.CORRECTRATIO,
                 title="Input Vector Size vs Correct Ratio",
                 xlabel="Input Vector Size",
                 ylabel="Correct Ratio",
                 seriestype=:scatter,
                 legend=false,
                 size=(800, 600))

    # Plot One Count 1 vs Correct Ratio
    plot4 = plot(df.ONE_COUNT1, df.CORRECTRATIO,
                 title="One Count 1 vs Correct Ratio",
                 xlabel="One Count 1",
                 ylabel="Correct Ratio",
                 seriestype=:scatter,
                 legend=false,
                 size=(800, 600))

    # Plot One Count 2 vs Correct Ratio
    plot5 = plot(df.ONE_COUNT2, df.CORRECTRATIO,
                 title="One Count 2 vs Correct Ratio",
                 xlabel="One Count 2",
                 ylabel="Correct Ratio",
                 seriestype=:scatter,
                 legend=false,
                 size=(800, 600))

    # Plot Effort Metrics vs Correct Ratio
    plot6 = plot(df.EFFORTMETRICS, df.CORRECTRATIO,
                 title="Effort Metrics vs Correct Ratio",
                 xlabel="Effort Metrics",
                 ylabel="Correct Ratio",
                 seriestype=:scatter,
                 legend=false,
                 size=(800, 600))

    # Plot Energy Metrics vs Correct Ratio
    plot7 = plot(df.ENERGYMETRICS, df.CORRECTRATIO,
                 title="Energy Metrics vs Correct Ratio",
                 xlabel="Energy Metrics",
                 ylabel="Correct Ratio",
                 seriestype=:scatter,
                 legend=false,
                 size=(800, 600))

    # Combine plots into a grid with increased size
    plot_combined = plot(plot1, plot2, plot3, plot4, plot5, plot6, plot7, layout=(3, 3), size=(2400, 1800))
    
    return plot_combined

end

# Generate and display the plots
plot_combined = plot_distributions(df)
display(plot_combined)


unique(df[!, "EFFORT"])

column_name = "EFFORTMETRICS"
histogram(df[!, column_name], title="Histogram of $column_name", xlabel=string(column_name), ylabel="Frequency", bins=30)

plot(df.ENERGY, df.CORRECTRATIO,
                 title="Energy vs Correct Ratio",
                 xlabel="Energy",
                 ylabel="Correct Ratio",
                 seriestype=:scatter,
                 legend=false,
                 size=(800, 600))

plot(df.INPUTVECTORSIZE, df.CORRECTRATIO,
                 title="Input Vector Size vs Correct Ratio",
                 xlabel="Input Vector Size",
                 ylabel="Correct Ratio",
                 seriestype=:scatter,
                 legend=false,
                 size=(800, 600))

plot(df.ENERGYMETRICS, df.CORRECTRATIO,
                 title="Energy Metrics vs Correct Ratio",
                 xlabel="Energy Metrics",
                 ylabel="Correct Ratio",
                 seriestype=:scatter,
                 legend=false,
                 size=(800, 600))

plot(df.ENERGY, df.CORRECTRATIO,
                 title="Energy vs Correct Ratio",
                 xlabel="Energy",
                 ylabel="Correct Ratio",
                 seriestype=:scatter,
                 legend=false,
                 size=(800, 600))
plot(df.EFFORT, df.CORRECTRATIO,
                 title="Effort vs Correct Ratio",
                 xlabel="Effort",
                 ylabel="Correct Ratio",
                 seriestype=:scatter,
                 legend=false,
                 size=(800, 600))

plot(df.ENERGY, df.CORRECTRATIO,
                 title="Energy vs Correct Ratio",
                 xlabel="Energy",
                 ylabel="Correct Ratio",
                 seriestype=:scatter,
                 legend=false,
                 size=(800, 600),
                 color=df.INPUTVECTORSIZE,
                 c=:viridis)

plot(df.EFFORT, df.ENERGY,
                 title="Effort vs Energy",
                 xlabel="Effort",
                 ylabel="Energy",
                 seriestype=:scatter,
                 legend=false,
                 size=(800, 600),
                 )
plot(df.EFFORT, df.ENERGYMETRICS,
                 title="Effort vs Energymetrics",
                 xlabel="Effort",
                 ylabel="Energymetrics",
                 seriestype=:scatter,
                 legend=false,
                 size=(800, 600),
                 )

                 sdf = filter(row -> row.EFFORT == 1 && row.CORRECTRATIO == 0.6, df)
                 sdf = filter(row -> row.EFFORT == 1, df)
                 sdf = filter(row -> row.EFFORT == 2, df)
                 sdf = filter(row -> row.EFFORT == 3, df)
                 sdf = filter(row -> row.EFFORT == 10, df)
                 unique(df[!, "INPUTVECTORSIZE"])

plot(sdf.ENERGY, sdf.CORRECTRATIO,
                 title="Energy vs Correct Ratio; effort==1",
                 xlabel="Energy",
                 ylabel="Correct Ratio",
                 seriestype=:scatter,
                 legend=false,
                 size=(800, 600),
                 )
# Remove rows with NaN or missing values in EFFORT or ENERGYMETRICS
clean_df = dropmissing(df, [:EFFORT, :ENERGYMETRICS])

# Create a violin plot for Effort vs Energymetrics
@df clean_df violin(:EFFORT, :ENERGYMETRICS,
                    title="Effort vs Energymetrics",
                    xlabel="Effort",
                    ylabel="Energymetrics",
                    legend=false,
                    size=(800, 600))