## ClojureScript: Getting Started ##

**NOTE: This is a WORK IN PROGRESS**

 * ClojureScript jar available on central: `[org.clojure/clojurescript "0.0-927"]`
 * Organize dirs like this:
     * `src/clj/project_name/...`
     * `src/cljs/project_name/...`
     * `src/cljs-macros/project_name/...`
 * Create a compile namespace in the `clj` dir for easy compilation. See code below.
 * Use [instructions on ClojureScript One wiki about having both a Clojure and ClojureScript REPL open in Emacs](https://github.com/brentonashworth/one/wiki/Emacs). I prefer keeping my Clojure swank/slime setup, and to let ClojureScript live in the `*shell*` buffer.
 * Use <kbd>C-c x</kbd> for top-level form eval and <kbd>C-c e</kbd> for "form under point" eval.
 * Make sure to evalute `(ns)` form to get your ClojureScript REPL in the namespace you're working in.
 * Get yourself a copy of `clj->js`. See code below.

### ClojureScript Compilation ###

Here is an example `compile.clj` file that you can load/evaluate to automatically have your ClojureScript compiled:

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

This is a "development mode" build, since I've commented out the `:optimizations` option to `build`.

### ClojureScript-to-JavaScript Transformations ###

While the pure ClojureScript ecosystem is still relatively immature, you'll still be depending on external JavaScript libraries for many "common" tasks. Or, like me, you've put a lot of time into understanding things like jQuery UI and want to leverage that experience in ClojureScript where needed.

API's like jQuery UI often require that you pass in an anonymous object as a parameter to a function (e.g., for passing in configuration options or callbacks to widgets). However, when you use a hash-map in ClojureScript, you're not creating an anonymous object; you're creating a `cljs.core.ObjMap` instance.

The following takes raw ClojureScript types (including instances of `ObjMap`) and recursively descends through them, creating a regular JavaScript objct for the purposes of interop:

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
