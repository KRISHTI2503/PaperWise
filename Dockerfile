# Multi-stage build for PaperWise
# Stage 1: Get Tomcat libs (servlet, JSP, EL, annotations, websocket APIs)
FROM tomcat:10.1-jre17 AS tomcat-libs

# Stage 2: Builder with JDK 17 and plain javac/jar build
FROM eclipse-temurin:17-jdk AS builder

# Copy Tomcat API JARs for compilation classpath
COPY --from=tomcat-libs /usr/local/tomcat/lib /tomcat-lib

# Download PostgreSQL JDBC driver from Maven Central (pinned version)
RUN mkdir -p /jdbc && \
    curl -fsSL -o /jdbc/postgresql-42.7.10.jar \
    https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.10/postgresql-42.7.10.jar && \
    echo "PostgreSQL driver downloaded: $(ls -lh /jdbc/postgresql-42.7.10.jar)"

# Copy project files
WORKDIR /build
COPY . .

# Create WAR structure
RUN mkdir -p /war/WEB-INF/classes /war/WEB-INF/lib

# Copy web resources (JSPs, HTML, CSS, JS, etc.)
RUN cp -r web/* /war/

# Build classpath for compilation (Tomcat APIs + PostgreSQL driver)
RUN TOMCAT_CP=$(find /tomcat-lib -name 'servlet-api.jar' -o -name 'jsp-api.jar' -o -name 'el-api.jar' -o -name 'annotations-api.jar' -o -name 'websocket-api.jar' | tr '\n' ':') && \
    JDBC_CP="/jdbc/postgresql-42.7.10.jar" && \
    echo "Tomcat classpath: $TOMCAT_CP" && \
    echo "JDBC classpath: $JDBC_CP" && \
    FULL_CP="${TOMCAT_CP}${JDBC_CP}" && \
    echo "Full compile classpath: $FULL_CP" && \
    # Compile all Java files
    find src/java -name '*.java' > sources.txt && \
    echo "=== Compiling Java sources ===" && \
    cat sources.txt && \
    javac --release 17 \
          -encoding UTF-8 \
          -d /war/WEB-INF/classes \
          -cp "$FULL_CP" \
          @sources.txt && \
    echo "=== Compilation complete ===" && \
    # Copy any non-Java resources from src/java (properties files, etc.)
    find src/java -type f ! -name '*.java' ! -name '*.class' -exec cp --parents {} /war/WEB-INF/classes/ \; 2>/dev/null || true && \
    # Count compiled classes
    CLASS_COUNT=$(find /war/WEB-INF/classes -name '*.class' | wc -l) && \
    echo "=== Compiled $CLASS_COUNT class files ===" && \
    # Build the WAR file
    cd /war && jar -cf /ROOT.war . && \
    echo "=== WAR file created ===" && \
    # Verify WAR contents
    echo "=== Verifying WAR contents ===" && \
    jar tf /ROOT.war | grep -E "(WEB-INF/classes/com/paperwise|META-INF/context.xml)" > /verify.txt && \
    # Check that compiled classes exist
    if ! grep -q "WEB-INF/classes/com/paperwise" /verify.txt; then \
        echo "ERROR: No compiled classes found in WAR!" && \
        exit 1; \
    fi && \
    # Check that context.xml exists
    if ! grep -q "META-INF/context.xml" /verify.txt; then \
        echo "ERROR: context.xml missing from WAR!" && \
        exit 1; \
    fi && \
    echo "=== WAR verification complete ===" && \
    echo "Compiled classes: $(grep 'WEB-INF/classes/com/paperwise.*\.class$' /verify.txt | wc -l)"

# Stage 3: Runtime with Tomcat
FROM tomcat:10.1-jre17

# Remove default Tomcat webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy PostgreSQL driver to Tomcat's lib folder (for JNDI DataSource in context.xml)
COPY --from=builder /jdbc/postgresql-42.7.10.jar /usr/local/tomcat/lib/

# Verify PostgreSQL driver exists in Tomcat lib
RUN if [ ! -f /usr/local/tomcat/lib/postgresql-42.7.10.jar ]; then \
        echo "ERROR: PostgreSQL driver missing from Tomcat lib!" && \
        exit 1; \
    fi && \
    echo "PostgreSQL driver installed: $(ls -lh /usr/local/tomcat/lib/postgresql-42.7.10.jar)"

# Copy the WAR file from builder stage and deploy as ROOT
COPY --from=builder /ROOT.war /usr/local/tomcat/webapps/ROOT.war

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
