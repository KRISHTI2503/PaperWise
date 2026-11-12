# Multi-stage build for PaperWise
# Stage 1: Build the WAR file with Ant
FROM tomcat:10.1-jre17 AS tomcat-libs

# Stage 2: Builder with JDK 17 and Tomcat classpath
FROM eclipse-temurin:17-jdk AS builder

# Set JAVA_HOME explicitly
ENV JAVA_HOME=/opt/java/openjdk

# Install Ant from Apache archive (avoid Java 25 from apt)
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget && \
    wget -q https://archive.apache.org/dist/ant/binaries/apache-ant-1.10.14-bin.tar.gz && \
    tar -xzf apache-ant-1.10.14-bin.tar.gz -C /opt && \
    rm apache-ant-1.10.14-bin.tar.gz && \
    rm -rf /var/lib/apt/lists/*

ENV ANT_HOME=/opt/apache-ant-1.10.14
ENV PATH="${ANT_HOME}/bin:${PATH}"

# Copy Tomcat from tomcat-libs stage to get servlet APIs
COPY --from=tomcat-libs /usr/local/tomcat /usr/local/tomcat
ENV TOMCAT_HOME=/usr/local/tomcat

# Copy project files
WORKDIR /build
COPY . .

# Build the classpath from Tomcat libs
ENV J2EE_PLATFORM_CLASSPATH="${TOMCAT_HOME}/lib/servlet-api.jar:${TOMCAT_HOME}/lib/jsp-api.jar:${TOMCAT_HOME}/lib/el-api.jar:${TOMCAT_HOME}/lib/annotations-api.jar:${TOMCAT_HOME}/lib/tomcat-api.jar:${TOMCAT_HOME}/lib/websocket-api.jar"

# Build the WAR file using Ant with all required properties
RUN ant \
    -Dj2ee.server.home=${TOMCAT_HOME} \
    -Dj2ee.platform.classpath=${J2EE_PLATFORM_CLASSPATH} \
    -Dlibs.CopyLibs.classpath=/build/lib/CopyLibs/org-netbeans-modules-java-j2seproject-copylibstask.jar \
    -Djavac.classpath=/build/lib/postgresql-42.7.10.jar:/build/web/WEB-INF/lib/jakarta.mail-2.0.1.jar:/build/web/WEB-INF/lib/gson-2.10.1.jar \
    clean war

# Verify WAR contents
RUN echo "=== Verifying WAR contents ===" && \
    jar tf /build/dist/PaperWise_AJT.war | grep -E "(WEB-INF/classes/com/paperwise|WEB-INF/lib/postgresql|META-INF/context.xml)" && \
    echo "=== WAR verification complete ==="

# Stage 3: Runtime with Tomcat
FROM tomcat:10.1-jre17

# Remove default Tomcat webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the WAR file from builder stage and deploy as ROOT
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
