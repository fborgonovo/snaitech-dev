Start-process powershell.exe    -credential 'GRUPPOSNAI\dipendenti_updater' \
                                -NoNewWindow \
                                -ArgumentList '-executionpolicy bypass', '-file', $fullArgs \
                                -WorkingDirectory c:\windows\system32

