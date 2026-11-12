package com.paperwise.util;

import javax.naming.Context;
import javax.naming.InitialContext;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Supabase Storage Service
 * 
 * Handles file upload, download, and deletion using Supabase Storage HTTP API.
 * Uses plain java.net.http (no external dependencies).
 * 
 * Configuration via JNDI environment variables:
 * - supabase/url: Your Supabase project URL (e.g., https://xxxxx.supabase.co)
 * - supabase/key: Your Supabase anon/service role key
 * - supabase/bucket: Storage bucket name (default: paperwise-uploads)
 */
public class SupabaseStorageService {

    private static final Logger LOGGER = Logger.getLogger(SupabaseStorageService.class.getName());
    
    private static String supabaseUrl;
    private static String supabaseKey;
    private static String bucketName;
    private static String appEnv;
    private static HttpClient httpClient;
    private static boolean initialized = false;

    /**
     * Initialize the service with configuration from JNDI context
     */
    public static synchronized void initialize() throws Exception {
        if (initialized) {
            return;
        }

        try {
            Context initCtx = new InitialContext();
            Context envCtx = (Context) initCtx.lookup("java:comp/env");

            supabaseUrl = (String) envCtx.lookup("supabase/url");
            supabaseKey = (String) envCtx.lookup("supabase/key");
            bucketName = (String) envCtx.lookup("supabase/bucket");
            
            // Get APP_ENV with fail-safe defaults
            try {
                appEnv = (String) envCtx.lookup("app/env");
            } catch (Exception e) {
                appEnv = null;
            }
            
            // Fail-safe logic for APP_ENV
            if (appEnv == null || appEnv.trim().isEmpty() || appEnv.contains("${")) {
                // Check if running in container (PORT env var is set by Render)
                String port = System.getenv("PORT");
                if (port != null && !port.isEmpty()) {
                    appEnv = "production";
                    LOGGER.log(Level.WARNING, 
                            "APP_ENV not properly configured (got: {0}), detected container environment, defaulting to production", 
                            appEnv);
                } else {
                    appEnv = "local";
                    LOGGER.log(Level.INFO, "APP_ENV not set, defaulting to local");
                }
            }

            // Check if values are placeholders (not resolved from environment)
            if (supabaseUrl != null && supabaseUrl.contains("${")) {
                throw new IllegalStateException("Supabase URL contains unresolved placeholder");
            }
            if (supabaseKey != null && supabaseKey.contains("${")) {
                throw new IllegalStateException("Supabase API key contains unresolved placeholder");
            }
            
            if (supabaseUrl == null || supabaseUrl.trim().isEmpty()) {
                throw new IllegalStateException("Supabase URL not configured");
            }
            if (supabaseKey == null || supabaseKey.trim().isEmpty()) {
                throw new IllegalStateException("Supabase API key not configured");
            }
            if (bucketName == null || bucketName.trim().isEmpty() || bucketName.contains("${")) {
                bucketName = "paperwise-uploads";
            }

            // Remove trailing slash from URL
            supabaseUrl = supabaseUrl.replaceAll("/+$", "");

            httpClient = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(30))
                    .build();

            initialized = true;
            LOGGER.log(Level.INFO, "Supabase Storage initialized. Environment: {0}, Bucket: {1}", 
                    new Object[]{appEnv, bucketName});

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to initialize Supabase Storage", e);
            throw e;
        }
    }
    
    /**
     * Check if running in production mode
     */
    public static boolean isProduction() {
        return "production".equalsIgnoreCase(appEnv);
    }

    /**
     * Upload a file to Supabase Storage
     * 
     * @param inputStream File content as InputStream
     * @param fileName Original file name
     * @param contentType MIME type (e.g., "application/pdf")
     * @return Unique file path in storage, or null on failure
     */
    public static String uploadFile(InputStream inputStream, String fileName, String contentType) 
            throws IOException {
        
        if (!initialized) {
            try {
                initialize();
            } catch (Exception e) {
                throw new IOException("Supabase Storage not initialized", e);
            }
        }

        // Generate unique file name: UUID-originalname
        String uniqueFileName = UUID.randomUUID().toString() + "-" + sanitizeFileName(fileName);
        String filePath = uniqueFileName;

        try {
            // Read file content into byte array
            byte[] fileContent = inputStream.readAllBytes();

            // Build upload URL
            String uploadUrl = String.format("%s/storage/v1/object/%s/%s",
                    supabaseUrl, bucketName, URLEncoder.encode(filePath, StandardCharsets.UTF_8));

            // Create HTTP request
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(uploadUrl))
                    .header("Authorization", "Bearer " + supabaseKey)
                    .header("apikey", supabaseKey)
                    .header("Content-Type", contentType != null ? contentType : "application/octet-stream")
                    .POST(HttpRequest.BodyPublishers.ofByteArray(fileContent))
                    .timeout(Duration.ofMinutes(5))
                    .build();

            // Send request
            HttpResponse<String> response = httpClient.send(request, 
                    HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 200 || response.statusCode() == 201) {
                LOGGER.log(Level.INFO, "File uploaded successfully: {0}", filePath);
                return filePath;
            } else {
                LOGGER.log(Level.SEVERE, "Upload failed. Status: {0}, Body: {1}",
                        new Object[]{response.statusCode(), response.body()});
                return null;
            }

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new IOException("Upload interrupted", e);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error uploading file to Supabase", e);
            throw new IOException("Upload failed", e);
        }
    }

    /**
     * Get public URL for a file
     * 
     * @param filePath File path in storage
     * @return Public URL to access the file
     */
    public static String getPublicUrl(String filePath) {
        if (!initialized) {
            try {
                initialize();
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Cannot get public URL - not initialized", e);
                return null;
            }
        }

        try {
            return String.format("%s/storage/v1/object/public/%s/%s",
                    supabaseUrl, bucketName, URLEncoder.encode(filePath, StandardCharsets.UTF_8));
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Error encoding file path", e);
            return null;
        }
    }

    /**
     * Get signed URL for private file access (valid for 1 hour)
     * 
     * @param filePath File path in storage
     * @param forDownload If true, includes download parameter for forced download
     * @return Signed URL with temporary access token
     */
    public static String getSignedUrl(String filePath, boolean forDownload) throws IOException {
        if (!initialized) {
            try {
                initialize();
            } catch (Exception e) {
                throw new IOException("Supabase Storage not initialized", e);
            }
        }

        try {
            // Create signed URL request (valid for 3600 seconds = 1 hour)
            String signedUrlEndpoint = String.format("%s/storage/v1/object/sign/%s/%s",
                    supabaseUrl, bucketName, URLEncoder.encode(filePath, StandardCharsets.UTF_8));

            // Add download parameter if requested
            String requestBody;
            String safeFileName = null;
            if (forDownload) {
                // Extract safe filename for download
                safeFileName = filePath.contains("/") 
                    ? filePath.substring(filePath.lastIndexOf("/") + 1) 
                    : filePath;
                // Remove UUID prefix if present (36 chars + hyphen)
                if (safeFileName.length() > 37 && safeFileName.charAt(36) == '-') {
                    safeFileName = safeFileName.substring(37);
                }
                requestBody = String.format("{\"expiresIn\": 3600, \"download\": \"%s\"}", 
                        safeFileName.replace("\"", "\\\""));
            } else {
                requestBody = "{\"expiresIn\": 3600}";
            }

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(signedUrlEndpoint))
                    .header("Authorization", "Bearer " + supabaseKey)
                    .header("apikey", supabaseKey)
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(requestBody))
                    .timeout(Duration.ofSeconds(30))
                    .build();

            HttpResponse<String> response = httpClient.send(request,
                    HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 200) {
                // Parse signedURL from response JSON
                String body = response.body();
                if (body.contains("\"signedURL\":\"")) {
                    String signedPath = body.split("\"signedURL\":\"")[1].split("\"")[0];
                    // Ensure the signed path includes the full URL with /storage/v1 prefix
                    String fullUrl = signedPath.startsWith("/storage/v1") 
                        ? supabaseUrl + signedPath 
                        : supabaseUrl + "/storage/v1" + signedPath;
                    
                    // NOTE: Testing needed - if Supabase doesn't honor the download parameter in the sign request,
                    // append ?download=<filename> to the URL as a fallback
                    // This requires testing against a real Supabase bucket to verify behavior
                    if (forDownload && safeFileName != null && !fullUrl.contains("download=")) {
                        String separator = fullUrl.contains("?") ? "&" : "?";
                        fullUrl = fullUrl + separator + "download=" + URLEncoder.encode(safeFileName, StandardCharsets.UTF_8);
                    }
                    
                    return fullUrl;
                } else {
                    LOGGER.log(Level.SEVERE, "Invalid signed URL response format: {0}", body);
                    throw new IOException("Failed to parse signed URL from response");
                }
            } else {
                String errorMsg = String.format("Failed to create signed URL. Status: %d, Body: %s",
                        response.statusCode(), response.body());
                LOGGER.log(Level.SEVERE, errorMsg);
                throw new IOException(errorMsg);
            }

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new IOException("Signed URL creation interrupted", e);
        } catch (IOException e) {
            throw e;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error creating signed URL", e);
            throw new IOException("Error creating signed URL: " + e.getMessage(), e);
        }
    }
    
    /**
     * Get signed URL for viewing (inline)
     */
    public static String getSignedUrl(String filePath) throws IOException {
        return getSignedUrl(filePath, false);
    }

    /**
     * Delete a file from Supabase Storage
     * 
     * @param filePath File path in storage
     * @return true if deleted successfully, false otherwise
     */
    public static boolean deleteFile(String filePath) {
        if (!initialized) {
            try {
                initialize();
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Cannot delete - not initialized", e);
                return false;
            }
        }

        try {
            String deleteUrl = String.format("%s/storage/v1/object/%s/%s",
                    supabaseUrl, bucketName, URLEncoder.encode(filePath, StandardCharsets.UTF_8));

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(deleteUrl))
                    .header("Authorization", "Bearer " + supabaseKey)
                    .header("apikey", supabaseKey)
                    .DELETE()
                    .timeout(Duration.ofSeconds(30))
                    .build();

            HttpResponse<String> response = httpClient.send(request,
                    HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 200 || response.statusCode() == 204) {
                LOGGER.log(Level.INFO, "File deleted successfully: {0}", filePath);
                return true;
            } else {
                LOGGER.log(Level.WARNING, "Delete failed. Status: {0}, Body: {1}",
                        new Object[]{response.statusCode(), response.body()});
                return false;
            }

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            LOGGER.log(Level.SEVERE, "Delete interrupted", e);
            return false;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error deleting file from Supabase", e);
            return false;
        }
    }

    /**
     * Check if the service is initialized
     */
    public static boolean isInitialized() {
        return initialized;
    }

    /**
     * Sanitize file name to remove dangerous characters
     */
    private static String sanitizeFileName(String fileName) {
        if (fileName == null || fileName.isEmpty()) {
            return "unnamed";
        }
        // Remove path separators and dangerous characters
        return fileName.replaceAll("[^a-zA-Z0-9._-]", "_");
    }
}
