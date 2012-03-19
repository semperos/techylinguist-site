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

A word to the wise: many of these functions perform similar tasks and sometimes there's more than one way to accomplish the same task. That said, you'll discover which functions fit your brain and your problems better as you practice.

#### for ####

There is no for "loop" in Clojure, but there is the `for` comprehension. It takes a sequence of things, lets you do something to each thing in order, and then returns a lazy sequence of new things.

~~~~
#!clojure
(def numbers [1 2 3 4 5])

(for [number numbers]
  (* number 2))
;=> (2 4 6 8 10)
~~~~

You can read it like this: "For each `number` in `numbers`, multiply that `number` by two." Each of those multiplications are kept along the way, forming a new sequence. The `for` comprehension allows for several more paramters inside of that `[number numbers]` binding, but this is the basic usage.

On top of it all, it's a *lazy* sequence, which means Clojure won't compute the items until they're needed. This may seem like overkill for simple addition, but if you're dealing with big data structure, long-running processes or processes that consume a lot of memory, lazy evaluation makes what would otherwise be impossible calculations possible.

#### first / rest ####

This is the classic `car` and `cdr` in traditional Lisp.

~~~~
#!clojure
(def foo [1 2 3 4 5])

(first foo)
;=> 1

(rest foo)
;=> (2 3 4 5)
~~~~

You may notice that Clojure has a `next` function that behaves very similarly to `rest`, but look more closely:

~~~~
#!clojure
;; This is the same
(next foo)
;=> (2 3 4 5)

;; This is different
(rest (rest (rest (rest (rest foo)))))
;=> ()

(next (next (next (next (next foo)))))
;=> nil
~~~~

#### filter / remove ####

Once you've got yourself a collection of things, you need an easy way to express what you'd like to keep, or what you'd like to remove, from that collection. The `filter` function lets you specify what you want to keep, `remove` what you want to `remove`.

~~~~
#!clojure
(def foo [1 2 3 4 5])

(filter even? foo)
;=> (2 4)

(remove even? foo)
;=> (1 3 5)
~~~~

#### map ####

The `map` function is like the `for` comprehension, but less complex. It just takes a function and a collection, applying the function to each item in the collection and returning a new resulting sequence.

~~~~
#!clojure
(def foo [1 2 3 4 5])
(defn times-two [n] (* n 2))

(map times-two foo)
;=> (2 4 6 8 10)
~~~~

#### reduce ####

The `reduce` function is a power-house. Like the `map` function, it takes a function and a collection, but the story's a little more complex.

Unlike `map`, the function you pass to `reduce` takes two parameters. The first is a running result that you keep track of as you work through the collection, and the second is the next item in the collection. Let's take a simple example:

~~~~
#!clojure
(reduce + [2 3 4 5 6])
~~~~

Here's how this works, step-by-step:

 1. Take `+` and pass in the first two items in the list, `2` and `3`. Step complete.
 2. Take `+` again and pass in the result from the last operation, `5` (adding 2 plus 3), then pass in the next item, `4`. Step complete.
 3. Take `+` again and pass in the previous result `9` and the next item, `5`. Step complete.
 
This keeps going until the end of the collection, at which point the running result you've been passing as the first parameter to `+` is returned as the result of the entire expression. So in this example, you're just adding numbers.

The real power comes in when you pass `reduce` a default starting value for the running result, in which case you can use anything you want. Here's `reduce` over the same vector, but with a lot more going on:

~~~~
#!clojure
(reduce (fn [result item]
          (if (even? item)
            (update-in result [:evens] conj item)
            (update-in result [:odds] conj item)))
        {:evens [], :odds []}
        [2 3 4 5 6])
;=> {:evens [2 4 6], :odds [3 5]}
~~~~

#### some / every? ####

The `some` function takes a function and a collection, returning `true` if the function returns true for any item in the collection.

It's also the idiomatic way to ask whether a vector/list contains an item:

~~~~
#!clojure
(some even? [1 2 3 4 5])
;=> true

(some even? [1 3 5])
;=> nil

(some #{:foo} [:foo :bar :baz])
;=> :foo

(some #{:wowza} [:foo :bar :baz])
;=> nil
~~~~

Note the use of a set `#{}` to determine if an item is in the vector. In the example above, the return of `:foo` is truthy, so when used in a conditional will behave like `true`.

The `every?` function works just like `some`, except it will only return truthy if every item matches, not just one.

#### doall ####

This one is less common, but good to know about when you run into issues with Clojure's default laziness. If at any point you need to *force* Clojure to realize a lazy sequence, you can do so by passing it to `doall`.

### Math and Numbers ###

 * `+`, `-`, `*`, `/`
 * mod - Returns the remainder (modulus)
 * int - Cast to an Integer, or round down
 * inc / dec - Increment/decrement by one
 
These work as expected. The basic arithmetic functions take a variable number of parameters, so `(+ 2 3 4 5 6 7 8)` is just fine.
 
### Strings and Regular Expressions ###

#### str ####

This acts both like `.toString()` and, when passed multiple parameters, will concatenate:

~~~~
#!clojure
(str 4)
;=> "4"

(str "foo" " bar" " baz")
;=> "foo bar baz"
~~~~

#### re-find ####

Clojure has several regular expression functions, and even a literal regular expression syntax. This find returns what it finds in a given string.

~~~~
#!clojure
(re-find #"t{2}" "latte")
;=> "tt"

(re-find #"t{2}(e)" "latte")
;=> ["tte" "e"]
~~~~

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
