#!/bin/bash
# Test script to verify environment variable injection in Docker
# This ensures no ${...} placeholders reach the Java code

echo "=== PaperWise Docker Environment Test ==="
echo "Building Docker image..."

# Build the image
docker build -t paperwise-test . || { echo "Build failed"; exit 1; }

echo ""
echo "=== Starting container with FAKE values to test placeholder substitution ==="
echo "All values are intentionally fake - we're testing that placeholders are resolved"
echo ""

# Start container with fake values
docker run --rm -d \
  --name paperwise-test \
  -p 8080:8080 \
  -e JDBC_URL="jdbc:postgresql://fake-host.test:5432/fakedb?sslmode=require" \
  -e JDBC_USERNAME="fake_user" \
  -e JDBC_PASSWORD="fake_password_12345" \
  -e SUPABASE_URL="https://fake-project.supabase.co" \
  -e SUPABASE_KEY="fake_supabase_key_abc123xyz" \
  -e SUPABASE_BUCKET="fake-bucket" \
  -e APP_ENV="production" \
  paperwise-test

echo "Container started. Waiting for Tomcat to initialize (15 seconds)..."
sleep 15

echo ""
echo "=== Checking container logs for placeholder resolution ==="
echo "Looking for evidence that environment variables were injected..."
echo ""

# Get logs
docker logs paperwise-test 2>&1 | grep -E "✓|✗|WARNING|configured"

echo ""
echo "=== Testing /health endpoint ==="
HEALTH_CHECK=$(curl -s http://localhost:8080/health)
if [ "$HEALTH_CHECK" = "OK" ]; then
    echo "✓ Health endpoint returned: $HEALTH_CHECK"
else
    echo "✗ Health endpoint failed or returned unexpected value: $HEALTH_CHECK"
fi

echo ""
echo "=== Checking Tomcat logs for unresolved placeholders ==="
echo "If you see '\${JDBC_URL}' or similar, the test FAILED"
echo ""

# Check if any ${...} made it into the logs (this would be BAD)
if docker logs paperwise-test 2>&1 | grep -q '\${'; then
    echo "✗ FAILURE: Found unresolved placeholder in logs:"
    docker logs paperwise-test 2>&1 | grep '\${'
else
    echo "✓ SUCCESS: No unresolved placeholders found"
fi

echo ""
echo "=== Checking for initialization errors ==="
if docker logs paperwise-test 2>&1 | grep -iE "error|exception" | grep -v "removeAbandoned" | head -5; then
    echo "Found errors (expected with fake credentials)"
else
    echo "No initialization errors found"
fi

echo ""
echo "=== Stopping test container ==="
docker stop paperwise-test

echo ""
echo "=== Test Complete ==="
echo "Review the output above to confirm:"
echo "1. All environment variables show '✓ configured'"
echo "2. No '\${...}' placeholders appear in logs"
echo "3. Health endpoint returns 'OK'"
echo ""
echo "Expected behavior: Connection errors are NORMAL with fake credentials"
echo "What we're testing: Placeholders are resolved BEFORE reaching Java code"
