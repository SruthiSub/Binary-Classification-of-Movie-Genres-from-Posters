# Data Scraping

# Importing the required libraries
library(stringr)
library(rvest)
library(imager)
library(glmnet)

setwd("C:/Users/sruth/OneDrive/Desktop/Movie Classification Project")

# From Kaggle Dataset - (https://www.kaggle.com/datasets/neha1703/movie-genre-from-its-poster)
data <- read.csv("MovieGenre.csv")
Genres <- data$Genre
Code <- data$Imdb.Link
Imgfiles <- data$imdbId
part1 <- str_split_i(Code, "tt", 1)
mid   <- str_split_i(Code, "tt", 2)
rest  <- str_split_i(Code, "tt", 3)
lengths <- nchar(rest)
keepind <- which(lengths == 6)
Code <- paste0(part1,"tt",mid,"tt0",rest)
Code <- Code[keepind]
Genres <- Genres[keepind]
Genres <- str_split_i(Genres, "\\|",1)
Comedy <- which(Genres == "Comedy")
Thriller <- which(Genres == "Thriller")
Thriller <- c(which(Genres == "Action"), Thriller)
Thriller <- c(which(Genres == "Crime"), Thriller)
Thriller <- c(which(Genres == "Adventure"), Thriller)
Indices <- c(Comedy, Thriller)
Genres <- Genres[Indices]
Code <- Code[Indices]
n <- length(Genres)

setwd("C:/Users/sruth/OneDrive/Desktop/Movie Classification Project/Posters")
# To download all the images
for (i in 1:7226){
  url <- Code[i]
  page <- read_html(url)
  poster_node <- html_node(page, "img.ipc-image")
  poster_url <- html_attr(poster_node, "src") 
  download.file(poster_url, destfile = paste0(Imgfiles[i], ".jpg"), mode = "wb")
  image <- load.image(paste0(Imgfiles[i], ".jpg"))
  save.image(image,paste0("poster",i,".jpg"))
}

# Shuffling the images as they are currently ordered based on category
shuffle_indexes <- sample(1:n)
Genres <- Genres[shuffle_indexes]

# Training Data
train_indexes <- shuffle_indexes
train_genres <- Genres[1:n]

# Creating y vectors from genres
convertgenre <- function(genre){
  if (genre == "Comedy"){
    return (0)
  }
  else{
    return (1)
  }
}
y_train <- matrix(nrow = n, ncol = 1)
for (i in 1:n){
  y_train[i] <- convertgenre(train_genres[i])
}

# Creating feature vector from the images
make_feature <- function(img)
{
  if (spectrum(img)==1){
    img <- imappend(list(img, img, img), "c")
  }
  hsv_img <- RGBtoHSV(img)
  hue <- quantile(as.vector(hsv_img[,,,1]), probs = c(0.2,0.4,0.6,0.8))   
  saturation <- quantile(as.vector(hsv_img[,,,2]), probs = c(0.2,0.4,0.6,0.8))  
  value <- quantile(as.vector(hsv_img[,,,3]), probs = c(0.2,0.4,0.6,0.8)) 
  red <- quantile(as.vector(img[,,1,1]), probs = c(0.2,0.4,0.6,0.8))
  green <- quantile(as.vector(img[,,1,2]), probs = c(0.2,0.4,0.6,0.8))
  blue <- quantile(as.vector(img[,,1,3]), probs = c(0.2,0.4,0.6,0.8))
  img_gray <- grayscale(img)
  img_gray <- resize(img_gray, 32, 32)
  img_mat <- as.matrix(img_gray)
  black <- matrix(0, nrow = 32, ncol = 32)
  darkness <- norm(as.numeric(black - img_mat),"2") 
  xi <- c(1,hue, saturation, value, red, blue, green, darkness)
  xi <- as.matrix(xi)
  return(xi)
}

nc <-26 # Number of features per image
X <- matrix(nrow = n, ncol = nc)
for (i in 1:n){
  img <- load.image(paste0("poster",train_indexes[i],".jpg"))
  X[i,] <- make_feature(img)
}

# Obtaining optimal beta_hat,  for a ridge logistic regression model
fit <- cv.glmnet(
  x = X, 
  y = y_train,
  family = "binomial",
  intercept = FALSE,
  alpha = 0 
)
best_lambda <- fit$lambda.min
coef_lasso <- coef(fit, s = "lambda.min")
beta_hat <- coef_lasso[-1] 

# Model 
class_prob <- function(lin.pred){
  p <-  1/(1+exp(-lin.pred))
  return(p)
}
classify <- function(p){
  if (p <0.5){ return (0) }
  else{
    return(1)
  }
}

setwd("C:/Users/sruth/OneDrive/Desktop/Movie Classification Project")
save(make_feature, beta_hat, class_prob, classify, file ="Model.Rdata")
