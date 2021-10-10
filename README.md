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
git clone https://github.com/bryanwhiting/sqlite_test
```

6. Build Docker image with R packages
7. Publish to Dockerhub
8. Pull to AWS
9. Run Docker container, mounting app
10. 
