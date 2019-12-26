class Employee < ActiveRemote::Base
  service_class ::EmployeeMessageService

  attribute :guid
  attribute :first_name
  attribute :last_name
end
