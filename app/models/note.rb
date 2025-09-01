class Note < ApplicationRecord
  belongs_to :user
  belongs_to :notable, polymorphic: true
  
  # Content is optional - notes can be created without content for todo completion
  validates :content, presence: true, unless: -> { notable_type == 'TodoItem' }
end
