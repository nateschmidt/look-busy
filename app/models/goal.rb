class Goal < ApplicationRecord
  belongs_to :user
  
  validates :description, presence: true, length: { maximum: 255 }
  validates :target_count, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :description, uniqueness: { scope: :user_id }
  
  scope :ordered, -> { order(:description) }
  
  has_many :todo_items, as: :source, dependent: :destroy
  
  def display_name
    "#{description} (#{target_count} per week)"
  end
end
