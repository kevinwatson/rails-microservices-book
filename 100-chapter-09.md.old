# Commands

$ mkdir code
$ cd code
$ vim Dockerfile.builder
$ vim docker-compose.builder.yml
$ docker-compose -f docker-compose.builder.yml run builder bash
# rails new active-remote --skip-active-record #--skip-javascript
# cd active-remote
# echo "gem 'active_remote'" >> Gemfile
# echo "gem 'protobuf-nats'" >> Gemfile
# bundle
# rails generate scaffold Employee guid:string first_name:string last_name:string

# cd ..
# rails new active-record #--skip-javascript
# cd active-record
# echo "gem 'active_remote'" >> Gemfile
# echo "gem 'protobuf-nats'" >> Gemfile
# echo "gem 'protobuf-activerecord'" >> Gemfile
# bundle
# rails generate scaffold Employee guid:string first_name:string last_name:string
# rails db:migrate

# exit
# mkdir -p protobuf/{definitions,lib}
$ vim protobuf/definitions/employee_message.proto
$ vim protobuf/Rakefile
$ docker-compose -f docker-compose.builder.yml run builder bash
# cd protobuf
# rake protobuf:compile
# exit
$ mkdir -p {active-record,active-remote}/app/lib
$ cp protobuf/lib/employee_message.pb.rb active-record/app/lib/
$ cp protobuf/lib/employee_message.pb.rb active-remote/app/lib/
$ mkdir active-record/app/services
$ vim active-record/app/services/employee_message_service.rb
$ vim active-record/app/models/employee.rb
$ vim active-remote/app/models/employee.rb
$ vim Docker
$ vim docker-compose.yml
$ vim active-record/config/environments/development.rb # config.eager_load = true
$ vim active-remote/config/environments/development.rb # config.eager_load = true
$ vim active-remote/controllers/employees_controller.rb # def index; @employees = Employee.search(:guid => ""); end and def set_employee; @employee = Employee.search(guid: params[:id]).first; end; def new; @employee = Employee.new(guid: SecureRandom.uuid); end;
$ vim active-record/config/protobuf_nats.yml
$ vim active-remote/config/protobuf_nats.yml
$ docker-compose build
$ docker-compose up
$ open http://localhost:3000/employees
