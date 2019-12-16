require 'employee_message.pb'

class Employee < ApplicationRecord
  protobuf_message :employee_message # protobuf-activerecord
  #service_name :employee_message_service

  scope :by_guid, lambda { |*values| where(guid: values) }
  scope :by_first_name, lambda { |*values| where(first_name: values) }
  scope :by_last_name, lambda { |*values| where(last_name: values) }

  field_scope :guid
  field_scope :first_name
  field_scope :last_name
end
