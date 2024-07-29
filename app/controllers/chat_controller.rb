# frozen_string_literal: true

class ChatController < ApplicationController
  protect_from_forgery with: :null_session

  def ask
    question = params[:question]
    Rails.logger.info "Received question: #{question}"
    chatbot_service = ChatbotService.new
    response = chatbot_service.ask_openai(question)
    Rails.logger.info "Chatbot response: #{response}"
    render json: { response: }
  end
end
