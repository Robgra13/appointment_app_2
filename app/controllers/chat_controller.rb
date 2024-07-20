class ChatController < ApplicationController
  protect_from_forgery with: :null_session

  def ask
    question = params[:question]
    Rails.logger.info "Received question: #{question}"
    chatbot_service = ChatbotService.new
    response = chatbot_service.handle_question(question)
    Rails.logger.info "Chatbot response: #{response}"
    render json: { response: response }
  end
end
