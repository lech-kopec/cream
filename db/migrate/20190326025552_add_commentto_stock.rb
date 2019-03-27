class AddCommenttoStock < ActiveRecord::Migration[5.2]
  def change
    add_column :stocks, :comment, :text
  end
end
