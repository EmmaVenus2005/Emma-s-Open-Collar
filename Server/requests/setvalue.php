<?php

// Handle setvalue request

// Ensure that there are key/value pairs after index 2
$numParams = count($msgParts) - 2;
if ($numParams <= 0 || $numParams % 2 != 0) {
    // No key/value pairs provided or an odd number of parameters
    ErrBadReq();
}

$session = "DefaultSession";

// Prepare the SQL statement once
$stmt = $conn->prepare("INSERT INTO Parameter (AppID, UserID, UserName, SessionID, `Key`, `Value`) 
                        VALUES (?, ?, ?, ?, ?, ?) 
                        ON DUPLICATE KEY UPDATE `Value` = VALUES(`Value`)");

if (!$stmt) {
    // Handle preparation error
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Statement preparation failed: " . $conn->error
    ]);
    exit();
}

$success = true;

// Loop through the key/value pairs starting from index 2
for ($i = 2; $i < count($msgParts); $i += 2) {
    $key = $msgParts[$i];
    $value = $msgParts[$i + 1];

    // Bind parameters for each key/value pair
    $stmt->bind_param("ssssss", $appid, $uuid, $name, $session, $key, $value);

    // Execute the statement
    if (!$stmt->execute()) {
        $success = false;
        break; // Exit the loop if execution fails
    }
}

if ($success) {
    echo json_encode([
        "status" => "OK",
        "reqid" => $reqid,
        "message" => ""
    ]);
} else {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Execution error: " . $stmt->error
    ]);
}

$stmt->close();

?>

