// oc_dressup_flow.lsl by EmmaVenus2005 (Second Life), Nov 15 2024
//
// This script is used to execute commands from the flows on server side.
// Flows is my new way to create apps on PHP side.
// This is still a test version !


// Constants used for HTTP requests using oc_nonvolatile
integer NV_REQUEST = 10800;
integer NV_RESPONSE = 10801;

// Constant to identify a flow start linked message
integer FLOW_START = 10850;

// Script Lifecycle Constants
integer STARTUP = -57;
integer ALIVE = -55;              // Indicates that the script is active and running
integer READY = -56;              // Indicates that the script is initialized and ready
integer REBOOT = -1000;           // Reboot the script to reset it

// Used to store the UUID of URL request (used to release)
key g_URLRequest;

// Used to store the request ID for NV Request (for uploading URL through nonvolatile.lsl)
// (to avoid handling a parrallel response that may not be for this script)
key g_kRequestID;

// Used to store the URL
string g_URL; 

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

// Funtion to sent a HTTP request using oc_nonvolatile
// (Used in this script to send the inbound URL to the server only)
NVRequest(string sReqType, string sReqData)
{

    // Generate a unique menu ID for this request
    g_kRequestID = llGenerateKey();

    // Creating request (reqtype|reqData)
    string sRequest = sReqType + "|" + sReqData;

    // Send a message with the menu details, excluding sParams
    llMessageLinked(LINK_SET, NV_REQUEST, sRequest, g_kRequestID);

}

// Function used to renew the URL, to ensure a valid one exists for the flow
RenewURL()
{

    // Revoke the previous URL 
    llReleaseURL(g_URLRequest);

    // Sending the HTTPS URL request
    g_URLRequest = llRequestSecureURL();

}

// Function that generates a new channel for dialog response that is not already used
integer GetChannel()
{

    // Generates channel
    integer iChan = llRound(llFrand(10000000)) + 100000; 
    
    // Checks if generated channel channel doesn't exist
    while (~llListFindList(llList2ListStrided(g_lDialogs, 2, -1, 4), [iChan]))
    {

        // In case, generates a new one
        iChan = llRound(llFrand(10000000)) + 100000; 

    }
    
    return iChan;

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

// Default code that is in most OpenCollar applications 
default
{
    on_rez(integer iNum){
        llResetScript();
    }
    state_entry(){
        llMessageLinked(LINK_SET, ALIVE, llGetScriptName(),"");
    }
    link_message(integer iSender, integer iNum, string sStr, key kID){
        if(iNum == REBOOT){
            if(sStr == "reboot"){
                llResetScript();
            }
        } else if(iNum == READY){
            llMessageLinked(LINK_SET, ALIVE, llGetScriptName(), "");
        } else if(iNum == STARTUP){
            state active;
        }

    }

}

state active
{
    
    on_rez(integer t){
        llResetScript();
    }
    
    state_entry()
    {

        // Creates a new URL and token
        RenewURL();
        
    }

    changed(integer change)
    {
        
        if (change & (CHANGED_OWNER | CHANGED_INVENTORY))
        {
            
            llReleaseURL(g_URLRequest);
            g_URLRequest = "";
 
            llResetScript();

        }
 
        if (change & (CHANGED_REGION | CHANGED_REGION_START | CHANGED_TELEPORT))
        { 
            
            //llOwnerSay("Changed SIM, generating new URL.");

            RenewURL();

        }

    }

    // Handle link messages for request responses
    link_message(integer iSender, integer iNum, string sStr, key kID)
    {
    
        // If flow start request from linkset...
        if (iNum == FLOW_START)
        {

            // Starting the flow
            NVRequest("flowstart", sStr + "|" + (string)kID);

        /* // Once URL has been sent to server...
        } else if (iNum == NV_RESPONSE && kID == g_kRequestID)
        {

            // Stays here in case of

        */
        } 


    }

    // Listen for the dialog response
    listen(integer channel, string name, key id, string message)
    {

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

    // Incoming HTTP request
    http_request(key id, string method, string body)
    {

        //llOwnerSay("Incoming request : " + body);

        // This is the URL obtained from Linden server
        if (method == URL_REQUEST_GRANTED)
        {

            // URL written in global variable
            g_URL = body;

            // Creating a unique token for this URL
            g_sToken = (string)llGenerateKey();

            // check every 5 mins for dropped URL
            llSetTimerEvent(300.0);
            
            // Sending HTTP inbound URL and token to the server
            NVRequest("setvalue","FlowURL|" + body + "|FlowToken|" + g_sToken);

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

            }

            // If no revelant action has been found
            llHTTPResponse(id, 404, "Action not found");
            return;

        }

        // Sending response (if no success previously sent)
        llHTTPResponse(id, 400, "Bad request");

    }

    // This is called when there is a response received 
    // (for self tests and used after generating a new URL to avoid it from getting reoked after 2 mins)
    http_response(key id, integer status, list metaData, string body)
    {

        if (id == g_kSelfCheckRequestId)
        {
            
            // If you're not usually doing this,
            // now is a good time to get used to doing it!
            g_kSelfCheckRequestId = NULL_KEY;
 
            // If not success, renews the URL
            if (status != 200)  { RenewURL(); }
 
        }

    }
 
    // Timer that self-checks URL every 5 minutes
    timer()
    {
        
        // Doing self-check ping
        g_kSelfCheckRequestId = llHTTPRequest(g_URL,
                                [HTTP_METHOD, "POST",
                                    HTTP_VERBOSE_THROTTLE, FALSE,
                                    HTTP_BODY_MAXLENGTH, 16384],
                                "ping|" + g_sToken);

    }

}
