#!/bin/bash
set -e

# PaperWise Docker Entrypoint
# Converts environment variables to Java system properties for Tomcat's ${...} substitution

echo "=== PaperWise Startup ==="
echo "Setting up Tomcat environment..."

# Build CATALINA_OPTS with all required environment variables as system properties
# Tomcat's ${...} in context.xml reads Java system properties, NOT environment variables
CATALINA_OPTS="${CATALINA_OPTS:-}"

# Database configuration
if [ -n "$JDBC_URL" ]; then
    CATALINA_OPTS="$CATALINA_OPTS -DJDBC_URL=$JDBC_URL"
    echo "✓ JDBC_URL configured"
else
    echo "✗ WARNING: JDBC_URL not set"
fi

if [ -n "$JDBC_USERNAME" ]; then
    CATALINA_OPTS="$CATALINA_OPTS -DJDBC_USERNAME=$JDBC_USERNAME"
    echo "✓ JDBC_USERNAME configured"
else
    echo "✗ WARNING: JDBC_USERNAME not set"
fi

if [ -n "$JDBC_PASSWORD" ]; then
    CATALINA_OPTS="$CATALINA_OPTS -DJDBC_PASSWORD=***"
    echo "✓ JDBC_PASSWORD configured (hidden)"
else
    echo "✗ WARNING: JDBC_PASSWORD not set"
fi

# Supabase Storage configuration
if [ -n "$SUPABASE_URL" ]; then
    CATALINA_OPTS="$CATALINA_OPTS -DSUPABASE_URL=$SUPABASE_URL"
    echo "✓ SUPABASE_URL configured"
else
    echo "✗ WARNING: SUPABASE_URL not set"
fi

if [ -n "$SUPABASE_KEY" ]; then
    CATALINA_OPTS="$CATALINA_OPTS -DSUPABASE_KEY=***"
    echo "✓ SUPABASE_KEY configured (hidden)"
else
    echo "✗ WARNING: SUPABASE_KEY not set"
fi

if [ -n "$SUPABASE_BUCKET" ]; then
    CATALINA_OPTS="$CATALINA_OPTS -DSUPABASE_BUCKET=$SUPABASE_BUCKET"
    echo "✓ SUPABASE_BUCKET configured"
else
    echo "✗ WARNING: SUPABASE_BUCKET not set"
fi

# Application environment (production/local)
if [ -n "$APP_ENV" ]; then
    CATALINA_OPTS="$CATALINA_OPTS -DAPP_ENV=$APP_ENV"
    echo "✓ APP_ENV=$APP_ENV"
else
    # Default to production in container
    CATALINA_OPTS="$CATALINA_OPTS -DAPP_ENV=production"
    echo "✓ APP_ENV=production (default)"
fi

# Render-specific: Use PORT environment variable if set
if [ -n "$PORT" ]; then
    CATALINA_OPTS="$CATALINA_OPTS -Dport.http=$PORT"
    echo "✓ HTTP Port: $PORT (Render)"
    
    # Update Tomcat server.xml to use PORT
    sed -i "s/port=\"8080\"/port=\"$PORT\"/g" /usr/local/tomcat/conf/server.xml
else
    echo "✓ HTTP Port: 8080 (default)"
fi

# Memory settings for Render free tier
CATALINA_OPTS="$CATALINA_OPTS -Xms256m -Xmx512m"

# Export CATALINA_OPTS for Tomcat
export CATALINA_OPTS

echo "=== Startup Complete ==="
echo "Starting Tomcat..."

# Execute the CMD (catalina.sh run)
exec "$@"
