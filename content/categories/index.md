## Categories ##

Posts fall into the following categories (posts are tagged with multiple topics, so there will be duplicates):


<% all_categories_with_posts.each do |cat, posts| %>

### <%= cat %> ###

  <% posts.each do |post| %>
 * [<%= post[:title] %>](<%= post.path %>)
  <% end %>

<% end %>
