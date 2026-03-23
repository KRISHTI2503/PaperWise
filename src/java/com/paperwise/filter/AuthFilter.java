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
                || path.equals("/logout")
                || path.equals("/")
                || path.equals("/index.html")
                || path.startsWith("/css/")
                || path.startsWith("/js/")
                || path.startsWith("/images/")
                || path.startsWith("/static/");
    }

    private boolean isAdminOnlyResource(String requestURI, String contextPath) {
        String path = requestURI.substring(contextPath.length());

        return path.equals("/upload.jsp")
                || path.equals("/uploadPaper")
                || path.equals("/adminDashboard")
                || path.equals("/adminRequests")
                || path.equals("/editPaper")
                || path.equals("/editPaper.jsp")
                || path.equals("/deletePaper")
                || path.startsWith("/admin-");
    }
}