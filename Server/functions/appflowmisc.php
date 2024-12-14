<?php

// Function to return one step back in app flow
function AFStepBack($step) 
{

    // Split the string into an array using '/' as the delimiter
    $parts = explode('/', $step);

    // Remove the last part from the array
    array_pop($parts);

    // Join the remaining parts back into a string with '/' as the separator
    return implode('/', $parts);

}

?>