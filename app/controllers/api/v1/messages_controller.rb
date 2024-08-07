require 'nokogiri'
require 'open-uri'

module Api
  module V1
    class MessagesController < ApplicationController
      before_action :set_conversation

      def index
        render json: @conversation.messages.map(&:attributes).map{|message| message.merge({widget_data: JSON.parse(message['widget_data'] || '{}')}) }
      end

      # POST /api/v1/conversations/:conversation_id/messages
      def create
        @message = @conversation.messages.build(message_params.merge({user: 'user'}))
        if @message.save
          react = ReAct.new(@conversation)
          react.ask

          render json: @message, status: :created
        else
          render json: @message.errors, status: :unprocessable_entity
        end
      end

      private

      def set_conversation
        @conversation = Conversation.find(params[:conversation_id])
      end

      def message_params
        params.require(:message).permit(:content)
      end
    end
  end
end
