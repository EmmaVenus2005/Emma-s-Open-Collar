<?php

class Clothings 
{
    
    // Attributes
    private array $catFolder = []; // Contains raw folder names (e.g., "Name (flag1-flag2)")
    private array $catNames = []; // Contains names without flags
    private array $catFlags = []; // Contains flags as an array
    private array $catItems = []; // Contains category-specific items

    // Constructor
    // Initializes the categories, names, flags, and items.
    public function __construct() 
    {
    
        // Reading the current dataset
        $dataset = NVGetValue("DirFetchCurrentDataset");

        // $this->catFolder = ["Category1 (flag1-flag2)", "Category2 (rel:test)"];
        $this->catFolder = NVGetLists("ClothingPieces" . (integer)$dataset);
        
        // Each $folder is like that : "Category1 (flag1-flag2)"
        foreach ($this->catFolder as $i => $folder)
        {
            
            // Extract the clean name (e.g., "Category1")
            $name = preg_replace('/\s*\(.*\)$/', '', $folder); // Remove everything after and including " ("
            $this->catNames[$i] = $name;

            // Extract the flags as a single string (e.g., "flag1-flag2")
            preg_match('/\((.*)\)$/', $folder, $matches);       // Extract everything inside the parentheses
            $flags = isset($matches[1]) ? $matches[1] : "";     // Keep the flags as a single string
            
            // Separating the flags, for short to regular conversion
            $flagsArray = explode('-', $flags);

            // Mapping for short flag conversion
            $mapShortFlags = [
                'mu' => 'multiple',
                'ko' => 'keepon',
                'mn' => 'mandatory',
                'rf' => 'resetfeet',
                'hg' => 'hidegenitals',
                'hp' => 'hideplug',
                'hn' => 'hidenipples',
                'oo' => 'owneronly'
            ];

            // Transforming short flags into regular
            foreach ($flagsArray as $k => $v)
            {
                
                // If flag begins by 'r:', becomes 'rel:xxx' (for related categories)
                if (str_starts_with($v, 'r:')) 
                {
                    
                    $flagsArray[$k] = 'rel:' . substr($v, 2);
                    continue;
                
                }
                
                // Else, trying to find flag in mapping table 
                if (isset($mapShortFlags[$v])) { $flagsArray[$k] = $mapShortFlags[$v]; }
                
            }
            
            // Actually storing the flags in the array
            $this->catFlags[$i] = implode('-', $flagsArray);

            // Getting the itemps from the database
            $this->catItems[$i] = NVGetList("ClothingPieces" . (integer)$dataset, $folder);

            // Debug
            // SLOwnerSay("Folder : " . $folder);
            // SLOwnerSay("Name : " . $this->catNames[$i]);
            // SLOwnerSay("Flags : " . $this->catFlags[$i]);
            // SLOwnerSay("Items : " . $this->catItems[$i]);

        }

        // Tests
        //$this->SetItemStatus("Bottoms", "Dark blue shred jeans", 9);

    }

    // Private Methods

    // Returns the index of a given category string (the clean name, not directory)
    private function GetCategoryIndex(string $cat): int 
    {
        
        // Searching for the index of the given category
        $index = array_search($cat, $this->catNames);
        
        // Return -1 if not found, and the index if found
        return $index === false ? -1 : $index;

    }

    // Returns the flags for a given category (array)
    private function GetCategoryFlags(string $cat): array 
    {
       
        // Searching for the index of the given category
        $index = $this->GetCategoryIndex($cat);

        // Returns the flags, or empty array if not found
        return $index === -1 ? [] : explode('-', $this->catFlags[$index]);

    }

    // Public Methods

    // Returns the folder of a given category
    public function GetCategoryFolder(string $cat): string 
    {
        
        // Searching for the index of the given category
        $index = $this->GetCategoryIndex($cat);
        
        // Returns the folder, or empty string if not found
        return $index === -1 ? "" : $this->catFolder[$index];

    }

    // Returns the list of the categories
    public function ListCategories(): array 
    {
        
        return $this->catNames;
    
    }

    // Returns true if the given category contains the given flag
    public function HasFlag(string $cat, string $flag): bool 
    {

        // If flag exists, returns true, else false
        return array_search($flag, $this->GetCategoryFlags($cat)) !== false;

    }

    // Returns the list of categories that have a specific flag (TO TEST)
    public function CategoriesWithFlag(string $flag): array 
    {
        
        // Initializing an empty array for categories that have the specified flag
        $categoriesWithFlag = [];

        // Looping through all categories to check their flags
        foreach ($this->ListCategories() as $category) {
            
            // If the category contains the given flag, add it to the result array
            if ($this->HasFlag($category, $flag)) {
                $categoriesWithFlag[] = $category;
            }

        }

        // Return the array with categories that have the given flag
        return $categoriesWithFlag;

    }

    // Returns true if at least one item in the category is worn (TO TEST)
    public function CategoryWorn(string $cat): bool
    {

        // Get all items for the given category
        $items = $this->GetItems($cat);

        // Loop through each item and check its worn status
        foreach ($items as $item => $status) {
            
            // If the status is 2, 3, or 9 (indicating the item is worn), return true
            if (in_array($status, [2, 3, 9])) { return true; }

        }

        // If no item is worn, return false
        return false;

    }

    // Returns the related categories
    public function GetRelated(string $cat): array {
        
        // Gets the flags of the current category
        $flags = $this->GetCategoryFlags($cat);

        // Extract all "rel:" flags
        $relations = array_filter($flags, fn($flag) => str_starts_with($flag, "rel:"));

        // If no "rel:" flags, return the category itself
        if (empty($relations)) { return [$cat]; }

        // Find related categories based on shared "rel:" flags
        $relatedCategories = [];
        
        // Loop through each relation
        foreach ($relations as $relation) 
        {
            
            // Loop through each category to find the relation
            foreach ($this->ListCategories() as $index => $category) {
                
                // If the flag is present in the current category
                if ($this->HasFlag($category, $relation))
                {

                    // Adding the category to the output list
                    array_push($relatedCategories, $category);

                }

            }

        }

        // Remove duplicates in return result
        return array_unique($relatedCategories);

    }

    // Returns a key/value array with categories and worn status
    public function GetItems(string $cat): array 
    {

        // Use foreach to loop through the result
        //foreach ($items as $key => $value) { }

        // Gets the folder, which is the actual list name in the databade
        $folder = $this->GetCategoryFolder($cat);
    
        // Reading the current dataset
        $dataset = NVGetValue("DirFetchCurrentDataset");

        // Reads the items
        $items = NVGetList("ClothingPieces" . (integer)$dataset, $folder);

        // Construct the regex to match each item and extract its value
        // Pattern matches ",<item_name>|<value>" (the ',' is optional, to include first element)
        $pattern = '/(?:^|,\s*)([^|]+)\|(\d{2})/';
       
        // Initializing an empty array
        $result = [];
    
        // Checks the matches
        if (preg_match_all($pattern, $items, $matches, PREG_SET_ORDER)) 
        {

            // Looping through all items
            foreach ($matches as $match) 
            {
                
                // Name of the item
                $item = trim($match[1]);

                // Worn status
                $value = (int)$match[2][0];

                // Adds the key/value to the output array
                $result[$item] = $value;

            }

        }
    
        // Return the associative array with item => value pairs
        return $result;
        
    }

    // Gets the worn status directly from the database
    public function GetItemStatus(string $cat, string $item): int 
    {

        // Gets the folder, which is the actual list name in the databade
        $folder = $this->GetCategoryFolder($cat);

        // Reading the current dataset
        $dataset = NVGetValue("DirFetchCurrentDataset");

        // Reads the items
        $items = NVGetList("ClothingPieces" . (integer)$dataset, $folder);
        
        // Split the input into pairs by ','
        $pairs = explode(',', $items);

        // Iterate over each pair to find the target string
        foreach ($pairs as $pair) {
            
            // Separates Name|Status
            $parts = explode('|', $pair);

            // Validate that the pair has two parts (excludes first status)
            if (count($parts) < 2) { continue; }

            // If the left part matches to the given item, extract and return the second digit
            if (trim($parts[0]) === $item) {
                
                // $numericValue becomes the status
                $numericValue = trim($parts[1]);

                // Return the first digit if it exists, otherwise return -1
                return isset($numericValue[0]) ? (int)$numericValue[0] : -1;

            }

        }

        // Return -1 if no match is found
        return -1;

    }
    
    // Sets the worn status for a particular item
    public function SetItemStatus(string $cat, string $item, int $status): void
    {
        
        // Get the folder, which is the actual list name in the database
        $folder = $this->GetCategoryFolder($cat);

        // Get the current dataset
        $dataset = NVGetValue("DirFetchCurrentDataset");

        // Retrieve the items list
        $items = NVGetList("ClothingPieces" . (int)$dataset, $folder);

        // Use regex to locate the item and capture its two-digit status.
        $pattern = '/((?<=^|,)' . preg_quote($item, '/') . '\|)(\d)(\d)/';

        // Replace only the first digit with $status using a callback.
        $newItems = preg_replace_callback($pattern, function ($matches) use ($status) {
            // Return the concatenation of:
            //   - Group 1: "ItemName|"
            //   - The new first digit (converted to string)
            //   - Group 3: the unchanged second digit
            return $matches[1] . (string)$status . $matches[3];
        }, $items, 1);

        // Update the database with the modified items list.
        NVSetList("ClothingPieces" . (int)$dataset, $folder, $newItems);

    }

}

?>
