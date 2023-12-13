import csv

from os.path import dirname, join

current_dir = dirname(__file__)
file_path = join(current_dir, "./082428.csv")

# open file in read mode
with open(file_path, 'r') as csvfile:
    data = list(csv.reader(csvfile, delimiter=';'))

print(*data[0], sep="\t")
print(*data[1:], sep="\n")

#
    # pass the file object to reader() to get the reader object
#    csv_reader = reader(read_obj)
    # Iterate over each row in the csv using reader object
#    for row in csv_reader:
        # row variable is a list that represents a row in csv
#        print(row)

