## Run Windows Command in the Background (Unix &amp;) ##

You can prepend whatever Windows command you want to run with `start` to force the command to relinquish control back to the command-line immediately (like the ampersand <tt>&amp;</tt> on *nix platforms):

~~~~
start WINDOWS_CMD
~~~~

I've used this to make my Vimclojure setup possible, following these [instructions](http://blog.darevay.com/2010/10/how-i-tamed-vimclojure/).
