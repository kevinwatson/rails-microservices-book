json.extract! employee, :id, :first_name, :last_name, :created_at, :updated_at
json.url employee_url(employee, format: :json)
