require 'json'
# GeoInvite class provide methods that reads a list of customers from a given file and output the names and user ids of
# customers located within N km from specific location, sorted by user id ascending
class GeoInvite
	
	attr_accessor :file, :latitude, :longitude , :invited_customers
	
	# Init GeoInvite class with:
	# file: file name contain customer data list, default to customers.json
	# latitude:  base latitude to be compare with, default to Intercom Dublin office
	# longitude: base longitude to be compare with, default to Intercom Dublin office
	def initialize(file = "common/customers.json",latitude = "53.339428",longitude = "-6.257664")
		@latitude = latitude.to_f
		@longitude = longitude.to_f
		@file = file
		@invited_customers = []
	end

	# invite customers within provided radius default to 100 km
	def invite(radius=100)
		load_customers
		find_customers_in_radius(radius)
		print_invited_customers
	end

	private

	# load customers from file and parse json line and store it in instance variable @customers
	def load_customers
		@customers = []
		File.readlines(File.expand_path(@file)).each do |customer|
			@customers << JSON.parse(customer)
		end
	end

	# find customers that fall within given radius
	def find_customers_in_radius(in_radius)
		raise "Radius should be integer" unless in_radius.is_a?(Numeric) && in_radius >= 0
		_invited_customers = []
		@customers.each do |customer|
			distance = calculate_distance(customer["latitude"].to_f, customer["longitude"].to_f)
			if (distance <= in_radius)
				_invited_customers << customer
			end
		end
		@invited_customers = _invited_customers.sort_by { |ic| ic["user_id"] }
	end

	# outputs list of eligible customers
	def print_invited_customers
		@invited_customers.each do |customer|
			puts "ID:#{customer["user_id"]} Name:#{customer["name"]}"
		end
	end
	
	# calculate distance
	def calculate_distance(customer_latitude, customer_longitude)
		earth_radius = 6371.0 #earth radius in km
		# subtract values and convert to radians
		latitude_delta  = (@latitude - customer_latitude) * (Math::PI / 180.0)
		longitude_delta = (@longitude - customer_longitude) * (Math::PI / 180.0)
		# perform distance calculation
		a = Math.sin(latitude_delta/2)**2 + Math.cos((@latitude * (Math::PI / 180.0))) * Math.cos((customer_latitude * (Math::PI / 180.0))) * Math.sin(longitude_delta/2) ** 2
		c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
		return (c * earth_radius).round(2)
	end
end