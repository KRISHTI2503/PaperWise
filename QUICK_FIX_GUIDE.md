# Quick Fix Guide - JSP Compilation Error

## Problem
HTTP 500 ClassNotFoundException: org.apache.jsp.student_002ddashboard_jsp

## Solution (5 Steps)

### 1️⃣ Stop Tomcat
```
Right-click Tomcat → Stop
```

### 2️⃣ Delete Compiled JSP Cache
```powershell
Remove-Item "C:\apache-tomcat-10.1.x\work\Catalina\localhost\PaperWise_AJT" -Recurse -Force
```

### 3️⃣ Clean Project
```
Right-click project → Clean
```

### 4️⃣ Rebuild Project
```
Right-click project → Build
```

### 5️⃣ Restart Tomcat
```
Right-click Tomcat → Start
```

## Code Verification

### ✅ Vote Button (Already Fixed)
```jsp
<form action="${pageContext.request.contextPath}/markUseful" method="post" style="display:inline;">
    <input type="hidden" name="paperId" value="<%= paper.getPaperId() %>">
    <button type="submit" class="btn btn-small btn-vote">
        👍 Useful (<%= paper.getUsefulCount() %>)
    </button>
</form>
```

### ✅ Paper Model Getters (Already Present)
- `getPaperId()` ✓
- `getUsefulCount()` ✓
- `isAlreadyMarked()` ✓

### ✅ No Wrong References
- NO `${paper.id}` found ✓
- All use `paper.getPaperId()` ✓

## Expected Result
- ✅ Student dashboard loads
- ✅ No HTTP 500 error
- ✅ Vote buttons visible
- ✅ No ClassNotFoundException

## If Still Failing
1. Check Tomcat logs for specific error
2. Verify `web/student-dashboard.jsp` exists
3. Verify Paper.java compiled successfully
4. Clear browser cache
5. Try accessing: `http://localhost:8080/PaperWise_AJT/studentDashboard`
