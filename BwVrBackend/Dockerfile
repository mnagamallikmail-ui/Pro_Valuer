FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# IMPORTANT: change the jar name if your file is different
COPY build/libs/BwVrBackend.jar app.jar

RUN mkdir -p /app/uploads /app/templates /app/reports \
    && chmod -R 777 /app/uploads /app/templates /app/reports

EXPOSE 8080

# Railway sets PORT env; use a shell so ${PORT} is expanded
ENTRYPOINT ["sh", "-c", "java -Xmx512m -Dserver.port=${PORT:-8080} -jar app.jar"]