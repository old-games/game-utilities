@echo off
SET NOTABENOID_USER=user
SET NOTABENOID_PASSWORD=password
SET RES_PATH=..\..\gameres
SET SKY_PATH=D:\games\scummvm\bass-cd-1.2\sky.dsk
SET SKY_RU_PATH=D:\games\scummvm\bassru\sky.dsk

SET NB_PATH=http://notabenoid.com/book/10919/


del eng.xml
br_nb_parser.exe union eng.xml %RES_PATH%\eng0.xml 60600 %RES_PATH%\eng1.xml 60601 %RES_PATH%\eng2.xml 60602
br_nb_parser.exe union eng.xml %RES_PATH%\eng3.xml 60603 %RES_PATH%\eng4.xml 60604 %RES_PATH%\eng5.xml 60605
br_nb_parser.exe union eng.xml %RES_PATH%\eng6.xml 60606 %RES_PATH%\eng7.xml 60607

br_nb_parser.exe parse eng.xml %NB_PATH% -u %NOTABENOID_USER% -p %NOTABENOID_PASSWORD%

bassru_patcher.exe make patch.xml

bassru_patcher.exe patch patch.xml -f %SKY_PATH% -o %SKY_RU_PATH%
 