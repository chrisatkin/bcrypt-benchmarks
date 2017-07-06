require 'benchmark'
require 'bcrypt'
require 'securerandom'

cost_factors = 11..15
samples = 10
plaintext = SecureRandom.hex(16)
results = {}

puts "Testing cost factors #{cost_factors.to_s}"
puts "Using sample size of #{samples}"
puts "Plaintext is #{plaintext}"

Benchmark.bm do |x|
	cost_factors.each do |cost_factor|
		results[cost_factor] = x.report("cost factor #{cost_factor}:") do
			samples.times { BCrypt::Password.create(plaintext, cost: cost_factor) }
		end
	end
end

puts "Times to compute a single hash:"

results.each do |cost_factor, result|
	puts "#{cost_factor}: #{result.real / samples} seconds"
end