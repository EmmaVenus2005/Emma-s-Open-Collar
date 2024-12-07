<?php

class Clothings {
    // Attributes
    private array $catFolder = []; // Contains raw folder names (e.g., "Name (flag1-flag2)")
    private array $catNames = []; // Contains names without flags
    private array $catFlags = []; // Contains flags as an array
    private array $catItems = []; // Contains category-specific items

    /**
     * Constructor
     * Initializes the categories, names, flags, and items.
     */
    public function __construct() {
        // TODO: Implement the logic to populate $catFolder, $catNames, $catFlags, and $catItems.
        // Example:
        // $this->catFolder = ["Category1 (flag1-flag2)", "Category2 (rel:test)"];
        // $this->catNames = ["Category1", "Category2"];
        // $this->catFlags = [["flag1", "flag2"], ["rel:test"]];
        // $this->catItems = [
        //     "01,Alpha|56,Beta|34,Gamma|78,Delta|02",
        //     "12,Alpha|45,Beta|10"
        // ];
    }

    // Private Methods
    private function GetCategoryIndex(string $cat): int {
        $index = array_search($cat, $this->catNames);
        if ($index === false) {
            return -1; // Return -1 if not found
        }
        return $index;
    }

    private function GetCategoryFlags(string $cat): array {
        $index = $this->GetCategoryIndex($cat);
        if ($index === -1) {
            return []; // Return an empty array if the category is not found
        }
        return $this->catFlags[$index];
    }

    private function GetCategoryFolder(string $cat): string {
        $index = $this->GetCategoryIndex($cat);
        if ($index === -1) {
            return ""; // Return an empty string if not found
        }
        return $this->catFolder[$index];
    }

    // Public Methods
    public function ListCategories(): array {
        return $this->catNames;
    }

    public function HasFlag(string $cat): bool {
        $flags = $this->GetCategoryFlags($cat);
        return !empty($flags);
    }

    public function GetRelated(string $cat): array {
        $flags = $this->GetCategoryFlags($cat);

        // Extract all "rel:" flags
        $relations = array_filter($flags, fn($flag) => str_starts_with($flag, "rel:"));

        if (empty($relations)) {
            return [$cat]; // If no "rel:" flags, return the category itself
        }

        // Find related categories based on shared "rel:" flags
        $relatedCategories = [];
        foreach ($relations as $relation) {
            foreach ($this->catFlags as $index => $categoryFlags) {
                if (in_array($relation, $categoryFlags)) {
                    $relatedCategories[] = $this->catNames[$index];
                }
            }
        }

        return array_unique($relatedCategories); // Remove duplicates
    }

    public function GetItemStatus(string $cat, string $item): int {

        // With $index
        $folder = GetCategoryFolder($cat);

        // Fetch the raw data string
        // Example: "01,Alpha|56,Beta|34,Gamma|78,Delta|10"
        $items = "01,Alpha|56,Beta|34,Gamma|78,Delta|10" // Get line from DB where CLASS = ClothingPiecesX AND Name = $folder

        // Split the input into pairs by ','
        $pairs = explode(',', $items);

        // Iterate over each pair to find the target string
        foreach ($pairs as $pair) {
            $parts = explode('|', $pair);

            // Validate that the pair has two parts
            if (count($parts) < 2) {
                continue; // Skip invalid pairs
            }

            // If the left part matches $forString, extract and return the second digit
            if (trim($parts[0]) === $item) {
                $numericValue = trim($parts[1]);

                // Return the second digit if it exists, otherwise return -1
                return isset($numericValue[1]) ? (int)$numericValue[1] : -1;
            }
        }

        // Return -1 if no match is found
        return -1;

    }

    /* public function GetItemStatus(string $cat, string $item): int {
        // With $index
        $folder = GetCategoryFolder($cat);
    
        // Fetch the raw data string
        // Example: "01,Alpha tango|56,Beta tango|34,Gamma|78,Delta|10"
        $items = "01,Alpha tango|56,Beta tango|34,Gamma|78,Delta|10"; // Get line from DB where CLASS = ClothingPiecesX AND Name = $folder
    
        // Construct the regex to match the item and extract the second digit of the value
        // The regex looks for ",item_name|" where item_name is precisely the value we're looking for
        $pattern = sprintf('/,\s*%s\|(\d)(\d)/', preg_quote($item, '/'));
    
        // Perform regex match
        if (preg_match($pattern, $items, $matches)) {
            // Return the second digit if found
            return (int)$matches[2];
        }
    
        // Return -1 if no match is found
        return -1;
    } */

    /* public function GetItems(string $cat): array {
        $index = $this->GetCategoryIndex($cat);
        if ($index === -1) {
            return []; // Return an empty array if the category is not found
        }

        // Fetch the raw data string
        $input = $this->catItems[$index] ?? ""; // Example: "01,Alpha|56,Beta|34,Gamma|78,Delta|10"

        // Ignore the first part (e.g., "01,") and start processing from the second part
        $itemsStatus = [];
        $parts = explode('|', strstr($input, '|')); // Start after the first `|`
        foreach ($parts as $part) {
            [$status, $item] = explode(',', $part);
            $itemsStatus[$item] = (int)$status[0]; // Use only the first digit of the status
        }

        return $itemsStatus;
    } */

    public function GetItems(string $cat): array {

        $folder = GetCategoryFolder($cat);
    
        // Fetch the raw data string
        // Example: "01,Alpha tango|56,Beta tango|34,Gamma|78,Delta|10"
        $items = "01,Alpha tango|56,Beta tango|34,Gamma|78,Delta|10"; // Get line from DB where CLASS = ClothingPiecesX AND Name = $folder
    
        // Construct the regex to match each item and extract its value
        // Pattern matches ",<item_name>|<value>"
        $pattern = '/,\s*([^|]+)\|(\d{2})/';
    
        $result = [];
    
        // Perform regex match
        if (preg_match_all($pattern, $items, $matches, PREG_SET_ORDER)) {
            foreach ($matches as $match) {
                $item = trim($match[1]); // The item name
                $value = (int)$match[2][1]; // Extract the second digit of the numeric value
                
                $result[$item] = $value;
            }
        }
    
        // Return the associative array with item => value pairs
        return $result;
    }
    

    public function SetItemStatus(string $cat, string $item, int $status): void 
    {

        $folder = GetCategoryFolder($cat);
    
        // Fetch the raw data string
        // Example: "01,Alpha tango|56,Beta tango|34,Gamma|78,Delta|10"
        $items = "01,Alpha tango|56,Beta tango|34,Gamma|78,Delta|10"; // Get line from DB where CLASS = ClothingPiecesX AND Name = $folder
    
        // Locate the item in the sequence
        $search = ",{$item}|";
        $position = strpos($items, $search);
    
        if ($position !== false) {
            // Find the start position of the value associated with the item
            $secondDigitPosition = $position + strlen($search) + 1;
    
            // Replace the second digit directly
            $items[$secondDigitPosition] = (string)$status;
        }
    
        // Placeholder for database update
        // Update the database with the new $items string
        // e.g., updateDatabase($folder, $items);
        
    }

}
