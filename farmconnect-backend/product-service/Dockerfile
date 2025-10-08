# Runtime stage - We only need this stage since Jenkins already built the JAR
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copy the JAR from the target folder (created by the Jenkins Maven build)
COPY target/*.jar app.jar

EXPOSE 8082
ENV SPRING_PROFILES_ACTIVE=docker

ENTRYPOINT ["java", "-jar", "app.jar"]