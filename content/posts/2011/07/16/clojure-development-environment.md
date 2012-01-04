## Clojure Development Environment ##

There are only two important things to remember about your Clojure development environment:

 1. Don't let it get in the way of learning Clojure.
 2. Don't let it get in the way of learning Clojure.

### Overview and Reasoning ###

I prefer coding with text editors over IDE's. I prefer coding Clojure within the context of an actual project, using a build tool to generate the directory structure and handle dependencies. These preferences inform the instructions that follow.

### Text Editors ###

I've used practically every text editor on every platform I've coded on. I prefer Emacs to all of them. Pick one and get on with learning Clojure, worry about the "perfect" environment once you've learned the basics.

#### Emacs ####

Instead of trying to explain all the various in's and out's, the up's and down's, and the packages you might install for Emacs, I'll just say the following:

 1. Install Emacs for your platform
    * [Windows binaries](http://ftp.gnu.org/gnu/emacs/windows/)
    * [Emacs For Mac OSX](http://emacsformacosx.com/), [Aquamacs](http://aquamacs.org/)
    * Use your package manager under Linux
    * On Linux, I personally compile Emacs 24 locally. See [SaltyCrane's blog](http://www.saltycrane.com/blog/2008/10/installing-emacs-23-cvs-ubuntu-hardy/) for instructions and [here](http://savannah.gnu.org/projects/emacs) for links to the source code itself.
 2. Emacs expects to see a file `.emacs` and a folder `.emacs.d` in your home directory. Download [my Emacs configuration from Github](https://github.com/semperos/emacs-config), put it in your home folder and rename it to `.emacs.d.`
 3. Make a soft link in your home directory to the `.emacs` file inside the `.emacs.d` folder. Use `ln -s TARGET LINK_NAME` on *nix platforms and `MKLINK /D LINK_NAME TARGET` on Windows (make sure to open command-line with admin privileges in Windows).
 4. You now have a working Emacs environment with support for all of the Clojure goodies you've heard about. You could have also used [Clojure Box](http://clojure.bighugh.com/) or followed the instructions on [Clojure's JIRA wiki](http://dev.clojure.org/display/doc/Getting+Started+with+Emacs). Run the Emacs tutorial by pressing `C-h t` (`Ctrl+h`, then `t`).

Now you can add/subtract whatever you want, but you can be assured that the packages and configuration in my setup work on Windows 7, Linux (Ubuntu and friends), and Mac OSX Snow Leopard, as I develop on all those platforms and use the same Emacs setup across the board.

### Building with a Clojure Project ###

When first starting, some folks just like to get a REPL up. But to (1) handle dependencies easily, (2) create anything reusable, and (3) utilize Emacs to its full potential, you need to bite the following small bullet and build using projects.

#### Start a Project ####

Install Leiningen by following the instructions [on its Github README](https://github.com/technomancy/leiningen#readme). Create a new project like so:

~~~~
lein new name-of-project
~~~~

Open up the `project.clj` file inside, add any libraries to `:dependencies` and `:dev-dependencies` that you want, then pull down the dependencies using Leiningen again:

~~~~
lein deps
~~~~

You can generally skip this step; most Leiningen commands perform an automatic `lein deps` if you haven't pulled down dependencies yet.

#### REPL ####

You have a few options concerning REPL's. The quickest method is to use Leiningen's built-in REPL by running the following at the command-line:

~~~~
lein repl
~~~~

For a more featureful setup, I personally use Swank/Slime. Install the Swank plugin for Leiningen on the command-line:

~~~~
lein plugin install swank-clojure 1.3.1
~~~~

This means you don't need to add swank-clojure in your `project.clj` file's `:dev-dependencies`. You can use it as follows:

 1. Open up a command-line terminal
 2. Navigate to your project's root
 3. Run `lein swank`
 4. Within Emacs, once the Swank server has started, do `M-x slime-connect` (means "press Alt/Option and x together, then type slime-connect and press enter")

With that, you should get a REPL that defaults to the user namespace. While there is a lot of built-in functionality with Slime (see [swank-clojure on Github](https://github.com/technomancy/swank-clojure) for concise list), I'll show you the workflow I use every day. If you're working on a particular file, do the following to focus your work in that namespace:

 1. Open the file in Emacs
 2. Do `C-c C-k` to compile and load the file into your Swank instance
 3. Press `,` then the letter `i`, then type out the name of your file's namespace (you can TAB-complete). Press enter when done.

And with that, your REPL should have gone from the `user` namespace to `your-files-namespace`. Now you can play with things at the REPL within the confines of that namespace, and as you add to your actual file in Emacs you can run `C-c C-k` along the way to update your Swank/Slime environment.

#### Jar it Up ####

When you're ready to share your code or just want to create an executable Jar, Leiningen is your friend again.

##### Basic Jar #####

The `lein jar` command creates a non-executable Jar from your project's source. If you're pushing to Clojars, you'll need to generate a `pom.xml` file as well with `lein pom` and then push up your Jar to Clojars with:

~~~~
scp pom.xml my-project.jar clojars@clojars:org
~~~~

For Windows users, either [Cygwin](http://cygwin.com/) or the [Git bash shell](http://code.google.com/p/msysgit/downloads/list) have the `scp` command.

##### Executable Jar #####

To get an executable jar requires a little more work. You'll need to:

 1. Indicate which namespace is your main (or entry) namespace inside your `project.clj` file
 2. Add a `-main` function to that namespace
 3. Add `:gen-class` to that namespace
 
Inside your `project.clj` file, add an entry that looks like this:

~~~~
:main my-project.foo
~~~~

...where `foo` is the target main namespace. Inside that file, add a `-main` function (note the dash):

~~~~
#!clojure
(defn -main
  []
  ;; do something...)
~~~~

In that same file, in the `ns` declaration, add a `:gen-class` declaration as follows:

~~~~
#!clojure
(:gen-class
 :main true)
~~~~

To test these settings, you can run `lein run` at the command-line and simulate running your project as an executable jar. If all works, run `lein uberjar` to generate the actual executable jar.

### Conclusion ###

There are a lot of other things you can add to your Clojure development environment, much of which is included in my Emacs config but not discussed here. Don't get hung up on your development environment; get something working, learn Clojure, pick up example projects to have real things to work on, and build up your toolkit as you need to and are comfortable.
