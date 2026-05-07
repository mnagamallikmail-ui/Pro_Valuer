FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# The JAR is built in GitHub Actions (BwVrBackend/build/libs/BwVrBackend.jar)
# With context set to root (.), we must specify the subfolder path.
COPY BwVrBackend/build/libs/*.jar app.jar

# Create the data directories for persistence
RUN mkdir -p /app/data/uploads /app/data/templates /app/data/reports \
    && chmod -R 777 /app/data

EXPOSE 8080

ENTRYPOINT ["java", "-Xmx512m", "-Dserver.port=8080", "-jar", "app.jar"]
