#!/usr/bin/env ruby

require 'optparse'

def ndist(mu, sigma, prg)
  x = Math.sqrt(-2*Math.log(prg.rand))*Math.cos(2*Math::PI*prg.rand)
  x*sigma+mu
end

def logistic(theta, x)
  1.0/(1.0+Math.exp(-theta*x))
end

def linear(x, coeffs, prg)
  eps = ndist(0, coeffs[2], prg)
  coeffs[0]+coeffs[1]*x+eps
end

def generate(prg, option)
  x = ndist(option[:x_mu], option[:x_sigma], prg)
  
  p = logistic(option[:theta], x)
  z = prg.rand(1.0) > p ? 0 : 1
  y = z == 0 ? linear(x, option[:zero], prg) : linear(x, option[:one], prg)
  [x, y, z]
end

def main(option)
  prg = Random.new(option[:seed])
  puts "x,y,z"
  option[:data_num].times{|i|
    sample = generate(prg, option)
    puts sample.join(",")
  }
end

def parse(argv)
  option = {}
  option[:zero] = Array.new(3)
  option[:one] = Array.new(3)
  OptionParser.new{|opt|
    opt.on("--x-mu M") {|v| option[:x_mu] = v.to_f}
    opt.on("--x-sigma M") {|v| option[:x_sigma] = v.to_f}
    opt.on("--theta M") {|v| option[:theta] = v.to_f}
    opt.on("--alpha-zero M") {|v| option[:zero][0] = v.to_f}
    opt.on("--beta-zero M") {|v| option[:zero][1] = v.to_f}
    opt.on("--epsilon-zero M") {|v| option[:zero][2] = v.to_f}
    opt.on("--alpha-one M") {|v| option[:one][0] = v.to_f}
    opt.on("--beta-one M") {|v| option[:one][1] = v.to_f}
    opt.on("--epsilon-one M") {|v| option[:one][2] = v.to_f}
    opt.on("--data-num M") {|v| option[:data_num] = v.to_i}
    opt.on("--seed M") {|v| option[:seed] = v.to_i}
    opt.parse!(argv)
  }
  option
end

if __FILE__ == $0
  option = parse(ARGV)
  warn option
  main option
end
