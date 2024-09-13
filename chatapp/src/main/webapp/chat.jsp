<%@ page import="model.User" %>
<%@ page session="true" %>

<%
    // Check if user is logged in
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    User loggedInUser = (User) session.getAttribute("user");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chat - Social Media App</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-gray-100 min-h-screen flex flex-col">

    <!-- Chat Header -->
    <header class="bg-blue-600 text-white p-4">
        <h1 class="text-xl">Welcome, <%= loggedInUser.getUsername() %>!</h1>
        <a href="logout" class="text-white underline">Logout</a>
    </header>

    <!-- Chat Body -->
    <div class="flex-1 p-4 overflow-y-auto" id="chat-window">
        <!-- Chat messages will be dynamically added here -->
    </div>

    <!-- Chat Input -->
    <div class="bg-gray-200 p-4">
        <form id="chat-form">
            <input type="text" id="message-input" class="w-full p-2 border rounded" placeholder="Type a message...">
            <button type="submit" class="mt-2 bg-blue-500 text-white py-1 px-4 rounded">Send</button>
        </form>
    </div>

    <script>
        // Placeholder for WebSocket integration
        document.getElementById('chat-form').addEventListener('submit', function (e) {
            e.preventDefault();
            let message = document.getElementById('message-input').value;
            // You will handle sending message via WebSocket here
            console.log('Message sent:', message);
        });
    </script>

</body>
</html>
