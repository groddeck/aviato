module Api
  module V1
    class ConversationsController < ApplicationController
      before_action :set_conversation, only: [:show]

      # GET /api/v1/conversations
      def index
        @conversations = Conversation.all.order(:created_at).reverse
        render json: @conversations
      end

      # GET /api/v1/conversations/:id
      def show
        render json: @conversation
      end

      # POST /api/v1/conversations
      def create
        @conversation = Conversation.new
        if @conversation.save
          render json: @conversation, status: :created
        else
          render json: @conversation.errors, status: :unprocessable_entity
        end
      end

      private

      def set_conversation
        @conversation = Conversation.find(params[:id])
      end

      def conversation_params
        params.require(:conversation)
      end
    end
  end
end
