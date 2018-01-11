# Social-Network-Analysis
Compiling, measuring, and managing network data; analyzing characteristics of individuals, relationships, and groups; predicting why relationships and network structures from; using network characteristics to predict both individual behavior and group and population outcomes.
The following are exercises and project on Social Network Analysis using R

## Exercise: Network Structure in venture capital coinvestment networks
The dataset contains information on venture capital investment events, from June 1981 until July 2014.
I explored clustering and core-periphery structures using iterative correlation clustering method, and coreness (k-core) calculation.

## Exercise: Feature Similarity of Films and Productors
The dataset contains information on the films producers made and the plot keywords these films are tagged with.
In this network, keywords appeared in the same film will be linked together.
I calculated and explored similarity, distance, correlation, and cooccurance in this network.

## Exercise: Angel investors and startups on AngelList
Many startups use AngelList as a platform for generating traction about their companies and securing early-stage funding from angel investors. The site’s internal database contains a table that tracks how much traction, which is a measure of support for a startup’s fundraising round, a startup receives over time.
In this network, ties represent directed connections from actors (startups) to events (participants in a startup fundraising round).
I used ERGM model to predict funding relationships among actors (startups and investors)

## Exercise: Political party diffusion and economic outcomes
The data is about parliamentary elections and droughts in India.
The electoral data is combined with meteorological data that details each district’s monthly level of rainfall. We used the occurrence of extreme weather events in a district as a proxy for economic disruption. We used the data to answer the question of whether abnormal levels of rainfall during the time leading up to an election cause more political parties to enter into a district during that election. We  used the data to find out whether there was a geographical diffusion process of political parties entering into districts.
I built regression model to find relationships and make predictions using R.

## Project: YouTube User Network
The original data set is retrieved from the ASU Social Computing Data Repository. It was crawled on Dec, 2008 from YouTube. (http://www.youtube.com/). We edited the data and the final data set contains: 13723 nodes, 76765 edges, 5 attributes and no missing value. 
In this nwtwork, users who are friends will be connected.
We examined network structure, centrality measurements, power law and correlations of attributes.

Project Contributors: Lancy Mao, Agnes Liu (Teammate), Wenbo Liu (Teammate)
