<%@ page import="java.sql.Connection, java.sql.DriverManager, java.sql.ResultSet, java.sql.SQLException, java.sql.Statement" %>
<%@ page import="model.User" %>
<%@ page session="true" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    User loggedInUser = (User) session.getAttribute("user");

    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    List<User> userList = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/chat", "root", "root");
        String sql = "SELECT * FROM users";
        stmt = conn.createStatement();
        rs = stmt.executeQuery(sql);

        while (rs.next()) {
            int id = rs.getInt("id");
            String username = rs.getString("username");
            String email = rs.getString("email");
            String passwordHash = rs.getString("password");

            User user = new User(id, username, email, passwordHash);
            userList.add(user);
        }

        out.println("<p>Number of users retrieved: " + userList.size() + "</p>");

    } catch (ClassNotFoundException | SQLException e) {
        e.printStackTrace();
        out.println("<p>Error: " + e.getMessage() + "</p>");
    } finally {
        if (rs != null) {
            try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
        if (stmt != null) {
            try { stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
        if (conn != null) {
            try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
%><!DOCTYPE html>
  <html lang="en">
  <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Chat - Social Media App</title>
      <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
      <style>

          body {
              overflow: hidden;
          }
          .chat-window {
              scroll-behavior: smooth;
              height: calc(100vh - 10rem);
              overflow-y: auto;
              padding-bottom: 2rem;
          }
          .message {
              padding: 12px;
              border-radius: 12px;
              margin-bottom: 12px;
              font-size: 1rem;
              max-width: 60%;
              display: inline-block;
              word-wrap: break-word;
          }
          .message.sent {
              background-color: #4F46E5;
              color: white;
              align-self: flex-end;
          }
          .message.received {
              background-color: #e5e7eb;
              color: black;
              align-self: flex-start;
          }
          .user-card-container {
              width: 100%;
              max-width: 350px;
              height: calc(100vh - 4rem);
              overflow-y: auto;
              padding: 24px;
              background-color: #f9fafb;
              box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
          }
          .user-card {
              background: #ffffff;
              box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
              padding: 16px;
              border-radius: 12px;
              display: flex;
              align-items: center;
              gap: 16px;
              transition: transform 0.2s ease, box-shadow 0.2s ease;
          }
          .user-card:hover {
              transform: scale(1.05);
              box-shadow: 0 6px 10px rgba(0, 0, 0, 0.2);
          }
          .user-card h2 {
              margin: 0;
              font-size: 1.25rem;
              font-weight: 600;
          }
          .chat-input {
              position: sticky;
              bottom: 0;
              background-color: white;
              padding: 0.7rem;
              border-top: 1px solid #e5e7eb;
          }
          .chat-input input {
              font-size: 1rem;
              padding: 0.35rem;
              width: 100%;
              border: 1px solid #d1d5db;
              outline: none;
              box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
          }
          .chat-input button {

              color: white;
              padding: 0.35rem 1.25rem;
              margin-left: 0.5rem;
              transition: background-color 0.2s ease;
          }
          .chat-input button:hover {
              background-color: #3730a3;
          }
      </style>
  </head>

  <body class="bg-gray-200 flex flex-col">

  <!-- Chat Header -->
  <header class="bg-blue-700 text-white p-4 pl-6 pr-6 shadow-md flex justify-between items-center fixed top-0 w-full z-10">
      <h1 class="text-xl font-semibold">Welcome, <%= loggedInUser.getUsername() %>!</h1>
      <a href="logout" class="text-white hover:text-gray-300 transition-colors duration-200">Logout</a>
  </header>

  <div class="flex h-screen pt-10">
      <!-- User List -->
      <aside class="bg-white w-1/4 border-r border-gray-300 user-card-container">
          <h1 class="text-2xl font-bold mb-5 text-center">Users</h1>
          <div class="flex flex-col space-y-4">
              <%
                  for (User user : userList) {
                      int user_id = user.getId();
                      String username = user.getUsername();
              %>
              <div class="user-card hover:bg-blue-100 transition-colors cursor-pointer">
                  <div class="w-12 h-12 bg-gray-200 rounded-full flex justify-center items-center text-gray-700 font-bold text-xl">
                      <%= String.valueOf(username.charAt(0)).toUpperCase() %>
                  </div>
                  <h2 class="text-lg truncate"><%= username %></h2>
              </div>
              <%
                  }
              %>
          </div>
      </aside>

      <!-- Chat Section -->
      <div class="flex-1 flex flex-col">

          <!-- Chat Body -->
          <div id="chat-window" class="flex-1 p-4 chat-window bg-gray-200 space-y-4 border-l border-gray-300">
              <!-- Default placeholder message -->
              <div id="default-message" class="flex flex-col items-center justify-center h-full text-center">
                  <h2 class="text-xl font-semibold text-gray-500">Select a conversation</h2>
                  <p class="text-gray-400">Please choose a user to start chatting</p>
              </div>

              <!-- Chat messages section, initially hidden -->
              <div id="chat-messages" class="hidden flex-col space-y-4">
                  <!-- Chat messages will be dynamically added here -->
                  <p class="text-gray-700">Chat messages go here...</p>
              </div>
          </div>

          <script>
              // Function to show chat messages when a user is selected
              function openChat() {
                  document.getElementById('default-message').classList.add('hidden');
                  document.getElementById('chat-messages').classList.remove('hidden');
              }

              // Example of triggering the function after clicking on a user
              // This should be tied to the actual user click event
              document.getElementById('some-user').addEventListener('click', openChat);
          </script>


          <!-- Chat Input (Sticky) -->
          <div class="chat-input">
              <form id="chat-form" class="flex w-full">
                  <input type="text" id="message-input" class="flex-1" placeholder="Type a message...">
                  <button class = "bg-blue-700" type="submit">Send</button>
              </form>
          </div>
      </div>

  </div>

  <script>
      document.getElementById('chat-form').addEventListener('submit', function (e) {
          e.preventDefault();
          let message = document.getElementById('message-input').value;
          if (message.trim() === '') return; // Don't send empty messages
          // Handle sending message via WebSocket or AJAX here
          console.log('Message sent:', message);
          document.getElementById('message-input').value = '';
          scrollToBottom();
      });

      function scrollToBottom() {
          const chatWindow = document.querySelector('.chat-window');
          chatWindow.scrollTop = chatWindow.scrollHeight;
      }

      // Ensure chat window auto scrolls to bottom
      window.onload = function() {
          scrollToBottom();
      };
  </script>

  </body>
  </html>

