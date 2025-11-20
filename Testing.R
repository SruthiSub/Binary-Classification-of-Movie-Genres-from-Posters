# Testing

library(imager)

setwd("C:/Users/sruth/OneDrive/Desktop/Movie Classification Project")

load("Model.Rdata")

setwd("C:/Users/sruth/OneDrive/Desktop/Movie Classification Project/Test dataset")
X <- matrix(nrow = 60, ncol = 26)
Y <- matrix(1, nrow = 60, ncol = 1)
Y_hat <- matrix(1, nrow = 60, ncol = 1)
for (i in 1:30){
  img <- load.image(paste0("thriller",i,".jpg"))
  X[i,] <- make_feature(img)
  img <- load.image(paste0("comedy",i,".jpg"))
  X[i+30,] <- make_feature(img)
  Y[i+30] <- 0
}
for (i in 1:60){
  xi <- X[i,]
  linear_pred <- sum(xi * beta_hat)
  pi <- class_prob(linear_pred)
  Y_hat[i] <- classify(pi)
}
e <- Y_hat - Y
sum(abs(e))/length(e) 

