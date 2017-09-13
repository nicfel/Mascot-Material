library(graphics)
library(ape)
library("gridExtra")

# clear workspace
rm(list = ls())



# Set the directory to the directory of the file
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)



con=file("H3N2_mascot.ape.nud.trees",open="r")
line=readLines(con) 
close(con)


tr <- read.tree(text=line)
tr <- ladderize(tr, right = TRUE)
edges <- tr$edge
node_labs <- tr$node.label
tip_labs <- tr$tip.label


edge_labs <- matrix(, nrow = length(edges[,1]))
edge_labs[1:length(tip_labs)] <- tip_labs
edge_labs[(length(tip_labs)+1):length(edges[,1])] <- node_labs[1:(length(node_labs))-1]


edge_col = matrix(, nrow = length(edge_labs))
node_col = matrix(, nrow = length(node_labs))
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
  tmp3 = as.numeric(tmp2[[1]][2])
  edge_col[i] = colors[tmp3]
}

for (i in 1: length(node_labs)){
  tmp2 = strsplit(node_labs[i],split="_")
  tmp3 = as.numeric(tmp2[[1]][2])
  node_col[i] = colors[tmp3]
}

for (i in 1: length(tip_labs)){
  tmp2 = strsplit(tip_labs[i],split="_")
  tmp3 = as.numeric(tmp2[[1]][2])
  tip_col[i] = colors[tmp3]
}



print("dfsljkdfjslldfjsjlkefs")

pdf("plot.pdf", height=8,width=8)

# get the time of the root. The nodeHeigths function is in the phytools lubrary
library(phytools)
root_heigth <- max(nodeHeights(tr))


plot(tr,show.tip.label=F,edge.color=edge_col,root.edge = F,edge.width=1)
tiplabels(pch=21, col=tip_col, adj=c(0.5, 0.5), bg=tip_col, cex=0.5)
nodelabels(pch=21, col=node_col, adj=c(0.5, 0.5), bg=node_col, cex=0.5)
axisPhylo(side = 1,root.time = 2002.742466-root_heigth, backward = F)

legend("bottomleft", legend=c("Australia","HongKong","Japan","New Zealand","New York"),col = colors,
         ncol = 1, cex = 1, lwd = 5,lty=1, text.font = i, text.col = 1,bty = "n")

dev.off()

blank_theme <- theme_minimal()+
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    panel.border = element_blank(),
    panel.grid=element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    plot.title=element_text(size=14, face="bold"),
    legend.position="none"
  )


plot.root <- data.frame(x=c(0.1,0.2,0.2,0.1,0.4))

pie_masco <- ggplot(plot.root, aes(x="", y=x*100, fill=colors)) + geom_bar(stat="identity",width=1) 
pie_masco <- pie_masco + coord_polar(theta = "y") +
  scale_fill_manual("",values = colors) +  blank_theme
plot(pie_root)



plot.u <- data.frame(x=c(0.1,0.2,0.2,0.1,0.4))
plot.nud <- data.frame(x=c(0.3,0.0,0.2,0.4,0.1))

pie_u <- ggplot(plot.u, aes(x="", y=x*100, fill=colors)) + geom_bar(stat="identity",width=1) 
pie_u <- pie_u + coord_polar(theta = "y") +
  scale_fill_manual("",values = colors) +  blank_theme
pie_nud <- ggplot(plot.nud, aes(x="", y=x*100, fill=colors)) + geom_bar(stat="identity",width=1) 
pie_nud <- pie_nud + coord_polar(theta = "y") +
  scale_fill_manual("",values = colors) +  blank_theme
pdf("pienode1.pdf", height=1,width=1.5)
grid.arrange(pie_u, pie_nud,ncol = 2)
dev.off()
