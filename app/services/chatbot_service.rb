# frozen_string_literal: true

class ChatbotService
  def initialize
    @client = OpenAI::Client.new(api_key: ENV.fetch('OPENAI_API_KEY', nil))
  end

  def ask_openai(question)
    functions = [
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

    response = @client.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: [{ role: 'user', content: question }],
        functions:,
        function_call: 'auto',
        max_tokens: 150
      }
    )

    message = response['choices'][0]['message']
    if message['function_call']
      handle_function_call(message['function_call'])
    else
      message['content'].strip
    end
  rescue StandardError => e
    Rails.logger.error "OpenAI API Error: #{e.message}"
    "An error occurred while contacting OpenAI: #{e.message}"
  end

  def fetch_room_availability(room_name)
    Rails.logger.info "Fetching availability for room: #{room_name}"
    room = Room.find_by('LOWER(name) = ?', room_name.downcase)
    if room
      bookings = room.bookings.where(start: Time.zone.now..)
      if bookings.any?
        booking_details = bookings.map do |b|
          start_time = b.start.strftime('%Y-%m-%d %H:%M:%S')
          end_time = b.end.strftime('%Y-%m-%d %H:%M:%S')
          purpose = b.purpose.presence || 'No purpose specified'
          "Booking from #{start_time} to #{end_time} for #{purpose}"
        end.join("\n")
        "Room #{room_name} has upcoming bookings:\n#{booking_details}"
      else
        "Room #{room_name} is available."
      end
    else
      "Room #{room_name} does not exist."
    end
  end

  def fetch_day_availability(day)
    date = begin
      Date.parse(day)
    rescue StandardError
      nil
    end
    if date
      bookings = Booking.where('DATE(start) = ?', date)
      if bookings.any?
        booking_details = bookings.map do |b|
          start_time = b.start.strftime('%Y-%m-%d %H:%M:%S')
          end_time = b.end.strftime('%Y-%m-%d %H:%M:%S')
          purpose = b.purpose.presence || 'No purpose specified'
          "Room #{b.room.name}: Booking from #{start_time} to #{end_time} for #{purpose}"
        end.join("\n")
        "There are bookings on #{day}:\n#{booking_details}"
      else
        "There are no bookings on #{day}."
      end
    else
      'The provided date is invalid.'
    end
  end

  def handle_function_call(function_call)
    case function_call['name']
    when 'fetch_room_availability'
      arguments = JSON.parse(function_call['arguments'])
      room_name = arguments['room_name']
      fetch_room_availability(room_name)
    when 'fetch_day_availability'
      arguments = JSON.parse(function_call['arguments'])
      day = arguments['day']
      fetch_day_availability(day)
    else
      "Unknown function: #{function_call['name']}"
    end
  end

  def handle_question(question)
    ask_openai(question)
  end
end
