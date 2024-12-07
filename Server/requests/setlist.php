<?php

// Handle setlist request

// Ensure all parameters are present for 'setlist'
$class = $msgParts[2] ?? null;
$listname = $msgParts[3] ?? null;
//$elements = $msgParts[4] ?? null;
if ($class === null || $listname === null || !isset($msgParts[4])) { 
    ErrBadReq(); 
}

//!!!
// Combine elements from $msgParts starting at index 4 with '|' delimiter
$elements = implode('|', array_slice($msgParts, 4));


// Insert or update entry in list table
$session = "DefaultSession";

$stmt = $conn->prepare("INSERT INTO List (Timestamp, AppID, UserID, UserName, SessionID, Class, Name, Elements) 
                        VALUES (NOW(), ?, ?, ?, ?, ?, ?, ?)
                        ON DUPLICATE KEY UPDATE Elements = VALUES(Elements)");
$stmt->bind_param("sssssss", $appid, $uuid, $name, $session, $class, $listname, $elements);

if ($stmt->execute()) {
    echo json_encode([
        "status" => "OK",
        "reqid" => $reqid,
        "message" => ""
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
