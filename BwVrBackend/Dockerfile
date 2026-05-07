FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

<<<<<<< HEAD
# The JAR is built in GitHub Actions and passed here
COPY build/libs/*.jar app.jar

# Create the data directories
RUN mkdir -p /app/data/uploads /app/data/templates /app/data/reports \
    && chmod -R 777 /app/data

EXPOSE 8080

ENTRYPOINT ["java", "-Xmx512m", "-Dserver.port=8080", "-jar", "app.jar"]
=======
# Copy the JAR from the build output
COPY BwVrBackend.jar app.jar

# Create the data directories for persistence
RUN mkdir -p /app/uploads /app/templates /app/reports \
    && chmod -R 777 /app/uploads /app/templates /app/reports

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "java -Xmx512m -Dserver.port=${PORT:-8080} -jar app.jar"]
>>>>>>> 84141aa47c8b58ff717d8d2c62f72a0cee589238
