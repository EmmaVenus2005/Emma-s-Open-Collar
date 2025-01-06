// Emma's Test Box LSL Script

// Used to get the "nv_appid" and "nv_secret" from linkset (script has to be nomod in order to avoid it getting revealed)
string g_sLinksetPassword = "h8&6K9nLusZ$GyG2$Kh*1K4ZCjPI@iCWBhOZAegpb@XBZn7i&qsgBRogkdmoylEi!5PaoyThBv9JRQE%t*M5N453EXA7kdo5UVmjxA!XkQTWR#S^GebO$iHwXKfvxtf7K3280wuBtb9QoLw10dgk%!OdghP14JczeOeBVB5uc^cxg821IwbvT65rzbQyBkj^H^U*X@cqvaRG$fVeBVEQ09*bbrrs@VGyf$00CzKfzBxgTxQPY8lA@hichhz$No^?";

// Constants
integer NV_REQUEST = 10800;
integer NV_RESPONSE = 10801;

// Global variables for server access
string g_sAppID;
string g_sURL;
string g_sSecretSalt;

default
{
    
    state_entry()
    {

        // Reading the server access parameters from linkset
        g_sAppID = llLinksetDataReadProtected("nv_appid", g_sLinksetPassword);
        g_sURL = llLinksetDataReadProtected("nv_url", g_sLinksetPassword);
        g_sSecretSalt = llLinksetDataReadProtected("nv_secret", g_sLinksetPassword);

    }

    // Event to handle HTTP responses
    http_response(key request_id, integer status, list metadata, string body) {
       
        if (status == 200) 
        {
            
            // Successful response
            //llOwnerSay("Data successfully sent to the API. Response: " + body);

            // Extracting message and requestid from the JSON
            string l_sReqID = llJsonGetValue(body, ["reqid"]);
            string l_sMessage = llJsonGetValue(body, ["message"]);
            
            // Send a message with the menu details, excluding sParams
            llMessageLinked(LINK_SET, NV_RESPONSE, l_sMessage, l_sReqID);
        
        } 
        else {
            
            // Error response
            //llOwnerSay("Failed to send data to the API. Status: " + (string)status + " Response: " + body);

        }

    }

    // Incoming requests (kID = requestID, sStr = name of sender script|reqtype|key|value)
    // IN ANY CASE, sStr begins by name of sender script|reqtype|
    // AFTER, depends of the specific data needed for the reqtype (e.g. key|value for setvalue)
    link_message(integer iSender, integer iNum, string sStr, key kID)
    {

        if (iNum == NV_REQUEST)
        {

            // Mixing the owner key with the secret salt, and hashing it
            string l_sHash = llSHA256String((string)llGetOwner() + g_sSecretSalt + llGetDate());

            // Create the request body
            string requestBody = "reqid=" + (string)kID  + "&reqcheck=" + l_sHash + "&request=" + g_sAppID + "|" + sStr;

            // Debug
            //llOwnerSay("Received request body : " + requestBody);

            // Send the HTTP request
            llHTTPRequest(g_sURL, [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/x-www-form-urlencoded"], requestBody);

        }

    }

}