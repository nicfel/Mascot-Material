library(graphics)
library(ape)
library("gridExtra")
library(ggplot2)

# clear workspace
rm(list = ls())



# Set the directory to the directory of the file
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)



con=file("out/ape.trees",open="r")
line=readLines(con) 
close(con)


tr <- read.tree(tex=line)
tr[[1]] <- ladderize(tr[[1]], right = F)
tr[[2]] <- ladderize(tr[[2]], right = F)
edges <- tr[[2]]$edge
node_labs1 <- tr[[1]]$node.label
node_labs2 <- tr[[2]]$node.label
tip_labs <- tr[[1]]$tip.label


edge_labs <- matrix(, nrow = length(edges[,1]))
edge_labs[1:length(tip_labs)] <- tip_labs
edge_labs[(length(tip_labs)+1):(length(edges[,1])+1)] <- node_labs2[1:(length(node_labs1))]


edge_col = matrix(, nrow = length(edge_labs)-1)
node_col1 = matrix(, nrow = length(node_labs1),5)
node_col2 = matrix(, nrow = length(node_labs2),5)
node_col3 = matrix(, nrow = length(node_labs2))
node_col4 = matrix(, nrow = length(node_labs2))
size_col = matrix(, nrow = length(node_labs2))
tip_col = matrix(, nrow = length(tip_labs))

alaska <- rgb(red=0, green=0.4470, blue=0.7410)
northwest <- rgb(red=0.8500, green=0.3250, blue=0.0980)
northeast <- rgb(red=0.9290, green=0.6940, blue=0.1250)
southeast <- rgb(red=0.4940, green=0.1840, blue=0.5560)
eastcoast <- rgb(red=0.4660, green=0.6740, blue=0.1880)
northmideast <- rgb(red=0.3010, green=0.7450, blue=0.9330)
center <- rgb(red=0.6350, green=0.0780, blue=0.1840)


colors = c(rgb(red=0.0, green=0.4470,blue=0.7410),
           rgb(red=0.8500, green=0.3250,blue=0.0980),
           rgb(red=0.9290, green=0.6940, blue=0.1250),
           rgb(red=0.4660, green=0.6740, blue=0.1880),
           rgb(red=0.3010, green=0.7450, blue=0.9330))



for (i in 1: length(edge_col)){
  if (min(edges[i,1],edges[i,2]) <= length(tr[[2]]$tip.label)){
    tmp = edge_labs[min(edges[i,1],edges[i,2])]
  }else{
    tmp = edge_labs[max(edges[i,1],edges[i,2])]
  }
  tmp2 = strsplit(tmp,split="_")
  tmp3 = as.numeric(tmp2[[1]][2:length(tmp2[[1]])])
  edge_col[i] = colors[which.max(tmp3)]
}

for (i in 1: length(node_labs1)){
  tmp2 = strsplit(node_labs1[i],split="_")
  tmp3 = as.numeric(tmp2[[1]][2:length(tmp2[[1]])])
  node_col1[i,] = tmp3
}
for (i in 1: length(node_labs2)){
  tmp2 = strsplit(node_labs2[i],split="_")
  tmp3 = as.numeric(tmp2[[1]][2:length(tmp2[[1]])])
  node_col2[i,] = tmp3
  tr[[2]]$node.label[i] = i
}
for (i in 1: length(node_labs2)){
  tmp2 = strsplit(node_labs1[i],split="_")
  tmp3 = as.numeric(tmp2[[1]][2:length(tmp2[[1]])])
  node_col3[i,] = colors[which.max(tmp3)]
}
for (i in 1: length(node_labs2)){
  tmp2 = strsplit(node_labs2[i],split="_")
  tmp3 = as.numeric(tmp2[[1]][2:length(tmp2[[1]])])
  node_col4[i,] = colors[which.max(tmp3)]
}
for (i in 1: length(node_labs2)){
    size_col[i,] = 0
}

for (i in 1: length(tip_labs)){
  tmp2 = strsplit(tip_labs[i],split="_")
  tmp3 = as.numeric(tmp2[[1]][2:length(tmp2[[1]])])
  tip_col[i] = colors[which.max(tmp3)]
}


size_col[[272]]=1
size_col[[273]]=1
size_col[[362]]=1
size_col[[11]]=1
size_col[[12]]=1
size_col[[2]]=1
size_col[[215]]=1
size_col[[216]]=1
# size_col[[9]]=1

size_col[[247]]=1



# size_col[[290]]=1
# size_col[[360]]=1
# size_col[[9]]=1
# 
# 
# size_col[[2]]=1
# size_col[[5]]=1
# size_col[[7]]=1
# size_col[[13]]=1
# size_col[[215]]=1
# size_col[[345]]=1
# size_col[[3]]=1


pdf("tree.pdf", height=8,width=8)

# get the time of the root. The nodeHeigths function is in the phytools library
library(phytools)
root_heigth <- max(nodeHeights(tr[[1]]))


plot(tr[[2]],show.tip.label=F, direction="downwards",edge.color=edge_col,root.edge = F,edge.width=1)
tiplabels(pch=21, col=tip_col, adj=c(0.5, 0.5), bg=tip_col, cex=0.3)
nodelabels(pch=21, col=node_col4, adj=c(0.5, 0.5), bg=node_col4, cex=0.3)
nodelabels(pch=21, col=node_col4[which(size_col==1),],  node=which(size_col==1)+length(tr[[2]]$tip.label), adj=c(0.5, 0.5), bg=node_col4[which(size_col==1),], cex=1)

nodelabels(pie=node_col2[which(size_col==1),], node=which(size_col==1)+length(tr[[2]]$tip.label), piecol=colors, adj=c(-6, 0.6),  cex=0.7)
nodelabels(pie=node_col1[which(size_col==1),], node=which(size_col==1)+length(tr[[2]]$tip.label), piecol=colors, adj=c(7.5, 0.6),  cex=0.7)

colss = seq(1,length(tr[[2]]$tip.label))
# nodelabels(text=colss, node=colss+length(tr[[2]]$tip.label),cex=0.25)
           
           
# color the root
nodelabels(pie= matrix(node_col1[1,],1), node=length(tr[[2]]$tip.label)+1, piecol=colors, adj=c(0.5,0.5),  cex=1.7)


axisPhylo(side = 2, las=1,root.time = 2002.742466-root_heigth, backward = F,cex = 10)

legend("bottomleft", legend=c("Australia","Hong Kong","Japan","New Zealand","New York"),col = colors,
         ncol = 1, cex = 1, lwd = 5,lty=1, text.font = i, text.col = 1,bty = "n")

dev.off()

# plot the migration rates and Ne estimates (mostly Ne)
log <- read.table(file="out/H3N2_mascot.log", header=TRUE, sep="\t")

p_violin <- ggplot(data=log) +
  geom_violin(aes(1,log$Ne.t.H3N2_subsampled.Australia,color="Australia")) + 
  geom_violin(aes(2,log$Ne.t.H3N2_subsampled.Hong_Kong,color="Hong Kong")) + 
  geom_violin(aes(3,log$Ne.t.H3N2_subsampled.Japan,color="Japan")) + 
  geom_violin(aes(4,log$Ne.t.H3N2_subsampled.New_Zealand,color="New Zealand")) + 
  geom_violin(aes(5,log$Ne.t.H3N2_subsampled.USA,color="New York")) 

p_violin <- p_violin +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        strip.text = element_text(size = 20, colour = rgb(red=0, green=0, blue=0)),
        axis.title=element_text(size=20), legend.position="none" ) + ylab("effective population size") + 
  scale_colour_manual("",values = c("Australia" = colors[1],
                                    "Hong Kong" =  colors[2],
                                    "Japan" =  colors[3],
                                    "New Zealand" =  colors[4],
                                    "New York" =  colors[5])) 
plot(p_violin)

ggsave(plot=p_violin,"Ne.pdf",width=6, height=3)


# plot migration rates

library("igraph")


# thickness = c(1,median(log$b_migration.t.H3N2_subsampled.Australia_to_Hong_Kong), median(log$b_migration.t.H3N2_subsampled.Australia_to_Japan), median(log$b_migration.t.H3N2_subsampled.Australia_to_New_Zealand), median(log$b_migration.t.H3N2_subsampled.Australia_to_USA), 
#               median(log$b_migration.t.H3N2_subsampled.Hong_Kong_to_Australia),1, median(log$b_migration.t.H3N2_subsampled.Hong_Kong_to_Japan), median(log$b_migration.t.H3N2_subsampled.Hong_Kong_to_New_Zealand), median(log$b_migration.t.H3N2_subsampled.Hong_Kong_to_USA),
#               median(log$b_migration.t.H3N2_subsampled.Japan_to_Australia), median(log$b_migration.t.H3N2_subsampled.Japan_to_Hong_Kong),1, median(log$b_migration.t.H3N2_subsampled.Japan_to_New_Zealand), median(log$b_migration.t.H3N2_subsampled.Japan_to_USA),
#               median(log$b_migration.t.H3N2_subsampled.New_Zealand_to_Australia), median(log$b_migration.t.H3N2_subsampled.New_Zealand_to_Hong_Kong), median(log$b_migration.t.H3N2_subsampled.New_Zealand_to_Japan),1, median(log$b_migration.t.H3N2_subsampled.New_Zealand_to_USA),
#               median(log$b_migration.t.H3N2_subsampled.USA_to_Australia), median(log$b_migration.t.H3N2_subsampled.USA_to_Hong_Kong), median(log$b_migration.t.H3N2_subsampled.USA_to_Japan), median(log$b_migration.t.H3N2_subsampled.USA_to_New_Zealand),1)


thickness = c(1,median(log$b_migration.t.H3N2_subsampled.Hong_Kong_to_Australia), median(log$b_migration.t.H3N2_subsampled.Japan_to_Australia), median(log$b_migration.t.H3N2_subsampled.New_Zealand_to_Australia), median(log$b_migration.t.H3N2_subsampled.USA_to_Australia), 
              median(log$b_migration.t.H3N2_subsampled.Australia_to_Hong_Kong),1, median(log$b_migration.t.H3N2_subsampled.Japan_to_Hong_Kong), median(log$b_migration.t.H3N2_subsampled.New_Zealand_to_Hong_Kong), median(log$b_migration.t.H3N2_subsampled.USA_to_Hong_Kong),
              median(log$b_migration.t.H3N2_subsampled.Australia_to_Japan), median(log$b_migration.t.H3N2_subsampled.Hong_Kong_to_Japan),1, median(log$b_migration.t.H3N2_subsampled.New_Zealand_to_Japan), median(log$b_migration.t.H3N2_subsampled.USA_to_Japan),
              median(log$b_migration.t.H3N2_subsampled.Australia_to_New_Zealand), median(log$b_migration.t.H3N2_subsampled.Hong_Kong_to_New_Zealand), median(log$b_migration.t.H3N2_subsampled.Japan_to_New_Zealand),1, median(log$b_migration.t.H3N2_subsampled.USA_to_New_Zealand),
              median(log$b_migration.t.H3N2_subsampled.Australia_to_USA), median(log$b_migration.t.H3N2_subsampled.Hong_Kong_to_USA), median(log$b_migration.t.H3N2_subsampled.Japan_to_USA), median(log$b_migration.t.H3N2_subsampled.New_Zealand_to_USA),1)


Edges <- data.frame(
  from = rep(c("Australia","Hong Kong","Japan","New Zealand","New York"),each=5),
  to = rep(c("Australia","Hong Kong","Japan","New Zealand","New York"),times=5),
  thickness = thickness)

Edges <- subset(Edges,from!=to)

g <- graph.edgelist(as.matrix(Edges[,-3]))
l <- layout.fruchterman.reingold(g)
# Define edge widths:
E(g)$width <- Edges$thicknes*5


# Define arrow widths:
E(g)$arrow.width <- Edges$thickness*20

# Make edges curved:
E(g)$curved <- 0.2

vertex_sizes = c(median(log$Ne.t.H3N2_subsampled.Australia),
                median(log$Ne.t.H3N2_subsampled.Hong_Kong),
                median(log$Ne.t.H3N2_subsampled.Japan),
                median(log$Ne.t.H3N2_subsampled.New_Zealand),
                median(log$Ne.t.H3N2_subsampled.USA))

# vertcols <- c(colors[1],colors[2],colors[3],colors[4],
#               colors[5])
edgecols <- c(colors[1],colors[1],colors[1],colors[1],
              colors[2],colors[2],colors[2],colors[2],
              colors[3],colors[3],colors[3],colors[3],
              colors[4],colors[4],colors[4],colors[4],
              colors[5],colors[5],colors[5],colors[5])

pdf("migration.pdf", height=5,width=5)
plot(g, vertex.color=colors, edge.color=edgecols, vertex.label.dist=100.5, vertex.label.color="black", vertex.size=as.matrix(vertex_sizes*20))
dev.off()
