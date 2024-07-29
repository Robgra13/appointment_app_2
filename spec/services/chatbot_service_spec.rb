# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChatbotService, type: :service do
  let(:chatbot_service) { described_class.new }
  let(:room) { Room.create!(name: 'Conference Room', capacity: 10) }
  let(:booking) do
    Booking.create!(
      room:,
      start: Time.zone.now.beginning_of_day + 2.hours,
      end: Time.zone.now.beginning_of_day + 4.hours,
      purpose: 'Meeting'
    )
  end

  describe '#ask_openai', :vcr do
    context 'when there is a booking' do
      before do
        booking
      end

      it 'handles room availability request' do
        VCR.use_cassette('room_availability') do
          question = 'Is the conference room available tomorrow?'
          response = chatbot_service.ask_openai(question)
          expect(response).to be_a(String)
        end
      end

      it 'matches expected room availability patterns' do
        VCR.use_cassette('room_availability') do
          question = 'Is the conference room available tomorrow?'
          response = chatbot_service.ask_openai(question)
          expect(response).to match(/Room|available|does not exist|There are no bookings/)
        end
      end

      it 'handles day availability request' do
        VCR.use_cassette('day_availability') do
          question = 'What bookings are there on 2024-07-28?'
          response = chatbot_service.ask_openai(question)
          expect(response).to be_a(String)
        end
      end

      it 'matches expected day availability patterns' do
        VCR.use_cassette('day_availability') do
          question = 'What bookings are there on 2024-07-28?'
          response = chatbot_service.ask_openai(question)
          expect(response).to match(/There are (no )?bookings/)
        end
      end
    end

    context 'when there is no booking' do
      before do
        Booking.destroy_all
      end

      it 'handles room availability request' do
        VCR.use_cassette('room_availability_no_bookings') do
          question = 'Is the conference room available tomorrow?'
          response = chatbot_service.ask_openai(question)
          expect(response).to be_a(String)
        end
      end

      it 'matches expected room availability patterns when no bookings' do
        VCR.use_cassette('room_availability_no_bookings') do
          question = 'Is the conference room available tomorrow?'
          response = chatbot_service.ask_openai(question)
          expect(response).to match(/Room|available|does not exist|There are no bookings/)
        end
      end

      it 'handles day availability request' do
        VCR.use_cassette('day_availability_no_bookings') do
          question = 'What bookings are there on 2024-07-28?'
          response = chatbot_service.ask_openai(question)
          expect(response).to be_a(String)
        end
      end

      it 'matches expected day availability patterns when no bookings' do
        VCR.use_cassette('day_availability_no_bookings') do
          question = 'What bookings are there on 2024-07-28?'
          response = chatbot_service.ask_openai(question)
          expect(response).to match(/There are (no )?bookings/)
        end
      end
    end
  end
end
