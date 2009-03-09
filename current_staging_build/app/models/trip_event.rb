class TripEvent < ActiveRecord::Base
  belongs_to :device
  belongs_to :reading_start,:class_name => "Reading"
  belongs_to :reading_stop,:class_name => "Reading"
end