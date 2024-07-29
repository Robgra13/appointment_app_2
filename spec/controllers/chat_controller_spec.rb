# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChatController, type: :controller do
  describe 'POST #ask', :vcr do
    it 'returns a successful response' do
      post :ask, params: { question: 'Is the conference room available tomorrow?' }
      expect(response).to be_successful
    end

    it 'returns a response from the chatbot service' do
      post :ask, params: { question: 'Is the conference room available tomorrow?' }
      json_response = response.parsed_body
      expect(json_response['response']).to be_a(String)
    end
  end
end
