// oc_dressup.lsl - DressUp clothing management script
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

// Constant Definitions for OpenCollar Menu, RLV, and Permissions Handling

// Menu Interaction Constants
integer MENUNAME_REQUEST = 3000;  // Request the name of the app or submenu for display
integer MENUNAME_RESPONSE = 3001; // Respond with the name of the app or submenu
integer MENUNAME_REMOVE = 3003;   // Remove the app or submenu from the menu

// Dialog Interaction Constants
integer DIALOG = -9000;           // Open a dialog (menu) for the user
integer DIALOG_RESPONSE = -9001;  // Handle the user's response to a dialog (menu)
integer DIALOG_TIMEOUT = -9002;   // Triggered when the dialog times out (no response)

// Script Lifecycle Constants
integer STARTUP = -57;
integer ALIVE = -55;              // Indicates that the script is active and running
integer READY = -56;              // Indicates that the script is initialized and ready
integer REBOOT = -1000;           // Reboot the script to reset it

// Command Constants for Permissions
integer CMD_OWNER = 500;          // Command sent by the owner of the object
integer CMD_TRUSTED = 501;        // Command sent by trusted users
integer CMD_GROUP = 502;          // Command sent by members of the object's group
integer CMD_WEARER = 503;         // Command sent by the wearer of the object
integer CMD_EVERYONE = 504;       // Command sent by anyone (public command)

// RLV (Restrained Life Viewer) Command Constants
integer RLV_CMD = 6000;           // Send an RLV command (e.g., restrict, allow)
integer RLV_REFRESH = 6001;       // Refresh the current RLV restrictions
integer RLV_OFF = 6100;           // Notify scripts that RLV is disabled
integer RLV_ON = 6101;            // Notify scripts that RLV is enabled
integer SAFEWORD = 510;           // Safeword command to release all RLV restrictions

// RLV Command Constants
integer RLV_CHANNEL = -1812221817;   // A private RLV channel for communication

// App specific data
string g_sParentMenu = "Apps";          // Parent menu where DressUp will appear
string g_sSubMenu = "DressUp";          // Name of the DressUp app
string g_sBasePath = "~wearings/";      // Base path for wearings

// This allows to store folder content
list g_lCatNames;                       // List of categories to display in the menu (cleaned without parameters)
list g_lCatFolders;                     // Folders of categories (actual folder names)
list g_lSubfolders;                     // List of subfolders
list g_lFolderFlags;                    // Flags of the categories
integer g_iNextCategory = 0;            // Used to know in which category belongs the next message

// The navigation variables
list g_lMenuIDs;                        // Track open menus
integer g_iMenuStride = 4;              // Adjust stride for menu handling
string UPMENU = "BACK";


// Main function to handle dialog and responses
Dialog(integer iWay, string sAnswer, integer iAuth, string sMenu,string sParams, integer iPage, key kID) {

    if (sMenu == "Menu~Main") {
    
        // 10 : Dialog Main Menu    
        if (iWay == DIALOG)
        {
            
            string sPrompt = "\n[DressUp] (V0.8)";
            OCDialog(kID, sPrompt, ["Individual clothes","Complete outfits","Strip completely"], [UPMENU], iPage, iAuth, sMenu, sParams);

        } else // 10 : Response Main Menu
        {
            
            integer MSG_TO_PLUG = -47832;   // Anal plug's request channel
            integer MSG_FROM_PLUG = -47833; // Anal plug's response channel
            
            if (sAnswer == "TestHidePlug")              // If the user tests the plug hiding
            {
                    
                llRegionSayTo(llGetOwner(), MSG_TO_PLUG, ":plug:hide");
                Dialog(DIALOG, sAnswer, iAuth, sMenu, sParams, 0, kID);
                
            } else if (sAnswer == "TestUnhidePlug")     // If the user tests the plug unhiding
            {
                
                llRegionSayTo(llGetOwner(), MSG_TO_PLUG, ":plug:unhide");
                Dialog(DIALOG, sAnswer, iAuth, sMenu, sParams, 0, kID);
                  
            } else
            {
            
                // Call Dialog at the end to render the next step (if needed)
                Dialog(DIALOG, sAnswer, iAuth, sMenu + "~" + sAnswer, sParams, 0, kID);
        
            }
        
        }
 
    } else if (sMenu == "Menu~Main~Individual clothes") {
    
        // 20 : Individual Clothes Menu    
        if (iWay == DIALOG)
        {
            
            // Copying global in local to leave time for the refresh, while
            // displaying the categories
            list l_lCatNames = g_lCatNames;

            // If the parameter 'needsrefresh' is 'true', will be done while user is choosing next action
            if (GetValue(sParams,"needsrefresh") == "true")
            {

                // This will refresh the wearings list, and hide/unhide genitals and plug
                RefreshWearings();

                // Setting the param to 'false' to avoid unnecessary refreshes
                sParams = SetValue(sParams,"needsrefresh","false");

            }

            string sPrompt = "\n[DressUp / Individual clothes]";
            OCDialog(kID, sPrompt, l_lCatNames, [UPMENU], iPage, iAuth, sMenu, sParams);

        } else // 20 : Response Individual Clothes
        {

            // Call Dialog at the end to render the next step (if needed)
            Dialog(DIALOG, sAnswer, iAuth, sMenu + "~Browse", sParams, 0, kID);
        
        }
 
    } else if (sMenu == "Menu~Main~Individual clothes~Browse") {
    
        // 21 : Individual Clothes Category Browsing   
        if (iWay == DIALOG)
        {

            // Setting up the category parameter
            sParams = SetValue(sParams,"category",sAnswer);
            
            // Creating a local list of elements in current category
            list l_lList;

            // Stores the state of multiple flag to avoid multiple calls
            integer l_iMultiple = FolderHasFlag(sAnswer,"multiple");

            // If at least one worn from the category, will flag the 'none' choice as now worn
            integer l_iAtLeastOneWorn = 0;

            // If 'multiple' flagged category, the dialog text will specify it
            string l_sMultipleChoicesText = "";
            if (l_iMultiple) { l_sMultipleChoicesText = "\nMultple choices, toggle wear / unwear"; }
            
            // Adding subfolders in the choice list
            l_lList += GetCategorySubfolders(sAnswer);

            // The items will be prefixed with ( ) or (x), or [ ] or [x] when multiple
            integer i;
            for (i = 0; i < llGetListLength(l_lList); i++) 
            {
                
                // Get the current item
                string l_sCurrentItem = llList2String(l_lList, i);

                // Get the wore status of the category
                string l_sWoreStatus = GetWoreStatus(sAnswer + "/" + l_sCurrentItem);

                // String declaration that will contain the prefix 
                string l_sPrefix;

                // In case of 'multiple' flag, [] will be used
                if (l_iMultiple)
                {
                    
                    // Check the first character of the wore status
                    if (llGetSubString(l_sWoreStatus, 0, 0) == "2" || llGetSubString(l_sWoreStatus, 0, 0) == "3") 
                    {

                        l_sPrefix = "[x]";

                    } else { l_sPrefix = "[ ]"; }

                } else  // No 'multiple' flag for the category, using ( )
                {
                    
                    // Check the first character of the wore status
                    if (llGetSubString(l_sWoreStatus, 0, 0) == "2" || llGetSubString(l_sWoreStatus, 0, 0) == "3") 
                    {

                        l_sPrefix = "(x)";
                        l_iAtLeastOneWorn = 1;

                    } else { l_sPrefix = "( )"; }

                }

                // Update the item in the list with prefix
                l_lList = llListReplaceList(l_lList, [l_sPrefix + " " + l_sCurrentItem], i, i);

            }

            // Adding 'none' option (only if no 'mandatory' or multiple parameter)
            if (!(FolderHasFlag(sAnswer,"mandatory") || l_iMultiple)) 
            { 
                
                if (l_iAtLeastOneWorn == 1) { l_lList += ".( ) < None >"; }
                else { l_lList += ".(x) < None >"; } 
                
            }
                        
            string sPrompt = "\n[DressUp / Individual clothes / " + sAnswer + "]" + l_sMultipleChoicesText;
            OCDialog(kID, sPrompt, l_lList, [UPMENU], iPage, iAuth, sMenu, sParams);

        } else // 21 : Response Individual Clothes Category Browsing
        {
            
            // Gets the category in a local variable (avoids calling the logic multiple times)
            string l_sCategory = GetValue(sParams,"category");

            // Getting the category folder
            string l_sCategoryFolder = GetCategoryFolder(l_sCategory);

            // Getting all subfolder of this category
            list l_lCategoryItems = GetCategorySubfolders(l_sCategory);

            // Getting the answer without the (x) prefix (wore status)
            string l_sCleanAnswer = llGetSubString(sAnswer, 4, -1);

            // Getting the wore status prefix ( ) (x) [ ] [x]
            string l_sWoreStatusPrefix = llGetSubString(sAnswer, 0, 2);

            // If we're in multiple choice and the selected item is worn
            if (l_sWoreStatusPrefix == "[x]")
            {

                // Taking off the selected item
                llMessageLinked(LINK_SET, RLV_CMD, "detach:" + g_sBasePath + l_sCategoryFolder + "/" + l_sCleanAnswer + "=force", NULL_KEY);

            // If we're in multiple choice and the selected item is NOT worn
            } else if (l_sWoreStatusPrefix == "[ ]")
            {

                // Wearing the selected item
                llMessageLinked(LINK_SET, RLV_CMD, "attachover:" + g_sBasePath + l_sCategoryFolder + "/" + l_sCleanAnswer + "=force", NULL_KEY);


            } else  // Here we're not in multiple mode, so selected is worn and other from same cat unworn
            {

                // Wearing the selected item
                llMessageLinked(LINK_SET, RLV_CMD, "attachover:" + g_sBasePath + l_sCategoryFolder + "/" + l_sCleanAnswer + "=force", NULL_KEY);

                // Loop through all items in the category to detach them (except the selected one)
                integer i;
                for (i = 0; i < llGetListLength(l_lCategoryItems); i++) 
                {
                
                    // Current element
                    string l_sItem = llList2String(l_lCategoryItems, i);

                    // Skip the currently selected item
                    if (l_sItem != l_sCleanAnswer) {

                        // Compose the full path of the current item
                        string l_sFullPath = g_sBasePath + l_sCategoryFolder + "/" + l_sItem;

                        // Send an RLV command to detach each item from the category
                        llMessageLinked(LINK_SET, RLV_CMD, "detach:" + l_sFullPath + "=force", NULL_KEY);

                    }

                }

            }

            // This will trigger a refresh when back to the dialog
            // Can't be done here because the dialog options would miss
            // When done after this list of categories have been created,
            // the refresh can be done while the user chooses his next action
            sParams = SetValue(sParams,"needsrefresh","true");
           
            // Call Dialog at the end to render the next step (if needed)
            Dialog(DIALOG, sAnswer, iAuth, "Menu~Main~Individual clothes", sParams, 0, kID);
        
        }
 
    } else if (sMenu == "Menu~Main~Strip completely") {
    
        // 40 : Complete Stripping Menu    
        if (iWay == DIALOG)
        {
            
            string sPrompt = "\n[DressUp / Strip completely]\n\nAre you sure you want to strip her completely ?\nEnsure that you're at a place where nudity is allowed.";

            OCDialog(kID, sPrompt, ["Strip her"], [UPMENU], iPage, iAuth, sMenu, sParams);

        } else // 40 : Response Complete Stripping
        {

            // Loop through all categories (g_lCatFolders contains the full list of categories)
            integer i;
            for (i = 0; i < llGetListLength(g_lCatNames); i++) 
            {
    
                // Get the current item from the loop
                string l_sCategory = llList2String(g_lCatNames, i);
                
                // Skip categories with 'keepon' or 'mandatory' flags
                if (!(FolderHasFlag(l_sCategory, "keepon") || FolderHasFlag(l_sCategory, "mandatory"))) 
                { 
                    
                    // Get the subfolders (clothes items) for this category
                    list l_lCategoryItems = GetCategorySubfolders(l_sCategory);
            
                    // Loop through all items in the category to detach them
                    integer j;
                    for (j = 0; j < llGetListLength(l_lCategoryItems); j++) 
                    {
                        
                        // Current item
                        string l_sItem = llList2String(l_lCategoryItems, j);

                        // Send an RLV command to detach each item
                        llMessageLinked(LINK_SET, RLV_CMD, "detach:" + g_sBasePath + GetCategoryFolder(l_sCategory) + "/" + l_sItem + "=force", NULL_KEY);
                        //llOwnerSay("detach:" + g_sBasePath + GetCategoryFolder(l_sCategory) + "/" + l_sItem + "=force");

                    }

                }

                    
            }

            // This will refresh the wearings list, and hide/unhide genitals and plug
            RefreshWearings();

            // Get back to main menu once stripped
            Dialog(DIALOG, sAnswer, iAuth, "Menu~Main", sParams, 0, kID);
        
        }
 
    }
     
}

// Function to display a dialog menu with categories, using OpenCollar function
OCDialog(key kID, string sPrompt, list lChoices, list lUtilityButtons, integer iPage, integer iAuth, string sName, string sParams) 
{

    // Generate a unique menu ID for this instance
    key kMenuID = llGenerateKey();
    
    // Prepare the full message without the additional params
    string sMessage = (string)kID + "|" + sPrompt + "|" + (string)iPage + "|" + llDumpList2String(lChoices, "`") + "|" + llDumpList2String(lUtilityButtons, "`") + "|" + (string)iAuth + "|1";

    // Send a message with the menu details, excluding sParams
    llMessageLinked(LINK_SET, DIALOG, sMessage, kMenuID);

    // Find the existing menu for this user (if any)
    integer iIndex = llListFindList(g_lMenuIDs, [kID]);

    // If the menu for this user already exists, replace the old entry with the new one
    if (~iIndex) 
    {
        g_lMenuIDs = llListReplaceList(g_lMenuIDs, [kID, kMenuID, sName, sParams], iIndex, iIndex + g_iMenuStride - 1);
    } 
    else 
    {
        // Otherwise, add a new entry to the menu list
        g_lMenuIDs += [kID, kMenuID, sName, sParams];
    }

}

// Extracts the folder name and parameters from the wearing categories
// Example : Hair (mandatory-testflag)
// Will return Hair, and add 'Hair|mandatory' and 'Hair|testflag' to g_lFolderParams
string ExtractFlags(string input) 
{

    // Find the position of the opening and closing parentheses
    integer openParen = llSubStringIndex(input, "(");
    integer closeParen = llSubStringIndex(input, ")");

    // Define folderName to store the name of the folder (or category)
    string folderName;

    // Define params to store the parameters extracted from parentheses
    string params;

    if (openParen != -1 && closeParen != -1 && closeParen > openParen) {
        // If parentheses exist, extract the folder name and parameters
        folderName = llGetSubString(input, 0, openParen - 1); // Text before the parentheses
        params = llGetSubString(input, openParen + 1, closeParen - 1); // Text between the parentheses
    } else {
        // If parentheses don't exist, treat the whole input as the folder name
        folderName = input;
        params = "";
    }

    // Trim any spaces from the start and end of the folder name (keep internal spaces)
    folderName = llStringTrim(folderName, STRING_TRIM);

    // Add new parameters if they exist
    if (llStringLength(params) > 0) {
        // Split the parameters by comma
        list paramList = llParseString2List(params, ["-"], []);
        integer i;
        for (i = 0; i < llGetListLength(paramList); i++) {
            string param = llList2String(paramList, i);
            g_lFolderFlags += [folderName + "|" + llStringTrim(param, STRING_TRIM)]; // Add 'folderName|param' to the global list
        }
    }

    // Return the folder name without parameters
    return folderName;
}

// Function to check if a folder has a specific flag
// Example : FolderHasFlag("Undies", "testflag") returns 1, exists
//           FolderHasFlag("Undies", "doesnotexist") returns 0, doesn't exist
integer FolderHasFlag(string sFolder, string sFlag) 
{

    // Loop through the list of folder parameters
    integer i;
    for (i = 0; i < llGetListLength(g_lFolderFlags); i++) {
        string folderFlags = llList2String(g_lFolderFlags, i);
        
        // Split the folder parameter into folder name and flags
        list entryParts = llParseString2List(folderFlags, ["|"], []);
        
        // Check if the folder matches sFolder
        if (llList2String(entryParts, 0) == sFolder) {
            // Get the flags part and split them by '-'
            list flagList = llParseString2List(llList2String(entryParts, 1), ["-"], []);
            
            // Check if the flag is present
            if (~llListFindList(flagList, [sFlag])) {
                return 1;  // Flag found
            }
        }
    }
    
    return 0;  // Flag not found

}

// Returns the folder from the "clean" name of a category : Undies returning Undies (flag1-flag2)
string GetCategoryFolder(string sCategory)
{

    // Find the index of the given category in g_lCatNames
    integer l_iIndex = llListFindList(g_lCatNames, [sCategory]);

    // Check if the category was found
    if (l_iIndex != -1) 
    {
        // Get the corresponding folder from g_lCatFolders based on the found index
        return llList2String(g_lCatFolders, l_iIndex);
    }
    
    // Return an empty string if the category is not found
    return "";

}

// Returns a list of subfolders from a given category
list GetCategorySubfolders(string sCategory)
{
    
    // Temp list for output
    list l_lSubfoldersList = [];
    
    // Loop through all the subfolders
    integer i;
    for (i = 0; i < llGetListLength(g_lSubfolders); i++) 
    {

        // Getting the current line
        string l_sTempSubfolder = llList2String(g_lSubfolders, i);                
        
        // Split the current line using a comma
        list l_lTempList = llParseString2List(l_sTempSubfolder, [","], [""]);            

        // Proceed only if the first element of the line matches the given category
        if (llGetSubString(llList2String(l_lTempList, 0), 0, -4) == sCategory)
        {
            
            // Loop through the remaining elements in the list (skip the first, which is the category name)
            integer j;
            for (j = 1; j < llGetListLength(l_lTempList); j++) 
            {

                // Add the subfolder (without the last 3 characters) to the list
                l_lSubfoldersList += llGetSubString(llList2String(l_lTempList, j), 0, -4);

            }

        }

    }
    
    return l_lSubfoldersList;

}

// Function to set or update a key-value pair in sParams (Dialog)
string SetValue(string sParams, string sKey, string sValue) 
{

    // Parse the existing sParams into a list
    list paramList = llParseString2List(sParams, [","], []);
    integer keyIndex = llListFindList(paramList, [sKey]);

    // If the key exists, update its value
    if (keyIndex != -1) {
        paramList = llListReplaceList(paramList, [sValue], keyIndex + 1, keyIndex + 1);
    } else {
        // If the key doesn't exist, add the new key-value pair
        paramList += [sKey, sValue];
    }

    // Convert the list back to a string with '|' separator
    return llDumpList2String(paramList, ",");

}

// Function to get the value associated with a key in sParams (Dialog)
string GetValue(string sParams, string sKey) 
{
 
    // Parse sParams into a list
    list paramList = llParseString2List(sParams, [","], []);
    integer keyIndex = llListFindList(paramList, [sKey]);

    // If the key exists, return its corresponding value
    if (keyIndex != -1) {
        return llList2String(paramList, keyIndex + 1);
    }

    // If the key doesn't exist, return an empty string
    return "";

}

// Function to get the wore status of a folder or subfolder
string GetWoreStatus(string sFolder) 
{

    // g_lSubfolders line example :
    // Bottoms|02,Skinny jeans white|10,Skinny jeans dark blue|10,Red tight leggins|10,Dark blue shred jeans|10,Pink tight skirt|10,Loose skirt multicolor|10,Tight pink pants|30,Ultra short skirt|10
    // Structure is : category name|<category_wore_status>,First subdir|<first_subdir_wore_status>|...
    //
    // Will return the wore status of weither the category, or a specific subfolder of a category (examples below)
    //
    // Usage will be : GetWoreStatus("Bottoms") returning 02
    //            or : GetWoreStatus("Bottoms/Red tight leggins") returning 10
    
    // Loop through g_lSubfolders to find the matching folder or subfolder
    integer i;
    for (i = 0; i < llGetListLength(g_lSubfolders); i++) 
    {
        
        // Get the current line (category and its subfolders)
        string l_sLine = llList2String(g_lSubfolders, i);
        
        // Separate the category and subfolder status using commas
        list l_lEntries = llParseString2List(l_sLine, [","], []);
        
        // Get the category name and its wore status
        list l_lCategoryEntry = llParseString2List(llList2String(l_lEntries, 0), ["|"], []);
        string l_sCategory = llList2String(l_lCategoryEntry, 0);
        string l_sCategoryStatus = llList2String(l_lCategoryEntry, 1);
        
        // Check if the requested folder matches the category (e.g., "Bottoms")
        if (sFolder == l_sCategory) {
            // Return the wore status for the category as a string (e.g., "02")
            return l_sCategoryStatus;
        }
        
        // Check if the requested folder is a subfolder (e.g., "Bottoms/Red tight leggins")
        if (llSubStringIndex(sFolder, l_sCategory + "/") == 0) 
        {
        
            // Extract the subfolder part from sFolder
            string l_sSubfolder = llGetSubString(sFolder, llStringLength(l_sCategory) + 1, -1);
            
            // Loop through the remaining entries (subfolders) to find the wore status
            integer j;
            for (j = 1; j < llGetListLength(l_lEntries); j++) 
            {
            
                list l_lSubfolderEntry = llParseString2List(llList2String(l_lEntries, j), ["|"], []);
                string l_sSubfolderName = llList2String(l_lSubfolderEntry, 0);
                string l_sSubfolderStatus = llList2String(l_lSubfolderEntry, 1);
                
                if (l_sSubfolder == l_sSubfolderName) {
                    // Return the wore status for the matching subfolder as a string (e.g., "10")
                    return l_sSubfolderStatus;
                }
            }
        }
    }

    // Return empty string if no match is found (category or subfolder not found)
    return "";

}

// Gets the previous menu (used to apply BACK instriuction)
// Example : 'Menu~Main~Any menu' returns 'Menu~Main'
string GetPreviousMenu(string sMenu) 
{
    
    // Initialized with the length of the input
    integer lastTilde = llStringLength(sMenu) - 1;
    
    // Used to break the loop once a '~' found
    integer l_iFound = 0;
    
    // Looking for the last '~' 
    while (lastTilde >= 0 && l_iFound == 0) 
    {
        
        // Comparing if the current checked char is '~'
        if (llGetSubString(sMenu, lastTilde, lastTilde) == "~") {
            
            // Exists the loop
            l_iFound = 1;

        }

        // Decrementing the value for next loop (if revelant)
        lastTilde--;
        
    }
    
    // If a tile exists in the string, removes the last part and returns it
    if (lastTilde != -1) { return llGetSubString(sMenu, 0, lastTilde); }

    // If not found, returns the input string
    return sMenu;

}

// Function to update the visibility status of plugs based on the 'hideplug' flag in categories
// Not call it explicitly, will be called after wearings lists are refreshed
UpdatePlugStatus() 
{

    // Flag to track if the plug should be hidden (2 or 3 means hidden)
    integer shouldHidePlug = 0;
    
    // Loop through all categories
    integer i;
    for (i = 0; i < llGetListLength(g_lCatNames); i++) {
        
        // Get the current category name
        string sCategory = llList2String(g_lCatNames, i);
        
        // Check if the category has the 'hideplug' flag
        if (FolderHasFlag(sCategory, "hideplug")) {
            
            // Get the wore status of the category
            string woreStatus = GetWoreStatus(sCategory);
            
            // Check the second character of the wore status
            if (llGetSubString(woreStatus, 1, 1) == "2" || llGetSubString(woreStatus, 1, 1) == "3") 
            {
                
                shouldHidePlug = 1;

            }

        }

    }

    // Send the appropriate RLV command based on the wore status
    if (shouldHidePlug) 
    {
    
        // For my own plug implementation of hide / unhide script
        integer MSG_TO_PLUG = -47832;  
        integer MSG_FROM_PLUG = -47833;
        llRegionSayTo(llGetOwner(), MSG_TO_PLUG, ":plug:hide");
        
        // Add any other commands here for different manufacturers
    
    } else 
    {
    
        // For my own plug implementation of hide / unhide script
        integer MSG_TO_PLUG = -47832;  
        integer MSG_FROM_PLUG = -47833;
        llRegionSayTo(llGetOwner(), MSG_TO_PLUG, ":plug:unhide");
        
        // Add any other commands here for different manufacturers
    
    }

}

// Function to update the visibility status of plugs based on the 'hideplug' flag in categories
// Not call it explicitly, will be called after wearings lists are refreshed
UpdateGenitalsStatus() 
{

    // Flag to track if the plug should be hidden (2 or 3 means hidden)
    integer shouldHideGenitals = 0;
    
    // Loop through all categories
    integer i;
    for (i = 0; i < llGetListLength(g_lCatNames); i++) {
        
        // Get the current category name
        string sCategory = llList2String(g_lCatNames, i);
        
        // Check if the category has the 'hideplug' flag
        if (FolderHasFlag(sCategory, "hidegenitals")) {
            
            // Get the wore status of the category
            string woreStatus = GetWoreStatus(sCategory);
            
            // Check the second character of the wore status
            if (llGetSubString(woreStatus, 1, 1) == "2" || llGetSubString(woreStatus, 1, 1) == "3") 
            {
                
                shouldHideGenitals = 1;

            }

        }

    }
    
    // Send the appropriate command based on the wore status
    if (shouldHideGenitals) 
    {
    
        // Debug
        //llOwnerSay("Genitals hidden");

        // Sapphos vagina 
        // ! (Doesn't work since probably checks if messages comes from avatar UUID)
        // ! One solution could be to use a HUD, because HUD may send messages from user UUID
        integer MSG_TO_SAPPHOSVAG = 55;
        llRegionSayTo(llGetOwner(), MSG_TO_SAPPHOSVAG, "hidevag");
        
        // Add any other commands here for different manufacturers
    
    } else 
    {
    
        // Debug
        //llOwnerSay("Genitals visible");

        // Sapphos vagina
        integer MSG_TO_SAPPHOSVAG = 55;
        llRegionSayTo(llGetOwner(), MSG_TO_SAPPHOSVAG, "resetvag");
        
        // Add any other commands here for different manufacturers
    
    }

}

// To call after a change in wearings, in order to keep the list up to date
RefreshWearings()
{
    
    // Clear the global variables related to inventory and categories
    g_lCatNames = [];
    g_lCatFolders = [];
    g_lSubfolders = [];
    g_lFolderFlags = [];
    g_iNextCategory = 0;

    // Trigger the timer to reload the inventory
    llSetTimerEvent(1);
    
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
        
        // Setting up a short timer event to load wearings
        // (will be disabled once executed)
        llSetTimerEvent(1);
 
        // Define here the channels that need to be listened when app active
        llListen(RLV_CHANNEL, "", NULL_KEY, "");
        
    }
    
    timer() 
    {
    
        // Send RLV command to get the folders (categories)
        // (will be read into g_lCategories by listen event)
        // (listen will only get messages when all functions finished in the script,
        // so need to be fetched a first time at start, and updated when entering 
        // again in menu (function UserCommand)
        llMessageLinked(LINK_SET, RLV_CMD, "getinv:" + g_sBasePath + "=" + (string)RLV_CHANNEL, NULL_KEY);
        
        // No new execution until explicit execution (timer to 1 again)
        llSetTimerEvent(0);
        
    }

    // Listen for the response from the RLV system with the list of folders
    listen(integer channel, string name, key id, string message)
    {
        
        // Debug
        //llOwnerSay("Message: " + message);
        
        // This list is empty means that the message to listen is category list
        if(llGetListLength(g_lCatNames) == 0)
        {
           
           // Temp list with category names and parameters
           g_lCatFolders = llParseString2List(message, [","], []);
           
           // Loops through each element
           integer i = 0;
           for (; i < llGetListLength(g_lCatFolders); ++i)
           {
           
                // Extract the category parameters, and returns cat name
                g_lCatNames += ExtractFlags(llList2String(g_lCatFolders, i));

                // Sending the RLV message to get details of each list
                llMessageLinked(LINK_SET, RLV_CMD, "getinvworn:" + g_sBasePath + "/" + llList2String(g_lCatFolders, i) + "=" + (string)RLV_CHANNEL, NULL_KEY);
           
           }

        } else  // The categories have been loaded, now the details of each category will be read
        {

            // Getting the name of the current category    
            string l_sCurrentCategory = llList2String(g_lCatNames, g_iNextCategory);  
            
            // Adds the category content (leaded by cat name for further selection)
            g_lSubfolders += l_sCurrentCategory + message;
        
            //llOwnerSay(l_sCurrentCategory + message);
            
            // At the next loop, next category will have to be loaded
            g_iNextCategory++;

            // if we reached the last category
            if (g_iNextCategory == llGetListLength(g_lCatNames))
            {

                // The plugs are hidden if at least one 'hideplug' flagged category has worn items
                UpdatePlugStatus();
                UpdateGenitalsStatus();

            }

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
        else if(iNum >= CMD_OWNER && iNum <= CMD_EVERYONE)
        { 
            
            // Avoids executing further when we're not on the root level from this app
            if (llSubStringIndex(sStr, llToLower(g_sSubMenu)) && sStr != "menu " + g_sSubMenu) return;

            // Opening the initial menu of Dialog function
            Dialog(DIALOG, sStr, iNum, "Menu~Main", "", 0, kID);             

        }
        
        // Response from a previous dialog
        else if (iNum == DIALOG_RESPONSE) 
        {
            
            // Looking if this is an answer to a dialog from this app
            integer iMenuIndex = llListFindList(g_lMenuIDs, [kID]);
            
            // If we're in this app
            if (iMenuIndex != -1)
            {            
            
                // Gets the menu hierarchy
                string sMenu = llList2String(g_lMenuIDs, iMenuIndex + 1);
                
                // Gets the parameters
                string sParams = llList2String(g_lMenuIDs, iMenuIndex + 2);

                // Deletes the dialog token
                g_lMenuIDs = llDeleteSubList(g_lMenuIDs, iMenuIndex - 1, iMenuIndex - 2 + g_iMenuStride);                
                
                // Parse the response
                list lMenuParams = llParseString2List(sStr, ["|"], []);
                key kAv = llList2Key(lMenuParams, 0);
                string sMsg = llList2String(lMenuParams, 1);
                integer iPage = llList2Integer(lMenuParams, 2);
                integer iAuth = llList2Integer(lMenuParams, 3);
                                
                // Console log (can be turned on or off)
                // Implement a user config ?
                
                // If BACK button has been selected
                if (sMsg == UPMENU)
                {

                    // sMenu will get back from one level
                    sMenu = GetPreviousMenu(sMenu);

                    // Handle the case where user gets back to the Apps
                    if (sMenu == "Menu")
                    {
                                                
                        // Return to OpenCollar / Apps
                        llMessageLinked(LINK_SET, iAuth, "menu " + g_sParentMenu, kAv);
                        
                    } else
                    {
  
                        // Opening the dialog from upper menu
                        Dialog(DIALOG, sMsg, iAuth, sMenu, sParams, iPage, kAv);

                    }

                } else
                {
   
                    // Sending the response to the Dialog function
                    Dialog(DIALOG_RESPONSE, sMsg, iAuth, sMenu, sParams, iPage, kAv);                        
                        
                }
                
            }

        }
        else if (iNum == DIALOG_TIMEOUT) {
            //llOwnerSay("Dialog timed out.");  // Tu me that timeout dialog is annoying (does it have an usage?)
        }
        else if (iNum == REBOOT) {
            llOwnerSay("Rebooting script.");
            llResetScript();  // Reset script on reboot
        }
    }
    
}
