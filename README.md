A Binary Classification model that predicts the genre of a movie (either comedy or thriller) from its poster.

**Data Scraping and Cleaning**

- A list of movies with their genres was obtained from a Kaggle dataset. The posters were scraped from the IMDB site for each movie. This was cleaned and formatted to comprise the training data of the model.

**Feature Extraction**

- Features extracted from the image - quantiles of Hue, Saturation, Value, the Red, Green and Blue components, and the darkness of the image (how different it is from black).

**Model**

- Follows the Generalized Linear Model - Ridge Logistic Regression, implemented using the library _glmnet_.

**Libraries Used** 

 - stringr, rvest, imager and glmnet

**Results from Testing** 

 - Obtained 81.67% accuracy on testing dataset!

**Reproduction Guidelines**

- Scraped data and results can be reproduced by running the given files (just make sure that you change the paths in the code, to ensure compatibility with your local system).
