# frozen_string_literal: true

class Room < ApplicationRecord
  validates :name, :capacity, presence: true
  has_many :bookings, dependent: :destroy
end
