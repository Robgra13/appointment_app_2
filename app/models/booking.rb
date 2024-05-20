class Booking < ApplicationRecord
  belongs_to :room

  validates :start, :end, presence: true
  validate :booking_does_not_overlap

  private

  def booking_does_not_overlap
    if room_id.present? && (overlapping_bookings.any? || overlapping_with_existing_bookings.any?)
      errors.add(:base, "Booking conflicts with existing bookings")
    end
  end

  def overlapping_bookings
    Booking.where(room_id: room_id)
           .where.not(id: id)
           .where("(? <= start AND start < ?) OR (? < end AND end <= ?) OR (start <= ? AND ? <= end)", start, self.end, start, self.end, start, start)
  end

  def overlapping_with_existing_bookings
    room.bookings.where.not(id: id)
                .where("(? <= start AND start < ?) OR (? < end AND end <= ?) OR (start <= ? AND ? <= end)", start, self.end, start, self.end, start, start)
  end
end
