# frozen_string_literal: true

class ChatbotService
  def initialize
    @client = OpenAI::Client.new(api_key: ENV.fetch('OPENAI_API_KEY', nil))
  end

  def ask_openai(question)
    functions = build_functions

    response = @client.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: [{ role: 'user', content: question }],
        functions:,
        function_call: 'auto',
        max_tokens: 150
      }
    )

    handle_response(response)
  rescue StandardError => e
    handle_error(e)
  end

  def fetch_room_availability(room_name)
    room = find_room_by_name(room_name)
    return "Room #{room_name} does not exist." unless room

    bookings = upcoming_bookings(room)
    return "Room #{room_name} is available." if bookings.empty?

    booking_details(room_name, bookings)
  end

  def fetch_day_availability(day)
    date = parse_date(day)
    return 'The provided date is invalid.' unless date

    bookings = bookings_on_date(date)
    return "There are no bookings on #{day}." if bookings.empty?

    day_booking_details(day, bookings)
  end

  def handle_function_call(function_call)
    case function_call['name']
    when 'fetch_room_availability'
      fetch_room_availability(JSON.parse(function_call['arguments'])['room_name'])
    when 'fetch_day_availability'
      fetch_day_availability(JSON.parse(function_call['arguments'])['day'])
    else
      "Unknown function: #{function_call['name']}"
    end
  end

  private

  def build_functions
    [
      {
        name: 'fetch_room_availability',
        description: 'Fetch the availability of a specific room',
        parameters: {
          type: 'object',
          properties: {
            room_name: { type: 'string', description: 'The name of the room' }
          },
          required: ['room_name']
        }
      },
      {
        name: 'fetch_day_availability',
        description: 'Fetch the bookings on a specific day',
        parameters: {
          type: 'object',
          properties: {
            day: { type: 'string', format: 'date', description: 'The date to check bookings for' }
          },
          required: ['day']
        }
      }
    ]
  end

  def handle_response(response)
    message = response['choices'][0]['message']
    if message['function_call']
      handle_function_call(message['function_call'])
    else
      message['content'].strip
    end
  end

  def handle_error(error)
    Rails.logger.error "OpenAI API Error: #{error.message}"
    "An error occurred while contacting OpenAI: #{error.message}"
  end

  def find_room_by_name(room_name)
    Room.find_by('LOWER(name) = ?', room_name.downcase)
  end

  def upcoming_bookings(room)
    room.bookings.where(start: Time.zone.now..)
  end

  def booking_details(room_name, bookings)
    details = bookings.map do |b|
      start_time = b.start.strftime('%Y-%m-%d %H:%M:%S')
      end_time = b.end.strftime('%Y-%m-%d %H:%M:%S')
      purpose = b.purpose.presence || 'No purpose specified'
      "Booking from #{start_time} to #{end_time} for #{purpose}"
    end.join("\n")
    "Room #{room_name} has upcoming bookings:\n#{details}"
  end

  def parse_date(day)
    Date.parse(day)
  rescue StandardError
    nil
  end

  def bookings_on_date(date)
    Booking.where('DATE(start) = ?', date)
  end

  def day_booking_details(day, bookings)
    details = bookings.map do |b|
      start_time = b.start.strftime('%Y-%m-%d %H:%M:%S')
      end_time = b.end.strftime('%Y-%m-%d %H:%M:%S')
      purpose = b.purpose.presence || 'No purpose specified'
      "Room #{b.room.name}: Booking from #{start_time} to #{end_time} for #{purpose}"
    end.join("\n")
    "There are bookings on #{day}:\n#{details}"
  end
end
