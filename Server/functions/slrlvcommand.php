<?php

function SLRLVCommand($rlv) 
{
    
    // Global session variables
    global $conn, $appid, $uuid, $name, $session;

    // Return false if $rlv is empty
    if (empty($rlv) || !is_array($rlv)) { return false; }

    // Remove the "@" at the beginning of each entry, if present
    $rlv = array_map(function ($entry) { return ltrim($entry, '@'); }, $rlv);

    // Retrieve FlowURL and FlowToken via NVGetValue
    $flowURL = NVGetValue('FlowURL');
	if (empty($flowURL)) {
		error_log("SLRLVCommand: Failed to retrieve FlowURL.");
		return null;
	}

	$flowToken = NVGetValue('FlowToken');
	if (empty($flowToken)) {
		error_log("SLRLVCommand: Failed to retrieve FlowToken.");
		return null;
	}

	// Prepare the command
    $command = 'rlv_command|' . $flowToken . "|" . implode("|", $rlv);
    
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
        error_log("SLRLVCommand: cURL error: " . curl_error($ch));
        curl_close($ch);
        return null;
    }

    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($httpCode !== 200) {
        // Non-200 HTTP response; interrupt the session
        error_log("SLRLVCommand: HTTP error code: $httpCode");
        return null;
    }

	// If message has been sent successfully, returns true
    return true;

}

?>
