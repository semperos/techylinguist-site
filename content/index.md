## Welcome ##

How many permutations can one blog have? As many as it takes to make it (1) easy for me to publish, (2) easy for me to deploy and (3) easy to keep everything under Git version control. I apologize to anyone who had my previous posts bookmarked.

If you want a local copy of this site, you can clone [the git repo on Github](https://github.com/semperos/techylinguist-site). Posts are located under the `/content` folder:

~~~~
git clone https://github.com/semperos/techylinguist-site.git
~~~~

The current iteration of the site uses [nanoc](http://nanoc.stoneship.org) for static site generation.

## Posts ##

<% @site.sorted_articles.each do |post| %>
 * [<%= post[:title] %>](<%= post.path %>)
{:class="post-list-title"} 
<% end %>

