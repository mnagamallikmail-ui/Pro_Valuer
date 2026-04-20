FROM eclipse-temurin:21-jre-alpine

# Use /opt/bwvr for the application binary to prevent Railway volumes
# (which the user mounts at /app) from masking the app.jar file.
WORKDIR /opt/bwvr

# Copy the JAR from the build output
COPY BwVrBackend.jar app.jar

# Create the data directories in the path intended for volume mounting
# The application.properties explicitly points to these /app subfolders.
RUN mkdir -p /app/uploads /app/templates /app/reports \
    && chmod -R 777 /app/uploads /app/templates /app/reports

EXPOSE 8080

# Explicitly use the absolute path to the jar
ENTRYPOINT ["sh", "-c", "java -Xmx512m -Dserver.port=${PORT:-8080} -jar /opt/bwvr/app.jar"]