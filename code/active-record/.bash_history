rails new -J --skip-coffee .
ls
rails s
bundle exec rpc_server start -p 9399 -o active-record ./app/services/employee_message_service.rb
bundle exec rpc_server start -p 9399 -o active-record ./app/services/employee_message_service.rb
