using CSV
using DataFrames
using StatsPlots
using Statistics

# Read the dataset
datafile = "all_simulation_results.csv"
df = CSV.read(pwd()*"/Source/UserModules/EnergyRegulationProject/"*datafile, DataFrame, delim=',')

# Remove the postfix ":0" from column names if present
for col in names(df)
    new_col = replace(col, r":0$" => "")
    rename!(df, col => new_col)
end

# Add a column for the difference between onecount1 and onecount2
df.difference = abs.(df.ONE_COUNT1 .- df.ONE_COUNT2)

# Sort the DataFrame by difference
sorted_df = sort(df, :difference)

# Function to plot smoothened distributions of ENERGYMETRICS for all values of EFFORT
function plot_energy_metrics_density(df)
    plots = []
    grouped = groupby(df, [:ONE_COUNT1, :ONE_COUNT2])
    for g in grouped
        p = plot(title="Energy Metrics Density by Effort (One Count 1 = $(g.ONE_COUNT1[1]), One Count 2 = $(g.ONE_COUNT2[1]))",
                 xlabel="Correct / Energy Metrics",
                 ylabel="Density",
                 legend=:topright,
                 size=(800, 1200))
        
        # Loop through each unique EFFORT value to plot their densities
        for effort in unique(g.EFFORT)
            subset_df = filter(row -> row.EFFORT == effort, g)
            density!(p, subset_df.ENERGYMETRICS, label="Effort = $effort", alpha=0.5)
        end
        
        # Add annotations for parameters
        vectorsize = unique(g.INPUTVECTORSIZE)[1]
        onecount1 = unique(g.ONE_COUNT1)[1]
        onecount2 = unique(g.ONE_COUNT2)[1]
        onecount1_pct = onecount1 / vectorsize * 100
        onecount2_pct = onecount2 / vectorsize * 100
        annotation_text = "Vector Size: $vectorsize\nOne Count 1: $onecount1_pct%\nOne Count 2: $onecount2_pct%"
        annotate!(p, (0.1, 0.9), text(annotation_text, :left, 10, "black"))
        
        push!(plots, p)
    end
    return plot(plots..., layout=(length(plots), 1))
end

function plot_effort_metrics_density(df)
    plots = []
    grouped = groupby(df, [:ONE_COUNT1, :ONE_COUNT2])
    for g in grouped
        p = plot(title="Effort Metrics Density by Effort (One Count 1 = $(g.ONE_COUNT1[1]), One Count 2 = $(g.ONE_COUNT2[1]))",
                 xlabel="Correct / Effort Metrics",
                 ylabel="Density",
                 legend=:topright,
                 size=(800, 1200))
        
        # Loop through each unique EFFORT value to plot their densities
        for effort in unique(g.EFFORT)
            subset_df = filter(row -> row.EFFORT == effort, g)
            density!(p, subset_df.EFFORTMETRICS, label="Effort = $effort", alpha=0.5)
        end
        
        # Add annotations for parameters
        vectorsize = unique(g.INPUTVECTORSIZE)[1]
        onecount1 = unique(g.ONE_COUNT1)[1]
        onecount2 = unique(g.ONE_COUNT2)[1]
        onecount1_pct = onecount1 / vectorsize * 100
        onecount2_pct = onecount2 / vectorsize * 100
        annotation_text = "Vector Size: $vectorsize\nOne Count 1: $onecount1_pct%\nOne Count 2: $onecount2_pct%"
        annotate!(p, (0.1, 0.9), text(annotation_text, :left, 10, "black"))
        
        push!(plots, p)
    end
    return plot(plots..., layout=(length(plots), 1))
end

# Function to plot CORRECTRATIO with confidence intervals for each EFFORT value
function plot_correct_ratio_with_confidence(df)
    plots = []
    grouped = groupby(df, [:ONE_COUNT1, :ONE_COUNT2])
    for g in grouped
        # Calculate mean and confidence intervals
        grouped_df = combine(groupby(g, :EFFORT), 
                             :CORRECTRATIO => mean => :mean_correctratio,
                             :CORRECTRATIO => (x -> std(x)/sqrt(length(x))) => :se_correctratio)
        
        # Calculate the lower and upper confidence intervals
        grouped_df.lower_ci = grouped_df.mean_correctratio .- 1.96 .* grouped_df.se_correctratio
        grouped_df.upper_ci = grouped_df.mean_correctratio .+ 1.96 .* grouped_df.se_correctratio

        # Plot mean CORRECTRATIO with confidence intervals
        p = plot(grouped_df.EFFORT, grouped_df.mean_correctratio, 
                 ribbon=(grouped_df.lower_ci, grouped_df.upper_ci),
                 title="Correct Ratio with Confidence Intervals by Effort (One Count 1 = $(g.ONE_COUNT1[1]), One Count 2 = $(g.ONE_COUNT2[1]))",
                 xlabel="Effort",
                 ylabel="Correct Ratio",
                 label="Mean Correct Ratio",
                 legend=:topright,
                 size=(800, 1200))
        
        # Add jitter to EFFORT values for scatter plot
        jittered_effort = g.EFFORT .+ 0.1 .* (rand(length(g.EFFORT)) .- 0.5)
        scatter!(p, jittered_effort, g.CORRECTRATIO, alpha=0.5, label="Data Points")
        
        # Add annotations for parameters
        vectorsize = unique(g.INPUTVECTORSIZE)[1]
        onecount1 = unique(g.ONE_COUNT1)[1]
        onecount2 = unique(g.ONE_COUNT2)[1]
        onecount1_pct = onecount1 / vectorsize * 100
        onecount2_pct = onecount2 / vectorsize * 100
        annotation_text = "Vector Size: $vectorsize\nOne Count 1: $onecount1_pct%\nOne Count 2: $onecount2_pct%"
        annotate!(p, (0.1, 0.9), text(annotation_text, :left, 10, "black"))
        
        push!(plots, p)
    end
    return plot(plots..., layout=(length(plots), 1))
end

# Function to plot a violin plot of CORRECTRATIO for each EFFORT value
function plot_correct_ratio_violin(df)
    plots = []
    grouped = groupby(df, [:ONE_COUNT1, :ONE_COUNT2])
    for g in grouped
        # Create the violin plot
        p = @df g violin(:EFFORT, :CORRECTRATIO,
                         title="Correct Ratio by Effort (One Count 1 = $(g.ONE_COUNT1[1]), One Count 2 = $(g.ONE_COUNT2[1]))",
                         xlabel="Effort",
                         ylabel="Correct Ratio",
                         legend=false,
                         size=(800, 1200))
        
        # Add annotations for parameters
        vectorsize = unique(g.INPUTVECTORSIZE)[1]
        onecount1 = unique(g.ONE_COUNT1)[1]
        onecount2 = unique(g.ONE_COUNT2)[1]
        onecount1_pct = onecount1 / vectorsize * 100
        onecount2_pct = onecount2 / vectorsize * 100
        annotation_text = "Vector Size: $vectorsize\nOne Count 1: $onecount1_pct%\nOne Count 2: $onecount2_pct%"
        annotate!(p, (0.1, 0.9), text(annotation_text, :left, 10, "black"))
        
        push!(plots, p)
    end
    return plot(plots..., layout=(length(plots), 1))
end

# Generate and display the plots
energy_metrics_density_plot = plot_energy_metrics_density(sorted_df)
effort_metrics_density_plot = plot_effort_metrics_density(sorted_df)
correct_ratio_confidence_plot = plot_correct_ratio_with_confidence(sorted_df)
correct_ratio_violin_plot = plot_correct_ratio_violin(sorted_df)

# Display the plots
display(energy_metrics_density_plot)
display(correct_ratio_confidence_plot)
display(correct_ratio_violin_plot)