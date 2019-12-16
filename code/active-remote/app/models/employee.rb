require 'employee_message.pb'

class Employee < ActiveRemote::Base
  #service_class EmployeeMessageService
  service_name :employee_message_service
  
  alias_attribute :id, :guid

  attribute :guid
  attribute :first_name
  attribute :last_name
end
