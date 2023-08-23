# batch-consensus-clustering
Required package: `ConsensusClusterPlus`
- **Input**:  
  rows are genes, columns are samples  
- **Output**:  
1. Create a folder named `xxxx_consensus_clustering` in the working directory ("xxxx" is the prefix, which will be introduced in detail later), in which there are 13 algorithm combinations (normally 13, if the data is small or the Other problems such as data not meeting the requirements of a certain algorithm combination may be less than 13)
```
13 algorithm combinations
pearson-hc
spearman-hc
binary-hc
maximum-hc
canberra-hc
minkowski-hc
pearson-pam
spearman-pam
binary-pam
maximum-pam
canberra-pam
minkowski-pam
euclidean-kmeans
```
3. In the Rstudio global environment, a list named `result_list` will be output, which contains group information.
```r
consensus_clustering(data=data,
                     subname = NULL,
                     maxK=4,
                     reps=1000,
                     pItem=0.8,
                     pFeature=1)
```
# parameter
- **data**: Input data, rows as genes, columns as samples. It is recommended to convert the data to `matrix` first  
- **subname**: The prefix name of the saved file, for example: subname = "xxxx", a folder `xxxx_consensus_clustering` will be generated in the working directory, which contains the result graphs of various algorithms  
- **maxK**: The maximum number of clusters, generally the maximum setting is 4 or 6, refer to the ConsensusClusterPlus package for details  
- **reps**: repeated sampling, the greater the value, the higher the accuracy, default 1000  
- **pItem**: sample ratio of random sampling, default 0.8  
- **pFeature**: random sampling feature (or gene) ratio, default 1  
# Interpretation of `result_cluster`
The list of each clustering algorithm combination has a list of each k value, and the `consensusClass` in it is the grouping information. If you need to extract group information:  
```r
#Extract group information, where the first [[1]] means to extract the first algorithm combination, and the second [[2]] means to extract the group whose k value is 2 for the algorithm combination
results_cluster[[1]][[2]][["consensusClass"]]
```
