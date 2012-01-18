# Categories/tags on posts
module Nanoc3
  module Helpers
    module Blogging
      def find_all_categories
        categories = []
        sorted_articles.each do |post|
          if post.attributes[:categories]
            post.attributes[:categories].each do |category|
              categories << category unless categories.include? category
            end
          end
        end
        categories.sort
      end

      def all_categories_with_posts
        cat_posts = {"Uncategorized" => []}
        sorted_articles.each do |post|
          if post.attributes[:categories]
            post.attributes[:categories].each do |category|
              cat_posts[category] ||= []
              cat_posts[category] << post
            end
          else
            cat_posts["Uncategorized"] << post unless cat_posts["Uncategorized"].include? post
          end
        end

        cat_posts.each do |category, posts_array|
          posts_array.sort! { |p1, p2| p1[:title] <=> p2[:title] }
        end.sort.delete_if { |k, v| v.length == 0}
      end
    end
  end
end
