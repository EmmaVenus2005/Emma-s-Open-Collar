<?php

// Ensure necessary variables are available
if (!isset($appid, $uuid, $name, $conn, $session)) {
    error_log("Required variables are not set.");
    exit();
}

// Constants that will identify the current flow step
//const 'EXIT' = -1;
//const 'MAIN' = 0;
//const 'INDIVIDUAL' = 1;

// Constants for authenticating the user that navigates in the collar ($session)
define('AUTH_OWNER', 500);

// Navigation variables
$flowStep = 0;

while ($flowStep != -1)
{

	// Initial step
	if ($flowStep == 0)
	{

		$dialog = "\nDressUp App [0.90]\n\n";
		$dialog .= "[Indiv.] : Manage individual clothing parts\n\n";
		$dialog .= "[Outfits] : Wear a complete oufit that you previously saved\n\n";
		$dialog .= "[Save] : Save the current outfit\n\n";
		$dialog .= "[Strip] : Strip completely\n\n";
		$dialog .= "[HUD] : Gives you the HUD for DressUp quick access\n\n";
		
		$options = ["Indiv.", "Outfits", "Save", "Strip", "HUD"];
		
		// Sending the dialog to the avatar
		$answer = SLDialog($dialog, $options, $session);
		
		switch ($answer) {
		    case "Indiv.": 	$flowStep = 1; break;
		    case "Outfits":	$flowStep = 2; break;
		    
		    // This happens when BACK is hit ; you're supposed to implement what happens
		    // Usually set the flow step on previous step
		    case "BACK" : 
		    
			    // Back to OpenCollar Apps
			    SLMessageLinked(-1, AUTH_OWNER, "menu Apps", $session);
			    $flowStep = -1; break;
		    
		    // This happens when the request times out or an error occurs
		    // Should be there in every flow step to ensure the session is closed
		    default:
		    
			// Exits the flow
			$flowStep = -1;
			break;
		
		}
				
	// Individual clothing
	} elseif ($flowStep == 1)
	{
	
		$dialogText = "This is a test dialog\n\nChoose your option:\n0 - First choice\n1 - Second choice\n2 - Third choice";

		$result = SLDialog(
		    $dialogText,
		    ["Option 1", "Option 2", "Option 3", "Option 4", "Option 5", "Option 6", "Option 7", "Option 8", "Option 9", "Option 10", "Option 11", "Option 12", "Option 13"],
		    $session
		);
		
		// Exits the flow
		$flowStep = -1;
	
	// Outfits
	} elseif ($flowStep == 2)
	{
	
		// Header of the dialog
		$dialog = "\nDressUp App / Complete outfits\n\n";
		$dialog .= "Choose the outfit to wear :\n\n";
		
		// Gets the list of outfits
		$lists = NVGetLists("Outfit");
		
		// List of choices
		$options = [];
		
		// Looping through those elements
		foreach($lists as $i => $list)
		{
			
			// Adding the outfit list in the dialog and options
			$dialog .= (string)($i + 1) . " - " . $list . "\n";
			$options[] = (string)($i + 1);
		
		}
		
		// Sending the dialog to the avatar
		$answer = SLDialog($dialog, $options, $session);
				
		// Exits the flow
		$flowStep = -1;
	
	}

}

exit();

?>

