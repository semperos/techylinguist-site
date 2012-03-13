## Clojure Language Primer ##

**Work in Progress**

In my opinion, once you get comfortable with general Lisp-ness and Java-ness, as well as the beginnings of what functional programming is all about, you really only need less than 40 functions (or pairs of functions) to get rolling with Clojure, plus the host interop syntax.

These are they, with brief, over-simplified explanations and examples.

### Defining Things ###

#### def / defn ####

Define a "variable" scoped to the current namespace. The `def` form binds a value to a var, while the `defn` form makes it simple to both define a function and bind that to a var.

~~~~
#!clojure
(def x 42)

(defn foo [your-name]
  (println (str "Hello, " your-name)))
  
;; Otherwise, you'd have to write it out like this:
(def foo
  (fn [your-name]
    (println (str "Hello, " your-name))))
~~~~

#### fn / #() ####

Create an anonymous function

~~~~
#!clojure
(map (fn [item] (* item 2)) [1 2 3 4 5])
;=> [2 4 6 8 10]

(map #(* % 2) [1 2 3 4 5])
;=> [2 4 6 8 10]
~~~~

#### ns ####

Define the current namespace ("package")

~~~~
#!clojure
(ns example.core
  (:use clj-webdriver.core
        [clojure.string :only [join]])
  (:require [clojure.java.io :as io])
  (:import com.example.MyJavaClass
           com.example.MyClojureRecord
           [org.openqa.selenium FirefoxDriver ChromeDriver]))
~~~~

The `:use` entry is equivalent to calling the `use` function at the REPL; it "imports an entire namespace and makes all of its functions immediately available (optionally limiting the functions loaded, as in the example for `clojure.string`). If you use `:use` at all, you should limit the functions thus imported with the `:only` syntax shown above.

The `:require` entry is equivalent to the `require` function at the REPL; it loads a file for use, and is most often used with `:as` to alias the namespace, so you'd call `io/as-file` to use the `as-file` function defined in `clojure.java.io`.

The `:import` entry is equivalent to `import` at the REPL, and performs a `use` on a Java class or Clojure Record.

#### let ####

99.9% of the time, this is what you'll use to define "variables" in your application. The bindings you specify in a `let` form are limited to that let; once you leave the scope of the let (once you're outside its parentheses), the bindings no longer hold.

Any bindings you create in a `let` form that have the same name as variables that already exist will shadow those higher-level bindings.

~~~~
#!clojure
(defn evens-and-odds [c]
  (let [evens (filter even? c)
        odds  (filter odd? c)]
    [evens, odds]))
    
(evens-and-odds [1 2 3 4 5 6 7])
;=> [(2 4 6) (1 3 5 7)]

(def x 42)
(let [x 0]
  (* x 2))
;=> 0
~~~~

This function takes a collection of numbers `c`, then sets up two intermediate bindings `evens` and `odds` which hold seq's of even and odd numbers respectively. The function finally returns a vector of the two sequences.

#### defmacro ####

Advanced!

Macros let you build language-level constructs into your Clojure programs. Here is a simple implementation of a conditional `unless` that is equivalent to Clojure's `if-not`:

~~~~
#!clojure
(defmacro unless [conditional then else]
  `(if (not ~conditional)
       ~then
       ~else))
       
(unless (> 0 1) "success" "failure")
;=> "success"
~~~~

### Conditionals ###

#### if ####

Like everything in Clojure, `if` returns a value. For this reason, an `if` form must have both a "then" and an "else" branch.

~~~~
#!clojure
(if (check-value of-something)
  (println "Do this if the above is true")
  (println "Else do this"))
~~~~

#### and / not ####

You logical operators are `and` and `not`. Use them like regular forms:

~~~~
#!clojure
(= (+ 2 2) 4)
;=> true

(and (= (+ 2 2) 4)
     (= (* 2 2) 4))
;=> true

(not (= (+ 2 2) 5))
;=> true
~~~~

#### cond ####

The `cond` form takes pairs of predicates and actions. If a predicate returns true, the action is performed. By "action" I just mean a "then" clause, not necessarily that side effects are performed.

~~~~
#!clojure
(cond
  (= x 2) (println "X equals 2)
  (= y 3) (println "Y equals 3)
  :else (println "Nothing else came back true"))
~~~~

#### case ####

The `case` form is Clojure's equivalent of a switch statement.

~~~~
#!clojure
(case x
 42 (println "X is 42")
 "foo" (prinltn "X if 'foo'")
 "Nothing else matched")
~~~~

#### when ####

Use `when` in situations where you would have otherwise written `if` that only needed a "then" clause (`when` returns `nil` when the conditional fails):

~~~~
#!clojure
(def x 42)
(when (= x 42)
  (* x 24))
;=> 1008

(def x 0)
(when (= x 42)
  (* x 24))
;=> nil
~~~~

### Comparisons ###

 * `=` 
 * `>`, `>=`
 * `<`, `<=`
 * `pos?` / `neg?`

Read comparisons from left to right, just like you'd say them in English:

~~~~
#!clojure
;; Say: "Is three greater than 2?"
(> 3 2)
;=> true

;; Say: "Is three less than 2?"
(< 3 2)
;=> false

(pos? 4)
;=> true

(pos? -4)
;=> false
~~~~

### Collections / Sequences ###

 * for - Clojure's sequence comprehension (**not** a for-loop)
 * first / rest - The first item in a sequence, the rest of the items in a sequence after first
 * filter - Return all elements in a seq that return true for a given predicate
 * remove - Remove all elements in a seq that return true for a given predicate
 * map - Take a function and a collection, call that function on each element in the collection, replacing the value of the element with the return value of the function
 * reduce - Take a function, an optional starting value and a collection, then apply the function to the first two things in the collection, then take that result and call the function with that result and the next item, etc., to the end of the collection, returning the final return value
 * some - Return true if any elements in the collection return true for the given predicate
 * every? - Return true if all elements in the collection return true for the given predicate
 * doall - Realize a lazy sequence

### Math and Numbers ###

 * `+`, `-`, `*`, `/`
 * mod - Returns the remainder (modulus)
 * int - Cast to an Integer, or round down
 * inc / dec - Increment/decrement by one
 

### Strings and Regular Expressions ###

 * str - Both .toString and for concatenating strings
 * re-find - Returns matches against a regular expression in a target string

### Side-Effects ###

 * do - Perform several actions, returning the value of the last
 * doseq - Like for, but when only going through a collection to perform side-effects

### Records ###

 * defrecord - Define a new record ("class")

### Protocols ###

 * defprotocol - Define a new protocol ("interface")

### Hash Maps ###

 * get-in / assoc-in / update-in - For use with nested lists, retrieve or change the value of a value
 * contains? - Return true if the map contains the given key
 
### Interop ###

 * (.toUpperCase "fred") => (. "fred" toUpperCase) - Calling an instance method on an object (42 is a Long by default)
 * (.getName String) - Property access
 * (System/getenv) => (. System getenv) - Calling a static method on a class
 * Math/PI - Static property access
 * (.get (System/getProperties) "os.name") => (.. System getProperties (get "os.name")) - Convenience macro for nested object access (works just like threading macro ->)
 * (new java.util.HashMap) => (java.util.HashMap.) - Object instantiation (calling constructor)
 * doto - Thread a new object through methods that act on it, returning the object itself at the end (instead of whatever the return value of the last method call was), e.g.:
 
    ;; Ok - Create object, call .put on it twice, manually return it at the end
    (let [hm (new java.util.HashMap)]
      (.put hm "a" 1)
      (.put hm "b" 2)
      hm)
      
    ;; Better - the new HashMap is implicitly made the first argument to eash .put method below,
    ;; and is returned as the return value of the whole form at the end instead of .put's
    ;; return value, which is nil
    (doto (new java.util.HashMap)
      (.put "a" 1)
      (.put "b" 2))

### Mutable State (Atoms, Refs) ###

 * swap! / reset! - Functions used to change the value of an atom
 * dosync, alter / ref-set - Functions used to change the value of a ref
