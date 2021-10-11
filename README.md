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

# Test the default app
docker run --rm -p 80:3838 rocker/shiny

# Run my custom app via mounting
docker run -p 80:3838 \
    -v /home/ec2-user/sqlite_test/app/:/srv/shiny-server/ \
    -v /srv/shinylog/:/var/log/shiny-server/ \
    --name argon \
    bryanwhiting/argonapp

# for some reason "plotly" wasn't installed (despite docker)
# and I forgot to add "install.packages('reactablefmtr')"
docker exect -it argon bash
# load R and download additional packages
R
install.packages('plotly')
install.packages('reactablefmtr')
q()

docker restart
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
  -v /home/ec2-user/sqlite_test/api:/root/api \
  -e DISABLE_AUTH=true \
  -e PASSWORD=mu \
  -e ROOT=true \
  -u root \
  -p 8080:8000 \
  --name plumber \
  bryanwhiting/plumber

# also, for some reason plumber wasn't installed in the docker.
# maybe it's a user-level issue (root vs. rstudio usernames)

docker exect -it <image> bash
> sudo R
> install.packages('plumber')
> plumber::plumb(file='plumber.R')$run(host="0.0.0.0", port=8000)
```

# Route to my personal website

on Godaddy DNS:

* Record A:, host: `apps`, target: ipv4 of the EC2

On AWS:

* go to [route53](https://console.aws.amazon.com/route53/v2/hostedzones#ListRecordSets/Z0765985164JUPFPQBFB4)
* follow [these instructions](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-to-ec2-instance.html)
