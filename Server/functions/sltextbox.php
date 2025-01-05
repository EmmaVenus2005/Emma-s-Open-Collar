<?php

function SLTextBox($recipient, $prompt) {
    global $conn, $appid, $uuid, $name, $session;

    // Validate parameters
    if (empty($prompt) || !is_string($prompt)) {
        error_log("SLTextBox: Invalid prompt.");
        return null;
    }
    if (empty($recipient) || !preg_match('/^[a-f0-9\-]{36}$/', $recipient)) {
        error_log("SLTextBox: Invalid recipient UUID.");
        return null;
    }

    // Retrieve FlowURL and FlowToken via NVGetValue
    $flowURL = NVGetValue('FlowURL');
    if (empty($flowURL)) {
        error_log("SLTextBox: Failed to retrieve FlowURL.");
        return null;
    }

    $flowToken = NVGetValue('FlowToken');
    if (empty($flowToken)) {
        error_log("SLTextBox: Failed to retrieve FlowToken.");
        return null;
    }

    // Prepare the command
    $command = 'open_textbox|' . $flowToken . "|" . $recipient . "|" . $prompt;
    
    // Set the maximum execution time to 60 seconds
    set_time_limit(60);

    // Send HTTPS POST request
    $ch = curl_init($flowURL);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $command);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: text/plain; charset=UTF-8'
    ]);
    // Optionally, ignore SSL certificate verification (not recommended for production)
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
    // Set timeout to 60 seconds
    curl_setopt($ch, CURLOPT_TIMEOUT, 60);

    // Execute the request
    $response = curl_exec($ch);

    if ($response === false) {
        // Error during communication
        error_log("SLTextBox: cURL error: " . curl_error($ch));
        curl_close($ch);
        return null;
    }

    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($httpCode !== 200) {
        // Non-200 HTTP response; interrupt the session
        error_log("SLDialog: HTTP error code: $httpCode");
        return null;
    }

    return $response;

}

?>

