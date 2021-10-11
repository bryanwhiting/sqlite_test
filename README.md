See site here: https://bryanwhiting.github.io/sqlite_test/

Raw data stored in `data-raw/data.csv`. The `index.Rmd` file is an R Markdown file, which compiles the SQL and R code into an html document.

# App

1. Create app
2. Create EC2 instance. Add security groups HTTP, HTTPS, SSH, and TCP 8080
3. Download key pair
4. `ssh -i shiny-sql-app.cer ec2-user@ec2-....us-east-2.compute.amazonaws.com`
5. Set up example shiny app

```
sudo yum update -y
sudo yum install git docker -y
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html
sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
docker info
sudo docker pull rocker/shiny
sudo docker pull bryanwhiting/argonapp
git clone https://github.com/bryanwhiting/sqlite_test
cd sqlite_test

docker run --rm -p 80:3838 rocker/shiny

docker run --rm -p 3838:3838 \
    -v /srv/shinyapps/:/srv/shiny-server/ \
    -v /srv/shinylog/:/var/log/shiny-server/ \
    rocker/shiny

docker run --rm -p 80:3838 \
    -v /home/ec2-user/sqlite_test/app/:/srv/shiny-server/ \
    -v /srv/shinylog/:/var/log/shiny-server/ \
    bryanwhiting/argonapp

```

`ec2-3-133-97-177.us-east-2.compute.amazonaws.com`

6. Build Docker image with R packages
7. Publish to Dockerhub
8. Pull to AWS
9. Run Docker container, mounting app
10. 


# Plumber API:

Set up R bare metal on AWS:

```
sudo amazon-linux-extras install R4 -y
sudo R -e "install.packages('dplyr', dependencies=TRUE, repos='http://cran.rstudio.com/')" 
sudo R -e "install.packages('tidyr', dependencies=TRUE, repos='http://cran.rstudio.com/')" 
sudo R -e "install.packages('stringr', dependencies=TRUE, repos='http://cran.rstudio.com/')"
sudo R -e "install.packages('plumber', dependencies=TRUE, repos='http://cran.rstudio.com/')"
```

^^ This had problems only at the `plumber` stage because `plumber` had some dependencies. So I build a docker container from the tidyverse docker image.

```
docker run --rm \
  -p 8080:8000 \
  bryanwhiting/plumber
```
