# Use the official Gradle image to create a build artifact.
# This is a multi-stage build. In the first stage, we're building the application.
FROM gradle:7.4.0-jdk17 AS build

# Set the working directory in the Gradle container.
WORKDIR /app

# Give the gradle user permissions to the working directory
RUN chown -R gradle /app

# Copy the Gradle configuration files separately to leverage Docker layer caching
COPY --chown=gradle:gradle build.gradle settings.gradle gradlew /app/
COPY --chown=gradle:gradle gradle /app/gradle

# Copy the source code
COPY --chown=gradle:gradle src /app/src

# Use the gradle user
USER gradle

# Build the application.
RUN gradle build --no-daemon

# For the final image, use the official OpenJDK base image.
FROM openjdk:17-slim

# Set the working directory in the JDK container.
WORKDIR /app

# Copy the JAR from the Gradle build stage to the JDK container.
COPY --from=build /app/build/libs/*.jar /app/spring-boot-application.jar

# Expose the port the app runs on.
EXPOSE 8080

# Run the jar file
ENTRYPOINT ["java","-jar","/app/spring-boot-application.jar"]
