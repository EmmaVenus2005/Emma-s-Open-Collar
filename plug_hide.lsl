// Anal plug script that allows a collar, or other weared object to hide / unhide the anal plug
// Written by EmmaVenus2005, on 24/09/2024. This code is GPL 2 licence, so can be used and modified freely.
//
// The purpose is to make my version of Open Collar able to hide / unhide the anal plug when underwear or pants
// are wore by the avatar, especially in my DressUp app. It can be used by other applications if necessary.
//
// I used custom channels to communicate, but feel free to contact me inworld if you want me to improve the code
// in order to be compatible with other revelant objects.
//
// Messages sent by the plug : ':plug:getstate' : The plug needs an immediate response (hide or unhide)
// Messages sent to the plug : ':plug:hide'     : The plug will be invisible
//                             ':plug:unhide'   : The plug will be visible


integer MSG_TO_PLUG = -47832;   // Used by external objects like the collar to communicate with the plug
integer MSG_FROM_PLUG = -47833; // Used by the plug to communicate with external objects
float TIMEOUT_DURATION = 2.0;   // Timeout duration for waiting for the collar's response

integer g_iHasReceivedResponse = FALSE;

default
{
    state_entry()
    {
        
        // Make the object invisible when it is initialized
        // waiting to ensure that it has to be visible,
        // or appears after 2 seconds when no response from the collar
        llSetAlpha(0.0, ALL_SIDES);

        // Listen to the MSG_TO_PLUG channel to receive requests for the plug 
        // to become visible / invisible
        llListen(MSG_TO_PLUG, "", NULL_KEY, "");

        // Send a request to the wearer's collar, to get the initial state
        llRegionSayTo(llGetOwner(), MSG_FROM_PLUG, ":plug:getstate");

        // Set a timer for timeout after 2 seconds
        llSetTimerEvent(TIMEOUT_DURATION);
        
    }

    timer()
    {
        
        // If no response has been received after the delay, make the plug visible
        if (!g_iHasReceivedResponse)
        {
        
            // Make the plug visible
            llSetAlpha(1.0, ALL_SIDES); 
            //llOwnerSay("No response from collar, plug is now visible.");
        
        }
        
        // Disable the timer
        llSetTimerEvent(0.0);
    
    }

    listen(integer channel, string name, key id, string message)
    {
        
        //llOwnerSay("Message : " + message);
        
        // If the message comes from an object that was the same wearer
        // avoiding than anyone else can control the plug's state
        if (channel == MSG_TO_PLUG && llGetOwnerKey(id) == llGetOwner())
        {
            
            // React based on the plug state received from the collar
            if (message == ":plug:hide")
            {
                
                // Make the plug invisible
                llSetAlpha(0.0, ALL_SIDES); 
                
                // That becomes true after a explicit state has been provided
                g_iHasReceivedResponse = TRUE;

            }
            else if (message == ":plug:unhide")
            {
                
                // Make the plug visible
                llSetAlpha(1.0, ALL_SIDES);
                
                // That becomes true after a explicit state has been provided
                g_iHasReceivedResponse = TRUE;

            }

            // Disable the timer as a response has been received
            llSetTimerEvent(0.0);
            
        }
    
    }

}
