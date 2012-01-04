## CoffeeScript on Windows 7 ##

It took me a little while to find solutions for CoffeeScript on Windows that actually worked without setting my hair on fire, so I'm outlining them below. Enjoy.

### Fastest and Simplest Method ###

The fastest and simplest method to get a working CoffeeScript compiler on Windows is to download Duncan Smart's [coffeescript-windows repository from Github](https://github.com/duncansmart/coffeescript-windows) and put it on your system `PATH` (open your Control Panel, search for "environment", edit your Environment Variables, and prepend the system PATH variable with something like `C:/Users/your_user/coffeescript_windows;`, making sure to have no dashes for any of the directories and to put a semicolon afterwards). The command works as follows:

~~~~
coffee input.coffee output.js
~~~~

That's it. It doesn't take any fancy options, just takes a file (or text from stdin) and spits out a file (or text to stdout).

**Pro:** Just download the repo and you have a working CoffeeScript compiler with the `coffee` command. Put the directory on your Path for easier use.

**Con:** The `coffee` command is very simple, providing the essential file-in-file-out functionality, but not compilation of entire directories, automatic recompilation of watched files, or opening an interactive CoffeeScript REPL/command-line prompt.

### Full-Featured Method ###

The standard way of using CoffeeScript is with Node.js. On systems that support it, you can install CoffeeScript with the [Node Package Manager](http://npmjs.org/) by running `npm install coffee`. In this vein, most blog posts describing how to setup CoffeeScript on Windows first explain how to compile Node.js on Windows. However, trying to compile various versions of Node.js on Windows is a chore at best, and at worst impossible. So I finally stumbled across [Mikhail Nasyrov's solution](http://blog.mnasyrov.com/post/2872046541/coffeescript-on-windows-how-to-roast-coffee), which uses the following method:

 1. Download the [CoffeeScript repository](https://github.com/jashkenas/coffee-script)
 2. Download a [*binary* of Node.js](http://node-js.prcn.co.cc/)
 3. (Optional) Install [Cygwin](http://cygwin.com/) to have access to the cygpath.exe command
 4. (Optional) Install [NAnt](http://nant.sourceforge.net/) for an Ant-like build tool for .NET

Mikhail goes into a lot of detail and provides some example batch and NAnt files to help automate his proposed workflow, but for me, I'm most interested in being able to use the `coffee` command from the command-line as similarly as possible to the experience on *nix-based operating systems. From that point, folks can automate their individual workflows as they see fit.

#### CoffeeScript Source ####

First, if you don't have Git, install the most recent `Git-x.x.x-previewxxxxxxxx.exe` from the [msysgit downloads page](http://code.google.com/p/msysgit/downloads/list). I suggest keeping all the defaults in the installer. Open up your Git Bash, navigate to wherever you want to keep the CoffeeScript source (I store code I'm going to use as "executable" and not for hacking in `C:/Users/my_user/opt`), and run:

~~~~
git clone http://github.com/jashkenas/coffee-script.git coffee_script
~~~~

This will create a folder called `coffee_script` in the current directory. I make sure the directory doesn't have dashes in it, because I'm going to be adding it to my system Path. To make sure you're using stable code, you should checkout a tag for a stable version of CoffeeScript. Run `git tag` inside Git Bash to see all tags, then run `git checkout name-of-tag` to "convert" your codebase to a stable version. For example, to use version 1.1.1 of CoffeeScript:

~~~~
git checkout 1.1.1
~~~~

Unless you have reason to do otherwise, you should checkout the tag with the highest version number that doesn't say anything like "beta", "alpha" or "rc".

#### Node.js Binary ####

First, make sure you [install 7-zip](http://www.7-zip.org/download.html), as the Node.js binaries come archived in `.7z` format. Next, download the latest stable binary of Node.js from [http://node-js.prcn.co.cc/](http://node-js.prcn.co.cc/). Open the archive with 7-zip and stick the files where you like (I again use `C:/Users/my_user/opt`, putting the files inside a folder called `node`).

#### Putting It All Together ####

The CoffeeScript source code we put in `C:/Users/my_user/opt/coffee_script` has a directory called `bin` which contains executable files. These files are written in JavaScript, and we can see from the shebang line `#!/usr/bin/env node` that we should use Node.js to run these files directly on the command-line. We're going to be using the `coffee` command in that `bin` folder. So without any Path niceties, we could check that our setup is working with the following on the command-line:

~~~~
C:/Users/my_user/opt/node/bin/node /cygdrive/C/Users/my_user/opt/coffee_script/bin/coffee --version
~~~~

Whoa whoa whoa, what's all that `cygdrive` and forward-slashes all about? Firstly, Windows doesn't care which way your slashes go. Secondly, the Node.js binary for Windows is compiled using Cygwin, so **it expects Cygwin-style, absolute paths**. As you can probably see, all that means is "replace back-slashes with forward slashes, and replace `C:/` with `/cygdrive/C/`". To make this a little easier, here's a quick batch script I whipped up:

~~~~
@echo OFF
set cdir=%CD%
set cdir=%cdir:\=/%
set cdir=%cdir:C:=/cygdrive/c%
~~~~

Just run that inside the directory where you're writing your CoffeeScript, and you'll have access to a variable `cdir` that you can use as I demonstrate below.

#### Path Time ####

I've already described how to edit your system path above, so I'll just outline the basics here:

 1. Put Node.js' `bin` folder on your system path. Open up a new command-line instance and type `where node` to make sure you set it correctly.
 2. Add a batch file to CoffeeScript's `bin` folder called `coffee.bat` (see below for actual code), and add that `bin` folder to your Path.
 
That magic batch file `coffee.bat`, stolen right from Mikhail's post:

~~~~
@pushd .
@cd /d %~dp0
@node coffee %*
@popd
~~~~

So since we have node on our Path, the batch call to `@node` will work. Once we add the `bin` folder inside our CoffeeScript directory which contains this `coffee.bat` file, we can just use `coffee` at the command-line, with the one added hiccough of paths. Here's how I handle it:

~~~~
# Create environment variables for my CoffeeScript source folder
# and JavaScript output folder respectively
set cdir=/cygdrive/c/users/my_user/coffee_src
set jdir=/cygdrive/c/users/my_user/js_output

# Now I can use those with the coffee command
# Compile whole folder of *.coffee files and output to js_output
coffee -o %jdir% -c %cdir%

# Compile a single file
coffee -c %cdir%/foo.coffee

# Watch files for changes and compile automatically
coffee --watch --compile %cdir%/foo.coffee

# Start the CoffeeScript REPL
coffee
~~~~

Yes, it's one bit less pretty than what *nix platforms have, because our Cygwin-compiled version of Node.js needs paths a certain way. But for me, this isn't a huge deal, and if you're performing the same operation(s) several times or as part of your build process, take a look at the batch and NAnt files that Mikhail Nasyrov [provides in his blog post](http://blog.mnasyrov.com/post/2872046541/coffeescript-on-windows-how-to-roast-coffee) for inspiration.
