FROM maven:3.8.6 AS build
COPY src /home/app/src
COPY pom.xml /home/app
RUN mvn -Dmaven.test.skip=true -f /home/app/pom.xml clean package

FROM --platform=linux/amd64 eclipse-temurin:17-alpine
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring
ARG JAR_FILE=target/*.jar
COPY --from=build /home/app/${JAR_FILE} app.jar
EXPOSE 4001
ENTRYPOINT ["java","-jar","/app.jar"]
