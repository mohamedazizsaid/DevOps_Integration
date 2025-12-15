FROM eclipse-temurin:17-jdk-alpine
LABEL maintainer="baeldung.com"
COPY target/student-management-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]