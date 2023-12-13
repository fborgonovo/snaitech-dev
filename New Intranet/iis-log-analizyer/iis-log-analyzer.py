import os
import glob
import pandas as pd
# modify the directory to point to the proper log dir
sourceDir="T:\IISLogFiles"
# modify to handle all log fields present in your logs
log_field_names = ['date', 'time', 's-ip', 'cs-method', 'cs-uri-stem', 'cs-uri-query', 's-port', 'cs-username', 'c-ip',
                    'cs(User-Agent)', 'cs(Referer)', 'sc-status', 'sc-substatus', 'sc-win32-status', 'time-taken']
df = pd.DataFrame()
for dirname, dirnames, filenames in os.walk(sourceDir):
    # traverse through directories
    for subdirname in dirnames:
        # skip FTP log directories - we don't want to parse FTP logs
        if subdirname[:3] != "FTP":
            list_of_files = glob.glob(sourceDir + "\\" + subdirname + "\*.log")
            # perform data gathering only if there are log files in the subdirectory
            if len(list_of_files) > 0:
                # find the newest log file
                latest_file = max(list_of_files, key=os.path.getctime)
                # import the log data into temporary dataframe
                df_temp = pd.read_csv(latest_file, sep=' ', comment='#', engine='python', names=log_field_names)
                # fill website identifier for further use
                df_temp["website"] = subdirname
                # append imported data to the main dataframe
                df = df.append(df_temp, ignore_index=True)
print("Imported data breakdown: ")
print(df.info())
print("The most frequent IPs")
print(df["c-ip"].value_counts())
print("The most frequent User Agents")
print(df["cs(User-Agent)"].value_counts())
print("The most frequent websites in the logs")
print(df["website"].value_counts())
print("The most frequent response code")
print(df["sc-status"].value_counts())