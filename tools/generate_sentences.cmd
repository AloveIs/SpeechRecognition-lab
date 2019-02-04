HSGen -l -n $1 four_digits.lat digits.dic | sed 's/.*\./TR&/' | sed 's/\./.wav/'
