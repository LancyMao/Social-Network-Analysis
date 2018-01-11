---
title: "SNA project"
output: html_notebook
team: Agnes Liu, Robin Liu, Lanxin Mao
---

```{r load package and dataset}
library(data.table)
library(igraph)
library(ggplot2)
library(network)
library(ergm)

d1 <- fread('1-edges.csv',header = F)
d2 <- fread('2-edges.csv',header = F)
d3 <- fread('3-edges.csv',header = F)
d4 <- fread('4-edges.csv',header = F)
d5 <- fread('5-edges.csv',header = F)
colnames(d1)=colnames(d2)=colnames(d3)=colnames(d4)=colnames(d5) <- c('A','B','attr')

data <- merge(d1,d2,by=c('A','B'),all.x = TRUE)
colnames(data)[3]<- c('contact')
colnames(data)[4]<- c('cofriend')
data <- merge(data,d3,by=c('A','B'),all.x = TRUE)
colnames(data)[5]<- c('fav')
data <- merge(data,d4,by=c('A','B'),all.x = TRUE)
colnames(data)[6]<- c('subp')
data <- merge(data,d5,by=c('A','B'),all.x = TRUE)
colnames(data)[7]<- c('subb')

data[is.na(data)]=0
```

```{r network graph}
g1 <- graph.data.frame(as.matrix(data), directed = F)

# nodes' colors are the same if they 
co <- clusters(g1)$membership
colours = sample(rainbow(max(co)+1))
V(g1)$color = colours[co+1]

# graph1: entire network--------------
plot1 <- plot(g1, vertex.label=NA, vertex.size=degree(g1, mode = "all")/25, main='Entire network')

# sample 5000-----------------
ord <- sample(nrow(data),5000)
Datasample <- data[ord,]
g2 <- graph.data.frame(as.matrix(Datasample), directed = F)
co <- clusters(g2)$membership
colours = sample(rainbow(max(co)+1))
V(g2)$color = colours[co+1]
plot2 <- plot(g2, vertex.label=NA, vertex.size=degree(g2, mode = "all")/2)

# subgraph1: top100 closeness nodes----------------
cln<-closeness(g1, normalized = T)
names(cln)<-c(1:length(cln))
cln<-sort(cln,decreasing = TRUE)
top_cln.index<-as.numeric(names(cln)[1:100])
g2 <-induced.subgraph(g1,top_cln.index)

# vertex size is their degree in entire network
V(g2)$color='skyblue'
plot2 <- plot.igraph(g2,vertex.label=NA, vertex.size=degree(g1, mode = "all")[top_cln.index]/25,main='Top 100 closeness')

# subgraph2: top100 coreness nodes----------------
crn<-coreness(g1)
names(crn)<-c(1:length(crn))
crn<-sort(crn,decreasing = TRUE)
top_crn.index<-as.numeric(names(crn)[1:98])
g3<-induced.subgraph(g1,top_crn.index)

# vertex size is their degree in entire network
V(g3)$color='skyblue'
coreness_clss<-intersect(names(V(g2)),names(V(g3)))
both_index<-match(coreness_clss,names(V(g3)))
V(g3)$color[both_index]='coral'
plot3 <- plot.igraph(g3,vertex.label=NA, vertex.size=degree(g1, mode = "all")[top_crn.index]/10,main='Top 98 coreness')

```


```{r degree distribution_power law}
deg <- degree(g1)
ta <- table(deg)

df <- data.frame('degree'=as.numeric(names(ta)),'Frequency'=unname(ta))
df <- df[,c(1,3)]
ggplot(df, aes(x=degree,y=Frequency.Freq/sum(ta))) + geom_point() + theme_bw()+ labs(y='Odds', x= 'Degree',title='Degree Distribution')

ggplot(df, aes(x=log(degree),y=log(Frequency.Freq/sum(ta)))) + geom_point() + theme_bw()+ labs(y='log(Odds)', x= 'log(Degree)',title='Degree Distribution')

# node distribution follows the power law
```


```{r attribute and centrality correlation}
#---------------------------------------- attribute cor
val<-nrow(data)
a1 <- table((data$contact == 1) & (data$subb != 0))[2]/val
a2 <- table((data$contact == 1) & (data$subp != 0))[2]/val
a3 <- table((data$contact == 1) & (data$fav != 0))[2]/val
a4 <- table((data$contact == 1) & (data$cofriend > 5 ))[2]/val

# 26.9% connections have shared subscribers
# 46.8% connections have shared subscriptions
# 46.5% connections have shared favoriate videos
# 16.1% connections have over 5 shared friends

cor(data[,4:7])

# correlations among these four attributes are low. cor(subsciption, favoriate videos) = 0.54 is the highest.

#---------------------------------------- measurement cor
stats <- as.data.table(list(V(g1)$name,degree(g1, normalized = T),betweenness(g1, directed = T,normalized = T),closeness(g1, normalized = T), (evcent(g1)$vector)))
colnames(stats)<- c('node','degree','betweenness','closeness','eigenvector')
# summary(stats)

cor(stats[,2:5])
# cor(betweenness, degree)=0.7
# Users with high degree tend to have high betweenness centrality, which means they usually act as bridges in this network. 
# Youtube can reduce betweenness by recommending one to the other if they have cofriends.

# cor(closeness, betweenness)=0.05
# users surround the one with high betweenness don't tend to be central.
```


```{r network structure}
#---------------------------------------- cluster
csize <- components(g1,mode='strong')$csize
largepc <- max(csize)/sum(csize)
# The largest cluster has 13679 (99.68%) users.
m <- components(g1,mode='strong')$membership
m.1 <-names(m)[m==2]
g3 <- induced_subgraph(g1,v=m.1)
sp <- mean(shortest.paths(g3))

#---------------------------------------- coreness
c <- coreness(g1)
high_pc <- length(c[c == quantile(c,1)])/length(c)

# In this network, the maximum k-core subgraph has k=25, and there are 98 (0.714%) users belong to at least one 25-core subgraph
```


```{r ergm}
#set up consecutive IDs for network. For some reason merge function isn't working properly therefore used for loop to do so.
g1.top_cr_edges<-as.data.frame(as_edgelist(g3))
g1.top_cr_edges[,1]<-as.numeric(as.character(g1.top_cr_edges[,1]))
g1.top_cr_edges[,2]<-as.numeric(as.character(g1.top_cr_edges[,2]))
g1.top_cr_edges$'A.id'<-0
g1.top_cr_edges$'B.id'<-0
colnames(g1.top_cr_edges)[1:2]<-c('A','B')
networl_vertex<-unique(c(g1.top_cr_edges[,1],g1.top_cr_edges[,2]))
for(i in 1:nrow(g1.top_cr_edges)){
  g1.top_cr_edges[i,3]<-which(networl_vertex==g1.top_cr_edges[i,1])
  g1.top_cr_edges[i,4]<-which(networl_vertex==g1.top_cr_edges[i,2])
}

#Retrive edge attributes from our subgraph.
g1.top_cr_edges.attr<-igraph::get.edge.attribute(g3)

#create network and set attribute
top_cor_network<-network(g1.top_cr_edges[,c(3,4)])
for(i in 1:length(g1.top_cr_edges.attr)){
  attr.name<-names(g1.top_cr_edges.attr)[i]
  network::set.edge.attribute(top_cor_network,attr.name,g1.top_cr_edges.attr[[i]])
}

#create model
m1 = ergm(top_cor_network ~ edges + mutual + edgecov(top_cor_network,'cofriend'), burnin=15000, MCMCsamplesize=30000, verbose=FALSE)
summary(m1)
```


