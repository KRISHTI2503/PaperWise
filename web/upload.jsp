<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.paperwise.model.User" %>
<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null || !"admin".equalsIgnoreCase(loggedInUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload Paper - PaperWise</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            max-width: 800px;
            margin: 0 auto;
        }

        .upload-card {
            background: white;
            border-radius: 16px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            padding: 40px;
            animation: slideUp 0.5s ease-out;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .header {
            margin-bottom: 32px;
        }

        .header h1 {
            font-size: 28px;
            color: #1a202c;
            font-weight: 700;
            margin-bottom: 8px;
        }

        .header p {
            color: #718096;
            font-size: 14px;
        }

        .error-message {
            background: #fee;
            border-left: 4px solid #e53e3e;
            color: #c53030;
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 24px;
            font-size: 14px;
            display: flex;
            align-items: center;
        }

        .form-group {
            margin-bottom: 24px;
        }

        .form-group label {
            display: block;
            color: #2d3748;
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 8px;
        }

        .form-group label .required {
            color: #e53e3e;
            margin-left: 2px;
        }

        .form-group input[type="text"],
        .form-group input[type="number"] {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e2e8f0;
            border-radius: 8px;
            font-size: 15px;
            color: #2d3748;
            transition: all 0.3s ease;
            background: #f7fafc;
        }

        .form-group input:focus {
            outline: none;
            border-color: #667eea;
            background: white;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .file-upload-wrapper {
            position: relative;
            overflow: hidden;
            display: inline-block;
            width: 100%;
        }

        .file-upload-input {
            position: absolute;
            left: -9999px;
        }

        .file-upload-label {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 20px;
            border: 2px dashed #cbd5e0;
            border-radius: 8px;
            background: #f7fafc;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .file-upload-label:hover {
            border-color: #667eea;
            background: #edf2f7;
        }

        .file-upload-label.has-file {
            border-color: #48bb78;
            background: #f0fff4;
        }

        .file-upload-icon {
            font-size: 48px;
            margin-bottom: 12px;
        }

        .file-upload-text {
            text-align: center;
        }

        .file-upload-text .main {
            color: #2d3748;
            font-weight: 600;
            margin-bottom: 4px;
        }

        .file-upload-text .sub {
            color: #718096;
            font-size: 13px;
        }

        .file-name-display {
            margin-top: 12px;
            padding: 8px 12px;
            background: #edf2f7;
            border-radius: 6px;
            font-size: 14px;
            color: #2d3748;
            display: none;
        }

        .file-name-display.show {
            display: block;
        }

        .button-group {
            display: flex;
            gap: 12px;
            margin-top: 32px;
        }

        .upload-button {
            flex: 1;
            padding: 14px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
        }

        .upload-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.5);
        }

        .upload-button:active {
            transform: translateY(0);
        }

        .cancel-button {
            flex: 1;
            padding: 14px;
            background: #e2e8f0;
            color: #2d3748;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            text-align: center;
            display: inline-block;
        }

        .cancel-button:hover {
            background: #cbd5e0;
        }

        .info-box {
            background: #ebf8ff;
            border-left: 4px solid #4299e1;
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 24px;
            font-size: 14px;
            color: #2c5282;
        }

        @media (max-width: 768px) {
            .upload-card {
                padding: 24px;
            }

            .button-group {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="upload-card">
            <div class="header">
                <h1>Upload Paper</h1>
                <p>Upload academic papers for students to access</p>
            </div>

            <% 
                String errorMessage = (String) request.getAttribute("errorMessage");
                if (errorMessage != null) {
            %>
                <div class="error-message">
                    <%= errorMessage %>
                </div>
            <% } %>

            <div class="info-box">
                Allowed file types: PDF, DOC, DOCX, PPT, PPTX, TXT, JPG, PNG, MP4, MKV (Max: 200MB)
            </div>

            <form action="${pageContext.request.contextPath}/uploadPaper" 
                  method="post" 
                  enctype="multipart/form-data"
                  onsubmit="return validateForm()">
                
                <div class="form-group">
                    <label for="subjectName">
                        Subject Name<span class="required">*</span>
                    </label>
                    <input 
                        type="text" 
                        id="subjectName" 
                        name="subjectName" 
                        placeholder="e.g., Data Structures and Algorithms"
                        value="<%= request.getParameter("subjectName") != null ? request.getParameter("subjectName") : "" %>"
                        required 
                        maxlength="150"
                    />
                </div>

                <div class="form-group">
                    <label for="subjectCode">
                        Subject Code<span class="required">*</span>
                    </label>
                    <input 
                        type="text" 
                        id="subjectCode" 
                        name="subjectCode" 
                        placeholder="e.g., CS101, MATH201"
                        value="<%= request.getParameter("subjectCode") != null ? request.getParameter("subjectCode") : "" %>"
                        required 
                        maxlength="50"
                    />
                </div>

                <div class="form-group">
                    <label for="year">
                        Year<span class="required">*</span>
                    </label>
                    <% 
                        int currentYear = java.time.Year.now().getValue();
                        int minYear = currentYear - 20;
                    %>
                    <input 
                        type="number" 
                        id="year" 
                        name="year" 
                        placeholder="e.g., <%= currentYear %>"
                        value="<%= request.getParameter("year") != null ? request.getParameter("year") : "" %>"
                        required 
                        min="<%= minYear %>" 
                        max="<%= currentYear %>"
                        title="Year must be between <%= minYear %> and <%= currentYear %>"
                    />
                    <small class="form-text text-muted">
                        Valid range: <%= minYear %> - <%= currentYear %>
                    </small>
                </div>

                <div class="form-group">
                    <label for="chapter">
                        Chapter (Optional)
                    </label>
                    <input 
                        type="text" 
                        id="chapter" 
                        name="chapter" 
                        placeholder="e.g., Chapter 5: Trees and Graphs"
                        value="<%= request.getParameter("chapter") != null ? request.getParameter("chapter") : "" %>"
                        maxlength="100"
                    />
                </div>

                <div class="form-group">
                    <label for="file">
                        Upload File<span class="required">*</span>
                    </label>
                    <div class="file-upload-wrapper">
                        <input 
                            type="file" 
                            id="file" 
                            name="file" 
                            class="file-upload-input"
                            accept=".pdf,.doc,.docx,.ppt,.pptx,.txt,.jpg,.jpeg,.png,.mp4,.mkv"
                            required
                            onchange="handleFileSelect(this)"
                        />
                        <label for="file" class="file-upload-label" id="fileLabel">
                            <div class="file-upload-text">
                                <div class="file-upload-icon"></div>
                                <div class="main">Click to select a file</div>
                                <div class="sub">or drag and drop here</div>
                            </div>
                        </label>
                    </div>
                    <div class="file-name-display" id="fileNameDisplay"></div>
                </div>

                <div class="button-group">
                    <button type="submit" class="upload-button">
                        Upload Paper
                    </button>
                    <a href="${pageContext.request.contextPath}/adminDashboard" class="cancel-button">
                        Cancel
                    </a>
                </div>
            </form>
        </div>
    </div>

    <script>
        function handleFileSelect(input) {
            const fileLabel = document.getElementById('fileLabel');
            const fileNameDisplay = document.getElementById('fileNameDisplay');
            
            if (input.files && input.files[0]) {
                const file = input.files[0];
                const fileName = file.name;
                const fileSize = (file.size / 1024 / 1024).toFixed(2);
                
                fileLabel.classList.add('has-file');
                fileNameDisplay.textContent = `Selected: ${fileName} (${fileSize} MB)`;
                fileNameDisplay.classList.add('show');
            } else {
                fileLabel.classList.remove('has-file');
                fileNameDisplay.classList.remove('show');
            }
        }

        function validateForm() {
            const fileInput = document.getElementById('file');
            
            if (!fileInput.files || fileInput.files.length === 0) {
                alert('Please select a file to upload.');
                return false;
            }
            
            const file = fileInput.files[0];
            const maxSize = 200 * 1024 * 1024;
            
            if (file.size > maxSize) {
                alert('File size exceeds 200MB limit. Please select a smaller file.');
                return false;
            }
            
            const allowedExtensions = ['.pdf', '.doc', '.docx', '.ppt', '.pptx', '.txt', 
                                      '.jpg', '.jpeg', '.png', '.mp4', '.mkv'];
            const fileName = file.name.toLowerCase();
            const isValidExtension = allowedExtensions.some(ext => fileName.endsWith(ext));
            
            if (!isValidExtension) {
                alert('Invalid file type. Please upload PDF, DOC, DOCX, PPT, PPTX, TXT, JPG, PNG, MP4, or MKV files only.');
                return false;
            }
            
            return true;
        }

        if (window.history.replaceState) {
            window.history.replaceState(null, null, window.location.href);
        }
    </script>
</body>
</html>