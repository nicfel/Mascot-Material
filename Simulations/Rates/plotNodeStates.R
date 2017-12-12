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



# use the matlab standard colors to plot
col0 <- rgb(red=0.0, green=0.4470,blue=0.7410)
col1 <- rgb(red=0.8500, green=0.3250,blue=0.0980)
col2 <- rgb(red=0.9290, green=0.6940,blue=0.1250)
col3 <- rgb(red=0.3010, green=0.7450,blue=0.9330)
col4 <- rgb(red=0.4660, green=0.6740,blue=0.1880)




t_node_states <- read.table("node_probs.txt", header=FALSE, sep="\t")
indices_ud = order(t_node_states$V1)
indices_nud = order(t_node_states$V2)
df_ud <- data.frame(x = seq(1,length(t_node_states$V1)), y=t_node_states$V1[indices_ud])
df_nud <- data.frame(x = seq(1,length(t_node_states$V2)), y=t_node_states$V2[indices_nud])
p_node <-  ggplot() +
  geom_line(data=df_ud[seq(1,length(t_node_states$V1),1000),], aes(x=x,y=y, color="With Backwards/Forwards")) +
  geom_line(data=df_nud[seq(1,length(t_node_states$V1),1000),], aes(x=x,y=y, color="Without Backwards/Forwards")) +
  ggtitle("internal node states") +
  ylab("posterior support of true node state") + xlab("ordered nodes") +
  scale_colour_manual("",values = c("With Backwards/Forwards" = col1, "Without Backwards/Forwards" = col3),
                    breaks=c("With Backwards/Forwards", "Without Backwards/Forwards")) + 
  theme(legend.position= c(0.6, 0.2),
        legend.background = element_rect(fill=alpha('white', 0)))
plot(p_node)

df <- data.frame(x = 1, y = sum(1-t_node_states$V1)/length(t_node_states$V1), color=col1)
df <- rbind(df, data.frame(x = 2, y = sum(1-t_node_states$V2)/length(t_node_states$V2), color=col3))
p_bar <-  ggplot(df, aes(x,y,fill=color)) + geom_col() +
  ylab("mean posterior support") + xlab("")+
  ggtitle("support of wrong internal node state") +
  theme(legend.position="none",
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank())
plot(p_bar)



t_root_states <- read.table("root_probs.txt", header=FALSE, sep="\t")
indices_ud = order(t_root_states$V1)
indices_nud = order(t_root_states$V2)
df_ud <- data.frame(x = seq(1,length(t_root_states$V1)), y=t_root_states$V1[indices_ud])
df_nud <- data.frame(x = seq(1,length(t_root_states$V2)), y=t_root_states$V2[indices_nud])
p_root <-  ggplot() +
  geom_line(data=df_ud, aes(x=x ,y=y ) ) +
  ylab("posterior support of true root state") + xlab("ordered nodes") +
  ggtitle("root states") 
plot(p_root)

ggsave(plot=p_node,"../../text/Figures/NodeStates_nodes.pdf",width=3, height=3)
ggsave(plot=p_bar,"../../text/Figures/NodeStates_bar.pdf",width=3, height=3)
ggsave(plot=p_root,"../../text/Figures/NodeStates_root.pdf",width=3, height=3)



