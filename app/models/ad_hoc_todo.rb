class AdHocTodo < ApplicationRecord
  belongs_to :user
  
  validates :description, presence: true
  
  scope :incomplete, -> { where(completed: false) }
  scope :completed, -> { where(completed: true) }
  
  has_many :todo_items, as: :source, dependent: :destroy
  has_many :notes, as: :notable, dependent: :destroy
end
