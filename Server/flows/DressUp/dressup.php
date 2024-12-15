<?php

// Ensure necessary variables are available
if (!isset($appid, $uuid, $name, $conn, $session)) {
    error_log("Required variables are not set.");
    exit();
}

// Constants for authenticating the user that navigates in the collar ($session)
define('AUTH_OWNER', 500);

// Custom variables
$g_basePath = "~wearings/";

// Navigation variables
$flowStep = "MAIN";

while ($flowStep != "EXIT")
{

	// Initial step
	if ($flowStep == "MAIN")
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
		    case "Indiv.": 	$flowStep = "MAIN/INDIV"; break;
		    case "Outfits":	$flowStep = "MAIN/OUTFITS"; break;
			case "Strip": $flowStep = "MAIN/STRIP"; break;
			case "Save": $flowStep = "MAIN/SAVE"; break;
			case "HUD": $flowStep = "MAIN/HUD"; break;
		    
		    // This happens when BACK is hit ; you're supposed to implement what happens
		    // Usually set the flow step on previous step
		    case "BACK" : 
		    
			    // Back to OpenCollar Apps
			    SLMessageLinked(-1, AUTH_OWNER, "menu Apps", $session);
			    $flowStep = "EXIT"; break;
		    
		    // This happens when the request times out or an error occurs
		    // Should be there in every flow step to ensure the session is closed
		    // default:
		    
			// // Exits the flow
			// $flowStep = "EXIT";
			// break;
		
		}
				
	// Individual clothing
	} elseif ($flowStep == "MAIN/INDIV")
	{
	
		// Creating an instance of the clothings class
		$clothings = new Clothings();
		
		// Header of the dialog
		$dialog = "\nDressUp App / Individual clothings\n\n";

		// Reading all categories
		$categories = $clothings->ListCategories();

		// List of choices
		$options = [];

		// Looping through categories
		foreach($categories as $i => $category)
		{

			$dialog .= (string)($i + 1) . " - " . $category . "\n";
			$options[] = (string)($i + 1);

		}

		// Sending the dialog to the avatar
		$answer = SLDialog($dialog, $options, $session);
		
		// If not BACK, timeout or HTTP error...
		if ($answer != "BACK" && $answer != NULL)
		{

			// Setting the $category for the next flow step
			$category = $categories[((int)$answer) - 1];
			
			// Jumping to category browsing
			$flowStep = "MAIN/INDIV/BROWSE";

		}

	// Individual clothing (browsing in a category)
	} elseif ($flowStep == "MAIN/INDIV/BROWSE")
	{

		// Gets all items from the category to browse
		$items = $clothings->GetItems($category);

		// If a "multiple" flagged category
		$multiple = $clothings->HasFlag($category, "multiple");

		// Header of the dialog
		$dialog = "\nDressUp App / Individual clothings / " . $category . "\n\n";

		if ($multiple)
		{ 

			$dialog .= "Select or unselect any item, multiple possible for that category :\n\n";

		} else 
		{

			$dialog .= "Select the item you want to wear, it will switch automatically :\n\n";

		}

		// List of choices
		$options = [];

		// If the category is not flagged as mandatory or multiple, adds the option "NONE"
		if (!$clothings->HasFlag($category, "mandatory") && !$multiple)
		{

			// Adding the "NONE" option
			$options[] = "NONE";				

		}

		// The choice list counter
		$i = 1;

		// Looping through items
		foreach ($items as $key => $value)
		{

			// If the item is worn, the leading "square" or "ring" is full, otherwise empty
			if ($value === 2 || $value === 3 || $value === 9)
			{ 

				$multiple === true ? $status = "■" : $status = "●";

			} else { $multiple === true ? $status = "□" : $status = "○"; }
			
			$dialog .= (string)$i . " - " . $status . " " . $key . "\n";
			$options[] = (string)$i;

			// Increasing the $i
			$i++;

		}

		// Sending the dialog to the avatar
		$answer = SLDialog($dialog, $options, $session);
		
		// If not BACK, timeout or HTTP error...
		if ($answer !== "BACK" && $answer !== null)
		{

			// Creating the list for RLV commands
			$rlv = [];

			// If "NONE" is selected, taking off all items from $category
			if ($answer === 'NONE')
			{

				// Looping through items
				foreach ($items as $key => $value)
				{

					// Preparing the RLV commands
					$rlv[] = "detach:" . $g_basePath . $clothings->GetCategoryFolder($category) . "/" . $key . "=force";

					// Updating the status in the current dataset from DB
					$clothings->SetItemStatus($category, $key, 0);

				}

			// If "multiple" flagged category, item is worn/unworn depending of current status
			} elseif ($multiple)
			{

				// Changing the key/value array into indexed array
				$keys = array_keys($items);

				// Gets the name of the item
				$selectedItem = $keys[(int)$answer - 1];

				// If the selected item is worn
				if (in_array($items[$selectedItem], [2, 3, 9]))
				{

					// Detaching the requested item
					$rlv[] = "detach:" . $g_basePath . $clothings->GetCategoryFolder($category) . "/" . $selectedItem . "=force";

					// Updating the status in the current dataset from DB
					$clothings->SetItemStatus($category, $selectedItem, 0);

				// If the selected item is NOT worn
				} else
				{

					// Attaching the requested item
					$rlv[] = "attachover:" . $g_basePath . $clothings->GetCategoryFolder($category) . "/" . $selectedItem . "=force";

					// Updating the status in the current dataset from DB
					$clothings->SetItemStatus($category, $selectedItem, 9);

				}			
			
			// Removing all items from category and related, and wearing the selected
			} else 	
			{

				// Changing the key/value array into indexed array
				$keys = array_keys($items);

				// Gets the name of the item
				$itemToWear = $keys[(int)$answer - 1];

				// Recovers the related categories
				$related = $clothings->GetRelated($category);

				// Looping through the related categories
				foreach ($related as $currentCat)
				{

					// Gets the list of item in the current category
					$items = $clothings->GetItems($currentCat);

					// Looping through the items
					foreach ($items as $currentItem => $currentStatus)
					{			

						// If the item is the one we selected, doesn't add it to the items to detach
						if (!($category === $currentCat && $itemToWear === $currentItem))
						{

							// Preparing the RLV commands
							$rlv[] = "detach:" . $g_basePath . $clothings->GetCategoryFolder($currentCat) . "/" . $currentItem . "=force";

							// Updating the status in the current dataset from DB
							$clothings->SetItemStatus($currentCat, $currentItem, 0);

						}

					}

				}

				// Attaching the requested item
				$rlv[] = "attachover:" . $g_basePath . $clothings->GetCategoryFolder($category) . "/" . $itemToWear . "=force";

				// Updating the status in the current dataset from DB
				$clothings->SetItemStatus($category, $itemToWear, 9);

			}

			// Sending RLV commands
			SLRLVCommand($rlv);

			DUAutoHide($clothings);

			// Back to individual clothing root
			$flowStep = "MAIN/INDIV";

		}
	
	// Outfits
	} elseif ($flowStep == "MAIN/OUTFITS")
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
		
		// If not BACK, timeout or HTTP error...
		if ($answer != "BACK" && $answer != null)
		{

			// Creating an instance of the clothings class
			$clothings = new Clothings();

			// Gets the name of the item
			$outfitToWear = $lists[(int)$answer - 1];

			// Gets the list of items in the selected outfit 
			// Tops/Santa helper pink top|Skirts/Santa helper pink skirt|Shoes/Santa helper pink heels|Undies (hideplug-hide/Santa helper pink thong
			$itemsToWear = NVGetList("Outfit", $outfitToWear);
			
			// Creating the list for RLV commands
			$rlv = [];
			
			// Array used to list items to lock (avoid removing them when removing all other items)
			$itemsToLock = [];

			// Looping through items to wear
			foreach (explode("|", $itemsToWear) as $currentItem)
			{
				
				// Takes the "clean" category name (without the flags, that may change after outfit save)
				$itemCleanCat = preg_replace('/\s*\(.*\)$/', '', explode("/", $currentItem)[0]);

				// Keeps only the actual item name (after /)
				$itemName = explode("/", $currentItem)[1];

				// Adding to the RLV commands list (Gets the current folder name / item name (second part after /))
				$rlv[] = "attachover:" . $g_basePath . $clothings->GetCategoryFolder($itemCleanCat) . "/" . $itemName . "=force";

				// Updating the status in the current dataset from DB
				$clothings->SetItemStatus($itemCleanCat, $itemName, 9);		

				// Updating the list of the objects to not remove in the next step
				$itemsToLock[] = (object)[
					'Category' => $itemCleanCat,
					'Item' => $itemName
				];

			}
			
			// Looping through all categories
			foreach ($clothings->ListCategories() as $currentCat)
			{

				// If the category has flags "keepon" or "mandatory", they are not part of the outfit (like hair or anal plug)
				if ($clothings->HasFlag($currentCat, "keepon") || $clothings->HasFlag($currentCat, "mandatory")) { continue; }

				// Looping through all items from that category
				foreach ($clothings->GetItems($currentCat) as $currentItem => $status)
				{

					// Checks if the object is part of this outfit
					$isPartOfOutfit = array_filter($itemsToLock, function ($item) use ($currentCat, $currentItem) {
						return $item->Category === $currentCat && $item->Item === $currentItem;
					});

					// Checks if object if not worn (can skip unwearing)
					$isWorn = in_array($status, [2, 3, 9]);

					// If it is not part of the current outfit.
					if (!$isPartOfOutfit)
					{

						// Preparing the RLV commands, only if the item is worn
						$isWorn ? $rlv[] = "detach:" . $g_basePath . $clothings->GetCategoryFolder($currentCat) . "/" . $currentItem . "=force" : null;
						
						// Updating the status in the current dataset from DB
						$clothings->SetItemStatus($currentCat, $currentItem, 0);		

					}
					
				}

			}
			
			// Sending RLV commands
			SLRLVCommand($rlv);

			// Back to the main menu
			$flowStep = "MAIN";

		}
	
	// Strip
	} elseif ($flowStep == "MAIN/STRIP")
	{

		// Header of the dialog
		$dialog = "\nDressUp App / Strip completely\n\n";
		$dialog .= "Are you sure you want to strip her completely ?\n\n";

		// Implement in flow.lsl the ability to request current SIM maturity level :
		// https://wiki.secondlife.com/wiki/LlRequestSimulatorData
		// If pg, should add a warning (suggested by ParkerHart)
		
		$options = ["Strip !"];

		// Sending the dialog to the avatar
		$answer = SLDialog($dialog, $options, $session);
		
		// If not BACK, timeout or HTTP error...
		if ($answer != "BACK" && $answer != null)
		{

			// Creating an instance of the clothings class
			$clothings = new Clothings();

			// Looping through all categories
			foreach ($clothings->ListCategories() as $currentCat)
			{

				// If the category has flags "keepon" or "mandatory", they are not part of the outfit (like hair or anal plug)
				if ($clothings->HasFlag($currentCat, "keepon") || $clothings->HasFlag($currentCat, "mandatory")) { continue; }

				// Looping through all items from that category
				foreach ($clothings->GetItems($currentCat) as $currentItem => $status)
				{

					// Checks if object if not worn (can skip unwearing)
					$isWorn = in_array($status, [2, 3, 9]);

					// Preparing the RLV commands, only if the item is worn
					$isWorn ? $rlv[] = "detach:" . $g_basePath . $clothings->GetCategoryFolder($currentCat) . "/" . $currentItem . "=force" : null;
					
					// Updating the status in the current dataset from DB
					$clothings->SetItemStatus($currentCat, $currentItem, 0);	
					
					//SLOwnerSay($status);

				}

			}

			// Sending RLV commands
			SLRLVCommand($rlv);

			// Back to the main menu
			$flowStep = "MAIN";

		}

	// Save
	} elseif ($flowStep == "MAIN/SAVE")
	{

		// Header of the dialog
		$dialog = "\nDressUp App / Save outfit\n\n";
		$dialog .= "Please enter the name of the outfit";

		// Opening the textbox		
		$answer = SLTextBox($dialog, $session);
		
		// TO IMPLEMENT

	// Give HUD
	} elseif ($flowStep == "MAIN/HUD")
	{

		// Avoids anyone else than me can get the HUD 
		// (still a beta version, don't want to share it as it is)
		if (!$uuid == $session) { exit(); }

		// Opens the dialog that gives the object to the user
		SLGiveInventory($session, "DressUp QuickAccess HUD");

		// Exits the flow (user will have to manage his new HUD)
		$flowStep = "EXIT";

	}

	// Managing the 'BACK' option and when a dialug returns null (timeout or HTTP error)
	if ($answer === null) {	$flowStep = "EXIT";	}
	elseif ($answer === "BACK")	{ $flowStep = AFStepBack($flowStep); }

}

exit();

?>

