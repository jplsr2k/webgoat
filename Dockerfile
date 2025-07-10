# Stage 1: Build the WebGoat application using Maven and OpenJDK 17
FROM maven:3.9.6-eclipse-temurin-17-alpine AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the entire WebGoat project
COPY . .

# Build the project, skipping tests to speed up the build for deployment
# The 'install' goal will produce the executable JARs
RUN mvn clean install -DskipTests

# Stage 2: Create a smaller runtime image using OpenJDK 17 JRE
FROM eclipse-temurin:17-jre-alpine

# Set the working directory
WORKDIR /app

# Copy the WebGoat JAR from the build stage
# Adjust the JAR name pattern if necessary (e.g., if it's not 'webgoat-container-*.jar')
COPY --from=build /app/webgoat-container/target/webgoat-container-*.jar webgoat.jar

# Copy the WebWolf JAR from the build stage (optional, but recommended for WebGoat)
COPY --from=build /app/webwolf/webwolf-api/target/webwolf-api-*.jar webwolf.jar

# Expose the ports that WebGoat and WebWolf will run on
EXPOSE 8080
EXPOSE 9090

# Command to run the WebGoat application
# WebGoat by default tries to find WebWolf on port 9090 on localhost.
# When deployed on Render, services are often isolated, so we might need to adjust.
# However, WebGoat usually bundles WebWolf, so just starting webgoat.jar is often enough.
# Render's environment variable PORT is usually what it provides for the main service.
# Let's use 8080 as the default internal port and map it.
# The --server.port and --webwolf.port are important for WebGoat/Spring Boot to bind correctly.
# Note: Render will map its own external port to the EXPOSED port (e.g., 8080)
CMD ["java", "-jar", "webgoat.jar", "--server.port=8080", "--webwolf.port=9090"]

# If you want to configure timezone (optional but good for some lessons)
# ENV TZ=America/Sao_Paulo
