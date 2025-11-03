<?php
// Simple webpage to display Google Sheets charts
// Save this file as index.php and place it on your web server
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ESP Sensor Dashboard</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background: #fafafa;
      margin: 0;
      padding: 20px;
      text-align: center;
    }
    h1 {
      color: #333;
    }
    iframe {
      border: none;
      margin: 20px auto;
      display: block;
      max-width: 100%;
    }
    .chart-container {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 30px;
    }
  </style>
</head>
<body>
  <h1>ESP Sensor Dashboard</h1>

  <div class="chart-container">
    <!-- Chart 1 -->
    <iframe 
      width="600" height="371" 
      src="">
    </iframe>

    <!-- Chart 2 -->
    <iframe 
      width="600" height="215" 
      src="">
    </iframe>
  </div>
</body>
</html>
