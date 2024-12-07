<?php

// Function to retrieve a value from the Parameter table based on $appid, $uuid, and $valueName
function NVGetValue($valueName) {
    global $conn, $appid, $uuid, $name, $session;
    
    if (!isset($conn, $appid, $uuid, $name, $session)) {
        error_log("SetValue: Required variables are not set.");
        return false;
    }
    
    $stmt = $conn->prepare("SELECT `Value` FROM Parameter WHERE AppID = ? AND UserID = ? AND `Key` = ? LIMIT 1");
    if (!$stmt) {
        error_log("GetValue: Statement preparation failed: " . $conn->error);
        return null;
    }
    
    $stmt->bind_param("sss", $appid, $uuid, $valueName);
    
    if (!$stmt->execute()) {
        error_log("GetValue: Execution failed: " . $stmt->error);
        $stmt->close();
        return null;
    }
    
    $stmt->bind_result($value);
    $result = $stmt->fetch();
    $stmt->close();
    
    if ($result) {
        return $value;
    } else {
        // Value not found
        return null;
    }
}

// Function to set a value in the Parameter table based on $appid, $uuid, and $valueName
function NVSetValue($valueName, $value) {
    global $conn, $appid, $uuid, $name, $session;
    
    if (!isset($conn, $appid, $uuid, $name, $session)) {
        error_log("SetValue: Required variables are not set.");
        return false;
    }
    
    $stmt = $conn->prepare("INSERT INTO Parameter (AppID, UserID, UserName, SessionID, `Key`, `Value`)
                            VALUES (?, ?, ?, 'DefaultSession', ?, ?)
                            ON DUPLICATE KEY UPDATE `Value` = VALUES(`Value`)");
    if (!$stmt) {
        error_log("SetValue: Statement preparation failed: " . $conn->error);
        return false;
    }
    
    $stmt->bind_param("sssss", $appid, $uuid, $name, $valueName, $value);
    
    if (!$stmt->execute()) {
        error_log("SetValue: Execution failed: " . $stmt->error);
        $stmt->close();
        return false;
    }
    
    $stmt->close();
    return true;
}

// Function to retrieve elements from a list in the List table based on $appid, $uuid, $listClass and $listName
function NVGetList($listClass, $listName, $delimiter) {
    global $conn, $appid, $uuid, $name, $session;
    
    if (!isset($conn, $appid, $uuid, $name, $session)) {
        error_log("SetValue: Required variables are not set.");
        return false;
    }
	
	$stmt = $conn->prepare("SELECT Elements FROM List WHERE AppID = ? AND UserID = ? AND Class = ? AND Name = ?");
	
	if (!$stmt) {
        error_log("GetList: Statement preparation failed: " . $conn->error);
        return false;
    	}
    	
	$stmt->bind_param("ssss", $appid, $uuid, $listClass, $listName);

	if (!$stmt->execute()) {
		error_log("GetList: Execution failed: " . $stmt->error);
		$stmt->close();
        	return false;    
    	}
    	
    	$stmt->bind_result($value);
	$result = $stmt->fetch();
	$stmt->close();
	    
	if ($result) {
		return explode($delimiter, $value);
	} else {
		// Value not found
		return null;
	}

}

// Function to enumerate lists from List table based on $appid, $uuid, $listClass
function NVGetLists($listClass) {
    global $conn, $appid, $uuid, $name, $session;
    
    if (!isset($conn, $appid, $uuid, $name, $session)) {
        error_log("SetValue: Required variables are not set.");
        return false;
    }
	
	$stmt = $conn->prepare("SELECT Name FROM List WHERE AppID = ? AND UserID = ? AND Class = ?");
	
	if (!$stmt) {
        error_log("GetLists: Statement preparation failed: " . $conn->error);
        return false;
    	}
    	
	$stmt->bind_param("sss", $appid, $uuid, $listClass);

	if (!$stmt->execute()) {
		error_log("GetLists: Execution failed: " . $stmt->error);
		$stmt->close();
        	return false;    
    	}
    	
    	$result = $stmt->get_result();

        // Collect the list names in an array
        $listNames = [];
        while ($row = $result->fetch_assoc()) {
            $listNames[] = $row['Name'];
        }
    	
	$stmt->close();
	    
	if ($listNames) {
		return $listNames;
	} else {
		// Value not found
		return null;
	}

}

?>

