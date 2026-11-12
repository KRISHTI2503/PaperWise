#!/bin/bash
set -e

# PaperWise Docker Entrypoint
# Converts environment variables to Java system properties for Tomcat's ${...} substitution

echo "=== PaperWise Startup ==="
echo "Setting up Tomcat environment..."

# Function to clean environment variable values
# Strips leading/trailing whitespace, \r, \n, and one pair of surrounding quotes
clean_env_var() {
    local value="$1"
    
    # Strip leading/trailing whitespace, tabs, \r, \n
    value=$(echo "$value" | sed -e 's/^[[:space:]\r\n]*//' -e 's/[[:space:]\r\n]*$//')
    
    # Strip one pair of surrounding quotes (single or double)
    if [[ "$value" =~ ^\"(.*)\"$ ]] || [[ "$value" =~ ^\'(.*)\'$ ]]; then
        value="${BASH_REMATCH[1]}"
    fi
    
    echo "$value"
}

# Build CATALINA_OPTS with all required environment variables as system properties
# Tomcat's ${...} in context.xml reads Java system properties, NOT environment variables
CATALINA_OPTS="${CATALINA_OPTS:-}"

# Clean all environment variables
JDBC_URL_CLEAN=$(clean_env_var "${JDBC_URL:-}")
JDBC_USERNAME_CLEAN=$(clean_env_var "${JDBC_USERNAME:-}")
JDBC_PASSWORD_CLEAN=$(clean_env_var "${JDBC_PASSWORD:-}")
SUPABASE_URL_CLEAN=$(clean_env_var "${SUPABASE_URL:-}")
SUPABASE_KEY_CLEAN=$(clean_env_var "${SUPABASE_KEY:-}")
SUPABASE_BUCKET_CLEAN=$(clean_env_var "${SUPABASE_BUCKET:-}")
APP_ENV_CLEAN=$(clean_env_var "${APP_ENV:-}")

# Database configuration
if [ -n "$JDBC_URL_CLEAN" ]; then
    CATALINA_OPTS="$CATALINA_OPTS -DJDBC_URL=$(printf '%q' "$JDBC_URL_CLEAN")"
    echo "✓ JDBC_URL configured (length: ${#JDBC_URL_CLEAN})"
else
    echo "✗ WARNING: JDBC_URL not set"
fi

if [ -n "$JDBC_USERNAME_CLEAN" ]; then
    CATALINA_OPTS="$CATALINA_OPTS -DJDBC_USERNAME=$(printf '%q' "$JDBC_USERNAME_CLEAN")"
    echo "✓ JDBC_USERNAME configured (length: ${#JDBC_USERNAME_CLEAN})"
else
    echo "✗ WARNING: JDBC_USERNAME not set"
fi

# Check if password was modified by cleaning
JDBC_PASSWORD_ORIGINAL="${JDBC_PASSWORD:-}"
JDBC_PASSWORD_CHANGED="no"
if [ "$JDBC_PASSWORD_ORIGINAL" != "$JDBC_PASSWORD_CLEAN" ]; then
    JDBC_PASSWORD_CHANGED="yes"
fi

if [ -n "$JDBC_PASSWORD_CLEAN" ]; then
    CATALINA_OPTS="$CATALINA_OPTS -DJDBC_PASSWORD=$(printf '%q' "$JDBC_PASSWORD_CLEAN")"
    echo "✓ JDBC_PASSWORD configured (length: ${#JDBC_PASSWORD_CLEAN}, changed: $JDBC_PASSWORD_CHANGED)"
else
    echo "✗ WARNING: JDBC_PASSWORD not set"
fi

# Supabase Storage configuration
if [ -n "$SUPABASE_URL_CLEAN" ]; then
    CATALINA_OPTS="$CATALINA_OPTS -DSUPABASE_URL=$(printf '%q' "$SUPABASE_URL_CLEAN")"
    echo "✓ SUPABASE_URL configured (length: ${#SUPABASE_URL_CLEAN})"
else
    echo "✗ WARNING: SUPABASE_URL not set"
fi

if [ -n "$SUPABASE_KEY_CLEAN" ]; then
    CATALINA_OPTS="$CATALINA_OPTS -DSUPABASE_KEY=$(printf '%q' "$SUPABASE_KEY_CLEAN")"
    echo "✓ SUPABASE_KEY configured (length: ${#SUPABASE_KEY_CLEAN})"
else
    echo "✗ WARNING: SUPABASE_KEY not set"
fi

if [ -n "$SUPABASE_BUCKET_CLEAN" ]; then
    CATALINA_OPTS="$CATALINA_OPTS -DSUPABASE_BUCKET=$(printf '%q' "$SUPABASE_BUCKET_CLEAN")"
    echo "✓ SUPABASE_BUCKET configured (length: ${#SUPABASE_BUCKET_CLEAN})"
else
    echo "✗ WARNING: SUPABASE_BUCKET not set"
fi

# Application environment (production/local)
if [ -n "$APP_ENV_CLEAN" ]; then
    CATALINA_OPTS="$CATALINA_OPTS -DAPP_ENV=$(printf '%q' "$APP_ENV_CLEAN")"
    echo "✓ APP_ENV=$APP_ENV_CLEAN (length: ${#APP_ENV_CLEAN})"
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
