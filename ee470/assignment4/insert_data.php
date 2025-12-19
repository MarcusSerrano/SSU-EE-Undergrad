<?php
// Hostinger creds
$servername = "";
$username   = "";
$password   = "";
$dbname     = "";

$conn = new mysqli($servername, $username, $password, $dbname);

// 1) Gather input: prefer Base64 if provided, else fall back to normal GET/POST
$in = [];
if (!empty($_REQUEST['b64'])) {
  $decoded = base64_decode($_REQUEST['b64']);      // e.g. "nodeId=node_3&nodeTemp=34&timeReceived=2022-10-01 10:25:01"
  parse_str($decoded, $in);                        // turns it into an array
}
if (!$in) {
  $in = $_REQUEST;                                 // allow plain GET/POST too
}

// 2) Normalize keys
$node_name     = $in['node_name']     ?? $in['nodeId']      ?? null;
$temperature   = $in['temperature']   ?? $in['nodeTemp']    ?? null;
$humidity      = $in['humidity']      ?? null;
$time_received = $in['time_received'] ?? $in['timeReceived'] ?? '';

// 3) Build INSERT
if (trim((string)$time_received) === '') {
  // no time provided → let DB default CURRENT_TIMESTAMP handle it
  $sql = "INSERT INTO sensor_data (node_name, temperature, humidity)
          VALUES ('$node_name', '$temperature', '$humidity')";
} else {
  // explicit time provided
  $sql = "INSERT INTO sensor_data (node_name, time_received, temperature, humidity)
          VALUES ('$node_name', '$time_received', '$temperature', '$humidity')";
}

// 4) Execute
echo $conn->query($sql) ? "OK" : ("Error: " . $conn->error);
$conn->close();