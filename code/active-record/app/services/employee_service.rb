class EmployeeService < RPCService
  def search(request)
    employee = Employee.where(first_name: request.payload[:first_name]).or(last_name: request.payload[:last_name])
    return employee
  end

  def create(request)
  end

  def update(request)
  end

  def delete(request)
  end
end
