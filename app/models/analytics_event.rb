class AnalyticsEvent
  include Mongoid::Document

  field :event_type, type: String
  field :data, type: Hash
  field :created_at, type: DateTime
  field :assignment_id, type: Integer
  field :user_id, type: Integer

  after_create do |event|
    AnalyticsAggregate.incr(event)
  end
end