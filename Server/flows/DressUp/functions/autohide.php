<?php

// Function that belongs to DressUp app and hides genitals and plug when needed
function DUAutoHide(Clothings $clothings)
{

    // Global session variables
    global $conn, $appid, $uuid, $name, $session;

    // Initializing variables
    $hideGenitals = false;
    $hidePlug = false;
    $hideNipples = false;
    $leaveFeet = false;

    // Initializing the array for RLV commands
    $rlv = [];

    // Looping through all categories to check their flags
    foreach ($clothings->ListCategories() as $category) 
    {
        
        // If the category has flag "hideplug" and at least one item is worn
        if ($clothings->HasFlag($category, "hideplug") && $clothings->CategoryWorn($category))
        {

            $hidePlug = true;

        }

        // If the category has flag "hidegenitals" and at least one item is worn
        if ($clothings->HasFlag($category, "hidegenitals") && $clothings->CategoryWorn($category))
        {

            $hideGenitals = true;

        }

        // If the category has flag "hidenipples" and at least one item is worn
        if ($clothings->HasFlag($category, "hidenipples") && $clothings->CategoryWorn($category))
        {

            $hideNipples = true;

        }

        // If the category has flag "resetfeet" and at least one item is worn
        if ($clothings->HasFlag($category, "resetfeet") && $clothings->CategoryWorn($category))
        {

            $leaveFeet = true;

        }

    }
    
    // Plug has to be hidden
    if ($hidePlug)
    {

        // For my own plug implementation of hide / unhide script
        $MSG_TO_PLUG = -47832; 
        SLRegionSayTo(":plug:hide", $MSG_TO_PLUG, $uuid);
        
        // Add any other commands here for different manufacturers

    // Plug has to be visible
    } else
    {

        // For my own plug implementation of hide / unhide script
        $MSG_TO_PLUG = -47832;
        SLRegionSayTo(":plug:unhide", $MSG_TO_PLUG, $uuid);
        
        // Add any other commands here for different manufacturers

    }

    // Genitals to be hidden
    if ($hideGenitals)
    {

        // Sapphos vagina hiding
        $MSG_TO_SAPPHOSVAG = 55;
        SLRegionSayTo("hidevag", $MSG_TO_SAPPHOSVAG, $uuid);

        // Add any other commands here for different manufacturers

    // Genitals to unhide
    } else
    {

        // Sapphos vagina hiding
        $MSG_TO_SAPPHOSVAG = 55;
        SLRegionSayTo("resetvag", $MSG_TO_SAPPHOSVAG, $uuid);

        // Add any other commands here for different manufacturers

    }

    // Nipples to be hidden (HAS TO HAVE OBJECT IN #RLV FOLDER)
    if ($hideNipples)
    {

        // Attaching the invisible box that hides nipples
        $rlv[] = "attachover:~outfits/~utils/~larax/hidenipples=force";

    // Nipples to be visible
    } else
    {

        // Detaching the invisible box that hides nipples
        $rlv[] = "detach:~outfits/~utils/~larax/hidenipples=force";

    }

    // Feet to be reset to flat (HAS TO HAVE OBJECT IN #RLV FOLDER)
    if (!$leaveFeet)
    {

        // Attaching the invisible box that resets feet to flat
        $rlv[] = "attachover:~outfits/~utils/~larax/feet:flat=force";

    } else
    {

        // Detaching the invisible box that resets feet to flat
        $rlv[] = "detach:~outfits/~utils/~larax/feet:flat=force";

    }

    // Sending RLV commands (if any)
	if ($rlv) { SLRLVCommand($rlv); }

}


?>
