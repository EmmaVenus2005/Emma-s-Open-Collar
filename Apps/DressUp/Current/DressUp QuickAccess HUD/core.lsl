// DressUp QuickAccessHUD by EmmaVenus2005
// Written on Nov 05 2024

integer ASS_CHANNEL = -696969;

default
{
    state_entry()
    {
                
    }
    
    touch_start(integer num_detected)
    {
    
        llRegionSayTo(llGetOwner(), ASS_CHANNEL, ":app:dressup:home");
    
    }
}
