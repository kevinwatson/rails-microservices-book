#require_relative '../lib/employee_message.pb'
#puts "EmployeeMessageService: #{EmployeeMessageService.inspect}"
class EmployeeMessageService < ::Protobuf::Rpc::Service #RPCService
  def search()
    puts "received request: #{request.inspect}"
    #byebug
    #records = ::Employee.where(guid: request.guid).to_a
      #.or(::Employee.where(first_name: request.first_name))
      #.or(::Employee.where(last_name: request.last_name))
    records = ::Employee.by_fields(request).map(&:to_proto)
    #byebug
    respond_with records: records
  end

  #def create(request)
  def create()
    record = ::Employee.create(request)

    respond_with record
  end

  #def update(request)
  def update()
    puts "request: #{request.inspect}"
    record = ::Employee.where(guid: request.guid).update_all(request)

    respond_with record
  end

  def delete(request)
    record = ::Employee.where(guid: request.guid).delete_all

    respond_with record
  end
end
