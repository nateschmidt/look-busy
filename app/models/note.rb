class Note < ApplicationRecord
  belongs_to :user
  belongs_to :notable, polymorphic: true
  
  validates :content, presence: true
end
