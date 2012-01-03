## Add Google OpenID to your Clojure Ring/Moustache App ##

If you read the [Google documentation for its OpenID support](http://code.google.com/apis/accounts/docs/OpenID.html#endpoint), it points you to the [openid4java](http://code.google.com/p/openid4java/) project. The following code snippets demonstrate how to leverage this library to communicate with Google and perform authentication via OpenID. The key is to translate Google's instructions into the [openid4java Quickstart](http://code.google.com/p/openid4java/wiki/QuickStart) tutorial, then Clojurify the process. First, here's my project.clj with dependencies for this code:

~~~~
#!clojure
(defproject example-web "1.0.0-SNAPSHOT"
  :description "Ring examples"
  :dependencies [[org.clojure/clojure "1.2.1"]
                 [ring/ring-jetty-adapter "0.3.8"]
                 [ring/ring-core "0.3.8"]
                 [net.cgrand/moustache "1.0.0"]
                 [enlive "1.0.0"]
                 [org.openid4java/openid4java "0.9.5"]])
~~~~

Next, here's the initial Clojure namespace with use/require/import statements:

~~~~
#!clojure
(ns example-web.auth
  (:use [ring.util.response :only [redirect]]
        [ring.util.response :only [response]])
  (:require [example-web.state :as config])
  (:import [org.openid4java.consumer ConsumerManager]))
~~~~

The `example-web.auth` namespaces includes a couple of functions from Ring for return responses, a bit of configuration state (the `user-whitelist` var where we'll store a list of email addresses allowed to access the site) and the workhorse of the openid4java library, the `ConsumerManager` class. Following all that, here is the function that calls out to Google, gathers all the required information, and returns a response map that will redirect a user to the proper Google page for authentication:

~~~~
#!clojure
(defn request-openid
  "Perform OpenID process and build redirect that goes to Google for authentication and requests email address in return"
  [req]
  (let [cm (ConsumerManager.)
        return-url "http://localhost:8080/auth-openid"
        user-supplied-string "https://www.google.com/accounts/o8/id"
        discoveries (.discover cm user-supplied-string)
        discovered (.associate cm discoveries)
        auth-req (.authenticate cm discovered return-url)
        redirect-response (redirect (.getDestinationUrl auth-req true))]
    (update-in redirect-response [:headers "Location"] str
               "&openid.ns.ax=http://openid.net/srv/ax/1.0"
               "&openid.ax.mode=fetch_request"
               "&openid.ax.required=email"
               "&openid.ax.type.email=http://axschema.org/contact/email")))
~~~~

If you're familiar with Ring apps, this function should make plenty of sense. The parameter `req` stands for "request", which is the standard parameter for a Ring handler function (even though in this case, we don't use it). Now if we attach this handler function to a route in our Ring app, we'll see everything at work. After we send the user off to Google to be authenticated, we're having Google redirect them to the the URL specified with `return-url`. Google will add various pieces of information as parameters to the URL, so we need to setup a function that will accept those parameters and do something with them. For this example, I'm using a very simple whitelist of email addresses that are allowed to authenticate. The following function checks whether or not the email address passed back from Google is on that list; if it is, a success message is returned with a print-out of the parameters, if not, then a denial message is returned.

~~~~
#!clojure
(defn authenticate-user
  [{params :params}]
  (if (some #{(params "openid.ext1.value.email")} config/user-whitelist)
    (response (str "You may enter.\n\n" params))
    (response "Access denied, you scoundrel!")))
~~~~

This function, like the previous, acts as a Ring handler, but instead of taking the whole request in a single var, we're pulling out the parameters from the `:params` key of the response map and binding that to the var `params`. We then use the `some` function to check that the email address at key `"openid.ext1.value.email"` is in the whitelist of emails. Well, now that we have these two Ring handlers, we better wire them up in an actual Ring app so we can see them at work. For this example, I'm using [Moustache](https://github.com/cgrand/moustache) to handle routing and middlewares with Ring. I've separated the Moustache-specific code from the OpenID code, so here's another namespace declaration for our Moustache file:

~~~~
#!clojure
(ns example-web.core
  (:use net.cgrand.moustache
        [ring.adapter.jetty :only [run-jetty]]
        [ring.middleware.params :only [wrap-params]])
  (:require [example-web.auth :as auth]))
~~~~

In this namespace, we use Moustache (the only thing we use is the `app` macro), functions from various Ring namespaces (Jetty adapter, the response utility function, and the `wrap-params` middleware), and finally the namespace we just put together for authentication. With that out of the way, here's our Ring/Moustache app with two routes defined, one for each handler we wrote above:

~~~~
#!clojure
(declare my-app)
(def server (doto (Thread. #(run-jetty #'my-app {:port 8080})) .start))

(def my-app
  (app
   wrap-params
   :get [["login"] auth/request-openid
         ["auth-openid"] auth/authenticate-user]))
~~~~

To make the entry-point to our web application clear, I include the definition of the Jetty server at the top of the file, passing in my to-be app definition as `#'my-app` so that I can re-evaluate my app while the server is running and have it update live. It doesn't get much simpler than Moustache's syntax. I use the `app` macro to define two routes, each of which point to an individual Ring handler function. I also include the `wrap-params` middleware so that the URL will be parsed for parameters and those parameters will be included in the response map for me to use. We've already seen how these functions work, so none of this should be surprising.

So if you load and evaluate the code in this namespace, you should have a server running at [http://localhost:8080](http://localhost:8080). To begin, go to [http://localhost:8080/login](http://localhost:8080/login). This will redirect you to a standard Google page that asks you to give this application permissions to use your email address. If you sign in and approve, Google will redirect you to [http://localhost:8080/auth-openid](http://localhost:8080/auth-openid). The authenticate-user function, as we've seen, verifies the email address in the URL params and returns the appropriate response. The only code not included in these examples is the `user-whitelist` vector, which you should make yourself and include your own email address. I put it in a separate `example-web.state` namespace to keep things clean.

I hope you enjoyed this post, and that it saves you the time looking through the Google and openid4java docs for the exact sequence of functions to call.
