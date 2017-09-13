######################################################
######################################################
# Here the inferred mean coalescent and migration
# rate ratios are plotted
######################################################
######################################################
library(ggplot2)
# needed to calculate ESS values
library(coda)
library(XML)
library("methods")


# clear workspace
rm(list = ls())

# Set the directory to the directory of the file
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

# get the names of all SISCO first (of three) run log files
log <- list.files(path="./logs", pattern="*mascot.log", full.names = TRUE)

# use the matlab standard colors to plot
col0 <- rgb(red=0.0, green=0.4470,blue=0.7410)
col1 <- rgb(red=0.8500, green=0.3250,blue=0.0980)
col2 <- rgb(red=0.9290, green=0.6940,blue=0.1250)
col4 <- rgb(red=0.4660, green=0.6740,blue=0.1880)
col3 <- rgb(red=0.3010, green=0.7450,blue=0.9330)


states <- 6

# Read In Data ---------------------------------
for (i in seq(1,length(log),1)){
  print(i)
  # Make the filenames for all the three runs
  filename1 <- paste(log[i], sep="")
  master_name <- gsub("logs","master", log[i])
  master_name <- gsub("1mascot","master", master_name)
  master_name <- gsub(".log",".xml", master_name)
  master_tree <- gsub(".xml",".tree", master_name)
  treeString <- paste(readLines(master_tree), collapse=" ")
  locations = gregexpr("location=\"(\\d)\"", treeString)
  rootState = substr(treeString, locations[[1]][length(locations[[1]])]+10,locations[[1]][length(locations[[1]])]+10)
  rootVar  = paste("RootProbability.",rootState, sep="")
  
  tree_name <- gsub("t.log","t.states.trees",filename1)
  tree_name_nud <- gsub("t.log","t.states.nud.trees",filename1)

  
  # Read in the SISCO *.logs
  t <- read.table(filename1, header=TRUE, sep="\t")
  t <- t[-seq(1,ceiling(length(t$m1)/10)), ]
  
  xml_data <- readLines(master_name)
  rates_string = grep("rate=\"(\\d)\\.(\\d)",xml_data, value = TRUE)
  rates_string <- gsub("                <reaction spec='Reaction' rate=\"","", rates_string)
  rates_string <- gsub("\">","", rates_string)
  true_rate <- as.numeric(rates_string)
  

  # calculate ess values
  ess <- effectiveSize(t)

    
  if (min(ess[2:6])<100){
    print("masco ESS value to low")
    print(sprintf("ESS value is %f for file %s",min(ess[2:6]),filename1))
  }else{
    if (i==1){
      dfname <- data.frame(filename = filename1)
      
      Ne <- data.frame(true=0.5/true_rate[1], est=median(t$Ne1))
      lower = quantile(t$Ne1, 0.025)
      upper = quantile(t$Ne1, 0.975)
      
      if (0.5/true_rate[1]>lower && 0.5/true_rate[1] < upper){
        cov.Ne <- data.frame(isIn = 1)
      }else{
        cov.Ne <- data.frame(isIn = 0)
      }
      
      for (i in seq(2,states)){
        name <- paste("Ne",i,sep="")
        Ne.new <- data.frame(true=0.5/true_rate[i], est=median(t[, name]))
        Ne <- rbind(Ne, Ne.new)
        
        lower = quantile(t[, name], 0.025)
        upper = quantile(t[, name], 0.975)
        
        if (0.5/true_rate[i]>lower && 0.5/true_rate[i] < upper){
          cov.Ne.new <- data.frame(isIn = 1)
        }else{
          cov.Ne.new <- data.frame(isIn = 0)
        }
        cov.Ne <- rbind(cov.Ne, cov.Ne.new)
      }
      
      
      m <- data.frame(true=true_rate[states+1], est=median(t$m1))
      lower = quantile(t$m1, 0.025)
      upper = quantile(t$m1, 0.975)
      
      if (true_rate[states+1]>lower && true_rate[states+1] < upper){
        cov.m <- data.frame(isIn = 1)
      }else{
        cov.m <- data.frame(isIn = 0)
      }
      
      for (i in seq(2,states*(states-1))){
        name <- paste("m",i,sep="")
        m.new <- data.frame(true=true_rate[i+states], est=median(t[, name]))
        m <- rbind(m, m.new)
        lower = quantile(t[, name], 0.025)
        upper = quantile(t[, name], 0.975)
        
        if (true_rate[i+states]>lower && true_rate[i+states] < upper){
          cov.m.new <- data.frame(isIn = 1)
        }else{
          cov.m.new <- data.frame(isIn = 0)
        }
        cov.m <- rbind(cov.m, cov.m.new)
        
      }
    }else{
      new.dfname <- data.frame(filename = filename1)
      dfname <- rbind(dfname,new.dfname)
      for (i in seq(1,states)){
        name <- paste("Ne",i,sep="")
        Ne.new <- data.frame(true=true_rate[i], est=median(t[, name]))
        Ne <- rbind(Ne, Ne.new)
        
        lower = quantile(t[, name], 0.025)
        upper = quantile(t[, name], 0.975)
        
        
        if (0.5/true_rate[i]>lower && 0.5/true_rate[i] < upper){
          cov.Ne.new <- data.frame(isIn = 1)
        }else{
          cov.Ne.new <- data.frame(isIn = 0)
        }
        cov.Ne <- rbind(cov.Ne, cov.Ne.new)
      }
      
      for (i in seq(1,states*(states-1))){
        name <- paste("m",i,sep="")
        m.new <- data.frame(true=true_rate[i+states], est=median(t[, name]))
        m <- rbind(m, m.new)
        lower = quantile(t[, name], 0.025)
        upper = quantile(t[, name], 0.975)
        
        if (true_rate[i+states]>lower && true_rate[i+states] < upper){
          cov.m.new <- data.frame(isIn = 1)
        }else{
          cov.m.new <- data.frame(isIn = 0)
        }
        cov.m <- rbind(cov.m, cov.m.new)
        
      }
    }
  }
}


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# plot the rate ratios
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
p_mig <- ggplot()+
  stat_density2d(data=m,aes(alpha = ..density..^0.25,fill = ..density..^0.25, x=true,y=est), geom = "tile", contour = FALSE, n = 200) +
  scale_fill_continuous(low = "white", high = "black") +
  geom_segment(data=m, aes(x = 0.001, y = 0.001, xend = 100, yend = 100), color="red") +
  scale_y_log10(limits=c(0.001,100)) + scale_x_log10(limits=c(0.001,100)) +
  ylab("estimated") + xlab("true") + ggtitle("migration rates") + 
  theme(legend.position="none")
plot(p_mig)

#geom_point(data=m, aes(x=true,y=est), size=0.001, alpha=0.1) +
  

p_Ne <- ggplot()+
  stat_density2d(data=Ne,aes(alpha = ..density..^0.25,fill = ..density..^0.25, x=0.5/true,y=est), geom = "tile", contour = FALSE, n = 200) +
  scale_fill_continuous(low = "white", high = "black") +
  geom_segment(data=Ne, aes(x = 0.1, y = 0.1, xend = 10, yend = 10), color="red") +
  scale_y_log10(limits=c(0.1,10)) + scale_x_log10(limits=c(0.1,10)) +
  ylab("estimated") + xlab("true") + ggtitle("effective population size") + 
  theme(legend.position="none")
plot(p_Ne)


ggsave(plot=p_mig,"../../text/figures/Rates_migration.pdf",width=5, height=5)
ggsave(plot=p_Ne,"../../text/figures/Rates_ne.pdf",width=5, height=5)

print(sprintf("coverage migration = %f ", mean(cov.m$isIn)))
print(sprintf("coverage Ne = %f ",mean(cov.Ne$isIn)))
