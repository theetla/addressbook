from maven:3.8.4-openjdk-11-slim as build-stage

workdir /app

copy pom.xml ./pom.xml
copy src ./src

run mvn package

from tomcat:8.5.78-jdk11-openjdk-slim

copy --from=build-stage /app/target/*.war /usr/local/tomcat/webapps/

expose 8080

cmd ["catalina.sh", "run"]
