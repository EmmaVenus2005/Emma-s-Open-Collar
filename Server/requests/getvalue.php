<?php

// Handle getvalue request
      
// Ensure all parameters are present for 'getvalue'
$key = $msgParts[2] ?? null;
if ($key === null) { ErrBadReq(); }

// Prepare and execute SQL statement to retrieve the value
$stmt = $conn->prepare("SELECT `Value` FROM Parameter WHERE AppID = ? AND UserID = ? AND `Key` = ?");
$stmt->bind_param("sss", $appid, $uuid, $key);

if ($stmt->execute()) {
$result = $stmt->get_result();
$row = $result->fetch_assoc();
$value = $row['Value'] ?? "";
echo json_encode([
    "status" => "OK",
    "reqid" => $reqid,
    "message" => $value
]);
} else {
http_response_code(500);
echo json_encode([
    "status" => "error",
    "message" => "Error: " . $stmt->error
]);
}

$stmt->close();

?>
