class TodoItem < ApplicationRecord
  belongs_to :user
  belongs_to :source, polymorphic: true
  
  validates :description, presence: true
  validates :source_type, presence: true
  validates :source_id, presence: true
  validates :week_start_date, presence: true
  
  scope :incomplete, -> { where(completed: false) }
  scope :completed, -> { where(completed: true) }
  
  has_many :notes, as: :notable, dependent: :destroy
end
