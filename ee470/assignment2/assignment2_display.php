<?php
// assignment2_display.php
$servername = "localhost";
$username   = "u335487609_assignment2";
$password   = "6d4=xyF=";
$dbname     = "u335487609_assignment2";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) die("DB connect failed");

// 1) Full data table (latest first)
$dataRes = $conn->query("SELECT * FROM data ORDER BY `time` DESC");
if (!$dataRes) { echo "Query failed"; $conn->close(); exit; }
$fields = $dataRes->fetch_fields();

// 2) Averages (computed live)
$avgRes = $conn->query("SELECT ROUND(AVG(temperature),2) AS avg_temp, ROUND(AVG(humidity),2) AS avg_humid FROM data");
$avgRow = $avgRes ? $avgRes->fetch_assoc() : ["avg_temp"=>"", "avg_humid"=>""];

// 3) Counts per node
$c1 = $conn->query("SELECT COUNT(*) AS c FROM data WHERE node_id='node_1'")->fetch_assoc()['c'] ?? 0;
$c2 = $conn->query("SELECT COUNT(*) AS c FROM data WHERE node_id='node_2'")->fetch_assoc()['c'] ?? 0;

// 4) Chart data (time ascending for cleaner plots)
$rows = $conn->query("SELECT node_id, `time`, temperature, humidity FROM data ORDER BY `time` ASC");
$tempData = [["Time","Temperature"]];
$humData  = [["Time","Humidity"]];
if ($rows) {
  while ($r = $rows->fetch_assoc()) {
    $t = $r['time']; // e.g. 2025-10-23T20:44:01.022813
    if ($r['node_id'] === 'node_1' && $r['temperature'] !== null && $r['temperature'] !== '')
      $tempData[] = [$t, (float)$r['temperature']];
    if ($r['node_id'] === 'node_2' && $r['humidity'] !== null && $r['humidity'] !== '')
      $humData[]  = [$t, (float)$r['humidity']];
  }
}
?>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Assignment 2 — Data Display</title>
</head>
<body>

<!-- ================= DATA TABLE ================= -->
<h3>Data</h3>
<table border="1" cellspacing="0" cellpadding="5">
  <tr>
    <?php foreach ($fields as $f) echo "<th>".htmlspecialchars($f->name)."</th>"; ?>
  </tr>
  <?php while ($row = $dataRes->fetch_assoc()): ?>
    <tr>
      <?php foreach ($row as $v) echo "<td>".htmlspecialchars((string)$v)."</td>"; ?>
    </tr>
  <?php endwhile; ?>
</table>

<!-- ================= AVERAGES ================= -->
<br>
<table border="1" cellspacing="0" cellpadding="5">
  <tr><th>Avg Temp (°C)</th><th>Avg Humidity (%)</th></tr>
  <tr>
    <td><?php echo htmlspecialchars((string)$avgRow['avg_temp']); ?></td>
    <td><?php echo htmlspecialchars((string)$avgRow['avg_humid']); ?></td>
  </tr>
</table>

<!-- ================= NODE COUNTS ================= -->
<br>
Entries recorded:<br>
Node 1 (Temperature): <?php echo (int)$c1; ?><br>
Node 2 (Humidity): <?php echo (int)$c2; ?><br>

<!-- ================= DROPDOWN + CHARTS ================= -->
<br><br>
<label for="nodeSelect"><b>Select Node:</b></label>
<select id="nodeSelect">
  <option value="node_1">node_1 (Temperature)</option>
  <option value="node_2">node_2 (Humidity)</option>
</select>

<div id="chart_temp" style="width:100%;height:300px;margin-top:20px;"></div>
<div id="chart_hum"  style="width:100%;height:300px;margin-top:20px;"></div>

<script src="https://www.gstatic.com/charts/loader.js"></script>
<script>
  // PHP → JS
  const tempData = <?php echo json_encode($tempData); ?>;
  const humData  = <?php echo json_encode($humData);  ?>;

  // Convert "YYYY-MM-DDTHH:MM:SS.mmmmmm" → Date (drop microseconds for browser parsing)
  function toDate(s){ return new Date((s.split('.')[0] || s).replace(' ', 'T')); }

  google.charts.load('current', {'packages':['corechart']});
  google.charts.setOnLoadCallback(initCharts);

  let tempChart, humChart, tTable, hTable;

  function initCharts() {
    // Build data tables
    tTable = new google.visualization.DataTable();
    tTable.addColumn('datetime','Time');
    tTable.addColumn('number','Temperature');
    for (let i=1;i<tempData.length;i++) tTable.addRow([toDate(tempData[i][0]), tempData[i][1]]);

    hTable = new google.visualization.DataTable();
    hTable.addColumn('datetime','Time');
    hTable.addColumn('number','Humidity');
    for (let i=1;i<humData.length;i++) hTable.addRow([toDate(humData[i][0]), humData[i][1]]);

    // Draw once
    tempChart = new google.visualization.LineChart(document.getElementById('chart_temp'));
    humChart  = new google.visualization.LineChart(document.getElementById('chart_hum'));
    tempChart.draw(tTable,{title:'Temperature', legend:'none'});
    humChart.draw(hTable,{title:'Humidity',    legend:'none'});

    // Show chart according to dropdown
    const select = document.getElementById('nodeSelect');
    select.addEventListener('change', () => toggleChart(select.value));
    toggleChart(select.value); // initial
  }

  function toggleChart(node) {
    document.getElementById('chart_temp').style.display = (node === 'node_1') ? 'block' : 'none';
    document.getElementById('chart_hum').style.display  = (node === 'node_2') ? 'block' : 'none';
  }
</script>

</body>
</html>
<?php $conn->close(); ?>
