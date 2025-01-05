<?php

function SLDialog($recipient, $prompt, $options) {
    global $conn, $appid, $uuid, $name, $session;

    // Validate parameters
    if (empty($prompt) || !is_string($prompt)) {
        error_log("SLDialog: Invalid prompt.");
        return null;
    }
    if (empty($options) || !is_array($options)) {
        error_log("SLDialog: Options must be a non-empty array.");
        return null;
    }
    if (empty($recipient) || !preg_match('/^[a-f0-9\-]{36}$/', $recipient)) {
        error_log("SLDialog: Invalid recipient UUID.");
        return null;
    }

    // Retrieve FlowURL and FlowToken via NVGetValue
    $flowURL = NVGetValue('FlowURL');
    if (empty($flowURL)) {
        error_log("SLDialog: Failed to retrieve FlowURL.");
        return null;
    }

    $flowToken = NVGetValue('FlowToken');
    if (empty($flowToken)) {
        error_log("SLDialog: Failed to retrieve FlowToken.");
        return null;
    }

    // Prepare the command
    $command = 'open_dialog';

    // Pagination management
    $maxButtons = 12; // Maximum number of buttons allowed by llDialog
    $reservedButtons = 3; // Buttons reserved for navigation (indices 0, 1, 2)
    $optionsPerPage = $maxButtons - $reservedButtons; // Number of options per page (9)
    $totalOptions = count($options);
    $totalPages = ceil($totalOptions / $optionsPerPage);

    // Initialize the current page
    $currentPage = 1;

    // Set the maximum execution time to 60 seconds
    set_time_limit(60);

    while (true) {
    
    	// Update the prompt with pagination info
        $promptWithPage = str_replace('<<PAGE>>', "[$currentPage / $totalPages]", $prompt);

        // Extract options for the current page
        $offset = ($currentPage - 1) * $optionsPerPage;
        $optionsForPage = array_slice($options, $offset, $optionsPerPage);

        // Prepare the buttons array with navigation controls at indices 0, 1, 2
        $buttons = [];

        // Indices 0 to 2: Navigation controls
        $buttons[0] = ($currentPage > 1) ? '◀' : ' ';
        $buttons[1] = 'BACK';
        $buttons[2] = ($currentPage < $totalPages) ? '▶' : ' ';

	// Reversing the list, so the first are display at the top
	$optionsForPage = array_reverse($optionsForPage, false);
	
	// Grouping options by 3
	$chunks = array_chunk($optionsForPage, 3);

	// Reverse each group
	foreach ($chunks as &$chunk) {
	    $chunk = array_reverse($chunk);
	    $buttons = array_merge($buttons, $chunk);
	}

        // Prepare the buttons string separated by commas
        $buttonsString = implode(',', $buttons);

        // Construct the data string
        $data = $command . '|' . $flowToken . '|' . $recipient . '|' . $promptWithPage . '|' . $buttonsString;
        error_log($data);

        // Send HTTPS POST request
        $ch = curl_init($flowURL);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
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
            error_log("SLDialog: cURL error: " . curl_error($ch));
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

        $selection = trim($response);

        // Handle navigation
        if ($selection === '◀') {
            $currentPage = max(1, $currentPage - 1);
            continue; // Loop to display the previous page
        } elseif ($selection === '▶') {
            $currentPage = min($totalPages, $currentPage + 1);
            continue; // Loop to display the next page
        } elseif ($selection === 'BACK') {
            // Handle the back action
            return 'BACK';
        } elseif (in_array($selection, $options)) {
            // User selected a valid option
            return $selection;
        } else {
            // Invalid selection or placeholder selected
            error_log("SLDialog: Invalid selection received.");
            return null;
        }
    }
}

?>

