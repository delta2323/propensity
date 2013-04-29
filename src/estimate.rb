#!/usr/bin/env ruby

require 'optparse'

def logistic(theta, x)
  1.0/(1.0+Math.exp(-theta*x))
end

def estimate_naive(data)
  raise "length=0" if data.length == 0
  data.map{|datum| datum[1]}.inject(:+).to_f/data.length
end

def naive(data)
  zero = data.select{|datum| datum[2] == 0}
  one = data.select{|datum| datum[2] == 1}
  estimate = [estimate_naive(zero), estimate_naive(one)]
  estimate << estimate[1] - estimate[0]
  estimate
end

def estimate_regression_coeffs(data)
  x_sum = data.map{|datum| datum[0]}.inject(:+)
  y_sum = data.map{|datum| datum[1]}.inject(:+)
  x_sqr = data.map{|datum| x=datum[1]; x*x}.inject(:+)
  inner_prod = data.map{|datum| datum[0]*datum[1]}.inject(:+)
  n = data.length
  det = n*x_sqr - x_sum*x_sum
  alpha = (x_sqr*y_sum-x_sum*inner_prod)/det
  beta = (-x_sum*y_sum+n*inner_prod)/det
  [alpha, beta]
end

def estimate_by_regression(data)
  coeffs = estimate_regression_coeffs(data)
  data.map{|datum|
    coeffs[0]+coeffs[1]*datum[0]
  }.inject(:+)/data.length
end

def regression(data)
  zero = data.select{|datum| datum[2] == 0}
  one = data.select{|datum| datum[2] == 1}
  estimate = [estimate_by_regression(zero), estimate_by_regression(one)]
  estimate << estimate[1] - estimate[0]
  estimate
end

def gradient(data, theta)
  data.inject(0.0){|sum, datum|
    x = datum[0]
    z = datum[2]
    p = logistic(theta, x)
    sum + x*(z-p)
  }
end

def estimate_theta(data)
  lo = -5.0
  hi = 5.0
  50.times {
    mid = (lo+hi)/2
    gradient(data, mid) > 0 ? lo = mid : hi = mid
  }
  lo
end

def estimate_by_propensity(data, theta, one)
  numerator = 0.0
  denominator = 0.0
  data.each{|datum|
    propensity = logistic(theta, datum[0])
    correction = one ? propensity : 1.0-propensity
    numerator += datum[1]/correction
    denominator += 1.0/correction
  }
  numerator / denominator
end

def propensity(data)
  theta = estimate_theta(data)
  zero = data.select{|datum| datum[2] == 0}
  one = data.select{|datum| datum[2] == 1}
  estimate = [estimate_by_propensity(zero, theta, false), estimate_by_propensity(one, theta, true)]
  estimate << estimate[1] - estimate[0]
  estimate
end

def linear(x, coeffs)
  coeffs[0]+coeffs[1]*x
end

def estimate_by_doubly_robust(data, theta, one)
  z = one ? 1 : 0
  regression_data = data.select{|datum| datum[2] == z}
  coeffs = estimate_regression_coeffs(regression_data)
  numerator = 0.0
  denominator = 0.0
  data.each{|datum|
    propensity = logistic(theta, datum[0])
    regression = linear(datum[0], coeffs)
    correction = one ? propensity : 1.0-propensity
    if datum[2] == z
      numerator += datum[1]/correction
      numerator += (1.0-1.0/correction)*regression
      denominator += 1.0/correction
    elsif datum[2] == 1-z
      numerator += regression
      denominator += 1.0
    end
  }
#  numerator/denominator
  numerator/data.length
end

def doubly_robust(data)
  theta = estimate_theta(data)
  estimate = [estimate_by_doubly_robust(data, theta, false),
              estimate_by_doubly_robust(data, theta, true)]
  estimate << estimate[1] - estimate[0]
  estimate
end

def main(option)
  method = option[:method]
  data = []
  gets
  while line = gets
    datum = line.strip.split(",")
    data << [datum[0].to_f, datum[1].to_f, datum[2].to_i]
  end

  result = nil
  if method == "naive"
    result = naive(data)
  elsif method == "regression"
    result = regression(data)
  elsif method == "propensity"
    result = propensity(data)
  elsif method == "doubly_robust"
    result = doubly_robust(data)
  end
  puts [method, result].flatten.join(", ")
end

def parse(argv)
  option = {}
  OptionParser.new{|opt|
    opt.on("--method M") {|v| option[:method] = v}
    opt.parse!(argv)
  }
  option
end

if __FILE__ == $0
  option = parse(ARGV)
#  warn option
  main option
end
