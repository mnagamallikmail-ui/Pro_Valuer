FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /app
COPY . .
RUN chmod +x gradlew
RUN ./gradlew bootJar --no-daemon

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/build/libs/BwVrBackend.jar .

# Create directories for uploads and set permissions
RUN mkdir -p /app/uploads /app/templates /app/reports && chmod -R 777 /app/uploads /app/templates /app/reports

EXPOSE 8080

# Use the PORT environment variable provided by Railway
ENTRYPOINT ["java", "-Xmx512m", "-Dserver.port=${PORT:8080}", "-jar", "BwVrBackend.jar"]
