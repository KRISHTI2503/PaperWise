package com.paperwise.filter;

import com.paperwise.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebFilter(filterName = "AuthFilter", urlPatterns = {"/*"})
public class AuthFilter implements Filter {

    private static final Logger LOGGER = Logger.getLogger(AuthFilter.class.getName());

    private static final String ATTR_LOGGED_IN_USER = "loggedInUser";
    private static final String LOGIN_PAGE = "/login.jsp";
    private static final String LOGIN_SERVLET = "/login";
    private static final String REGISTER_PAGE = "/register.jsp";
    private static final String REGISTER_SERVLET = "/register";

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        LOGGER.log(Level.INFO, "AuthFilter initialized.");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();

        if (isPublicResource(requestURI, contextPath)) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = httpRequest.getSession(false);
        User loggedInUser = (session != null) ? (User) session.getAttribute(ATTR_LOGGED_IN_USER) : null;

        if (loggedInUser == null) {
            LOGGER.log(Level.FINE, "Unauthenticated access attempt to: {0}", requestURI);
            httpResponse.sendRedirect(contextPath + LOGIN_PAGE);
        } else {
            if (isAdminOnlyResource(requestURI, contextPath)) {
                if (!"admin".equalsIgnoreCase(loggedInUser.getRole())) {
                    LOGGER.log(Level.WARNING,
                            "Non-admin user ''{0}'' attempted to access admin resource: {1}",
                            new Object[]{loggedInUser.getUsername(), requestURI});
                    httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN,
                            "Access denied. Administrator privileges required.");
                    return;
                }
            }

            if (isStudentOnlyResource(requestURI, contextPath)) {
                if (!"student".equalsIgnoreCase(loggedInUser.getRole())) {
                    LOGGER.log(Level.WARNING,
                            "Non-student user ''{0}'' (role={1}) attempted to access student resource: {2}",
                            new Object[]{loggedInUser.getUsername(), loggedInUser.getRole(), requestURI});
                    httpResponse.sendRedirect(contextPath + LOGIN_PAGE);
                    return;
                }
            }

            chain.doFilter(request, response);
        }
    }

    @Override
    public void destroy() {
        LOGGER.log(Level.INFO, "AuthFilter destroyed.");
    }

    private boolean isPublicResource(String requestURI, String contextPath) {
        String path = requestURI.substring(contextPath.length());

        return path.equals(LOGIN_PAGE)
                || path.equals(LOGIN_SERVLET)
                || path.equals(REGISTER_PAGE)
                || path.equals(REGISTER_SERVLET)
                || path.equals("/forgotPassword")
                || path.equals("/forgotPassword.jsp")
                || path.equals("/logout")
                || path.equals("/")
                || path.equals("/index.html")
                || path.equals("/error404.jsp")
                || path.equals("/error500.jsp")
                || path.startsWith("/css/")
                || path.startsWith("/js/")
                || path.startsWith("/images/")
                || path.startsWith("/static/")
                || path.startsWith("/resources/")
                || path.startsWith("/assets/");
    }

    private boolean isAdminOnlyResource(String requestURI, String contextPath) {
        String path = requestURI.substring(contextPath.length());

        return path.equals("/upload.jsp")
                || path.equals("/uploadPaper")
                || path.equals("/adminDashboard")
                || path.equals("/allPapers")
                || path.equals("/students")
                || path.equals("/adminRequests")
                || path.equals("/updateRequest")
                || path.equals("/editPaper")
                || path.equals("/editPaper.jsp")
                || path.equals("/deletePaper")
                || path.startsWith("/admin-");
    }

    private boolean isStudentOnlyResource(String requestURI, String contextPath) {
        String path = requestURI.substring(contextPath.length());
        return path.startsWith("/student/") || path.equals("/studentDashboard");
    }
}