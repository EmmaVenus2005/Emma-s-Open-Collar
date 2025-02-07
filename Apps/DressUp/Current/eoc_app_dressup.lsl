// oc_dressup_app.lsl - DressUp clothing management script
// Designed by EmmaVenus2005 (2024) for OpenCollar
//
// This script is licensed under the GPL (General Public License). You are free to distribute and modify it
// as long as any modified versions remain under GPL and credit the original authors.
//
// How it works:
// This script interacts with the #RLV system to manage clothing and outfits in the folder "#RLV/~wearings/".
// Inside this folder, subfolders represent categories of clothing (such as Pants, Shirts, etc.).
//
// Each subfolder within a category represents a clothe for that specific category. When aclothe is selected,
// it replaces the currently worn in that category. For example, choosing a new pair of pants in the "Pants" category
// will replace the one already being worn.
//
// The items inside each subfolder should contain everything necessary for that clothe (clothing, alphas, HUDs, etc.)
// to avoid missing elements when something is worn.
//
// The Category names may contain flags, inside () and separated by - :
// Example : Undies (flag1-flag2)
// 
// Flags :  mandatory    : No choice 'None' will be available, for example for hair, a truster can change them but never remove (will also not be taken off when stripped)
//          multiple     : Here you can wear multiple items, like jewelry, you may add/remove earrings or piercing, each one independantly         
//          keepon       : Will not be removed when a truster strips you naked (cuffs, jewelry, ...)
//          hidegenitals : If an item of this category is wore, the genitals will be hidden (for compatible ones), used to avoid the genitals clipping with underwear/pants
//          hideplug     : If an item of this category is worn, compatible anal plugs will hide (same usage as below)

// Emma on 2024/11/05 (Version 0.90)
//
// - This version gets rid of the legacy LSL code. Instead, calls my server-side flow system : https://github.com/EmmaVenus2005/Emma-s-Open-Collar,
// - Created a HUD for quick access (wearer only), to open the home menu of DressUp,
// - Implemented the Give HUD option in main manu,
// - Implemented related categories (rel:catname), making that wearing a pant it will remove the worn skirt (needs both categories to be related)

// Further ideas
//
// - Add a 'resetfeet' flag, in order that if something from that category is taken off, the feet will reset to initial state (flat).
//   This will avoid to take off high heels and have feet that remain raised, even tho been bare.
//   For now, I investgated about how to do that with Lara X, and since they keep their communication secret,
//   that would need an invisible shoe to be worn, but would need to self-detach.
//   Interesting topic found : https://community.secondlife.com/forums/topic/478988-automagic-feet-changer-for-maitreya-body/
// - Add 'hidenipples' flag, and find out how to do with Lara X (other may come)
// - Add related categories
// - Add flags for body parts, and use them for RLV stripping. Example : RLV detaches item worn on pelvis. That means that we want take off underwear, 
//   but pelvis may have worn other items (vagina, anal plug, ...). We should be able to say that a specific DressUp category corresponds to pelvis (like Undies).


// Constant Definitions for OpenCollar Menu, RLV, and Permissions Handling

// Menu Interaction Constants
integer MENUNAME_REQUEST = 3000;        // Request the name of the app or submenu for display
integer MENUNAME_RESPONSE = 3001;       // Respond with the name of the app or submenu
integer MENUNAME_REMOVE = 3003;         // Remove the app or submenu from the menu

// Script Lifecycle Constants
integer STARTUP = -57;                  // Indicates that the script is starting up
integer ALIVE = -55;                    // Indicates that the script is active and running
integer READY = -56;                    // Indicates that the script is initialized and ready
integer REBOOT = -1000;                 // Reboot the script to reset it

// Command Constants for Permissions
integer CMD_OWNER = 500;                // Command sent by the owner of the object
integer CMD_TRUSTED = 501;              // Command sent by trusted users
integer CMD_GROUP = 502;                // Command sent by members of the object's group
integer CMD_WEARER = 503;               // Command sent by the wearer of the object
integer CMD_EVERYONE = 504;             // Command sent by anyone (public command)

// Constants used for HTTP requests using oc_nonvolatile
integer NV_REQUEST = 10800;
integer NV_RESPONSE = 10801;

// Channel for ASS : Advanced Sore System (more info soon)
integer ASS_CHANNEL = -696969;

// App specific data
string g_sParentMenu = "Apps";          // Parent menu where DressUp will appear
string g_sSubMenu = "DressUp";          // Name of the DressUp app


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

    state_entry()
    {
        
        // Listening -696969 channel (ASS : Advanced Sore System)
        llListen(ASS_CHANNEL, "", NULL_KEY, "");

    }

    // Listen for the response from the RLV system with the list of folders
    listen(integer channel, string name, key id, string message)
    {
        
        // Debug
        //llOwnerSay("Message: " + message);

        // If not ASS message coming from same wearer, ignored
        if (!(channel == ASS_CHANNEL && llGetOwnerKey(id) == llGetOwner())) { return; }
        
        if (message == ":app:dressup:home") 
        {
            
            // Starting the flow  
            llMessageLinked(LINK_SET, NV_REQUEST, "flowstart|dressup|" + (string)llGetOwner(), NULL_KEY);

        }

    }

    // Handle link messages for menu interaction
    link_message(integer iSender, integer iNum, string sStr, key kID)
    {
        
        // Used to register the App in the main menu
        if (iNum == MENUNAME_REQUEST && sStr == g_sParentMenu)
        {
            
            // Respond with the name of the app in the "Apps" menu
            llMessageLinked(iSender, MENUNAME_RESPONSE, g_sParentMenu + "|" + g_sSubMenu, "");

        }
        
        // Has to check if the message has been triggeered by an avatar
        else if (iNum >= CMD_OWNER && iNum <= CMD_EVERYONE)
        { 
            
            // Avoids executing further when we're not on the root level from this app
            if (llSubStringIndex(sStr, llToLower(g_sSubMenu)) && sStr != "menu " + g_sSubMenu) return;

            // Starting the flow  
            llMessageLinked(LINK_SET, NV_REQUEST, "flowstart|dressup|" + (string)kID, NULL_KEY);
         
        // Reset script on reboot
        } else if (iNum == REBOOT) 
        {
        
            //llOwnerSay("Rebooting script.");
            llResetScript();  
        
        }

    }

}
