<?php

// Handle getlists request

// Ensure the class parameter is present
$class = $msgParts[2] ?? null;
if ($class === null) {
    ErrBadReq();
}

// Prepare and execute the SQL statement to select all lists for the given class
$stmt = $conn->prepare("SELECT Name FROM List WHERE AppID = ? AND UserID = ? AND Class = ?");
$stmt->bind_param("sss", $appid, $uuid, $class);

if ($stmt->execute()) {
    $result = $stmt->get_result();

    // Collect the list names in an array to encode as JSON
    $listNames = [];
    while ($row = $result->fetch_assoc()) {
        $listNames[] = $row['Name'];
    }
    
    // Join the list names with a delimiter "|"
    $listString = implode("|", $listNames);
    
    // Return the list names as a JSON response
    echo json_encode([
        "status" => "OK",
        "reqid" => $reqid,
        "message" => $listString
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

