using CSV
using DataFrames
using StatsPlots
using Statistics

# Read the dataset
datafile = "all_simulation_results.csv"
df = CSV.read(datafile, DataFrame, delim=',')

# Remove the postfix ":0" from column names if present
for col in names(df)
    new_col = replace(col, r":0$" => "")
    rename!(df, col => new_col)
end

# Function to plot smoothened distributions of ENERGYMETRICS for all values of EFFORT
function plot_correct_ratio_with_confidence(df)
    # Calculate mean and confidence intervals
    grouped_df = combine(groupby(df, :EFFORT), 
                         :CORRECTRATIO => mean => :mean_correctratio,
                         :CORRECTRATIO => (x -> std(x)/sqrt(length(x))) => :se_correctratio)
    
    # Calculate the lower and upper confidence intervals
    grouped_df.lower_ci = grouped_df.mean_correctratio .- 1.96 .* grouped_df.se_correctratio
    grouped_df.upper_ci = grouped_df.mean_correctratio .+ 1.96 .* grouped_df.se_correctratio

    # Plot mean CORRECTRATIO with confidence intervals
    p = plot(grouped_df.EFFORT, grouped_df.mean_correctratio, 
             ribbon=(grouped_df.lower_ci, grouped_df.upper_ci),
             title="Correct Ratio with Confidence Intervals by Effort",
             xlabel="Effort",
             ylabel="Correct Ratio",
             label="Mean Correct Ratio",
             legend=:topright)
    
    # Add jitter to EFFORT values for scatter plot
    jittered_effort = df.EFFORT .+ 0.1 .* (rand(length(df.EFFORT)) .- 0.5)
    scatter!(p, jittered_effort, df.CORRECTRATIO, alpha=0.5, label="Data Points")
    
    # Add annotations for parameters
    vectorsize = unique(df.INPUTVECTORSIZE)[1]
    onecount1 = unique(df.ONE_COUNT1)[1]
    onecount2 = unique(df.ONE_COUNT2)[1]
    onecount1_pct = onecount1 / vectorsize * 100
    onecount2_pct = onecount2 / vectorsize * 100
    annotation_text = "Vector Size: $vectorsize\nOne Count 1: $onecount1_pct%\nOne Count 2: $onecount2_pct%"
    annotate!(p, (0.5, 0.9), text(annotation_text, :left, 10, "black"))
    
    return p
end


# Function to plot CORRECTRATIO with confidence intervals for each EFFORT value
function plot_correct_ratio_with_confidence(df)
    # Calculate mean and confidence intervals
    grouped_df = combine(groupby(df, :EFFORT), 
                         :CORRECTRATIO => mean => :mean_correctratio,
                         :CORRECTRATIO => (x -> std(x)/sqrt(length(x))) => :se_correctratio)
    
    # Calculate the lower and upper confidence intervals
    grouped_df.lower_ci = grouped_df.mean_correctratio .- 1.96 .* grouped_df.se_correctratio
    grouped_df.upper_ci = grouped_df.mean_correctratio .+ 1.96 .* grouped_df.se_correctratio

    # Plot mean CORRECTRATIO with confidence intervals
    p = plot(grouped_df.EFFORT, grouped_df.mean_correctratio, 
             ribbon=(grouped_df.lower_ci, grouped_df.upper_ci),
             title="Correct Ratio with Confidence Intervals by Effort",
             xlabel="Effort",
             ylabel="Correct Ratio",
             label="Mean Correct Ratio",
             legend=:topright)
    scatter!(df.EFFORT, df.CORRECTRATIO, label="Data Points")
    
    # Add annotations for parameters
    vectorsize = unique(df.INPUTVECTORSIZE)[1]
    onecount1 = unique(df.ONE_COUNT1)[1]
    onecount2 = unique(df.ONE_COUNT2)[1]
    onecount1_pct = onecount1 / vectorsize * 100
    onecount2_pct = onecount2 / vectorsize * 100
    annotation_text = "Vector Size: $vectorsize\nOne Count 1: $onecount1_pct%\nOne Count 2: $onecount2_pct%"
    annotate!(p, 0.1, 0.9, text(annotation_text, :left, 10, "black"))
    
    return p
end

# Function to plot a violin plot of CORRECTRATIO for each EFFORT value
function plot_correct_ratio_violin(df)
    # Create the violin plot
    p = @df df violin(:EFFORT, :CORRECTRATIO,
                      title="Correct Ratio by Effort",
                      xlabel="Effort",
                      ylabel="Correct Ratio",
                      legend=false,
                      size=(800, 600))
    
    # Add annotations for parameters
    vectorsize = unique(df.INPUTVECTORSIZE)[1]
    onecount1 = unique(df.ONE_COUNT1)[1]
    onecount2 = unique(df.ONE_COUNT2)[1]
    onecount1_pct = onecount1 / vectorsize * 100
    onecount2_pct = onecount2 / vectorsize * 100
    annotation_text = "Vector Size: $vectorsize\nOne Count 1: $onecount1_pct%\nOne Count 2: $onecount2_pct%"
    annotate!(p, 0.1, 0.9, text(annotation_text, :left, 10, "black"))
    
    return p
end

# Generate and display the plots
energy_metrics_density_plot = plot_energy_metrics_density(df)
correct_ratio_confidence_plot = plot_correct_ratio_with_confidence(df)
correct_ratio_violin_plot = plot_correct_ratio_violin(df)

# Display the plots
display(energy_metrics_density_plot)
display(correct_ratio_confidence_plot)
display(correct_ratio_violin_plot)