import configparser

parser = configparser.ConfigParser(interpolation=configparser.ExtendedInterpolation())

parser.read("C:/Users/borgonovo_furio/OneDrive - Playtech/Documents/snaitech-dev/Timetable/config/tt_config.ini");
#parser.read_dict(config_dict)

for section_name, section in parser.items():
    print("{:18s}\n".format(section_name))
    a = dict(section)
    for name, value in a:
        print("{} {}".format(name, value))