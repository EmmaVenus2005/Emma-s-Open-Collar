<?php

// Handle getlist request

// Ensure the class and list name parameters are present
$class = $msgParts[2] ?? null;
$listname = $msgParts[3] ?? null;
if ($class === null || $listname === null) {
    ErrBadReq();
}

// Prepare and execute the SQL statement to select the list with the given class and name
$stmt = $conn->prepare("SELECT Elements FROM List WHERE AppID = ? AND UserID = ? AND Class = ? AND Name = ?");
$stmt->bind_param("ssss", $appid, $uuid, $class, $listname);

if ($stmt->execute()) {
    $result = $stmt->get_result();

    if ($row = $result->fetch_assoc()) {
        
        // Return the list elements as response
        echo json_encode([
            "status" => "OK",
            "reqid" => $reqid,
            "message" => $row['Elements']
        ]);
    } else {
        // No matching list found
        http_response_code(404);
        echo json_encode([
            "status" => "error",
            "message" => "List not found"
        ]);
    }
} else {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Error: " . $stmt->error
    ]);
}

$stmt->close();

?>

