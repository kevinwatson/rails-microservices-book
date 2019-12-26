# encoding: utf-8

##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf'
require 'protobuf/rpc/service'


##
# Message Classes
#
class EmployeeMessage < ::Protobuf::Message; end
class EmployeeMessageRequest < ::Protobuf::Message; end
class EmployeeMessageList < ::Protobuf::Message; end


##
# Message Fields
#
class EmployeeMessage
  optional :string, :guid, 1
  optional :string, :first_name, 2
  optional :string, :last_name, 3
end

class EmployeeMessageRequest
  optional :string, :guid, 1
  optional :string, :first_name, 2
  optional :string, :last_name, 3
end

class EmployeeMessageList
  repeated ::EmployeeMessage, :records, 1
end


##
# Service Classes
#
class EmployeeMessageService < ::Protobuf::Rpc::Service
  rpc :search, ::EmployeeMessageRequest, ::EmployeeMessageList
  rpc :create, ::EmployeeMessage, ::EmployeeMessage
  rpc :update, ::EmployeeMessage, ::EmployeeMessage
  rpc :destroy, ::EmployeeMessage, ::EmployeeMessage
end

