## Deploy a JRuby on Rails Application as a WAR File ##

### Overview ###

There are several ways to deploy a JRuby on Rails application. This post focuses on the following use-case:

> My application is a JRuby on Rails app version 3.1. I need to deploy my app within an existing Java deployment infrastructure.

This generally means an installation of Tomcat, JBoss or some other servlet container. For this reason, this post will focus on preparing your JRuby on Rails app for production mode, generating a `*.war` file and deploying that to a servlet container.

At the end, you will have a Bash script which can you put in `RAILS_ROOT/script` and run like this from the root of your Rails app:

~~~~
./script/deploy
~~~~

### Deployment Choices ###

The most common methods for deploying a JRuby on Rails app that come to mind are:

 * Source code with Glassfish
 * [Torquebox](http://torquebox.org) (JBoss with helpers)
 * As a `*.war` with any servlet container

Although this post will focus on the WAR-file variant, I wanted to mention the work that the [Project:odd](http://projectodd.org/) team has done with [Torquebox](http://torquebox.org/). Torquebox bundles JBoss AS (version 7.1 as of this writing) and includes tools for starting up daemon processes, job scheduling, messaging support and asynchronous task execution. It provides a no-brainer approach to deploying your Rack-based application, and is well worth a look[^1].

### Deployment Instructions ###

When deploying a JRuby on Rails 3.1 application as a WAR file, there are a few primary steps involved:

 1. Install necessary gems
 2. Edit `config/environments/production.rb` if needed
 3. Pre-compile all assets
 4. Generate the WAR file

Let's tackle them one at a time.

#### Install Gems ####

We are going to use the warbler gem for generating our WAR files. You should add these lines to your Rails `Gemfile`:

~~~~
group :development do
  gem "warbler", "~> 1.3.2"
  gem "jruby-rack", "~> 1.1.3"
end
~~~~

**IMPORTANT:** As of this writing, you need to ensure that you're using version 1.1.3 of jruby-rack.

Now install the gems:

~~~~
jruby -S bundle
~~~~

Verify that warbler was installed correctly by running `jruby -S warble -T` at the command-line.

#### Production Configuration ####

Before going on, take a look at `config/environments/production.rb` and ensure all of the settings meet your needs. Feel free to start with the defaults, but make sure to read all of the comments in that file and brush up on [configurating Rails applications](http://guides.rubyonrails.org/configuring.html).

#### Asset Compilation ####

In Rails-speak, an "asset" represents a stylesheet, a JavaScript file or an image. In an effort both to increase the performance of Rails sites and to increase developer productivity, Rails provides an "asset pipeline" which compiles all assets into their appropriate formats and optionally minifies and compresses them.

In development mode, your Rails site re-compiles assets as needed. In production, you don't want to incur that performance hit, so run the following to pre-compile your assets:

~~~~
jruby -S rake assets:precompile
~~~~

(Note: If you do this multiple times, you might want to occasionally clean out the `tmp` and `public/assets` folders in your Rails app.)

The `assets:precompile` task automatically compiles CoffeeScript to JavaScript and SASS to CSS, optionally minifies JavaScript and CSS, and finally gzips files to make them smaller.

##### Adding Asset Compilation to the WAR Process #####

For our deployment strategy, the only time we will need to pre-compile assets is when we are planning to generate our WAR file. By default, the warbler gem comes with a `warble` executable. However, there's a nicer way to integrate warbler behavior with our Rails app.

Run the following at the root of your Rails app to have warbler populate your Rails Rake tasks with some of its own:

~~~~
jruby -S warble pluginize
~~~~

If you do `jruby -S rake -T | grep war` you should see tasks that warbler has added. Now let's make the process of asset pre-compilation a part of the WAR-generation process. Add the following to a file `lib/tasks/warble.rake`:

~~~~
begin
  require 'warbler'
  Warbler::Task.new
  task :war => ["assets:precompile"]
rescue LoadError => e
  puts "Failed to load Warbler. Make sure it's installed."
end
~~~~

Now whenever you run `jruby -S rake war`, you'll get asset pre-compilation for free.

##### Caveat: Long or Unending Processes #####

If you start long or non-terminating processes as part of your Rails app's initialization, your asset pre-compilation task will never finish.

Per usual, when running Rake tasks, your Rails application is bootstrapped. If you begin any processes that do not terminate during the initializatioin of your Rails app (e.g., you start up an AMQP subscription on a RabbitMQ exchange that stays open for the lifetime of your app), you need to provide a mechanism to skip starting those processes when performing asset pre-compilation.

One method that I have used is to depend on environment variables. To continue with my parenthetical AMQP example (using the [hot_bunnies](https://github.com/ruby-amqp/hot_bunnies) AMQP gem), suppose you had the following in `config/initializers/amqp.rb`:

~~~~
#!ruby
require 'hot_bunnies'

connection = HotBunnies.connect( my_amqp_conf )
channel = connection.create_channel
channel.prefetch = 10

exchange = channel.exchange('my_exchange', :type => :topic, :durable => true)

queue = channel.queue('foo.all')
queue.bind(exchange, :routing_key => 'foo.#')
queue.purge

Rails.logger.info "Starting up AMQP subscriber on #{connection.get_host_address}..."
subscription = queue.subscribe(:blocking => false) do |headers, payload|
  # do interesting things here
end
~~~~

The important part here is the `:blocking => false` option, which makes this connection asynchronous. When simply running a Rake task to pre-compile assets, nothing will happen to close this connection, which means the Rake task will hang well after its already completed its real work.

As an alternative, you could enclose the previous code in a conditional block that relies on the presence of an environment variable:

~~~~
#!ruby
unless ENV['MY_PROJECT_COMPILE'] == 'true'
 # Never-ending code here...
end
~~~~

Then, when you go to compile your assets (or generate a WAR file, see below), issue your Rake command like this:

~~~~
jruby -S rake assets:precompile MY_PROJECT_COMPILE=true
~~~~

#### WAR Generation ####

There are several gems out there for packaging up JRuby code, but the [warbler](https://github.com/jruby/warbler) gem sits in the [jruby organization account on Github](https://github.com/jruby)[^2] and offers all of the features we need.

_NOTE: If you skipped the previous section, make sure you at least read the caveat about long or unending processes before running these commands._

For the purposes of this post, I'm going to assume you're "practicing" a deployment of your Rails app to a local installation of Tomcat. In light of that assumption, I'm going to take you on a journey to build a Bash script that will perform the following operations:

 1. Make you double-check that you're in the root of your Rails app
 2. Establish a TOMCAT_HOME variable
 3. Set your compile-time variable to true so long-running processes aren't started
 4. Cleanup old WAR files generated by warbler
 5. Delete all `*.class` files in your Rails app
 6. Generate a new WAR file (finally!)
 7. Remove old deployments of your app from your local Tomcat installation
 8. Stop your local Tomcat process
 9. Copy your newly-generated WAR file into your Tomcat installation
 10. Start up Tomcat again

For Windows users, the commands that follow should be simple enought to translate. If not, leave comments below and I'll do my best to help.

##### 1. Double-check you're in Rails root #####

Some Rails commands get goofy when you're not in the root of your app. Make this the first lines of our Bash script to remind you:

~~~~
#!/bin/bash

echo ""
echo " ##############################################################"
echo " #                                                            #"
echo " # NOTE: This script must be run from the Rails project root. #"
echo " #                                                            #"
echo " ##############################################################"
echo ""
read -p "Press [ENTER] to continue..."
~~~~

If you're not in the Rails root, press `Ctrl-c` to exit the process.

##### 2. Where's Tomcat? #####

Make sure a `TOMCAT_HOME` variable is defined, and if not, give it a default. Since this is your local computer, this shouldn't be too hard, but here's the logic:

~~~~
if [ "$TOMCAT_HOME" = "" ]; then
  TOMCAT_HOME="/opt/tomcat"
fi
~~~~

Watch trailing slashes; we'll be building further paths based on this variable in later steps.

##### 3. (Optional) Set a compile-time flag #####

If you start long or non-terminating processes in your Rails initialization, you need to skip them when pre-compiling assets or generating the WAR file. The following assumes you took my above advice about depending on an environment variable in your Rails code. Here's where you set it to `"true"` before compiling things:

~~~~
export MY_PROJECT_COMPILE=true
~~~~

##### 4. Remove previous WAR files #####

The warbler gem comes with a `war:clean` Rake task. Run it before we get too far along:

~~~~
jruby -S rake war:clean
~~~~

##### 5. Remove compiled files #####

Before we compile our JRuby files again, it never hurts to delete the old `*.class` files that were generated on previous runs. Do that now:

~~~~
find . -type f -name *.class -print0 | xargs -0 rm
~~~~

We should also delete the `tmp` and `public/assets` folders to avoid any weird cache conflicts across compilations:

~~~~
rm -rf tmp public/assets
~~~~

##### 6. Generate the WAR file #####

Finally, generate the WAR file.

But wait! We haven't precompiled our assets yet! Remember earlier, we added asset pre-compilation to the `war` task provided by warbler, since that's the only time we need it.

Add this to automatically pre-compile your assets and generate a WAR file:

~~~~
jruby -S rake war
~~~~

Before moving along, we should set our compile-time variable to a different value, so our shell session doesn't continue to keep it as `"true"`:

~~~~
export MY_PROJECT_COMPILE=""
~~~~

##### 7. Remove old deployment from Tomcat #####

As a matter of thoroughness, let's completely clear out the old deployment of our application in Tomcat (assuming you've done this now multiple times). This is where having `TOMCAT_HOME` properly defined is quite important:

~~~~
rm -rf $TOMCAT_HOME/webapps/my_project*
~~~~

Make sure you've taken the time to ensure (1) this is where your deployment is located and (2) what your deployment is called (by default, it's the name of your Rails app).

##### 8. Stop Tomcat #####

I'm not sure if it's my setup, or the way that JRuby WAR files are generated by warbler, but I receive errors when I attempt to "hot load" a WAR file into Tomcat. So let's stop Tomcat before we go any further:

~~~~
$TOMCAT_HOME/bin/shutdown.sh
~~~~

This is the manual script for shutting down Tomcat. If you started Tomcat with something like `service tomcat start`, you should use the corresponding stop function.

##### 9. Deploy your WAR #####

We've finally generated a new WAR and have a clean `webapps` directory to drop it into. Copy it:

~~~~
cp my_project.war $TOMCAT_HOME/webapps/
~~~~

Since Tomcat is stopped, you should not see a `my_project` folder automatically appear. If you do, Tomcat didn't stop successfully and you may want to try again.

##### 10. Start Tomcat #####

Finally, start Tomcat again to have your new WAR file auto-expanded in Tomcat's `webapps` folder:

~~~~
$TOMCAT_HOME/bin/startup.sh
~~~~

Again, use the appropriate start command if you have Tomcat installed as a service on your system.

You should now be able to visit [http://localhost:8080](http://localhost:8080) to see that Tomcat is running, and then [http://localhost:8080/my_project](http://localhost:8080/my_project) to go to your application's home page.

### Conclusion ###

The above explanation is long and there's lots of code snippets in-between. As a reference, here are the basic steps required:

 1. Install warbler and jruby-rack gems
 2. Tweak your `config/environments/production.rb` config
 3. Pre-compile your assets
 4. Generate a WAR
 5. Copy that WAR file into your servlet container's appropriate deployment folder

Also for reference, here is the final Bash script based on this post's assumptions:

~~~~
#!/bin/bash

echo ""
echo " ##############################################################"
echo " #                                                            #"
echo " # NOTE: This script must be run from the Rails project root. #"
echo " #                                                            #"
echo " ##############################################################"
echo ""
read -p "Press [ENTER] to continue..."

if [ "$TOMCAT_HOME" = "" ]; then
  TOMCAT_HOME="/opt/tomcat"
fi

export MY_PROJECT_COMPILE=true

echo "INFO: [x] TOMCAT_HOME is ${TOMCAT_HOME}."
echo "INFO: [x] Cleaning local WAR files."
jruby -S rake war:clean

echo "INFO: [x] Deleting old *.class files."
find . -type f -name *.class -print0 | xargs -0 rm

echo "INFO: [x] Generating new WAR for my_project"
jruby -S rake war

# no longer compiling, so deactivate this flag
export MY_PROJECT_COMPILE=""

# necessary evil
echo "INFO: [x] Removing old WAR deployment and shutting down Tomcat."
./script/my_project/war-undeploy
$TOMCAT_HOME/bin/shutdown.sh

echo "INFO: [x] Copying new WAR to Tomcat in ${TOMCAT_HOME}/webapps/"
cp my_project.war $TOMCAT_HOME/webapps/

echo "INFO: [x] Starting Tomcat."
$TOMCAT_HOME/bin/startup.sh
~~~~

### Footnotes ###

[^1]: Especially if you do Clojure development as well. Their sister [Immutant](http://immutant.org/) project provides a similar frictionless path for deploying your Clojure web applications in a JBoss container, but as of this writing is much less mature than Torquebox.
[^2]: Like that _argumentum ad verecundiam_?
