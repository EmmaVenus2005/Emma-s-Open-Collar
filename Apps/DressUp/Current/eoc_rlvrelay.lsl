// RLV relay by EmmaVenus2005, on 2025-01-01
// This relay simply sends the command to the app flow server

// Channel on which RLV commands are sent
integer RLV_CHANNEL = -1812221819;

// Constants used for HTTP requests using oc_nonvolatile
integer NV_REQUEST = 10800;
integer NV_RESPONSE = 10801;

default
{
    
    on_rez(integer iNum) { llResetScript(); }
    
    state_entry()
    {

        // Starting to listen the RLV channel
        llListen(RLV_CHANNEL, "", NULL_KEY, "");

        // Launches the "rlvinit" flow
        // TO IMPLEMENT

    }

    // Listen for the RLV messages
    listen(integer channel, string name, key id, string message)
    {

        // DEBUG
        //llOwnerSay("Em's relay : " + message);

        // Example : sit,2b0350ae-69ad-45f8-a586-553caa9a0e44,@sit:aa13ce00-9e06-88a9-413d-9169b079767a=force
        // Incoming command has 3 strides (separated by ,) :
        // Command(s) ID (whatever name the sender device wants to give)
        // Recipient (UUID) : Ignore those that don't correspond to wearer's UUID
        // List of commands separated by |

        // See wiki : https://wiki.secondlife.com/wiki/LSL_Protocol/Restrained_Love_Relay/Specification

        // Separating the different parts
        list l_lMessageParts = llParseString2List(message, [","], [""]);

        // If there are not 3 parts, it's not an incoming RVL command 
        // (might be aknowledgement from another avi or wrong formatted command)
        if (llGetListLength(l_lMessageParts) != 3) { return; }

        // Checking if the owner is the recipient of the command
        if (llList2String(l_lMessageParts, 1) != (string)llGetOwner()) { return; }

        // Getting the needed parts
        string l_sCommandID = llList2String(l_lMessageParts, 0);
        string l_sCommands = llList2String(l_lMessageParts, 2);

        // Starting the flow with the commands (flowstart|flowname|session[|cmds])
        // session is command id @ UUID of the sender ofject
        llMessageLinked(LINK_SET, NV_REQUEST, "flowstart|rlvcmd|" + l_sCommandID + "@" + (string)id + "|" + l_sCommands, NULL_KEY);
        
    }

}