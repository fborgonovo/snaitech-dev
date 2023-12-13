"""
    -----------------------------
    --- Employes data updater ---
    -----------------------------
    
    Workflow:

        1) Validate preconditions
        2) Get user's data from the REST: curl -X GET "http://10.177.111.32:8080/Employee/getXMLForExcel?caller=intranet&firma=E2E38FDC09A1CAEF479F96E887D049DB&requestId=1" -H  "accept: */*"
                                          intranet - - E2E38FDC09A1CAEF479F96E887D049DB 1
        3) Convert XML user's data in table format
        4) For each record:
            a) Validate the record
            b) Use the email field to search the SQL DB
            c) Check for deleted employes
            d) Check for added employes
            e) For each employee check for variations

	Parameter(s):

        User's data from the REST:
            esito
            desc
            dipendente
            elencoDip
            company
            sn
            givenName
            mail
            department
            description
            office
            jobTitle
            manager
            l
            streetAddress
            telephoneNumber
            mobile
            thumbnailphoto
            customAttribute6
            gruppoSPOwner
            gruppoSPReader
            mailDelResponsabile
            codAzienda
            codDipendente
            codBU

        User's data from the Intranet DB:
            [samAccountName]    [varchar](255) NULL,
            [dataCreazione]     [nvarchar](50) NULL,
            [mailResp]          [nvarchar](50) NULL,
            [codAzienda]        [tinyint] NULL,
            [codDipendente]     [smallint] NULL,
            [cognome]           [nvarchar](50) NULL,
            [nome]              [nvarchar](50) NULL,
            [mail]              [nvarchar](50) NULL,
            [id_reparto]        [int] NULL,
            [id_squadra]        [int] NULL,
            [id_divisione]      [int] NULL,
            [id_mansione]       [int] NULL,
            [codBU]             [smallint] NULL,
            [codRespStringa]    [nvarchar](50) NULL,
            [samResp]           [nvarchar](50) NULL,
            [codAzResp]         [tinyint] NULL,
            [codDipResp]        [smallint] NULL,
            [id_avatar]         [nvarchar](1) NULL,
            [dataAssunzione]    [date] NULL,
            [dataNascita]       [date] NULL,
            [inquadramento]     [nvarchar](1) NULL,
            [unitaLocale]       [int] NULL,
            [unitaProduttiva]   [int] NULL,
            [cellulare]         [nvarchar](50) NULL,
            [interno]           [nvarchar](50) NULL,
            [sede]              [nvarchar](50) NULL,
            [Azienda]           [varchar](255) NULL,
            [Reparto]           [varchar](255) NULL,
            [Squadra]           [varchar](255) NULL,
            [Divisione]         [varchar](255) NULL,
            [Mansione]          [varchar](255) NULL,
            [Thumbnailphoto]    [varchar](255) NULL,
            [customAttribute6]  [varchar](255) NULL,
            [gruppoSPOwner]     [varchar](255) NULL,
            [gruppoSPReader]    [varchar](255) NULL

    Results:

        a) Deleted employes file (deleted-yyyymmdd.sql)
        b) Modifyed employes file (modifyed-yyyymmdd.sql)
        c) Info (info-yyyymmdd.log)
        d) Anomalies (anomalies-yyyymmdd.log)

	History:

        v0.1 :	Project start

"""

"""
__author__ = "Furio Angelo Borgonovo"
__copyright__ = ""
__date__ = "Mar 2020"
__credits__ = [""]
__license__ = ""
__version__ = "0.1"
__maintainer__ = "Furio Angelo Borgonovo"
__email__ = "furio.borgonovo@snaitech.it"
__status__ = "Prototype"
"""

import pyodbc

conn = pyodbc.connect('Driver={SQL Server};'
                      'Server=intra-prod-db01.grupposnai.net;'
                      'Database=LibraryDB;'
                      'UID=dipendenti_updater;'
                      'PWD=dipendenti_updater!;'
                      'Trusted_Connection=No;')

cursor = conn.cursor()

""" Single record insertion """

name = "Book - A"
price = 125

insert_records = '''INSERT INTO Books(Name, Price) VALUES(?,?) ''' 
cursor.execute(insert_records, name, price)

conn.commit()

""" Multiple records insertion """

record_1 = ["Book - B", 300]
record_2 = ["Book - C", 200]

record_list = []
record_list.append(record_1)
record_list.append(record_2)

insert_records = '''INSERT INTO Books(Name, Price) VALUES(?,?) ''' 
cursor.executemany(insert_records, record_list)

conn.commit()

""" Selecting records """

select_record = '''SELECT * FROM Books'''
cursor.execute(select_record)
     
for row in cursor:
    print(row)

""" Updating records """

update_query = '''UPDATE Books SET Price = 400 WHERE Id= 1'''
cursor.execute(update_query)

conn.commit()

""" Deleting records """

delete_query = '''DELETE FROM Books WHERE Id= 1'''
cursor.execute(delete_query )

conn.commit()
