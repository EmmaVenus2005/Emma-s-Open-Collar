<?php

// Handle flowstart request

// At this point, $appid, $uuid, $name, $conn, and other necessary variables are already defined in the main script.

// Extract $flowName and $session from $msgParts
$flowName = $msgParts[2] ?? null;
$session = $msgParts[3] ?? null;

// What comes after the session becomes parameter for the flow (separated by |)
$flowParams = array_slice($msgParts, 4) ?: [];

if ($flowName === null || $session === null) {
    ErrBadReq();
}

// Sanitize the $flowName to prevent unauthorized file inclusions
if (!preg_match('/^[a-zA-Z0-9_]+$/', $flowName)) {
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Invalid FlowName"
    ]);
    exit();
}

// Define the path to the flow script
$flowPath = dirname(__DIR__) . '/flows/' . $appid;
$flowScript = $flowPath . '/' . $flowName . '.php';

// Check if the flow script exists
if (!file_exists($flowScript)) {
    http_response_code(404);
    echo json_encode([
        "status" => "error",
        "message" => "Flow not found : " . $flowScript
    ]);
    exit();
}

// Send positive response immediately
echo json_encode([
    "status" => "OK",
    "message" => "Flow started successfully",
    "app" => $appid,
    "flow" => $flowName,
    "session" => $session
]);

// Flush the output buffers to send the response now
if (function_exists('fastcgi_finish_request')) {
    // If using PHP-FPM, this will finish the request and allow the script to continue running
    fastcgi_finish_request();
} else {
    // For other environments
    ignore_user_abort(true); // Allow the script to continue even if the user aborts the request

    while (ob_get_level()) {
        ob_end_flush();
    }
    flush();
}

// Optionally, set unlimited execution time
set_time_limit(0);

// Get the directory path containing the PHP files
$functionsDir = dirname(__DIR__) . '/functions/';

// Ensure the directory exists
if (is_dir($functionsDir)) {
    // Scan the directory for PHP files
    foreach (glob($functionsDir . '*.php') as $filename) {
        // Include each PHP file
        require_once $filename;
    }
}

// Get the directory path containing the app-specific PHP files
$functionsDir = $flowPath . '/functions/';

// Ensure the directory exists
if (is_dir($functionsDir)) {
    // Scan the directory for PHP files
    foreach (glob($functionsDir . '*.php') as $filename) {
        // Include each PHP file
        require_once $filename;
    }
}

// Include the flow script
include_once $flowScript;

// Optionally, log the completion of the flow
//error_log("Flow '$flowName' for app '$appid' with session '$session' completed.");

?>

