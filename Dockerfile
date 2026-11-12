# Multi-stage build for PaperWise
# Stage 1: Build the WAR file with Ant
FROM eclipse-temurin:17-jdk AS builder

# Install Ant
RUN apt-get update && \
    apt-get install -y ant && \
    rm -rf /var/lib/apt/lists/*

# Copy project files
WORKDIR /build
COPY . .

# Build the WAR file using Ant
RUN ant clean war

# Stage 2: Runtime with Tomcat
FROM tomcat:10.1-jre17

# Remove default Tomcat webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the WAR file from builder stage
COPY --from=builder /build/dist/PaperWise_AJT.war /usr/local/tomcat/webapps/ROOT.war

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set default environment to production
ENV APP_ENV=production

# Expose port (Render will override with PORT env var)
EXPOSE 8080

# Use custom entrypoint to inject environment variables as system properties
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["catalina.sh", "run"]
