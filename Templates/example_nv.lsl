// Created by EmmaVenus2005 from Second Life, on Oct. 19 / 2024
//
// Template to use my OpenCollar NonVolatile API, designed to store pairs of key/values on an external server.
// This early template is meant to show the possibiliies of the oc_nonvolatile.lsl script 
// (or oc_nonvolatiletest, which is so far the only available version).
//
// The key/value pairs are user-specific, and oc_nonvolatile or oc_nonvolatiletest automatically will use the owner of the object in which the script is nested.
// For security reasons, this can't be done otherwise (or complex user rights management).
//
// At this day, this code is not yet open-source, and I am still the owner of my work. Please let me know if you may be interested in using it,
// it is of course entirely free as long as it remains for the Open Collar. This includes this file and oc_nonvolatile script.
//
// I will soon provide a new template with a function that allows to automatically send the response to the dialog
// like Dialog() does for dialog boxes. My ultimate wish would be a synchrone way to work, like GetNVParam('testparam'),
// but seems not easy with LSL limitations.
//
// Oct 27 2024 : EmmaVenus2005
// Adding 'getlists','getlist' and 'setlist' request types :
//
// getlists (plurial) : input : appid|reqid|list_class : Returns all lists from given class (separated by |).
// Example : "oc_dressup|getlists|Outfit" -> My first outfit|My second outfit
//
// getlist (singular) : input : appid|reqid|list_class|list_name : Returns the content of the list (a string with | separated)
// Example : "oc_dressup|getlist|Outfit|Halloween outfit" -> Undies/Black thong|Skirts/Halloween skirt| ...
// 
// setlist : input : appid|reqid|list_class|list_name|list_content : Returns nothing 
// Example : "oc_dressup|getlist|Outfit|Halloween outfit|Undies/Black thong|Skirts/Halloween skirt| ... (may have many items)

// UUID of the person who touched the object
string g_touchUUID;  

// Constants (iNums used for message linked)
integer NV_REQUEST = 10800;
integer NV_RESPONSE = 10801;

default
{
    state_entry()
    {
    }

    // Event to handle object touch
    touch_start(integer total_number) {
        
        // Get the UUID of the person who touched the object
        g_touchUUID = llDetectedKey(0);  
        
        // Listen on channel 256 for the user's response
        llListen(256, "", g_touchUUID, "");  

        // Open a text box for the user to enter data
        llTextBox(g_touchUUID, "Enter the value to send to the API: ", 256);  
    
    }

    // Event to handle dialog input
    listen(integer channel, string name, key id, string message) {
        
        if (channel == 256 && id == g_touchUUID) {
            
            // Stop listening after receiving the input
            llListenRemove(channel);  
        
            // A unique key that will allow to identify for which request the response is
            key l_kReqID = llGenerateKey();
            
            // So far, possibilities in oc_nonvolatile 1.0 :
            // "oc_dressup|setvalue|key|value" (only one possible for now, in the future multiple key/value will be possible)
            // "oc_dressup|getvalue|key" -> Returns the value from the provided key (empty string if not existing)
            //
            // The string is pipe separated and contains following information :
            // appid : The best practice is to use your script name (for me oc_dressup)
            // reqtype : So far, setvalue and getvalue
            // 
            // Following parameters depend of the request type
            string l_sMessage = "oc_dressup|setvalue|testkey|" + message;

            // Sends the message to oc_nonvolatile or oc_nonvolatiletest
            llMessageLinked(LINK_SET, NV_REQUEST, l_sMessage, l_kReqID);
        
        }

    }

    // Event to handle the response of oc_nonvolatile or oc_nonvolatiletest
    link_message(integer iSender, integer iNum, string sStr, key kID)
    {

        if (iNum == NV_RESPONSE)
        {

            // Chat log
            llOwnerSay("Response from request : " + (string)kID);
            llOwnerSay("Response message : " + sStr);

        }

    }

}
