<?php

// Function to retrieve a value from the Parameter table based on $appid, $uuid, and $valueName
function NVGetValue($valueName) {
    global $conn, $appid, $uuid, $name, $session;
    
    if (!isset($conn, $appid, $uuid, $name, $session)) {
        error_log("NVGetValue: Required variables are not set.");
        return false;
    }
    
    $stmt = $conn->prepare("SELECT `Value` FROM Parameter WHERE AppID = ? AND UserID = ? AND `Key` = ? LIMIT 1");
    if (!$stmt) {
        error_log("NVGetValue: Statement preparation failed: " . $conn->error);
        return null;
    }
    
    $stmt->bind_param("sss", $appid, $uuid, $valueName);
    
    if (!$stmt->execute()) {
        error_log("NVGetValue: Execution failed: " . $stmt->error);
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
        error_log("NVSetValue: Required variables are not set.");
        return false;
    }
    
    $stmt = $conn->prepare("INSERT INTO Parameter (AppID, UserID, UserName, SessionID, `Key`, `Value`)
                            VALUES (?, ?, ?, 'DefaultSession', ?, ?)
                            ON DUPLICATE KEY UPDATE `Value` = VALUES(`Value`)");
    if (!$stmt) {
        error_log("NVSetValue: Statement preparation failed: " . $conn->error);
        return false;
    }
    
    $stmt->bind_param("sssss", $appid, $uuid, $name, $valueName, $value);
    
    if (!$stmt->execute()) {
        error_log("NVSetValue: Execution failed: " . $stmt->error);
        $stmt->close();
        return false;
    }
    
    $stmt->close();
    return true;
}

// Function to retrieve elements from a list in the List table based on $appid, $uuid, $listClass and $listName
function NVGetList($listClass, $listName) {
    global $conn, $appid, $uuid, $name, $session;
    
    if (!isset($conn, $appid, $uuid, $name, $session)) {
        error_log("NVGetList: Required variables are not set.");
        return false;
    }
	
	$stmt = $conn->prepare("SELECT Elements FROM List WHERE AppID = ? AND UserID = ? AND Class = ? AND Name = ?");
	
	if (!$stmt) {
        error_log("NVGetList: Statement preparation failed: " . $conn->error);
        return false;
    	}
    	
	$stmt->bind_param("ssss", $appid, $uuid, $listClass, $listName);

	if (!$stmt->execute()) {
		error_log("NVGetList: Execution failed: " . $stmt->error);
		$stmt->close();
        	return false;    
    	}
    	
    	$stmt->bind_result($value);
	$result = $stmt->fetch();
	$stmt->close();
	    
	if ($result) {
		return $value; //explode($delimiter, $value);
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

// Function that allows to update a list
function NVSetList($listClass, $listName, $listElements) {
    global $conn, $appid, $uuid, $name, $session;
    
    if (!isset($conn, $appid, $uuid, $name, $session)) {
        error_log("NVSetList: Required variables are not set.");
        return false;
    }

    $stmt = $conn->prepare("INSERT INTO List (Timestamp, AppID, UserID, UserName, SessionID, Class, Name, Elements) 
                        VALUES (NOW(), ?, ?, ?, 'DefaultSession', ?, ?, ?)
                        ON DUPLICATE KEY UPDATE Elements = VALUES(Elements)");
    $stmt->bind_param("ssssss", $appid, $uuid, $name, $listClass, $listName, $listElements);

    if (!$stmt->execute()) {
        error_log("NVSetList: Execution failed: " . $stmt->error);
        $stmt->close();
        return false;
    }
    
    $stmt->close();
    return true;

}

// Function to delete a specific list based on $listClass and $listName
function NVDelList($listClass, $listName) {
    global $conn, $appid, $uuid, $name, $session;

    if (!isset($conn, $appid, $uuid, $name, $session)) {
        error_log("NVDelList: Required variables are not set.");
        return false;
    }

    $stmt = $conn->prepare("DELETE FROM List WHERE AppID = ? AND UserID = ? AND Class = ? AND Name = ?");
    if (!$stmt) {
        error_log("NVDelList: Statement preparation failed: " . $conn->error);
        return false;
    }

    $stmt->bind_param("ssss", $appid, $uuid, $listClass, $listName);

    if (!$stmt->execute()) {
        error_log("NVDelList: Execution failed: " . $stmt->error);
        $stmt->close();
        return false;
    }

    $stmt->close();
    return true;
}

// Function to delete all lists of a given class
function NVDelLists($listClass) {
    global $conn, $appid, $uuid, $name, $session;

    if (!isset($conn, $appid, $uuid, $name, $session)) {
        error_log("NVDelLists: Required variables are not set.");
        return false;
    }

    $stmt = $conn->prepare("DELETE FROM List WHERE AppID = ? AND UserID = ? AND Class = ?");
    if (!$stmt) {
        error_log("NVDelLists: Statement preparation failed: " . $conn->error);
        return false;
    }

    $stmt->bind_param("sss", $appid, $uuid, $listClass);

    if (!$stmt->execute()) {
        error_log("NVDelLists: Execution failed: " . $stmt->error);
        $stmt->close();
        return false;
    }

    $stmt->close();
    return true;
}

?>
