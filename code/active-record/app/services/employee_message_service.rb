class EmployeeMessageService
  def search
    records = ::Employee.search_scope(request).map(&:to_proto)

    respond_with records: records
  end

  def create
    record = ::Employee.create(request)

    respond_with record
  end

  def update
    record = ::Employee.where(guid: request.guid).first
    record.assign_attributes(request)
    record.save!

    respond_with record
  end

  def destroy
    record = ::Employee.where(guid: request.guid).first

    record.delete
    respond_with record.to_proto
  end
end
