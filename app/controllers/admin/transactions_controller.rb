# frozen_string_literal: true

module Admin
  class TransactionsController < Admin::BaseController
    def index
      @transactions = Transaction.kept.order(created_at: :desc)
    end

    def show
      @transaction = Transaction.kept.find(params[:id])
      @order = @transaction.order
    end
  end
end
