class User < ActiveRecord::Base

  validates(:name, {presence:true})

  validates(:email, {presence:true})
  validates :name, length: {maximum:50}
  validates :email, length: {maximum:255}
  validates :email, uniqueness: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, format:{with: VALID_EMAIL_REGEX }


end
