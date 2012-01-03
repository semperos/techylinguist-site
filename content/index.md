## Welcome ##

This blog focuses on code (mostly Clojure and Ruby) and notes (mostly ramblings) that I want to keep track of as I hack on open source software.

I am currently in the process of migrating some of my old posts (last post migrated on January 3rd, 2012), so please be patient as I add more content.

If you want a local copy of this site, you can clone [the git repo on Github](https://github.com/semperos/techylinguist-site). Posts are located under the `/content` folder:

~~~~
git clone https://github.com/semperos/techylinguist-site.git
~~~~

The current iteration of the site uses [nanoc](http://nanoc.stoneship.org) for static site generation.

## Posts ##

<% sorted_articles.each do |post| %>
 * <%= post.human_post_date %> - [<%= post[:title] %>](<%= post.path %>)
<% end %>

