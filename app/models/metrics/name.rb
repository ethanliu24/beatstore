# frozen_string_literal: true

require "set"

module Metrics
  class Name
    TEST = "test"

    # payments & fulfillments
    ORDER_FULFILLMENT_RESULT = "order_fulfillment_result"
    STRIPE_ONE_TIME_PAYMENT = "stripe_one_time_payment"
    STRIPE_CHECKOUT_INTENT = "stripe_checkout_intent"

    # clean ups
    METRICS_CLEAN_UP_FINISHED = "metrics_clean_up_finished"

    # back ups
    BACKUP_PG_DUMP_RESULT = "backup_pg_dump_result"
    BACKUP_GOOGLE_DRIVE_UPLOAD_RESULT = "backup_google_drive_upload_result"
    CLEAN_UP_BACKUP_ARTIFACT_RESULT = "clean_up_backup_artifact_result"

    class << self
      def is_defined?(name)
        defined_names.include?(name)
      end

      private

      def defined_names
        @defined_names ||= Set.new(
          Name.constants.map { |const_name| Name.const_get(const_name) }
        )
      end
    end
  end
end
