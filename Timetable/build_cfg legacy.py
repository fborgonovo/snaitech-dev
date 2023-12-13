from configparser import ConfigParser

# creating object of configparser
config = ConfigParser()

# creating a section
config.add_section('database')

# adding key-value pairs
config.set("database", "host", "local host")
config.set("database", "admin", "local admin")
config.set("database", "password", "qwerty@123")
config.set("database", "port no", "2253")
config.set("database", "database", "SQL")
config.set("database", "version", "1.1.0")

# creating another section
config.add_section("user")

# adding key-value pairs
config.set("user", "name", "test_name")
config.set("user", "e-mail", "test@example.com")
config.set("user", "id", "4759422")

with open("C:/Users/borgonovo_furio/OneDrive - Playtech/Documents/snaitech-dev/Timetable/config/tt_config.ini", 'w') as tt_config:
    config.write(tt_config)