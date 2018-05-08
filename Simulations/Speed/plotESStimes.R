######################################################
######################################################
# Here the inferred mean coalescent and migration
# rate ratios are plotted
######################################################
######################################################
library(ggplot2)
# needed to calculate ESS values
library(coda)
library("methods")


# clear workspace
rm(list = ls())

# Set the directory to the directory of the file
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

# get the names of all mtt run log files
log <- list.files(path="./mttout", pattern="*.log", full.names = TRUE)

# Read in the mtt runtimes
runtimes_mtt <- read.table("runtime_mtt.csv", header=TRUE, sep=",")

# get the names of all mtt run log files
log_mascot <- list.files(path="./out", pattern="*.log", full.names = TRUE)

# Read in the mtt runtimes
runtimes_mascot <- read.table("runtime_mascot.csv", header=TRUE, sep=",")


# use the matlab standard colors to plot
col0 <- rgb(red=0.0, green=0.4470,blue=0.7410)
col1 <- rgb(red=0.8500, green=0.3250,blue=0.0980)
col2 <- rgb(red=0.9290, green=0.6940,blue=0.1250)
col4 <- rgb(red=0.4660, green=0.6740,blue=0.1880)
col3 <- rgb(red=0.3010, green=0.7450,blue=0.9330)

# Read In Data ---------------------------------
for (i in seq(1,length(log),1)){
  print(i)
  filename1 = log[i]
  # Read in the SISCO *.logs
  t <- read.table(filename1, header=TRUE, sep="\t")
  t <- t[-seq(1,ceiling(length(t$m1)/10)), ]

  # calculate ess values
  ess <- effectiveSize(t)
  
  post_ess = as.numeric(ess["posterior"])
  
  # find the correct run_time value
  fname = gsub("./mttout/","",filename1)
  rtime <- as.numeric(runtimes_mtt[which(runtimes_mtt[,1]==fname),2])

  tmp = strsplit(fname, "_")
  states = as.numeric(tmp[[1]][2])
  lineages = as.numeric(tmp[[1]][3])
  
  if (length(rtime)>0){
    if (i==1){
      dfname <- data.frame(states=states, lineages=lineages, ess_time = post_ess/rtime*3600, method="mtt")
    }else{
      new.dfname <- data.frame(states=states, lineages=lineages, ess_time = post_ess/rtime*3600, method="mtt")
      dfname <- rbind(dfname,new.dfname)
    }
  }
  
}


# Read In Data ---------------------------------
for (i in seq(812,length(log_mascot),1)){
  print(i)
  filename1 = log_mascot[i]
  # Read in the SISCO *.logs
  t <- read.table(filename1, header=TRUE, sep="\t")
  t <- t[-seq(1,ceiling(length(t$m1)/10)), ]
  
  # calculate ess values
  ess <- effectiveSize(t)
  
  post_ess = as.numeric(ess["posterior"])
  
  # find the correct run_time value
  fname = gsub("./out/","",filename1)
  rtime <- as.numeric(runtimes_mascot[which(runtimes_mascot[,1]==fname),2])
  
  tmp = strsplit(fname, "_")
  states = as.numeric(tmp[[1]][2])
  lineages = as.numeric(tmp[[1]][3])
  if (length(rtime)>0){
    new.dfname <- data.frame(states=states, lineages=lineages, ess_time = post_ess/rtime*3600, method="mascot")
    dfname <- rbind(dfname,new.dfname)
  }
}

dfname <- read.table(file="median_ess.tsv")

# write.table(dfname, file="median_ess.tsv")

lins = c(200, 400, 600, 800, 1000)
sts = c(2,4,6,8,10)
methods = c("mtt", "mascot")

for (a in seq(1,length(sts))){
  for (b in seq(1, length(lins))){
    c=1
    indices_a = which(dfname$states==sts[a])
    indices_b = which(dfname$lineage==lins[b])
    indices_c = which(dfname$method==methods[c])
    indices_tmp = intersect(indices_a,indices_b)
    indices = intersect(indices_tmp,indices_c)
    if (a==1 && b==1 && c==1){
      vals_mtt = data.frame(states=sts[a], lineage=lins[b], median=quantile(dfname[indices,"ess_time"],0.5), method=methods[c],color=as.character(sts[a]))
    }else{
      new.vals = data.frame(states=sts[a], lineage=lins[b], median=quantile(dfname[indices,"ess_time"],0.5), method=methods[c],color=as.character(sts[a]))
      if (length(indices>0)){
        vals_mtt <- rbind(vals_mtt,new.vals)
      }
    }
    
  }
}
for (a in seq(1,length(sts))){
  for (b in seq(1, length(lins))){
    c=2
    indices_a = which(dfname$states==sts[a])
    indices_b = which(dfname$lineage==lins[b])
    indices_c = which(dfname$method==methods[c])
    indices_tmp = intersect(indices_a,indices_b)
    indices = intersect(indices_tmp,indices_c)
    if (a==1 && b==1 && c==2){
      vals_mascot = data.frame(states=sts[a], lineage=lins[b], median=quantile(dfname[indices,"ess_time"],0.5), method=methods[c],color=as.character(sts[a]))
    }else{
      new.vals = data.frame(states=sts[a], lineage=lins[b], median=quantile(dfname[indices,"ess_time"],0.5), method=methods[c],color=as.character(sts[a]))
      if (length(indices>0)){
        vals_mascot <- rbind(vals_mascot,new.vals)
      }
    }
    
  }
}

color_vals = c(col0,col1,col2,col3,col4)

annotate = data.frame(x = rep(1020,1), y =vals_mascot[which(vals_mascot$lineage==1000), "median"], text= vals_mascot[which(vals_mascot$lineage==1000), "states"])


p_speed <- ggplot()+
  geom_line(data=vals_mtt,aes(x=lineage, y=median, group=states,color=color),linetype="dashed") +
  geom_line(data=vals_mascot,aes(x=lineage, y=median, group=states,color=color)) + scale_y_log10("median ESS per hour") +
  xlab("number of lineages") + ggtitle("ESS per hour") + scale_color_manual(breaks=c("2","4","6","8","10"), values=c(col0,col1,col2,col3,col4)) +
  theme(legend.position="none")  
p_speed <- p_speed +
  annotate("text",x=annotate$x, y=annotate$y, label=annotate$text) +
  annotate("text",x=320, y=1300, label="MTT")

plot(p_speed)

ggsave(plot=p_speed,"../../text/figures/ESS.pdf",width=3, height=3)
