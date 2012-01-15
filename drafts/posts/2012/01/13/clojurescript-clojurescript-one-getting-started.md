## ClojureScript and ClojureScript One: Getting Started ##

This post contains (1) a synopsis of what [ClojureScript](https://github.com/clojure/clojurescript) and [ClojureScript One](http://clojurescriptone.com/) are all about and (2) a solution in between ClojureScript and ClojureScript One for "getting started."

If you're coming to this post without any background on ClojureScript, I suggest you first read Rich Hickey's [rationale](https://github.com/clojure/clojurescript/wiki/Rationale) behind its development.

### Introduction ###

ClojureScript, first and foremost, provides the full expressive power of Clojure, available _as_ your client-side JavaScript. On top of that, its integration with the [Google Closure](http://code.google.com/closure/) suite of JavaScript utilities provides a production-ready ecosystem for client-side development.

However, there is one growing pain that no version of Clojure has yet outgrown: the "getting started" phase.

For Clojure on the JVM, one has to be familiar with how Java jar files work, how to setup the classpath, and how dependencies are deployed and managed. By the sweet mercy of projects like Leiningen, non-Java developers have a "pure" Clojure interface to manage these JVM hurdles without too much fuss.

For ClojureScript, however, the process is much less polished. And for good reason: it's not been released as "stable." I, for one, am extraordinarily grateful to Rich Hickey for releasing ClojureScript at the stage of maturity at which he did. We are all getting a chance to watch the evolution of a language, contribute to its development, and still reap the benefits the code base already offers (which are substantial).

### ClojureScript One ###

In an effort to provide _a_ way to start working with ClojureScript within the context of a full web application, the Clojure/core team released ClojureScript One this week.

As has been explained in multiple places, ClojureScript One is not meant to be a library or framework at this point. It is an example of how to write a web application that relies heavily on client-side code, and of how to write that code using ClojureScript. It provides a set of Bash scripts that handle dependency management and starting up a REPL. It includes an enhanced browser-connected REPL that opens up the needed web page on startup. On top of base ClojureScript and the Google Closure library, it includes things like Domina for more Clojurey DOM manipulation.

From a workflow standpoint, ClojureScript One is not merely focused on ClojureScript development. It outlines three clear phases of Design, Development and Production, with helper pages built into the application to show how to interact with the codebase for those phases. For Design, Enlive was chosen as a default templating language, since it relies solely on pure HTML templates (obviously much easier for your non-Clojurian web designer). For Development, the application has a pre-built page (much like the [samples/repl](https://github.com/clojure/clojurescript/tree/master/samples/repl) project in ClojureScript's code base) that allows you to connect your REPL to the browser and have side-effects occur there. For Production, ClojureScript One will compile all your ClojureScript using advanced optimizations, giving you an easy way to ensure your code base works as expected as you develop it.

### Emacs Integration FTW ###

As cool as it is to start up a REPL on the command-line and start changing things in the browser, I want my editor integration. I have been far too spoiled by `swank-clojure` with Emacs (and have too much invested in Emacs) to stop at the terminal. Here's how I get a ClojureScript REPL in Emacs connected to the browser:


