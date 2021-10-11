FROM rocker/shiny:latest

# RUN R -e "install.packages('tidyverse', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('argonR', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('argonDash', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('reactable', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('ggplot2', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('plotly', dependencies=TRUE, repos='http://cran.rstudio.com/')"
