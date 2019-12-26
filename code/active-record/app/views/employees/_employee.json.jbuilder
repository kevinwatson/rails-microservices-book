json.extract! employee, :id, :guid, :first_name, :last_name, :created_at, :updated_at
json.url employee_url(employee, format: :json)
