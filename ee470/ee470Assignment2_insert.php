<?php
// assignment2_insert.php
$servername = "localhost";
$username   = "u335487609_assignment2";
$password   = "6d4=xyF=";
$dbname     = "u335487609_assignment2";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) die("ERR_DB");

// Inputs
$node_id     = $_GET['node_id']     ?? '';
$time        = $_GET['time']        ?? '';
$temperature = $_GET['temperature'] ?? '';
$humidity    = $_GET['humidity']    ?? '';

// (a) Require time
if (trim($time) === '') { echo "ERR_NO_TIME"; exit; }

// (b) Reject duplicates (NULL-safe for blanks)
$dup = $conn->query("
  SELECT 1 FROM data
  WHERE node_id='$node_id' AND `time`='$time'
    AND COALESCE(temperature,'') = COALESCE(NULLIF('$temperature',''),'')
    AND COALESCE(humidity,'')    = COALESCE(NULLIF('$humidity',''),'')
  LIMIT 1
");
if ($dup && $dup->num_rows) { echo "ERR_DUP"; $conn->close(); exit; }

// Insert (store blanks as NULL so AVG ignores them)
$ok = $conn->query("
  INSERT INTO data (node_id, `time`, temperature, humidity)
  VALUES ('$node_id', '$time', NULLIF('$temperature',''), NULLIF('$humidity',''))
");

echo $ok ? "OK" : "ERR";

$conn->close();
?>
