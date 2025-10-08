# Build stage
FROM maven:3.9.5-eclipse-temurin-17 AS build
WORKDIR /build

# Copy Maven settings to use mirror
COPY docker-maven-settings.xml /root/.m2/settings.xml

# Copy parent POM first
COPY pom.xml ./pom.xml

# Copy this service's pom and source
COPY product-service/pom.xml ./product-service/pom.xml
COPY product-service/src ./product-service/src

# Build the service
WORKDIR /build/product-service
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copy the JAR from build stage
COPY --from=build /build/product-service/target/*.jar app.jar

EXPOSE 8082
ENV SPRING_PROFILES_ACTIVE=docker

ENTRYPOINT ["java", "-jar", "app.jar"]