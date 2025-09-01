class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  has_many :recurring_meetings, dependent: :destroy
  has_many :goals, dependent: :destroy
  has_many :ad_hoc_todos, dependent: :destroy
  has_many :todo_items, dependent: :destroy
  has_many :notes, dependent: :destroy
end
