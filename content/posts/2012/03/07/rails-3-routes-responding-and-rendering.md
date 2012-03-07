## Rails 3: Routes, Responding and Rendering ##

The `render`, `respond_to`, and `respond_with` methods all have a part to play in how Rails 3 apps handle routing and rendering. Here are some code snippets I made for myself to help illuminate what's going on.

From my `routes.rb` file:

~~~~
#!ruby
get "dev/routing/noformat" => 'dev_tools#test_routing_no_format'
get "dev/routing/fail" => 'dev_tools#test_routing_failure'
get "dev/routing/defaults" => 'dev_tools#test_routing_with_defaults', :defaults => { :format => 'json' }
get "dev/routing/respond-with" => 'dev_tools#test_routing_respond_with'
~~~~

From my `dev_tools_controller.rb` file:

~~~~
#!ruby
class DevToolsController < ApplicationController
  respond_to :html, :xml, :json

  def test_routing_no_format
    @foo = {:foo => "Routing with no specific format in URL or routes.rb",
            :method => "render :json => @foo"}
    render :json => @foo, :content_type => "application/json"
  end

  def test_routing_failure
    @foo = {:foo => "Failure of respond_with because no default is chosen.",
            :method => "respond_with(@foo)"}
    respond_with(@foo)
  end

  def test_routing_with_defaults
    @foo = {:foo => "Success of respond_with without specifying a format in the URL, because in routes.rb we've specified a default :format to pass in.",
            :method => "respond_with(@foo)"}
    respond_with(@foo)
  end

  def test_routing_respond_with
    @foo = {:foo => "Success of respond_with with custom block passed in, ONLY if you add a :format extension in the URL.",
      :method => "respond_with(@foo)"}
    respond_with(@foo) do |format|
      format.xml { @foo[:bar] = "Something new!"; render :xml => @foo }
    end
  end
end
~~~~

And what gets returned (in order of routes defined above):


~~~~
http://localhost:3000/dev/routing/noformat - Content-Type set correctly because I made it explicit
{"foo":"Routing with no specific format in URL or routes.rb","method":"render :json => @foo"}

http://localhost:3000/dev/routing/fail
Template is missing
Missing template dev_tools/test_routing_failure, application/test_routing_failure with {:locale=>[:en], :formats=>[:html], :handlers=>[:erb, :builder, :coffee]}. Searched in: * "/Users/semperos/web/pegasus_web/app/views"

http://localhost:3000/dev/routing/defaults - Content-Type set correctly by respond_with
{"foo":"Success of respond_with without specifying a format in the URL, because in routes.rb we've specified a default :format to pass in.","method":"respond_with(@foo)"}

http://localhost:3000/dev/routing/respond-with.json - Content-Type set correctly by respond_with
{"foo":"Success of respond_with with custom block passed in, ONLY if you add a :format extension in the URL.","method":"respond_with(@foo)"}
~~~~

So the short-and-sweet of it:

 * Use `respond_with` when you're *exposing* an endpoint to consumers who want data in multiple formats (and should be able to get it simply by changing something like `.xml` to `.json`)
 * Use `render { :xml => @foo }` for *internal* endpoints to your application for which you can easily change the controller code.
 
**You might ask,** why not just use `respond_with` and use a `:defaults` key in your `routes.rb` file for your internal endpoints as well? In my opinion, routes should be a fairly static thing that only capture necessary *data* to send back to your controllers; they shouldn't be containing any logic, primary or auxiliary, outside of RESTful semantics, which would not be the case if we set a default `:format` in `routes.rb` only because the business logic in our application leveraged that format.

**You might ask,** why not just use `respond_with` and make sure all of your URL's have a format extension on the end? Because my endpoints should really just be like function calls, and the format of the return value of a function shouldn't be captured in its name. A function call should be able to return the correct type of value solely depending on my business logic. This means that I could potentially return XML under one set of circumstances, or JSON in another.

I've had controller methods returning XML at a point in the development of my application when I wanted raw KML returned for rendering with Google Earth, only later to want a more complex JSON object that might have that same KML embedded with other properties in a JavaScript object. Being able to hit endpoints simply by name (like regular function calls) makes these kinds of transformations much easier to reason about and implement.
