<?php
// === CHANGE THESE TO MATCH YOUR DATABASE ===
$DB_HOST     = "";
$DB_USER     = "";
$DB_PASS = "";
$DB_NAME     = "";
$TABLE = "mqtt_data";
// ==========================================

$conn = new mysqli($DB_HOST, $DB_USER, $DB_PASS, $DB_NAME);
if ($conn->connect_error) {
    die("DB connection failed: " . $conn->connect_error);
}

$sql = "SELECT ts, payload FROM $TABLE ORDER BY ts";
$result = $conn->query($sql);

$ts = [];
$payload = [];

if ($result) {
    while ($row = $result->fetch_assoc()) {
        $ts[] = $row["ts"];
        $payload[] = (float)$row["payload"];
    }
}

$conn->close();
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>MQTT Data Graph</title>
    <style>
        body { font-family: sans-serif; margin: 20px; }
        #chartContainer { max-width: 800px; margin: auto; }
    </style>
</head>
<body>
<h2>Payload vs Time</h2>
<div id="chartContainer">
    <canvas id="myChart"></canvas>
</div>

<!-- Chart.js from CDN -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
const labels = <?php echo json_encode($ts); ?>;
const dataPoints = <?php echo json_encode($payload, JSON_NUMERIC_CHECK); ?>;

const ctx = document.getElementById('myChart');

new Chart(ctx, {
    type: 'line',
    data: {
        labels: labels, // ts on x-axis
        datasets: [{
            label: 'Payload',
            data: dataPoints, // payload on y-axis
            borderWidth: 1,
            fill: false
        }]
    },
    options: {
        responsive: true,
        scales: {
            x: {
                title: { display: true, text: 'ts' }
            },
            y: {
                title: { display: true, text: 'payload' }
            }
        }
    }
});
</script>
</body>
</html>
