// SLFlowApp gateway script, by EmmaVenus2005 from Second Life
// 
// This script is meant to be a standart version of the gateway allowing external app running.
// The goal is not avoid any LSL code unless this script.

// Used to get the "nv_appid", "nv_url" and "nv_secret" from linkset (script has to be nomod in order to avoid it getting revealed)
string g_sLinksetPassword = "";

// Gateway version (float value)
float g_fGatewayVersion = 0.995;

// Global variables for server access
string g_sAppID;
string g_sURL;
string g_sSecretSalt;

// Used to store the UUID of URL request (used to release)
key g_kURLRequest;

// Used to store the request ID for NV Request (for uploading URL through nonvolatile.lsl)
// (to avoid handling a parrallel response that may not be for this script)
key g_kRequestID;

// Used to store the URL from the object
string g_sInURL;

// Used to determine if the URL has been successfully sent to the server
integer g_iInURLSent = 0;

// Last timestamp (Unix time) when a self-check ping was performed on the URL
float g_fLastURLSelfCheck = 0.0;

// Used to store the token that has to be valid in order to take the incoming message in account
string g_sToken;

// Used to store the open dialogs
// index 0 : UUID of the user for which dialog is
// index 1 : Key of the request
// index 2 : Channel
// index 3 : Channel listen handle
list g_lDialogs;

// Used for URL self-testing
key g_kSelfCheckRequestId;

// List of pending RLV requests
// Each entry is a stride of 2 elements: [command, requestID]
list g_lRLVRequests;

// Indicates if a RLV request is currently pending
// 1 = request in progress, 0 = no active request
integer g_iRLVRequestPending = 0;

// Timestamp (Unix time) when the current RLV request was sent
// Used for timeout detection
float g_fRLVRequestSentOn = 0.0;

// Number of retries already done for the current RLV request
// Reset to 0 when a new request starts
integer g_iRLVRetries = 0;

// First communication channel used for the RLV request
integer g_iRLVPrimaryChannel = 0;

// Second communication channel used for redundancy
integer g_iRLVSecondaryChannel = 0;

// Listen handle for the first channel
integer g_iRLVPrimaryListener = 0;

// Listen handle for the second channel
integer g_iRLVSecondaryListener = 0;

// Stores the first response received
// Used to compare with the second response to validate consistency
string g_sRLVLastResponse = "";

// Used to store the key of the pending permission request
key g_kPendingPermissionRequest = NULL_KEY;

// Internal funds counter (local balance)
integer g_iInternalFunds = 0;

// Global timer list: each stride is [key, datetime]
list g_lTimers = [];

// Funtion to sent a HTTP request
NVRequest(string sReqType, string sReqData)
{

    // Generate a unique menu ID for this request
    g_kRequestID = llGenerateKey();

    // Gets the date in following format : "2025-07-04T13:24"
    string l_sDatetime = llGetSubString(llGetTimestamp(), 0, 15);

    // Mixing together some stuff to get a unique hash
    string l_sHash = llSHA256String((string)llGetOwner() + g_sSecretSalt + l_sDatetime + (string)g_kRequestID);

    // Create the request body
    string requestBody = "reqid=" + (string)g_kRequestID + "&reqcheck=" + l_sHash + "&request=" + g_sAppID + "|" + sReqType + "|" + sReqData;

    // Debug
    //llOwnerSay("Received request body : " + requestBody);

    // Headers
    list l_lHeaders = [
        HTTP_METHOD, "POST", 
        HTTP_MIMETYPE, "application/x-www-form-urlencoded",
        HTTP_CUSTOM_HEADER, "X-AFGatewayVersion", (string)g_fGatewayVersion
        ];

    // Send the HTTP request
    llHTTPRequest(g_sURL, l_lHeaders, requestBody);

}

// Function used to renew the URL, to ensure a valid one exists for the flow
RenewURL()
{

    // Clearing the current inbound URL
    g_sInURL = "";

    // Setting to 0 until new URL is sent
    g_iInURLSent = 0;

    // Revoke the previous URL 
    llReleaseURL(g_kURLRequest);

    // Sending the HTTPS URL request
    g_kURLRequest = llRequestSecureURL();

}

// Function that generates a new channel for dialog response that is not already used
integer GetChannel()
{

    // Generates channel
    integer l_iChannel = llRound(llFrand(10000000)) + 100000; 
    
    // Checks if generated channel doesn't exist
    while (
        ~llListFindList(llList2ListStrided(g_lDialogs, 2, -1, 4), [l_iChannel])
        || l_iChannel == g_iRLVPrimaryChannel
        || l_iChannel == g_iRLVSecondaryChannel
    )
    {

        // In case, generates a new one
        l_iChannel = llRound(llFrand(10000000)) + 100000; 

    }
    
    // Returns the channel
    return l_iChannel;

}

// Adds or replaces a dialog entry in g_lDialogs
// Includes the UUID, request key, channel, and the listen handle
AddOrReplaceDialog(string userUUID, key requestKey, integer channel)
{
    
    // Create a listener for the channel
    integer handle = llListen(channel, "", NULL_KEY, ""); 
    
    // Iterate through the list in strides of 4
    integer i;
    for (i = 0; i < llGetListLength(g_lDialogs); i += 4) 
    {
        
        // Check if the UUID matches an existing entry
        if (llList2String(g_lDialogs, i) == userUUID)
        {
            
            // Remove the old listener
            integer oldHandle = llList2Integer(g_lDialogs, i + 3);
            llListenRemove(oldHandle);

            // Replace the existing dialog entry
            g_lDialogs = llListReplaceList(g_lDialogs, [userUUID, requestKey, channel, handle], i, i + 3);
            return;

        }

    }
    
    // Add a new dialog entry if no matching UUID was found
    g_lDialogs += [userUUID, requestKey, channel, handle];

}

// Manage the sending of RLV requests with double-channel validation
ExecuteRLVRequest()
{

    // Close previous listeners if they are still open
    if (g_iRLVPrimaryListener != 0)
    {
        llListenRemove(g_iRLVPrimaryListener);
    }
    if (g_iRLVSecondaryListener != 0)
    {
        llListenRemove(g_iRLVSecondaryListener);
    }

    // Reset RLV temporary variables
    g_iRLVPrimaryChannel = 0;
    g_iRLVSecondaryChannel = 0;
    g_iRLVPrimaryListener = 0;
    g_iRLVSecondaryListener = 0;
    g_sRLVLastResponse = "";

    // Check if there are still pending RLV requests
    if (llGetListLength(g_lRLVRequests) == 0)
    {
        
        // No more requests to process
        g_iRLVRequestPending = 0;

        // Reset retries as there is no more active request
        g_iRLVRetries = 0;

        // Nothing more to do in this function
        return;
        
    }

    // Retrieve the command and the associated request ID
    string l_sCommand = llList2String(g_lRLVRequests, 0);
    string l_sRequestID = llList2String(g_lRLVRequests, 1);

    // Increments retries counter
    g_iRLVRetries++;

    // Generate two different random channels
    g_iRLVPrimaryChannel = GetChannel();
    g_iRLVSecondaryChannel = GetChannel();

    // Open listeners on the two channels
    g_iRLVPrimaryListener = llListen(g_iRLVPrimaryChannel, "", llGetOwner(), "");
    g_iRLVSecondaryListener = llListen(g_iRLVSecondaryChannel, "", llGetOwner(), "");

    // Prepare the commands by replacing '#' with the respective channels
    string l_sPrimaryCommand = llInsertString(llDeleteSubString(l_sCommand, llSubStringIndex(l_sCommand, "#"), llSubStringIndex(l_sCommand, "#")), llSubStringIndex(l_sCommand, "#"), (string)g_iRLVPrimaryChannel);
    string l_sSecondaryCommand = llInsertString(llDeleteSubString(l_sCommand, llSubStringIndex(l_sCommand, "#"), llSubStringIndex(l_sCommand, "#")), llSubStringIndex(l_sCommand, "#"), (string)g_iRLVSecondaryChannel);

    // Send the commands
    llOwnerSay("@" + l_sPrimaryCommand);
    llOwnerSay("@" + l_sSecondaryCommand);

    // Update tracking variables
    g_fRLVRequestSentOn = llGetUnixTime();
    g_iRLVRequestPending = 1;
    
}

// Applies a texture or media block based on a JSON input
ApplyVisualBlock(string json)
{
    
    // Read core fields
    integer link    = (integer)llJsonGetValue(json, ["link"]);
    integer face    = (integer)llJsonGetValue(json, ["face"]);
    string  type    = llJsonGetValue(json, ["type"]);

    vector scale  = <(float)llJsonGetValue(json, ["scale", 0]),
                     (float)llJsonGetValue(json, ["scale", 1]), 0.0>;

    vector offset = <(float)llJsonGetValue(json, ["offset", 0]),
                     (float)llJsonGetValue(json, ["offset", 1]), 0.0>;

    float rot = (float)llJsonGetValue(json, ["rotation"]);

    // Apply texture type
    if (type == "texture")
    {
        string texValue = llJsonGetValue(json, ["texture", "value"]);
        string texSource = llJsonGetValue(json, ["texture", "source"]);

        // Remove the media if it was set on the face
        llClearLinkMedia(link, face);

        // Apply the texture directly to the given link/face
        llSetLinkPrimitiveParams(link, [
            PRIM_TEXTURE, face, texValue, scale, offset, rot
        ]);
    }

    // Apply media type
    else if (type == "media")
    {

        string url      = llJsonGetValue(json, ["media", "url"]);
        integer width   = (integer)llJsonGetValue(json, ["media", "width"]);
        integer height  = (integer)llJsonGetValue(json, ["media", "height"]);
        integer autoPlay = (integer)llJsonGetValue(json, ["media", "auto_play"]);
        integer autoScale = (integer)llJsonGetValue(json, ["media", "auto_scale"]);

        // Whitelist handling
        string rawList = llJsonGetValue(json, ["media", "whitelist"]);
        list whitelist = [];
        integer i = 0;
        while (llJsonValueType(rawList, [i]) == JSON_STRING) {
            whitelist += llJsonGetValue(rawList, [i]);
            ++i;
        }

        // CSV format for whitelist
        string whitelistCSV = llDumpList2String(whitelist, ",");
        
        // If list contains something, is true
        integer enableWhitelist = llGetListLength(whitelist) > 0;

        string interact = llJsonGetValue(json, ["media", "interact"]);
        string ctrl  = llJsonGetValue(json, ["media", "control"]);

        integer permInteract = PRIM_MEDIA_PERM_NONE;
        if (interact == "owner")      permInteract = PRIM_MEDIA_PERM_OWNER;
        else if (interact == "group") permInteract = PRIM_MEDIA_PERM_GROUP;
        else if (interact == "anyone") permInteract = PRIM_MEDIA_PERM_ANYONE;

        integer permControl = PRIM_MEDIA_PERM_NONE;
        if (ctrl == "owner")      permControl = PRIM_MEDIA_PERM_OWNER;
        else if (ctrl == "group") permControl = PRIM_MEDIA_PERM_GROUP;
        else if (ctrl == "anyone") permControl = PRIM_MEDIA_PERM_ANYONE;

        // Apply blank texture for media with mapping
        llSetLinkPrimitiveParams(link, [
            PRIM_TEXTURE, face, TEXTURE_BLANK, scale, offset, rot
        ]);

        // Apply media
        llSetPrimMediaParams(face, [
            PRIM_MEDIA_CURRENT_URL, url,
            PRIM_MEDIA_HOME_URL, url,
            PRIM_MEDIA_AUTO_PLAY, autoPlay,
            PRIM_MEDIA_AUTO_SCALE, autoScale,
            PRIM_MEDIA_WIDTH_PIXELS, width,
            PRIM_MEDIA_HEIGHT_PIXELS, height,
            PRIM_MEDIA_WHITELIST_ENABLE, enableWhitelist,
            PRIM_MEDIA_WHITELIST, whitelistCSV,
            PRIM_MEDIA_PERMS_INTERACT, permInteract,
            PRIM_MEDIA_PERMS_CONTROL, permControl
        ]);
    }

}

// Default state of the script
default
{
    
    // If the object is rezzed, it's reset
    on_rez(integer t){ llResetScript();  }
    
    // On initialization
    state_entry()
    {

        // Reading the server access parameters from linkset
        g_sAppID = llLinksetDataReadProtected("nv_appid", g_sLinksetPassword);
        g_sURL = llLinksetDataReadProtected("nv_url", g_sLinksetPassword);
        g_sSecretSalt = llLinksetDataReadProtected("nv_secret", g_sLinksetPassword);

         // Check if one of the values is missing
        if (g_sAppID == "" || g_sURL == "" || g_sSecretSalt == "")
        {
            
            // State to "off" if the linkset data is not complete
            state off;
        
        }

        // Creates a new URL and token
        RenewURL();

        // Timer event for timeout and self-checks
        llSetTimerEvent(5);
        
    }

    // Something changed
    changed(integer change)
    {
        
        // If the owner changes, or something in object's inventory
        if (change & (CHANGED_OWNER | CHANGED_INVENTORY))
        {
            
            // Reinitializing the URL and token
            RenewURL();

        }
 
        // If the avatar changes region
        if (change & (CHANGED_REGION | CHANGED_REGION_START | CHANGED_TELEPORT))
        { 
            
            // Reinitializing the URL and token
            RenewURL();

        }

    }

    // Event when the object gets touched
    touch_start(integer total_number)
    {
        
        // Get the index of the first toucher (can be multiple)
        integer i = 0;

        // Retrieve useful touch data
        key toucherId = llDetectedKey(i);                      // UUID of the toucher
        string toucherName = llDetectedName(i);                // Display name
        key toucherOwner = llDetectedOwner(i);                 // Owner of the toucher
        vector toucherPos = llDetectedPos(i);                  // Toucher's world position
        rotation toucherRot = llDetectedRot(i);                // Toucher's rotation
        integer toucherType = llDetectedType(i);               // AGENT, OBJECT, etc.
        vector surfaceST = llDetectedTouchST(i);               // Surface UV (ST) coordinates
        vector surfaceUV = llDetectedTouchUV(i);               // UV mapping coordinates
        integer touchedFace = llDetectedTouchFace(i);          // Face index that was touched
        vector touchNormal = llDetectedTouchNormal(i);         // Surface normal vector
        vector touchBinormal = llDetectedTouchBinormal(i);     // Surface binormal vector
        vector touchPos = llDetectedTouchPos(i);               // Local position on the object
        integer touchedLink = llDetectedLinkNumber(i);         // Link number of the touched object (0 for root prim)

        // Combine all data into a single string separated by "|"
        string touchInfo =
            (string)toucherId + "|" +
            toucherName + "|" +
            (string)toucherOwner + "|" +
            (string)toucherPos + "|" +
            (string)toucherRot + "|" +
            (string)toucherType + "|" +
            (string)surfaceST + "|" +
            (string)surfaceUV + "|" +
            (string)touchedFace + "|" +
            (string)touchNormal + "|" +
            (string)touchBinormal + "|" +
            (string)touchPos + "|" +
            (string)touchedLink;

        // Launching on_touch event flow (if existing)
        NVRequest("flowstart", "on_touch|" + touchInfo);
    
    }

    // Handle link messages for request responses
    link_message(integer iSender, integer iNum, string sStr, key kID)
    {
    
        // Starting the event on_linkset_message
        NVRequest("flowstart", "on_linkset_message|" + (string)iSender + "|" + (string)iNum + "|" + sStr + "|" + (string)kID);

    }

    // Listen for the dialog response
    listen(integer channel, string name, key id, string message)
    {

        // Handle RLV Responses
        if (channel == g_iRLVPrimaryChannel || channel == g_iRLVSecondaryChannel)
        {
            
            // Close the listener corresponding to the received channel
            if (channel == g_iRLVPrimaryChannel && g_iRLVPrimaryListener != 0)
            {
                llListenRemove(g_iRLVPrimaryListener);
                g_iRLVPrimaryListener = 0;
            }
            if (channel == g_iRLVSecondaryChannel && g_iRLVSecondaryListener != 0)
            {
                llListenRemove(g_iRLVSecondaryListener);
                g_iRLVSecondaryListener = 0;
            }

            // If this is the first response received
            if (g_sRLVLastResponse == "")
            {
                
                // Store the first received response
                g_sRLVLastResponse = message;

                // Nothing more to do, the second response will be handled in the next event
                return;

            } else  // Second response received: compare with the first one
            {

                // If responses are identical, the request is considered successful
                if (g_sRLVLastResponse == message)
                {
                    // Send success response (200) to the server
                    llHTTPResponse(llList2Key(g_lRLVRequests, 1), 200, message);

                    // Remove the processed request from the queue
                    g_lRLVRequests = llDeleteSubList(g_lRLVRequests, 0, 1);

                    // Reset the retries counter
                    g_iRLVRetries = 0;

                    // Try to execute the next RLV request if available
                    ExecuteRLVRequest();
                
                } else  // Responses differ
                {
                    
                    // If the retry limit is reached, send failure response
                    if (g_iRLVRetries >= 3)
                    {

                        // Too many retries: send failure response
                        llHTTPResponse(llList2Key(g_lRLVRequests, 1), 504, "Responses mismatch after retries.");

                        // Clean the processed request
                        g_lRLVRequests = llDeleteSubList(g_lRLVRequests, 0, 1);

                        // Reset the retries counter (for the next request)
                        g_iRLVRetries = 0;

                        // Start next request if exists
                        ExecuteRLVRequest();

                    } else
                    {
                        
                        // Retry the request
                        ExecuteRLVRequest();
                    
                    }

                }

            }

        }

        // Iterate through g_lDialogs to find the matching entry
        integer i;
        for (i = 0; i < llGetListLength(g_lDialogs); i += 4)
        {
            
            // Getting the channel and user
            integer l_iChannel = llList2Integer(g_lDialogs, i + 2);
            key l_kUser = (key)llList2String(g_lDialogs, i);
            
            // Check if the channel and user match
            if (l_iChannel == channel && l_kUser == id)
            {
                
                // Retrieve the stored HTTP request ID
                key l_kRequestID = llList2Key(g_lDialogs, i + 1);

                // Send the HTTP response with the dialog response
                llHTTPResponse(l_kRequestID, 200, message);

                // Clean up: remove listener and dialog entry
                integer l_iHandle = llList2Integer(g_lDialogs, i + 3);
                llListenRemove(l_iHandle);
                g_lDialogs = llDeleteSubList(g_lDialogs, i, i + 3);

                // Debug
                //llOwnerSay("User " + llKey2Name(id) + " selected: " + message);

                // If found, no need to check further
                return;

            }

        }

    }

    // Event after the permission has been asked
    run_time_permissions(integer perm)
    {
        
        // Build the JSON response with all current permissions
        string response = llList2Json(JSON_OBJECT, [
            "debit",             (perm & PERMISSION_DEBIT) != 0,
            "attach",            (perm & PERMISSION_ATTACH) != 0,
            "take_controls",     (perm & PERMISSION_TAKE_CONTROLS) != 0,
            "trigger_animation", (perm & PERMISSION_TRIGGER_ANIMATION) != 0,
            "change_links",      (perm & PERMISSION_CHANGE_LINKS) != 0,
            "teleport",          (perm & PERMISSION_TELEPORT) != 0
        ]);

        // This is the case when a permission request was pending
        if (g_kPendingPermissionRequest != NULL_KEY)
        {

            // If the permission request was successful, send the response
            llHTTPResponse(g_kPendingPermissionRequest, 200, response);
            
            // Reset the pending permission request key
            g_kPendingPermissionRequest = NULL_KEY;

        }

    }

    // Event called when this object receives a payment (L$)
    money(key payerId, integer amount)
    {

        // Increase the local balance
        g_iInternalFunds += amount;

        // Retrieve payer name (could be empty if not in the same region)
        string payerName = llKey2Name(payerId);

        // Compose the flow data (order: payerId, payerName, amount, internalCount)
        string flowData = (string)payerId + "|" + payerName + "|" + (string)amount + "|" + (string)g_iInternalFunds;

        // Send to server: launches the flow 'on_payment'
        NVRequest("flowstart", "on_payment|" + flowData);

    }

    // Incoming HTTP request
    http_request(key id, string method, string body)
    {

        //llOwnerSay("Incoming request : " + body);

        // This is the URL obtained from Linden server
        if (method == URL_REQUEST_GRANTED)
        {

            // URL written in global variable
            g_sInURL = body;

            // Creating a unique token for this URL
            g_sToken = (string)llGenerateKey();

            // Sending HTTP inbound URL and token to the server
            NVRequest("seturl", "FlowURL|" + body + "|FlowToken|" + g_sToken + "|GatewayVersion|" + (string)g_fGatewayVersion);

            // No need to check other conditions or send response
            return;
        
        }

        if (method == "POST")
        {

            // Should receive message where instructions are separated by |
            list l_lInboundData = llParseString2List(body, ["|"], []);

            // The first element of the list defines what action should be done
            string l_sAction = llList2String(l_lInboundData, 0);

            // Checking the token (2nd element of the list)
            if (llList2String(l_lInboundData, 1) != g_sToken)
            {

                llHTTPResponse(id, 403, "Forbidden");
                return;

            }
            
            // Test ping
            if (l_sAction == "ping")
            {

                llHTTPResponse(id, 200, "Ping received successfully");
                return;

            // This is made to send and RLV command
            } else if (l_sAction == "rlv_command")
            {

                // Incoming information : 
                // - RLV commands

                // Getting the commands
                list l_lCommands = llList2List(l_lInboundData, 2, -1);

                // Looping through the commands
                integer i;
                for (i = 0; i < llGetListLength(l_lCommands); i++)
                {

                    // Sending RLV command
                    llOwnerSay("@" + llList2String(l_lCommands, i));

                }

                // Responding to the server to confirm
                llHTTPResponse(id, 200, "RLV command(s) sent");
                return;

            } else if (l_sAction == "rlv_request")
            {
                
                // Incoming information : 
                // - RLV request
                
                // Verify that the command was provided
                if (llGetListLength(l_lInboundData) != 3)
                {
                    llHTTPResponse(id, 400, "Bad request");
                    return;
                }

                // Extract the command to send
                string l_sCommand = llList2String(l_lInboundData, 2);

                // Add to the RLV requests queue
                g_lRLVRequests += [ l_sCommand, (string)id ];

                // If no current request is pending, start immediately
                if (g_iRLVRequestPending == 0)
                {
                    ExecuteRLVRequest();
                }

                // No response to send, will be done in the listen event
                return;

            } else if (l_sAction == "open_dialog")
            {

                // Incoming information : 
                // - UUID of the avi for which dialog is
                // - Prompt (line separated by \n)
                // - Buttons (separated by ,)

                // List has not good size 
                if (llGetListLength(l_lInboundData) != 5) 
                {

                    llHTTPResponse(id, 400, "Bad request");
                    return;

                }

                // Recovering dialog information
                string l_sRecipient = llList2String(l_lInboundData, 2);
                string l_sPrompt = llList2String(l_lInboundData, 3);
                list l_lButtons = llParseString2List(llList2String(l_lInboundData, 4), [","], []);

                // Creating a new channel for dialog response
                integer l_iChannel = GetChannel();

                // Add or replace the dialog for the user
                AddOrReplaceDialog(l_sRecipient, id, l_iChannel);

                // Create the dialog with the recipient
                llDialog(l_sRecipient, l_sPrompt, l_lButtons, l_iChannel);
                
                // Response will be sent in listen event that will get the dialog response
                return;

            } else if (l_sAction == "open_textbox")
            {

                // Incoming information : 
                // - UUID of the avi for which textbox is
                // - Prompt text

                // List has not good size 
                if (llGetListLength(l_lInboundData) != 4) 
                {

                    llHTTPResponse(id, 400, "Bad request");
                    return;

                }

                // Recovering dialog information
                string l_sRecipient = llList2String(l_lInboundData, 2);
                string l_sPrompt = llList2String(l_lInboundData, 3);

                // Creating a new channel for dialog response
                integer l_iChannel = GetChannel();

                // Add or replace the dialog for the user
                AddOrReplaceDialog(l_sRecipient, id, l_iChannel);

                // Actual opening of the textbox
                llTextBox(l_sRecipient, l_sPrompt, l_iChannel);

                // Response will be sent in listen event that will get the dialog response
                return;

            } else if (l_sAction == "message_linked")
            {

                // Incoming information : 
                // - Linkset
                // - Num
                // - Message
                // - Key

                // List has not good size 
                if (llGetListLength(l_lInboundData) != 6) 
                {

                    llHTTPResponse(id, 400, "Bad request");
                    return;

                }

                // Recovering dialog information
                integer l_iLinkset = llList2Integer(l_lInboundData, 2);
                integer l_iNum = llList2Integer(l_lInboundData, 3);
                string l_sMessage = llList2String(l_lInboundData, 4);
                string l_sKey = llList2String(l_lInboundData, 5);

                // Sending the message
                llMessageLinked(l_iLinkset, l_iNum, l_sMessage, l_sKey);

                // Responding to the server to confirm
                llHTTPResponse(id, 200, "Message linked sent");
                return;

            } else if (l_sAction == "give_inventory")
            {

                // Incoming information : 
                // - UUID of the avatar that receives the object
                // - Name of the object to give

                // List has not good size 
                if (llGetListLength(l_lInboundData) != 4) 
                {

                    llHTTPResponse(id, 400, "Bad request");
                    return;

                }

                // Getting the recipient and object name
                key l_kRecipient = llList2Key(l_lInboundData, 2);
                string l_sObject = llList2String(l_lInboundData, 3);

                // Gives the object to the requested avatar
                llGiveInventory(l_kRecipient, l_sObject);

                // Responding to the server to confirm
                llHTTPResponse(id, 200, "Inventory item given");
                return;

            } else if (l_sAction == "owner_say")
            {

                // Incoming information : 
                // - Message
                
                // List has not good size (must contain at least one message) 
                if (llGetListLength(l_lInboundData) < 3) 
                {

                    llHTTPResponse(id, 400, "Bad request");
                    return;

                }

                // Message received successfully
                llHTTPResponse(id, 200, "Message sent to the owner");

                // Saying the received message
                llOwnerSay(llDumpList2String(llList2List(l_lInboundData, 2, -1), "|"));

            } else if (l_sAction == "region_say_to")
            {

                // Incoming information : 
                // - UUID of the avatar that gets the message
                // - Channel on which message is sent
                // - Message

                // List has not good size (must contain at least one message) 
                if (llGetListLength(l_lInboundData) < 5) 
                {

                    llHTTPResponse(id, 400, "Bad request");
                    return;

                }

                // Getting the recipient and message
                key l_kRecipient = llList2Key(l_lInboundData, 2);
                list l_lMessage = llList2List(l_lInboundData, 4, -1);

                // Gets the channel
                integer l_iChan = llList2Integer(l_lInboundData, 3);
                
                // Looping through the messages
                integer i;
                for(i; i < llGetListLength(l_lMessage); i++)
                {

                    // Sending the received message
                    llRegionSayTo(l_kRecipient, l_iChan, llList2String(l_lMessage, i));

                }

                // Message received successfully
                llHTTPResponse(id, 200, "Message sent successfully");

            } else if (l_sAction == "object_info")
            {

                // 1. Gather base information
                key objectId   = llGetKey();
                string name    = llGetObjectName();
                string desc    = llGetObjectDesc();
                key ownerId    = llGetOwner();
                key creatorId  = llGetCreator();

                vector pos     = llGetPos();
                string regionName = llGetRegionName();
                vector regionCorner = llGetRegionCorner();
                vector globalPos = regionCorner + pos;

                rotation rot   = llGetRot();
                vector vel     = llGetVel();
                vector omega   = llGetOmega();

                integer isPhys = llGetStatus(STATUS_PHYSICS);
                integer isPhan = llGetStatus(STATUS_PHANTOM);

                integer primCount = llGetNumberOfPrims();
                integer freeMem   = llGetFreeMemory();

                // 2. Prepare JSON-safe values
                string jsonPos    = llList2Json(JSON_ARRAY, [pos.x, pos.y, pos.z]);
                string jsonGlobal = llList2Json(JSON_ARRAY, [globalPos.x, globalPos.y, globalPos.z]);
                string jsonRot    = llList2Json(JSON_ARRAY, [rot.x, rot.y, rot.z, rot.s]);
                string jsonVel    = llList2Json(JSON_ARRAY, [vel.x, vel.y, vel.z]);
                string jsonOmega  = llList2Json(JSON_ARRAY, [omega.x, omega.y, omega.z]);
                string jsonRegion = llList2Json(JSON_OBJECT, [
                    "name", regionName,
                    "grid", llList2Json(JSON_ARRAY, [regionCorner.x, regionCorner.y])
                ]);

                // Booleans as strings for JSON compatibility
                string physicalFlag;
                if (isPhys)
                    physicalFlag = "true";
                else
                    physicalFlag = "false";

                string phantomFlag;
                if (isPhan)
                    phantomFlag = "true";
                else
                    phantomFlag = "false";

                // 3. Build final JSON object
                string jsonResponse = llList2Json(JSON_OBJECT, [
                    "id",        (string)objectId,
                    "name",      name,
                    "description", desc,
                    "owner_id",  (string)ownerId,
                    "creator_id", (string)creatorId,
                    "position",  jsonPos,
                    "global_position", jsonGlobal,
                    "region",    jsonRegion,
                    "rotation",  jsonRot,
                    "velocity",  jsonVel,
                    "angular_velocity", jsonOmega,
                    "physical",  physicalFlag,
                    "phantom",   phantomFlag,
                    "prims_count", primCount,
                    "script_memory_free", freeMem
                ]);

                // 4. Return JSON response to the client
                llHTTPResponse(id, 200, jsonResponse);

            } else if (l_sAction == "ask_permission")
            {

                // Incoming information : 
                // - Permission type (debit, attach, take_controls, trigger_animation, change_links, teleport)

                // Getting the permission type
                string l_sPerm = llList2String(l_lInboundData, 2);
                
                // Declaring the variable for the permission constant 
                integer l_iPermConst = 0;

                // Check the permission type and set the corresponding constant
                if (l_sPerm == "debit")                   l_iPermConst = PERMISSION_DEBIT;
                else if (l_sPerm == "attach")             l_iPermConst = PERMISSION_ATTACH;
                else if (l_sPerm == "take_controls")      l_iPermConst = PERMISSION_TAKE_CONTROLS;
                else if (l_sPerm == "trigger_animation")  l_iPermConst = PERMISSION_TRIGGER_ANIMATION;
                else if (l_sPerm == "change_links")       l_iPermConst = PERMISSION_CHANGE_LINKS;
                else if (l_sPerm == "teleport")           l_iPermConst = PERMISSION_TELEPORT;
                else
                {

                    // If the permission type is unknown, respond with an error
                    llHTTPResponse(id, 400, "Unknown permission requested");
                    return;

                }

                // Store the request key for the callback
                g_kPendingPermissionRequest = id;
                llRequestPermissions(llGetOwner(), l_iPermConst);

                // Do not respond here, will respond in run_time_permissions
                return;

            } else if (l_sAction == "add_timer")
            {
                
                // Incoming information : 
                // - Timer key
                // - Datetime

                // Checking if all the information are provided
                if (llGetListLength(l_lInboundData) != 4)
                {
                    
                    llHTTPResponse(id, 400, "Bad request");
                    return;
                
                }

                // Getting the key and timestamp
                string l_sTimerKey = llList2String(l_lInboundData, 2);
                integer l_iTimerWhen = (integer)llList2String(l_lInboundData, 3);

                // Looping through the timer list
                integer i;
                for (i = 0; i < llGetListLength(g_lTimers); i += 2)
                {

                    // If a timer with the same key already existed
                    if (llList2String(g_lTimers, i) == l_sTimerKey)
                    {

                        // In case the timestamp is null, removes it
                        if (l_iTimerWhen == 0)
                        {
                            
                            // Remove timer if new time is 0
                            g_lTimers = llDeleteSubList(g_lTimers, i, i+1);
                            llHTTPResponse(id, 200, "Timer deleted");
                            return;
                            
                        }
                        else
                        {
                            
                            // Update existing timer value
                            g_lTimers = llListReplaceList(g_lTimers, [l_sTimerKey, l_iTimerWhen], i, i+1);
                            llHTTPResponse(id, 200, "Timer updated");
                            return;
                            
                        }
                        
                    }
                    
                }
                
                // If not found in the existing list, add new timer
                if (l_iTimerWhen != 0)
                {
                    
                    g_lTimers += [ l_sTimerKey, l_iTimerWhen ];
                    llHTTPResponse(id, 200, "Timer added");
                
                }
                else
                {
                    
                    // Timer to remove not found
                    llHTTPResponse(id, 404, "Timer not found");
                    
                }

                // Debug
                //llOwnerSay("Timer list : " + llDumpList2String(g_lTimers, ", "));

                // End of processing
                return;

            } else if (l_sAction == "apply_texture")
            {
                
                // Incoming information : 
                // - JSON structure (for texture or media block)
                
                // Check if the JSON payload is provided
                if (llGetListLength(l_lInboundData) < 3)
                {
                    llHTTPResponse(id, 400, "Bad request: missing JSON content");
                    return;
                }

                // Recover the JSON string (all parts after the 2nd index re-joined)
                string l_sJson = llDumpList2String(llList2List(l_lInboundData, 2, -1), "|");

                if (llJsonValueType(l_sJson, []) == JSON_ARRAY)
                {
                    
                    // Loop through each block
                    integer i;
                    for (i = 0; i < llGetListLength(llJson2List(l_sJson)); i++)
                    {
                        
                        string block = llJsonGetValue(l_sJson, [i]);
                        ApplyVisualBlock(block);
                    
                    }

                } else { ApplyVisualBlock(l_sJson); } // Single block

                // Acknowledge success
                llHTTPResponse(id, 200, "Visual block applied");
                return;

            } else if (l_sAction == "instant_message") 
            {
                
                // Incoming information : 
                // - Recipient UUID
                // - Instant_message

                // Check that we have at least a UUID and a message
                if (llGetListLength(l_lInboundData) < 4) 
                {
                    llHTTPResponse(id, 400, "Bad request: missing UUID or message");
                    return;
                }

                // Retrieve the recipient of the message
                key l_kRecipient = llList2Key(l_lInboundData, 2);
                
                // Retrieve the message (all parts after the 3rd field, joined with pipes in case the message contains them)
                string l_sMessage = llDumpList2String(llList2List(l_lInboundData, 3, -1), "|");

                // Send the instant message
                llInstantMessage(l_kRecipient, l_sMessage);

                // Successfully sent
                llHTTPResponse(id, 200, "Instant message sent");
                return;

            } else if (l_sAction == "pay")
            {

                // Incoming information:
                // - Recipient UUID
                // - Amount in L$

                // Check that we have at least a UUID and amount
                if (llGetListLength(l_lInboundData) != 4)
                {
                    llHTTPResponse(id, 400, "Bad request: missing recipient or amount");
                    return;
                }

                // Getting the recipient of the money
                key l_kRecipient = llList2Key(l_lInboundData, 2);

                // Get the amount as a string for strict verification
                string l_sAmount = llList2String(l_lInboundData, 3);

                // Converting the amount as integer
                integer l_iAmount = (integer)llList2String(l_lInboundData, 3);

                // Strict check: amount must be a positive integer, and the string must match the integer cast
                if (l_iAmount <= 0 || (string)l_iAmount != l_sAmount)
                {
                    llHTTPResponse(id, 400, "Bad request: invalid amount value");
                    return;
                }

                // Check internal balance (object's received funds)
                if (g_iInternalFunds < l_iAmount)
                {
                    llHTTPResponse(id, 402, "Insufficient funds in the local balance");
                    return;
                }

                // Check PERMISSION_DEBIT
                if (!(llGetPermissions() & PERMISSION_DEBIT))
                {
                    llHTTPResponse(id, 401, "Unauthorized: PERMISSION_DEBIT not granted");
                    return;
                }

                // Proceed to pay and decrement balance
                llGiveMoney(l_kRecipient, l_iAmount);
                g_iInternalFunds -= l_iAmount;

                // Respond with success
                llHTTPResponse(id, 200, "Payment sent");
                return;

            } else if (l_sAction == "link_info") 
            {

                // Incoming information:
                // - Link number
                                
                // Check if we have all the incoming parameters
                if (llGetListLength(l_lInboundData) != 3) {
                    llHTTPResponse(id, 400, "Bad request: linknum required");
                    return;
                }

                // Getting the integer of the link number
                integer linknum = (integer)llList2String(l_lInboundData, 2);
                integer prims = llGetNumberOfPrims();

                // Checks if it's a valid integer of an existing prim
                if (linknum < 1 || linknum > prims) {
                    llHTTPResponse(id, 400, "Invalid link number");
                    return;
                }

                // Gets the local position
                vector pos = llList2Vector(llGetLinkPrimitiveParams(linknum, [PRIM_POS_LOCAL]), 0);

                // Gets the local rotation
                rotation rot = llList2Rot(llGetLinkPrimitiveParams(linknum, [PRIM_ROT_LOCAL]), 0);

                // Prepare a list to hold info for all faces
                list faces_info = [];

                // Get number of sides (faces) for this prim
                integer faces = llGetLinkNumberOfSides(linknum);

                // Get the name of the prim
                string name = llGetLinkName(linknum);

                // Loop through all faces (usually 0 to 5, but can be less for some prim shapes)
                integer f;
                for (f = 0; f < faces; ++f)
                {
                    
                    // Get color and alpha for this face
                    list colorParams = llGetLinkPrimitiveParams(linknum, [PRIM_COLOR, f]);
                    vector color = llList2Vector(colorParams, 0);
                    float alpha = llList2Float(colorParams, 1);

                    // Get texture UUID and repeats/offsets/rotation
                    list texParams = llGetLinkPrimitiveParams(linknum, [PRIM_TEXTURE, f]);
                    string texture = llList2String(texParams, 0);
                    vector repeats = llList2Vector(texParams, 1);
                    vector offsets = llList2Vector(texParams, 2);
                    float rot      = llList2Float(texParams, 3);

                    // Build a JSON object for this face
                    string face_json = llList2Json(JSON_OBJECT, [
                        "face",    f,
                        "color",   llList2Json(JSON_ARRAY, [color.x, color.y, color.z]),
                        "alpha",   alpha,
                        "texture", texture,
                        "repeats", llList2Json(JSON_ARRAY, [repeats.x, repeats.y]),
                        "offsets", llList2Json(JSON_ARRAY, [offsets.x, offsets.y]),
                        "rotation", rot
                    ]);

                    // Add this face info to the list
                    faces_info += [face_json];

                }

                // Creating the output JSON
                string response = llList2Json(JSON_OBJECT, [
                    "linknum", linknum,
                    "face_count", faces,
                    "name", name,
                    "local_position", llList2Json(JSON_ARRAY, [pos.x, pos.y, pos.z]),
                    "faces", llList2Json(JSON_ARRAY, faces_info)
                ]);

                // Sending the response
                llHTTPResponse(id, 200, response);
                return;

            } else if (l_sAction == "set_child_pos") 
            {

                // Incoming information:
                // - Link number
                // - X pposition (local)
                // - Y pposition (local)
                // - Z pposition (local)

                // Check if we have all the incoming parameters
                if (llGetListLength(l_lInboundData) != 6) {
                    llHTTPResponse(id, 400, "Bad request: linknum and x,y,z required");
                    return;
                }

                // Getting the float values
                integer linknum = (integer)llList2String(l_lInboundData, 2);
                float x = (float)llList2String(l_lInboundData, 3);
                float y = (float)llList2String(l_lInboundData, 4);
                float z = (float)llList2String(l_lInboundData, 5);

                // Checking if we have a valid prim number (can't be 1, which is root)
                integer prims = llGetNumberOfPrims();
                if (linknum < 2 || linknum > prims) {
                    llHTTPResponse(id, 400, "Invalid link number (must be >=2 and <= prim count)");
                    return;
                }

                // Creates a vector using the input position
                vector newpos = <x, y, z>;

                // Apply the new local position
                llSetLinkPrimitiveParamsFast(linknum, [PRIM_POSITION, newpos]);

                // Successfully moved
                llHTTPResponse(id, 200, "Child prim moved");
                return;

            }

            // If no revelant action has been found
            llHTTPResponse(id, 404, "Action not found");
            return;

        }

        // Sending response (if no success previously sent)
        llHTTPResponse(id, 400, "Bad request");

    }

    // This is called when there is a response received 
    http_response(key id, integer status, list metaData, string body)
    {

        // If this response is the self-check
        if (id == g_kSelfCheckRequestId)
        {
            
            // If you're not usually doing this,
            // now is a good time to get used to doing it!
            g_kSelfCheckRequestId = NULL_KEY;
 
            // If not success, renews the URL
            if (status != 200)  { RenewURL(); }

            // Quits the http_response event
            return;

        }

        // Extracting message and requestid from the JSON
        string l_sReqID = llJsonGetValue(body, ["reqid"]);
        string l_sMessage = llJsonGetValue(body, ["message"]);
            
        // This is the case when receiving response after the URL has been sent
        if (g_iInURLSent == 0 && l_sReqID == g_kRequestID && status == 200)
        {

            // Avoiding to enter this loop again for further requests
            g_iInURLSent = 1;

            // Setting the last URL check time to now
            g_fLastURLSelfCheck = llGetUnixTime();

            // Starting the event on_hooked, which is lanched when an object gets known by the server
            NVRequest("flowstart", "on_hooked");

            // Other operation which have to be done once the gateway ready
            //llOwnerSay("URL has been sent");
            
        }

    }
 
    // Timer (for self-checks or request timeouts)
    timer()
    {

        // If the incoming URL is not set, or not successfully sent
        if (g_iInURLSent == 0)
        {

            // Retrying a new URL request
            RenewURL();

            // Nothing more to do, since the URL is not set yet
            return;

        }
        
        // Doing self-check ping (every 5 mins)
        if ((llGetUnixTime() - g_fLastURLSelfCheck) > 300.0) 
        {
            
            // Sending the self-check request
            g_kSelfCheckRequestId = llHTTPRequest(g_sInURL,
                                [HTTP_METHOD, "POST",
                                HTTP_VERBOSE_THROTTLE, FALSE,
                                HTTP_BODY_MAXLENGTH, 16384],
                                "ping|" + g_sToken);

            // Setting the last URL check time to now
            g_fLastURLSelfCheck = llGetUnixTime();

            // Debug
            //llOwnerSay("Self-check ping sent to the server.");

        }

        // If a RLV request is pending, check if it has timed out
        if (g_iRLVRequestPending == 1)
        {

            // If the RLV request has timed out (5 seconds)
            if ((llGetUnixTime() - g_fRLVRequestSentOn) > 5.0)
            {

                // Check retry count
                if (g_iRLVRetries >= 3)
                {
                    
                    // Timeout: send error to server
                    key l_kRequestID = llList2Key(g_lRLVRequests, 1);
                    llHTTPResponse(l_kRequestID, 504, "No response received or timeout.");

                    // Clean the processed request
                    g_lRLVRequests = llDeleteSubList(g_lRLVRequests, 0, 1);

                    // Start next request if exists
                    ExecuteRLVRequest();

                } else
                {
                    
                    // Retry sending the RLV request
                    ExecuteRLVRequest();

                }

            }

        }

        // Handle custom timer triggers if any are scheduled
        if (llGetListLength(g_lTimers) > 0)
        {
            
            // Get the current time in seconds since epoch
            integer l_iNow = llGetUnixTime();
            
            // Each stride: [key, datetime]
            integer i = 0;
            while (i < llGetListLength(g_lTimers))
            {
                
                // Get the timer key and when it should trigger
                string l_sTimerKey = llList2String(g_lTimers, i);
                integer l_iTimerWhen = llList2Integer(g_lTimers, i + 1);

                // If this timer should trigger now or in the past
                if (l_iTimerWhen <= l_iNow)
                {
                    
                    // Start the on_timer flow, passing the key as a parameter
                    NVRequest("flowstart", "on_timer|" + l_sTimerKey);

                    // Remove this timer entry from the list
                    g_lTimers = llDeleteSubList(g_lTimers, i, i + 1);
                    
                    // Do not increment i: next timer now at the same index

                }
                else { i += 2; } // Move to the next timer entry

            }

        }

    }

}

// Empty state when the linkset data is not complete
state off { state_entry() {} }
