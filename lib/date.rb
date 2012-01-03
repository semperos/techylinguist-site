# Date helpers

module Nanoc3
  class Item
    def human_post_date
      Time.at(self[:created_at]).to_date.to_s
    end
  end
end
