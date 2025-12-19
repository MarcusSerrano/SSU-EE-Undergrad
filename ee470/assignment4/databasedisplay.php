<?php
$servername = "";
$username   = "";
$password   = "";
$dbname     = "";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}

function showTable($conn, $tableName) {
  $result = $conn->query("SELECT * FROM $tableName");
  if ($result && $result->num_rows > 0) {
    echo "<table border=1>";
    $fields = $result->fetch_fields();
    echo "<tr>";
    foreach ($fields as $f) echo "<th>{$f->name}</th>";
    echo "</tr>";
    while ($row = $result->fetch_assoc()) {
      echo "<tr>";
      foreach ($row as $v) echo "<td>".htmlspecialchars($v)."</td>";
      echo "</tr>";
    }
    echo "</table><br>";
  } else {
    echo "No data in $tableName<br>";
  }
}

// show both tables
showTable($conn, "sensor_register");
showTable($conn, "sensor_data");

// average temperature for Node 1
$sql = "SELECT AVG(temperature) AS avg_temp 
        FROM sensor_data 
        WHERE node_name = 'node_1'";
$result = $conn->query($sql);
$row = $result->fetch_assoc();
echo "Average temperature for Node 1: " . round($row['avg_temp'], 2) . "<br>";

// average humidity for Node 1
$sql = "SELECT AVG(humidity) AS avg_humidity 
        FROM sensor_data 
        WHERE node_name = 'node_1'";
$result = $conn->query($sql);
$row = $result->fetch_assoc();
echo "Average humidity for Node 1: " . round($row['avg_humidity'], 2);

?>

<?php
// fetch data for node_1
$res = $conn->query("SELECT time_received, temperature FROM sensor_data WHERE node_name='node_1' ORDER BY time_received ASC");
$labels = [];
$temps  = [];
while ($row = $res->fetch_assoc()) {
  $labels[] = $row['time_received'];
  $temps[]  = (float)$row['temperature'];
}
?>
<canvas id="chart" width="800" height="400"></canvas>
<script src="chart.umd.min.js"></script>
<script>
const labels = <?php echo json_encode($labels); ?>;
const temps  = <?php echo json_encode($temps); ?>;

new Chart(document.getElementById('chart'), {
  type: 'line',
  data: {
    labels,
datasets: [{ label: 'Sensor Node node_1', data: temps, borderColor: 'green' }]
  },
  options: {
    scales: {
      x: { title: { display: true, text: 'Time' } },
      y: { title: { display: true, text: 'Temperature' } }
    },
    plugins: { title: { display: true, text: 'Sensor Node node_1' } }
  }
});
</script>