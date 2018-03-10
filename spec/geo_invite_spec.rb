require "geo_invite"

RSpec.describe GeoInvite do
	
	describe "initialize" do
		context "when there is no params" do
			it "set up default parameters" do
				geo_invite = GeoInvite.new()
				expect(geo_invite.file).to eq("common/customers.json")
				expect(geo_invite.latitude).to eq(53.339428)
				expect(geo_invite.longitude).to eq(-6.257664)
				expect(geo_invite.invited_customers).to match_array([])
			end
		end
		
		context "when there are all params params" do
			it "set up parameters" do
				geo_invite = GeoInvite.new("common/customers1.json","339428.11","-86876.122")
				expect(geo_invite.file).to eq("common/customers1.json")
				expect(geo_invite.latitude).to eq(339428.11)
				expect(geo_invite.longitude).to eq(-86876.122)
				expect(geo_invite.invited_customers).to match_array([])
			end
		end

	end
	
	describe "invite" do

		context "when customers file not exist" do
			it "throws an exception" do
				expect {
					GeoInvite.new("spec/nofile.json").invite
				}.to raise_error(Errno::ENOENT)
			end
		end

		context "when customers file has bad json data" do
			it "throws an exception" do
				expect {
					GeoInvite.new("spec/bad.json").invite
				}.to raise_error(JSON::ParserError)
			end
		end

		context "when customers file exist" do
			it "load file and parse json data" do
				geo_invite = GeoInvite.new("spec/customers_spec.json")
				geo_invite.invite
				expect(geo_invite.invited_customers.count).to eq(5)
				first_customer = geo_invite.invited_customers.first
				expect(first_customer["name"]).to eq("Eoin Ahearn")
				expect(first_customer["user_id"]).to eq(8)
			end
		end

		context "when customer invited" do
			it "sort customers by id ascending" do
				geo_invite = GeoInvite.new("spec/customers_spec.json")
				geo_invite.invite
				expect(geo_invite.invited_customers.map{|customer| customer["user_id"]}).to match_array([8, 15, 17, 29, 39])
			end
		end

	end 	

	describe "load_customers" do

		context "when customers file has no json data" do
			it "@customers should be empty" do
				geo_invite = GeoInvite.new("spec/empty.json")
				geo_invite.send(:load_customers)
				expect(geo_invite.instance_variable_get(:@customers).size).to eql(0)
			end
		end

		context "when customers file has valid json data" do
			it "@customers should not be empty" do
				geo_invite = GeoInvite.new("spec/customers_spec.json")
				geo_invite.send(:load_customers)
				expect(geo_invite.instance_variable_get(:@customers).size).to eql(12)
			end
		end

	end 	

	describe "find_customers_in_radius" do
		context "when radius is not valid" do
			it "throws an exception" do
				geo_invite = GeoInvite.new("spec/customers_spec.json")
				geo_invite.send(:load_customers)
				expect {
					geo_invite.send(:find_customers_in_radius,-100)
				}.to raise_error("Radius should be integer")
				
				expect {
					geo_invite.send(:find_customers_in_radius,"100")
				}.to raise_error("Radius should be integer")
				
				geo_invite.send(:find_customers_in_radius,100.00)
				expect(geo_invite.instance_variable_get(:@invited_customers).size).to eql(5)
			end
		end
		
		context "when radius specified" do
			it "should use param radius" do
				geo_invite = GeoInvite.new("spec/customers_spec.json")
				geo_invite.send(:load_customers)
				geo_invite.send(:find_customers_in_radius,50)
				expect(geo_invite.instance_variable_get(:@invited_customers).size).to eql(2)
			end
		end
	end 	

	describe "calculate_distance" do
		
		it "should throws exception" do
			geo_invite = GeoInvite.new
			expect {
				geo_invite.send(:calculate_distance,"53.4692815","-9.436036")
			}.to raise_error("String can't be coerced into Float")
		end

		it "should calculate distanc correctly" do
			geo_invite = GeoInvite.new
			distance = geo_invite.send(:calculate_distance,53.4692815,-9.436036)
			expect(distance).to eq(211.17)
		end
	end 	
end