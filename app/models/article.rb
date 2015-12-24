class Article < ActiveRecord::Base
  belongs_to :user
  validates :user_id, presence:true
  validates :content, presence:true
  validates :title, presence:true
  validates :title, length: {maximum:256}
  default_scope -> { order(created_at: :desc) }


end
