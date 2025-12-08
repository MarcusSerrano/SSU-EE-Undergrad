<?php
// insert_sensor_data.php
header('Content-Type: application/json');

// 1. Database credentials
$DB_HOST = '156.67.74.201';
$DB_NAME = 'u335487609_assignment8';
$DB_USER = 'u335487609_assignment8usr';
$DB_PASS = 'Mi5//ZLN>M=';

// 2. Collect parameters (accept a couple of common name variants)
$nodeId      = $_GET['nodeId']      ?? null;
$arrivalTime = $_GET['arrivalTime'] ?? ($_GET['time'] ?? null);
$temp        = $_GET['Temp']        ?? ($_GET['temp'] ?? null);
$hum         = $_GET['Hum']         ?? ($_GET['hum']  ?? null);

// 3. Check required fields (assignment: no time -> reject)
$missing = [];
if (!$nodeId)        $missing[] = 'nodeId';
if (!$arrivalTime)   $missing[] = 'arrivalTime/time';
if ($temp === null)  $missing[] = 'Temp';
if ($hum === null)   $missing[] = 'Hum';

if (!empty($missing)) {
    http_response_code(400);
    echo json_encode([
        'status'  => 'error',
        'error'   => 'missing_fields',
        'message' => 'Missing required fields: ' . implode(', ', $missing)
    ]);
    exit;
}

// 4. Validate datetime format (YYYY-MM-DD HH:MM:SS)
$dt = DateTime::createFromFormat('Y-m-d H:i:s', $arrivalTime);
if (!$dt || $dt->format('Y-m-d H:i:s') !== $arrivalTime) {
    http_response_code(400);
    echo json_encode([
        'status'  => 'error',
        'error'   => 'invalid_time_format',
        'message' => 'arrivalTime must be in format YYYY-MM-DD HH:MM:SS'
    ]);
    exit;
}

// 5. Connect to DB
try {
    $dsn = "mysql:host=$DB_HOST;dbname=$DB_NAME;charset=utf8mb4";
    $pdo = new PDO($dsn, $DB_USER, $DB_PASS, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'status'  => 'error',
        'error'   => 'db_connection_failed'
    ]);
    exit;
}

// 6. Check that node is registered
try {
    $stmt = $pdo->prepare('SELECT 1 FROM nodes WHERE nodeId = ? LIMIT 1');
    $stmt->execute([$nodeId]);
    if (!$stmt->fetchColumn()) {
        http_response_code(403);
        echo json_encode([
            'status'  => 'error',
            'error'   => 'unregistered_node',
            'message' => 'This nodeId is not registered in the nodes table'
        ]);
        exit;
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'status'  => 'error',
        'error'   => 'node_check_failed'
    ]);
    exit;
}

// 7. Insert row into sensor_data
try {
    //  If your column names differ, change them here:
    $sql = 'INSERT INTO sensor_data (arrivalTime, nodeId, Temp, Hum)
            VALUES (:arrivalTime, :nodeId, :temp, :hum)';

    $stmt = $pdo->prepare($sql);
    $stmt->execute([
        ':arrivalTime' => $arrivalTime,
        ':nodeId'      => $nodeId,
        ':temp'        => $temp,
        ':hum'         => $hum
    ]);

    echo json_encode([
        'status'      => 'ok',
        'inserted_id' => $pdo->lastInsertId()
    ]);
} catch (PDOException $e) {
    // 23000 = integrity constraint violation (our unique key -> duplicate)
    if ($e->getCode() === '23000') {
        http_response_code(409);
        echo json_encode([
            'status'  => 'duplicate',
            'error'   => 'duplicate_reading',
            'message' => 'A reading for this node and arrivalTime already exists'
        ]);
    } else {
        http_response_code(500);
        echo json_encode([
            'status'  => 'error',
            'error'   => 'insert_failed'
        ]);
    }
}
