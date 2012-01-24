## ClojureScript: Getting Started ##

**NOTE: This is a WORK IN PROGRESS**

ClojureScript brings Clojure's reach to one more platform: JavaScript. On top of all the power of Clojure's language specification, ClojureScript also leverages the power of the Google Closure compiler, providing convenient mechanisms for coding to its standard and compiling your ClojureScript with its advanced settings.

This post provides an introduction to setting up your ClojureScript environment and becoming acquainted with a few of the idiosyncracies of the JavaScript platform that surface in ClojureScript code.

### Create a Project ###

You should use [Leiningen](https://github.com/technomancy/leiningen) to start a new project. See [my earlier instructions on this topic](/posts/2011/07/16/clojure-development-environment/).

### Get ClojureScript ###

As of this writing, ClojureScript is now available via Maven's central repository, marking a drastic shift in usability since its initial release. Add the following snippet to your `:dependencies` in your `project.clj`:

~~~~
#!clojure
[org.clojure/clojurescript "0.0-927"]
~~~~

### Organize your Project ###

By default, Leiningen creates a directory structure that includes a `src/my_project/...` directory. You should setup your folders to include one more layer of hierarchy for language, in this case `clj` versus `cljs` (as well as a folder for `cljs-macros`). For example:

~~~~
my-project
  - .gitignore
  - README
  - project.clj
  - src
    `-- clj
      `-- my_project
    `-- cljs
      `-- my_project
    `-- cljs-macros
      `-- my_project
~~~~

Make sure you edit your `project.clj` by adding a `:source-path` entry with a value of `src/clj`.

### Compiling your ClojureScript ###

ClojureScript won't do you much good unless you compile it into JavaScript. As explained on the ClojureScript wiki, when developing you application, you should use the bare-bones compilation options provided by ClojureScript.

For the sake of convenience, it makes sense to create a namespace dedicated to compiling your project's ClojureScript files. Here is some example code that would accomplish this in a development environment:

~~~~
#!clojure
;; ClojureScript Compilation
(ns my-project.compile
    (:use [cljs.closure :only [build]]))

(defn build-cljs
  []
  (build "src/cljs/red" {;; :optimizations :advanced
                         ;; :externs ["src/cljs/externs/jquery-1.7.js"]
                         :output-dir "resources/public/js/out"
                         :output-to "resources/public/js/core.js"
                         :pretty-print true}))

(build-cljs)
~~~~

Save this code in a file at `src/clj/my_project/compile.clj`. When working at the REPL, you can compile this whole file to have your ClojureScript compiled automatically.

There are ways to have your code compile automatically, but I prefer to manually compile and even occassionally delete all compiled files, to ensure that I'm not building my UI against cached or stale versions of my ClojureScript.

### Clojure and ClojureScript Together ###

These instructions are specific to Emacs.

In Emacs, folks code Clojure with either an open inferior lisp program or a Slime REPL connected via Swank. However, what do you do when you want to code Clojure and ClojureScript simultaneously?

For those who have read through the documentation for ClojureScript, you know that it first requires that you start a Clojure REPL. The developers of ClojureScript One [have documented a technique](https://github.com/brentonashworth/one/wiki/Emacs) to use a `*shell*` buffer to house a second REPL, and have provided a set of E-lisp functions that make this possible.

TODO: Finish section with details of how to use their code.

Use <kbd>C-c x</kbd> for top-level form eval and <kbd>C-c e</kbd> for "form under point" eval.

### Coding Away ###

Now that you have the two most important keyboard shortcuts for interacting between Emacs buffers and your shell-based REPL, it's time to start coding.

If you want to code within the "context" of a target namespace, just make sure to evalute the `(ns)` form at the top of the file.

### JavaScript Interop ###

Just as with Clojure on the JVM, there are aspects of the underlying system that invariably affect Clojure's semantics. JavaScript is no exception.

 * Get yourself a copy of `clj->js`. See code below.

~~~~
#!clojure
(defn clj->js
  "Recursively transforms ClojureScript maps into Javascript objects,
   other ClojureScript colls into JavaScript arrays, and ClojureScript
   keywords into JavaScript strings.

   Borrowed and updated from mmcgrana."
  [x]
  (cond
    (string? x) x
    (keyword? x) (name x)
    (map? x) (.-strobj (reduce (fn [m [k v]]
               (assoc m (clj->js k) (clj->js v))) {} x))
    (coll? x) (apply array (map clj->js x))
    :else x))
~~~~

This has been borrowed from [this post by Mark McGrangahan](http://mmcgrana.github.com/2011/09/clojurescript-nodejs.html), with a slight tweak to the `.-strobj` call to include the recently-added property-access syntax (Mark's example uses the older `(.strobj ...)` syntax).
