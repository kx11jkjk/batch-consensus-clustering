#02 consensus clustering
consensus_clustering <- function(data=data,subname = NULL,maxK=4,reps=1000,pItem=0.8,pFeature=1){
  #进行consensus clustering
  #sweep函数减去中位数进行标准化
  dc = sweep(data,1, apply(data,1,median,na.rm=T)) #标准化
  #完成聚类
  library(ConsensusClusterPlus)
  if(!dir.exists(paste0(subname,"_consensus_clustering/")))dir.create(paste0(subname,"_consensus_clustering/"))
  #####写个for循环看看所有算法得出来的聚类结果，可能要运行十几分钟（KIRC=17.7min）#####
  distance= c('pearson','spearman','binary', 'maximum', 'canberra', 'minkowski')
  clusterAlg= c('hc','pam') 
  results_cluster <- list()
  time1 <- Sys.time()
  for (i in 1:6){
    for (j in 1:2){
      tryCatch({fn=paste0(subname,"_consensus_clustering/",distance[i],'_',clusterAlg[j])
      cat(paste0(fn,'\n')) #cat函数通过逐条打印来显示进度
      if(clusterAlg[j]=='hc'){
        IL="complete"
      }else
      {
        IL="average"
      }
      results = ConsensusClusterPlus(dc,maxK=maxK,reps=reps,pItem=pItem,pFeature=pItem,
                                     title=fn,
                                     clusterAlg=clusterAlg[j],
                                     distance=distance[i],
                                     seed=1234,
                                     innerLinkage=IL,
                                     plot="pdf")
      icl = calcICL(results,title=fn,plot="pdf")
      results_cluster[[paste0(distance[i],"_",clusterAlg[j])]] <- results
      },error = function(e) {
        # 处理错误信息（可选）
        print(paste("Error occurred for method:", distance[i],clusterAlg[j]))
        print(e)})
    }}
  fn <- paste0(subname,"_consensus_clustering/euclidean_km")
  cat(paste0(fn, '\n'))
  euclidean_km <- ConsensusClusterPlus(dc, maxK = 4, reps = 1000, pItem = 0.8, pFeature = 1,
                                       title = fn,
                                       clusterAlg = 'km',
                                       distance = 'euclidean',
                                       seed = 1234,
                                       innerLinkage = "average",
                                       plot = "pdf")
  icl <- calcICL(euclidean_km, title = fn, plot = "pdf")
  results_cluster[["euclidean_km"]] <- euclidean_km #再单独把欧氏距离与Kmeans聚类加上去
  time2 <- Sys.time()
  print(time2-time1)
  results_cluster <<- results_cluster
  
  
  ######修改了一下for循环，用并行循环跑了7.36min，但是出不来图……#####
  if(F){
    library(parallel)
    library(foreach)
    distance <- c('pearson', 'spearman', 'euclidean')
    clusterAlg <- c('hc', 'pam', 'km')
    results_cluster <- list()
    time1 <- Sys.time()
    
    # 创建并行集群，设置并行计算的核心数，可以根据实际情况进行调整
    cl <- makeCluster(detectCores())
    
    # 设置并行循环参数
    foreach(i = 1:2, .combine = "c") %:%
      foreach(j = 1:2, .combine = "c") %dopar% {
        fn <- paste0("./results/KIRC_consensus_clustering/", distance[i], '_', clusterAlg[j])
        cat(paste0(fn, '\n')) # 使用cat函数通过逐条打印来显示进度
        if (clusterAlg[j] == 'hc') {
          IL <- "complete"
        } else {
          IL <- "average"
        } #帮助文档说hc聚类时用complete更好
        results <- ConsensusClusterPlus(dc, maxK = 4, reps = 1000, pItem = 0.8, pFeature = 1,
                                        title = fn,
                                        clusterAlg = clusterAlg[j],
                                        distance = distance[i],
                                        seed = 1234,
                                        innerLinkage = IL,
                                        plot = "pdf")
        icl <- calcICL(results, title = fn, plot = "pdf")
        # 使用动态命名的变量保存结果
        var_name <- paste0(distance[i], "_", clusterAlg[j])
        assign(var_name, results, envir = .GlobalEnv)
      }
    
    stopCluster(cl) # 停止并行集群
    #欧式距离只能用kmeans聚类组合，所以再单独做euclidean和kmeans
    fn <- "./results/KIRC_consensus_clustering/euclidean_km"
    cat(paste0(fn, '\n'))
    euclidean_km <- ConsensusClusterPlus(dc, maxK = 4, reps = 1000, pItem = 0.8, pFeature = 1,
                                         title = fn,
                                         clusterAlg = 'km',
                                         distance = 'euclidean',
                                         seed = 1234,
                                         innerLinkage = "average",
                                         plot = "pdf")
    icl <- calcICL(euclidean_km, title = fn, plot = "pdf")
    
    time2 <- Sys.time()
    print(time2 - time1)#显示运行总时长
    
    # 将每次循环的结果添加到结果列表
    for (i in 1:2) {
      for (j in 1:2) {
        var_name <- paste0(distance[i], "_", clusterAlg[j])
        results_cluster[[var_name]] <- get(var_name)
      }
    }
    results_cluster[["euclidean_km"]] <- euclidean_km #再单独把欧氏距离与Kmeans聚类加上去
    save(results_cluster, file = "./RData/",subname,"_cluster_results.RData")
  }
  
}



