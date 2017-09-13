library(graphics)
library(ape)
library("gridExtra")

# clear workspace
rm(list = ls())



# Set the directory to the directory of the file
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)



con=file("ape.trees",open="r")
line=readLines(con) 
close(con)


tr <- read.tree(text=line)
tr[[1]] <- ladderize(tr[[1]], right = F)
tr[[2]] <- ladderize(tr[[2]], right = F)
edges <- tr[[2]]$edge
node_labs1 <- tr[[1]]$node.label
node_labs2 <- tr[[2]]$node.label
tip_labs <- tr[[1]]$tip.label


edge_labs <- matrix(, nrow = length(edges[,1]))
edge_labs[1:length(tip_labs)] <- tip_labs
edge_labs[(length(tip_labs)+1):length(edges[,1])] <- node_labs2[1:(length(node_labs1))-1]


edge_col = matrix(, nrow = length(edge_labs))
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
  tmp = edge_labs[min(edges[i,1],edges[i,2])]
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



size_col[[265]]=1
size_col[[286]]=1
size_col[[287]]=1
size_col[[288]]=1
size_col[[288]]=1
size_col[[2]]=1
size_col[[5]]=1
size_col[[7]]=1
size_col[[13]]=1
size_col[[215]]=1
size_col[[345]]=1
size_col[[3]]=1


#265 286 287 288 355 369 375 390 423 424 425 430

print("dfsljkdfjslldfjsjlkefs")

pdf("plot.pdf", height=8,width=8)

# get the time of the root. The nodeHeigths function is in the phytools lubrary
library(phytools)
root_heigth <- max(nodeHeights(tr[[1]]))


plot(tr[[2]],show.tip.label=F, direction="downwards",edge.color=edge_col,root.edge = F,edge.width=1)
tiplabels(pch=21, col=tip_col, adj=c(0.5, 0.5), bg=tip_col, cex=0.3)
nodelabels(pch=21, col=node_col4, adj=c(0.5, 0.5), bg=node_col4, cex=0.3)
nodelabels(pch=21, col=node_col4[which(size_col==1),],  node=which(size_col==1)+length(tr[[2]]$tip.label), adj=c(0.5, 0.5), bg=node_col4[which(size_col==1),], cex=1)

nodelabels(pie=node_col2[which(size_col==1),], node=which(size_col==1)+length(tr[[2]]$tip.label), piecol=colors, adj=c(-4, 0.6),  cex=0.5)
nodelabels(pie=node_col1[which(size_col==1),], node=which(size_col==1)+length(tr[[2]]$tip.label), piecol=colors, adj=c(5.5, 0.6),  cex=0.5)

# color the root
nodelabels(pie= matrix(node_col1[1,],1), node=length(tr[[2]]$tip.label)+1, piecol=colors, adj=c(0.5,0.5),  cex=1)


axisPhylo(side = 2, las=1,root.time = 2002.742466-root_heigth, backward = F,cex = 10)

legend("bottomleft", legend=c("Australia","HongKong","Japan","New Zealand","New York"),col = colors,
         ncol = 1, cex = 1, lwd = 5,lty=1, text.font = i, text.col = 1,bty = "n")

dev.off()

