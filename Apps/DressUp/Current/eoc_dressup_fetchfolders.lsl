// Script oc_dressup_fetchfolders written by EmmaVenus2005 on Nov 8th 2024
//
// This script is fetching the ~wearings folder for DressUp app, and sending to the server
//  using oc_nonvolatile (or oc_nonvolatiletest).
//
// Version 0.8

// Storing the current step
integer g_iCurrentStep = 0;

// Dialog Interaction Constants
integer DIALOG = 0;
integer DIALOG_RESPONSE = 1;

// Constants used for HTTP requests using oc_nonvolatile
integer NV_REQUEST = 10800;
integer NV_RESPONSE = 10801;

// App specific RLV return channel interval
integer RLV_CHANNEL_MIN = 1813331800;      
integer RLV_CHANNEL_MAX = 1813331899;

// Script Lifecycle Constants
integer STARTUP = -57;
integer ALIVE = -55;              // Indicates that the script is active and running
integer READY = -56;              // Indicates that the script is initialized and ready
integer REBOOT = -1000;           // Reboot the script to reset it

// Used to know if update is still pending (if a response is lost, allows the timer to relaunch the fetch)
integer g_iUpdatePending = 0;

// Used to determine which dataset has to be updated 
// 0 = First dataset
// 1 = Second dataset
integer g_iDatasetToUpdate = 0;

// Contains the list of folders once data checked
list g_lFolders = [];

// Channels used to receive messages (will be randomly set)
integer g_iPrimaryChannel;
integer g_iSecondaryChannel;

integer g_iPrimaryListener;
integer g_iSecondaryListener;

// Used to store the request ID (to avoid handling a parrallel response that may not be for this script)
key g_kRequestID;

// This is the index of the current checked subfolder
integer g_iCurrentSubfolder;

// Used to double check RLV feedback
string g_sLastMessage;

// Base path for wearings and app ID
string g_sBasePath = "~wearings/";

// Funtion to sent a HTTP request using oc_nonvolatile
NVRequest(string sReqType, string sReqData)
{

    // Generate a unique menu ID for this request
    g_kRequestID = llGenerateKey();

    // Creating request (reqtype|reqData)
    string sRequest = sReqType + "|" + sReqData;

    // Send a message with the menu details, excluding sParams
    llMessageLinked(LINK_SET, NV_REQUEST, sRequest, g_kRequestID);

}

SetChannels()
{

    // Initialize local variables for the new channels
    integer newPrimaryChannel;
    integer newSecondaryChannel;

    do {

        // Generate a random primary channel within the RLV range
        newPrimaryChannel = RLV_CHANNEL_MIN + (integer)llFrand(RLV_CHANNEL_MAX - RLV_CHANNEL_MIN + 1);

        // Generate a random secondary channel within the RLV range
        newSecondaryChannel = RLV_CHANNEL_MIN + (integer)llFrand(RLV_CHANNEL_MAX - RLV_CHANNEL_MIN + 1);

    } while (
        
        // Ensure the new channels are different from each other
        newPrimaryChannel == newSecondaryChannel || 
        
        // Ensure the new channels are different from previous ones
        (newPrimaryChannel == g_iPrimaryChannel && newSecondaryChannel == g_iSecondaryChannel)

    );

    // Set global variables to the newly generated channels
    g_iPrimaryChannel = newPrimaryChannel;
    g_iSecondaryChannel = newSecondaryChannel;
    
    // Output the new channels for debugging purposes
    //llOwnerSay("Primary Channel set to: " + (string)g_iPrimaryChannel);
    //llOwnerSay("Secondary Channel set to: " + (string)g_iSecondaryChannel);

    // Stop listening on old channels if they are set
    if (g_iPrimaryListener) llListenRemove(g_iPrimaryListener);
    if (g_iSecondaryListener) llListenRemove(g_iSecondaryListener);

    // Start listening on new primary and secondary channels
    g_iPrimaryListener = llListen(g_iPrimaryChannel, "", NULL_KEY, "");
    g_iSecondaryListener = llListen(g_iSecondaryChannel, "", NULL_KEY, "");

}


// Flowing through different steps
Flow(integer iWay,string sStr)
{

    // Step 0 : Determining which dataset has to be updated (if none existing on server, will be 1)
    if (g_iCurrentStep == 0)
    {

        // Dialog
        if(iWay == DIALOG)
        {

            // We need to get the parameter from the server, to know which dataset has to be updated
            //llOwnerSay("Fetch started !");

            // Variable avoids to update again until ended
            g_iUpdatePending = 1;

            // Sending the HTTP request
            NVRequest("getvalue", "DirFetchCurrentDataset");

        // Response
        } else
        {

            // If the server's current dataset is 0 (primary), we'll update the 1 (secondary)
            if(sStr == "0") { g_iDatasetToUpdate = 1; }

            // If no previous dataset fetched or current is 1, we'll fetch the 0 (primary)
            else { g_iDatasetToUpdate = 0; }

            // Going to step 1
            g_iCurrentStep = 1;
            Flow(DIALOG,"");

        }

    // Step 1 : Choosing two channels between RLV_CHANNEL_MIN and RLV_CHANNEL_MAX into g_iPrimaryChannel and g_iSecondaryChannel
    } else if (g_iCurrentStep == 1)
    {

        // Dialog
        if(iWay == DIALOG)
        {

            // Calls the function that sets both channels randomly
            SetChannels();

            // Synchrone function, so need to implicitly jump to response section
            Flow(DIALOG_RESPONSE,"");
            
        // Response
        } else
        {

            // Going to step 2
            g_iCurrentStep = 2;
            Flow(DIALOG,"");

        }

    // Step 2 : Sending RLV command on both channels to get the main directory content (Categories)
    } else if (g_iCurrentStep == 2)
    {

        // Dialog
        if(iWay == DIALOG)
        {
        
            // Resetting the string
            g_sLastMessage = "";

            // Requesting the main folder list (on both channels)
            llOwnerSay("@getinv:" + g_sBasePath + "=" + (string)g_iPrimaryChannel);
            llOwnerSay("@getinv:" + g_sBasePath + "=" + (string)g_iSecondaryChannel);
            
        // Response
        } else
        {
        
            // If it is the first message (primary channel)
            if(g_sLastMessage == "") { g_sLastMessage = sStr; }

            // If both channels had the same result, it is validated
            else if (g_sLastMessage == sStr)
            {

                //llOwnerSay("Validated response : " + sStr);
                
                // Parse the string into a list, using commas as the separator
                g_lFolders = llParseString2List(sStr, [","], []);

                // Going to step 4
                g_iCurrentStep = 4;
                Flow(DIALOG,"");

            }

            // If the messages were different...
            else
            {

                // Changing channels to avoid receiving previous messages (when some latencies)
                SetChannels();

                // Sending the RLV request again
                Flow(DIALOG,"");

            }

        }

    // Step 3 : Sending Categories to the server
    // } else if (g_iCurrentStep == 3)
    // {

    //     // Dialog
    //     if(iWay == DIALOG)
    //     {

    //         // Sending list to the server
    //         NVRequest("setlist", "Categories" + (string)g_iDatasetToUpdate + "|List|" + llDumpList2String(g_lFolders, "|"));

    //     // Response
    //     } else
    //     {

    //         // Going to step 4
    //         g_iCurrentStep = 4;
    //         Flow(DIALOG,"");

    //     }

    // Step 4 : Deleting previous subfolders from server for the current dataset
    } else if (g_iCurrentStep == 4)
    {

        // Dialog
        if(iWay == DIALOG)
        {

            // Ensure this variable is 0 for the next step
            g_iCurrentSubfolder = 0;

            // Sending the request for deletion
            NVRequest("dellists", "ClothingPieces" + (string)g_iDatasetToUpdate);

        // Response
        } else
        {

            // Going to step 5
            g_iCurrentStep = 5;
            Flow(DIALOG,"");

        }

    // Step 5 : Sending RLV request for the content of the category at index g_iCurrentSubfolder
    } else if (g_iCurrentStep == 5)
    {

        // Dialog
        if(iWay == DIALOG)
        {

            // Resetting the string
            g_sLastMessage = "";

            // Requesting the subfolder list (on both channels)
            llOwnerSay("@getinvworn:" + g_sBasePath + "/" + llList2String(g_lFolders, g_iCurrentSubfolder) + "=" + (string)g_iPrimaryChannel);
            llOwnerSay("@getinvworn:" + g_sBasePath + "/" + llList2String(g_lFolders, g_iCurrentSubfolder) + "=" + (string)g_iSecondaryChannel);
            
        // Response
        } else
        {

            // If it is the first message (primary channel)
            if(g_sLastMessage == "") { g_sLastMessage = sStr; }

            // If both channels had the same result, it is validated
            else if (g_sLastMessage == sStr)
            {

                // Going to step 6
                g_iCurrentStep = 6;
                Flow(DIALOG,"");

            }

            // If the messages were different...
            else
            {

                // Changing channels to avoid receiving previous messages (when some latencies)
                SetChannels();

                // Sending the RLV request again
                Flow(DIALOG,"");

            }

        }

    // Step 6 : Storing the previously received subfolder to the server
    } else if (g_iCurrentStep == 6)
    {

        // Dialog
        if(iWay == DIALOG)
        {

            // Sending list to the server
            NVRequest("setlist", "ClothingPieces" + (string)g_iDatasetToUpdate + "|" + llList2String(g_lFolders, g_iCurrentSubfolder) + "|" + g_sLastMessage);

        // Response
        } else
        {

            // If reached last subfolder
            if (g_iCurrentSubfolder >= llGetListLength(g_lFolders) - 1) 
            {

                // Going to step 7
                g_iCurrentStep = 7;
                Flow(DIALOG,"");

            // Else (other subfolders coming)
            } else 
            {
                
                // Incrementing g_iCurrentSubfolder
                g_iCurrentSubfolder++;

                // Back to step 5
                g_iCurrentStep = 5;
                Flow(DIALOG,"");

            }

        }

    // Step 7 : Telling the server that the dataset is fully updated
    } else if (g_iCurrentStep == 7)
    {

        // Dialog
        if(iWay == DIALOG)
        {

            // Setting the pending variable to 0 (next update may happen)
            g_iUpdatePending = 0;

            // Sending the HTTP request
            NVRequest("setvalue", "DirFetchCurrentDataset|" + (string)g_iDatasetToUpdate);
        
        // Response
        } else
        {

            //llOwnerSay("Update done !");

        }

    }

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

        // Debug listening
        //llListen(69, "", NULL_KEY, "");

        // Going to step 0
        g_iCurrentStep = 0;
        Flow(DIALOG,"");

    }

    // Handle link messages for request responses
    link_message(integer iSender, integer iNum, string sStr, key kID)
    {
    
        // Response from an HTTP request using oc_nonvolatile
        if (iNum == NV_RESPONSE && g_kRequestID == kID)
        {
    
            // Callig the function that handles response
            Flow(DIALOG_RESPONSE, sStr);

        }

    }

    // Listen for the response from the RLV system with the list of folders
    listen(integer channel, string name, key id, string message)
    {

       /*  // Debug
        if (channel == 69)
        {

            llOwnerSay(message);
            return;

        } */

        // RLV channel feedback
        if (channel == g_iPrimaryChannel || channel == g_iSecondaryChannel)
        {

            // Global used by the flow to identify on which channel the response was sent
            //g_iLastChannel = channel;

            // Callig the function that handles response
            Flow(DIALOG_RESPONSE, message);

        }
        
    }

}