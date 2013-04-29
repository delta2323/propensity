#!/usr/bin/env bash

data_num=5000

for b in `jot - -5 5`
do
     data_file=../data/sample.${b}.${data_num}.dat
     ./generate.rb --x-mu 0 --x-sigma 4\
             --theta 0.5\
             --alpha-zero 5 --beta-zero 0 --epsilon-zero 2\
 	    --alpha-one 5 --beta-one ${b} --epsilon-one 2\
 	    --data-num ${data_num} --seed ${b} > ${data_file}
      ./estimate.rb --method naive < ${data_file}
      ./estimate.rb --method regression < ${data_file}
     ./estimate.rb --method propensity < ${data_file}
     ./estimate.rb --method doubly_robust < ${data_file}
done