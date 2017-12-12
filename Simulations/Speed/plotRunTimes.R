######################################################
######################################################
# Here the inferred mean coalescent and migration
# rate ratios are plotted
######################################################
######################################################
library(ggplot2)


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


# Read in the SISCO *.logs
t <- read.table("CPUtimes.txt", header=TRUE, sep="\t")

annotate = data.frame(x = rep(1020,1), y =t[which(t$lineages==1000), "median"], text= t[which(t$lineages==1000), "states"])

p_speed <- ggplot()+
  geom_line(data=t,aes(x=lineages, y=median/6, group=states)) +
  ylab("median CPU time in min/Mio Samples") + xlab("number of lineages") + ggtitle("run time") + 
  theme(legend.position="none")
p_speed <- p_speed +
  annotate("text",x=annotate$x, y=annotate$y/6, label=annotate$text)
plot(p_speed)

#geom_point(data=m, aes(x=true,y=est), size=0.001, alpha=0.1) +
  

ggsave(plot=p_speed,"../../text/figures/Speed.pdf",width=3, height=3)
