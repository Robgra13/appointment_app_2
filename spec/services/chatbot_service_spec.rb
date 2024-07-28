# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChatbotService, type: :service do
  let(:chatbot_service) { described_class.new }

  describe '#ask_openai', :vcr do
    it 'handles room availability request' do
      VCR.use_cassette('room_availability') do
        question = 'Is the conference room available tomorrow?'
        response = chatbot_service.ask_openai(question)
        expect(response).to be_a(String)
        expect(response).to match(/Room|available|does not exist|There are no bookings/)
      end
    end

    it 'handles day availability request' do
      VCR.use_cassette('day_availability') do
        question = 'What bookings are there on 2024-07-28?'
        response = chatbot_service.ask_openai(question)
        expect(response).to be_a(String)
        expect(response).to match(/There are (no )?bookings/)
      end
    end
  end
end
