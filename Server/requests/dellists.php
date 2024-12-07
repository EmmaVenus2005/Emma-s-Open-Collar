<?php

// Handle dellists request

// Ensure the class parameter is present
$class = $msgParts[2] ?? null;
if ($class === null) {
    ErrBadReq();
}

// Prepare and execute the SQL statement to delete lists for the given class
$stmt = $conn->prepare("DELETE FROM List WHERE AppID = ? AND UserID = ? AND Class = ?");
$stmt->bind_param("sss", $appid, $uuid, $class);

if ($stmt->execute()) {

    // Check if any rows were affected
    if ($stmt->affected_rows > 0) {
        echo json_encode([
            "status" => "OK",
            "reqid" => $reqid,
            "message" => "Lists successfully deleted"
        ]);
    } else {
        echo json_encode([
            "status" => "OK",
            "reqid" => $reqid,
            "message" => "No lists found for deletion"
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

