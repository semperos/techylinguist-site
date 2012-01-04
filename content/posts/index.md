## Posts ##

<% sorted_articles.each do |post| %>
 * <%= post.human_post_date %> - [<%= post[:title] %>](<%= post.path %>)
<% end %>
