require 'rails_helper'

RSpec.describe ChatController, type: :controller do
  describe 'POST #ask', :vcr do
    it 'returns a response from the chatbot service' do
      post :ask, params: { question: "Is the conference room available tomorrow?"}
      expect(response).to be_successful
      json_response = JSON.parse(response.body)
      expect(json_response['response']).to be_a(String)
    end
  end
end
