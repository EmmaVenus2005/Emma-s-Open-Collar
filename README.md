All my code is under GPL 2 or greater licence. My code goes in the original Open Collar, but it will become completely different. 
However, as I inspired a lot from that code to learn LSL scripting, I want to thank all the people that worked, and still working on that project.

My first OpenCollar app is DressUp, which works great, but it was completely coded in LSL. There are many limitations that I wanted to get rid of, like the ability to
have advanced arrays, and functions to handle them, and to be able to do synchrone method calls. E.g. : In OpenCollar, a trusted person can navigate within its menus,
while yourself or another trusted can do it in the meanwhile. Each one sending its dialog responses. In order for the script to keep the context of each dialog session,
OpenCollar team found a nice trick, to use strided list. This is great, but not very fast, and a struggle to add new fields. I added another string, which was a list of key/values
that could be used for the context, and the GetValue and SetValue functions. This was more dynamic, but LSL is not that effiscient to handle huge strings. I could have used JSON instead,
which has been introduced in LSL, but it's given to be even less performant, even though more flexible.
Another limitation is that you can't do method calls, in a synchronous way, like SLDialog(), stay in the context, and let your code continue in the current scope. You needed to take
a lot of time to handle those dialog/response and joining contexts together. I did a clean code with DressUp 0.80, that organizes the app in a serie of steps, each having a request and response,
but it didn't change the whole thing.
Last but not least, LSL doesn't provide a lot of solutions to store persistent data. From that, I had the idea to set up a server, with PHP API that stores data in a MySQL database.
That works great, the nonvolatile.lsl script may get or set data, in a secure way, using my PHP code. This means that now, in a flow step, instead of sending a request to a SL user with
dialog, I can now request or store something on the server.
But wait, LSL is not that effiscient, doesn't have advanced string or array handling, does not allow synchronous calls, .... in the other hand, I have a PHP server with a database and secured
the communications between LSL and my API, why not run the app on server-side ?

That's where I built this architecture :

<img width="1030" alt="OpenCollar" src="https://github.com/user-attachments/assets/5792437f-93cc-4eae-b991-fae12ce5c29d">

This readme is still to complete, I will soon provide details about all folders.
