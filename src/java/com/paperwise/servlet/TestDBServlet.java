package com.paperwise.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

@WebServlet("/testdb")
public class TestDBServlet extends HttpServlet {

    private static final String JNDI_DATASOURCE = "java:comp/env/jdbc/paperwise";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        out.println("<!DOCTYPE html>");
        out.println("<html>");
        out.println("<head>");
        out.println("<title>Database Connection Test</title>");
        out.println("<style>");
        out.println("body { font-family: Arial, sans-serif; margin: 40px; }");
        out.println(".success { color: green; }");
        out.println(".error { color: red; }");
        out.println(".info { background: #f0f0f0; padding: 10px; border-radius: 5px; }");
        out.println("</style>");
        out.println("</head>");
        out.println("<body>");
        out.println("<h1>PaperWise Database Connection Test</h1>");

        try {
            Context initContext = new InitialContext();
            DataSource dataSource = (DataSource) initContext.lookup(JNDI_DATASOURCE);

            out.println("<p class='success'>JNDI lookup successful: " + JNDI_DATASOURCE + "</p>");

            try (Connection conn = dataSource.getConnection()) {
                out.println("<p class='success'>Database connection established</p>");

                try (Statement stmt = conn.createStatement();
                     ResultSet rs = stmt.executeQuery("SELECT version()")) {

                    if (rs.next()) {
                        out.println("<div class='info'>");
                        out.println("<h3>PostgreSQL Version:</h3>");
                        out.println("<p>" + rs.getString(1) + "</p>");
                        out.println("</div>");
                    }
                }

                try (Statement stmt = conn.createStatement();
                     ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as user_count FROM users")) {

                    if (rs.next()) {
                        int userCount = rs.getInt("user_count");
                        out.println("<p class='success'>Users table accessible: " + userCount + " users found</p>");
                    }
                }

                out.println("<div class='info'>");
                out.println("<h3>Connection Details:</h3>");
                out.println("<p><strong>Database:</strong> " + conn.getCatalog() + "</p>");
                out.println("<p><strong>URL:</strong> " + conn.getMetaData().getURL() + "</p>");
                out.println("<p><strong>Driver:</strong> " + conn.getMetaData().getDriverName() + " " +
                           conn.getMetaData().getDriverVersion() + "</p>");
                out.println("<p><strong>User:</strong> " + conn.getMetaData().getUserName() + "</p>");
                out.println("</div>");

                out.println("<h2 class='success'>All tests passed!</h2>");
                out.println("<p>Database is properly configured and accessible.</p>");
            }

        } catch (Exception e) {
            out.println("<h2 class='error'>Database Connection Failed</h2>");
            out.println("<p class='error'><strong>Error:</strong> " + e.getMessage() + "</p>");
            out.println("<div class='info'>");
            out.println("<h3>Troubleshooting:</h3>");
            out.println("<ul>");
            out.println("<li>Verify PostgreSQL is running</li>");
            out.println("<li>Check postgresql-42.7.10.jar is in $CATALINA_HOME/lib/</li>");
            out.println("<li>Verify context.xml Resource configuration</li>");
            out.println("<li>Check database credentials in context.xml</li>");
            out.println("<li>Review Tomcat logs for detailed errors</li>");
            out.println("</ul>");
            out.println("</div>");
            out.println("<pre>");
            e.printStackTrace(out);
            out.println("</pre>");
        }

        out.println("<hr>");
        out.println("<p><a href='" + request.getContextPath() + "/login.jsp'>Go to Login</a></p>");
        out.println("</body>");
        out.println("</html>");
    }
}