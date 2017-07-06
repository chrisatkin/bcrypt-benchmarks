require 'benchmark'
require 'bcrypt'
require 'securerandom'

cost_factors = 11..15
samples = 10
plaintext = SecureRandom.hex(16)
hashes = {}
results = {}

def secure_compare(a, b)
	return false if a.blank? || b.blank? || a.bytesize != b.bytesize
	l = a.unpack "C#{a.bytesize}"

	res = 0
	b.each_byte { |byte| res |= byte ^ l.shift }
	res == 0
end

puts "Testing cost factors #{cost_factors.to_s}"
puts "Using sample size of #{samples}"
puts "Plaintext is #{plaintext}"

# Generate original hahes
cost_factors.each do |cost_factor|
	hashes[cost_factor] = BCrypt::Password.create(plaintext, cost: cost_factor).to_s
end

Benchmark.bm do |x|
	cost_factors.each do |cost_factor|
		results[cost_factor] = x.report("cost factor #{cost_factor}:") do
			samples.times do
				bcrypt = BCrypt::Password.new(hashes[cost_factor])
				password = BCrypt::Engine.hash_secret(plaintext, bcrypt.salt)
				secure_compare(password, hashes[cost_factor])
			end
		end
	end
end

puts "Times to verify a single hash:"

results.each do |cost_factor, result|
	puts "#{cost_factor}: #{result.real / samples} seconds"
end