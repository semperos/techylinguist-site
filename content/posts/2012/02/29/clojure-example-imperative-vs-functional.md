## Clojure Example: Imperative vs Functional ##

I was writing a utility in Clojure today to randomize searches for testing a web-based search application. I began with a list of possible search terms:

~~~~
#!clojure
;; these weren't really the terms I used :-)
(def search-terms ["apple" "banana" "orange"
                   "mango" "papaya" "pear" 
                   "nectarine" "tangerine"])
~~~~

I then wrote the following two functions to cobble together a random selection of these terms into a query like "apple banana orange":

~~~~
#!clojure
(defn random-term
  "Return a random term, optionally checking that it's not in the seq of `previous` terms."
  ([] (random-term []))
  ([previous]
     (let [choice (nth search-terms (rand-int (count search-terms)))]
       (if (some #{choice} previous)
         (random-term previous)
         choice))))

(defn gen-search-query-loop
  "Return a string to act as a search query with `num-terms` number of terms."
  ([] (gen-search-query 3))
  ([num-terms]
     (let [term (random-term)]
       (loop [previous [term] query term count (dec num-terms)]
         (if (zero? count)
           query
           (let [new-term (random-term previous)]
             (recur (conj previous new-term)
                    (str/join " " [query new-term])
                    (dec count))))))))
~~~~

In short, the `random-term` function looks at `search-terms`, picks a random one, and optionally makes sure that the randomly picked term hasn't already been picked. The `gen-search-query-loop` function then uses a loop to manually loop `num-terms` times and use this `random-term` function to concatenate a final query string.

The logic is fairly straightforward, but whenever I see `loop` in my code, 9 times out of 10 I know I've done something non-idiomatic. So I stopped for a moment and pondered a more functional version.

Here is what I wrote next:

~~~~
#!clojure
(defn gen-search-query-reduce
  "Return a string to act as a search query with `num-terms` number of terms."
  ([] (gen-search-query-reduce 3))
  ([num-terms]
     (str/join " " (:query (reduce
                            (fn [state item]
                              (let [chosen? (< (rand) (/ (:num-needed state)
                                                         (:num-left state)))]
                                (if chosen?
                                  (-> state
                                      (update-in [:query] conj item)
                                      (update-in [:num-needed] dec)
                                      (update-in [:num-left] dec))
                                  (update-in state [:num-left] dec))))
                            {:query []
                             :num-needed num-terms
                             :num-left (count search-terms)}
                            search-terms)))))
~~~~

Only one function is needed in this case. I used the idea of checking the probability of the number needed divided by the number left in a collection from [this StackOverflow answer](http://stackoverflow.com/a/48089), and then used Clojure's `reduce` function to build a query.

Often folks see `reduce` used with only two arguments, like `(reduce + [1 2 3 4 5])` which returns the sum of those items, but remember that `reduce` also takes an optional `val` parameter that is the starting value for the given function. So `(reduce + [1 2 3 4 5])` can also be written `(reduce + 0 [1 2 3 4 5])` and will return the same result, as in this case it explicitly starts adding with `0` instead of with the first element of the given collection, `1`. This isn't limited to simple scenarios like a starting number for addition; you can supply any kind of complex data structure as the initial value for `reduce`, which becomes the first parameter to the function you pass to `reduce` (in my example, I'm calling this value `state` and each item that gets processed as `item`).

In this case, I use a basic Clojure hash map, which keeps track of:

 1. How many terms are still needed
 2. How many terms are left in the collection
 3. The final query (the collection of terms to join with spaces)

For each item, I determine if it should be chosen. If it should be, then I update this initial map by:

 1. Conj'ing the chosen item onto the query collection
 2. Decrementing the number needed
 3. Decrementing the number left

If the item is not to be chosen, the only action that needs to be taken is decrementing the total number of items. At the end, my `reduce` form returns a map like `{:query "apple banana orange" :num-left 0 :num-needed 0}`. In the above code, I then simply get the `:query` value and call `clojure.string/join` on it for my final query string that gets passed to my web application.

I think the code speaks for itself. The functional variant looks cleaner and its intent is easier to follow. We're only keeping track of iterations to do the math for choosing an element randomly based on the probability of its being needed, not because we're manually looping over a collection.

This isn't anything ground-breaking, but I think it's a clear example of transforming "imperative" thinking into "functional" thinking.
