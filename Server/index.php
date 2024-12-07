<?php

// Reading the config file that contains confidential data
$config = parse_ini_file(__DIR__ . '/config.ini', true);

// Allow requests from other domains (e.g., SL)
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

// Error functions
function ErrBadReq() {
    http_response_code(400);
    echo json_encode([
        "status" => "error", 
        "message" => "Bad request"
    ]);
    exit;
}

function ErrAuthFail() {
    http_response_code(403);
    echo json_encode([
        "status" => "error", 
        "message" => "Authentication failed"
    ]);
    exit;
}

function ErrDbConn($error) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Database connection failed",
        "error" => $error
    ]);
    exit;
}

// Get all headers from the request
$headers = getallheaders();  

// Log the incoming request
//$logData = date('Y-m-d H:i:s') . " - Request Data: " . json_encode($_REQUEST) . "\n";
//$logData .= "Headers: " . json_encode($headers) . "\n";
//file_put_contents('request_log.txt', $logData, FILE_APPEND);

// Checking if request ID available
$reqid = $_POST['reqid'] ?? null;
if ($reqid === null) { ErrBadReq(); };

// Checking request ID
$request = $_POST['request'] ?? null;
if ($request === null) { ErrBadReq(); };

// Retrieve UUID and hash from the request
$uuid = $headers['X-Secondlife-Owner-Key'] ?? null;
$reqcheck = $_POST['reqcheck'] ?? null;

if ($uuid === null || $reqcheck === null) {
    ErrBadReq();
}

// Retrieve the owner name
$name = $headers['X-Secondlife-Owner-Name'] ?? null;

// Checking the request validity
// This is NOT shared, but you can implement your own function to check the validity
// Use globals, dynamic parameters, secrets, all you want ^^
include 'secret.php';
if (!CheckValidity()) { ErrAuthFail(); }

// Database connection details
$servername = $config['database']['servername'];
$username = $config['database']['username'];
$password = $config['database']['password'];
$dbname = $config['database']['dbname'];

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    ErrDbConn($conn->connect_error);
}

// The message sent contains :
// appid|requesttype| ... other items that depend on the request type
// Splitting it into a table
$msgParts = explode('|', $request);

// Getting the app ID
$appid = $msgParts[0] ?? null;
if ($appid === null) { ErrBadReq(); }

// Getting the request type
$reqtype = $msgParts[1] ?? null;
if ($reqtype === null || !preg_match('/^[a-zA-Z0-9_]+$/', $reqtype)) { ErrBadReq(); }

// Define the path to the request file based on the request type
$requestFile = __DIR__ . "/requests/{$reqtype}.php";

// Check if the file exists before including it
if (file_exists($requestFile)) { include $requestFile; } else { ErrBadReq(); }

// Close the database connection
$conn->close();

?>
