REM ******************************************************************
REM  File:        EDI.sql
REM  Description: Used for inserting EDI Partner Trading Data
REM               
REM  Created:     April 1, 2017 Caleb Crickette
REM  Modified:    April 1, 2017 CC
REM Modified:     April 15, 2017 CC
REM  Version:     1.3
REM ******************************************************************

--Drop Tables

REM ******************************************************************
REM  File: dropEDI.sql
REM  Description: used for droping EDI schema objects. 
REM ******************************************************************

PROMPT Dropping EDI schema objects

REM === Drop Tables ===

DROP TABLE SENDER CASCADE CONSTRAINTS;
DROP TABLE EDI CASCADE CONSTRAINTS;
DROP TABLE COMMUNICATION CASCADE CONSTRAINTS;
DROP TABLE CONTACT CASCADE CONSTRAINTS;
DROP TABLE TERMINAL CASCADE CONSTRAINTS;


--DROP VIEWS
DROP VIEW VW_PARTNER_TRANSMISSION;
DROP VIEW VW_TERMINAL_CONTACTS;


REM === Drop Sequences ===
DROP SEQUENCE SENDER_ID_SEQ;
DROP SEQUENCE EDI_ID_SEQ;
DROP SEQUENCE CONTACT_ID_SEQ;
DROP SEQUENCE COMMUNICATION_ID_SEQ;
DROP SEQUENCE TERMINAL_ID_SEQ;




--Create Tables

PROMPT Creating Table 'TERMINAL'
CREATE TABLE TERMINAL
 (TERMINAL_ID NUMBER (8) NOT NULL
 ,COUNTRY VARCHAR2(100) 
 ,CITY VARCHAR2(100) 
 ,ADDRESS VARCHAR2(300) 
 ,PORTTYPE VARCHAR2(100) 
 ,UNLOCODE VARCHAR(5) NOT NULL
 ,TERMINALCODE VARCHAR(6) NOT NULL
 ,TERMINALFACILITY VARCHAR2(100) 
 ,LATITUDE VARCHAR2(30) 
 ,LONGITUDE VARCHAR2(30) 
 ,WEBSITE VARCHAR2(300) 
 )
/

PROMPT Creating Table 'CONTACT'
CREATE TABLE CONTACT
 (
 CONTACT_ID NUMBER(8) NOT NULL
 ,FIRSTNAME VARCHAR(100) NOT NULL 
 ,LASTNAME VARCHAR2(100) NOT NULL
 ,EMAIL VARCHAR2(300) NOT NULL
 ,OFFICEPHONE VARCHAR(100) 
 ,DESCRIPTION VARCHAR2(500) 
 ,TITLE VARCHAR2(100)
 ,WEBSITE VARCHAR2(300) 
 ,COUNTRY VARCHAR2(100) 
 ,ZIPCODE VARCHAR2(15) 
 ,CITY VARCHAR2(100) 
 ,MOBILEPHONE VARCHAR2(100)
 ,FK_TERMINAL_ID NUMBER(8) NOT NULL
 )
/

PROMPT Creating Table 'SENDER'
CREATE TABLE SENDER
 (SENDER_ID VARCHAR(100) NOT NULL
 ,COMPANY VARCHAR2(100) 
 ,BUSINESSFUNCTION VARCHAR2(100) 
 ,DESCRIPTION VARCHAR2(500) 
 ,FK_CONTACT_ID NUMBER(8) NOT NULL
 ,FK_EDI_ID NUMBER(8) NOT NULL
 )
/

PROMPT Creating Table 'EDI'
CREATE TABLE EDI
 (EDI_ID NUMBER(8) NOT NULL
 ,MESSAGETYPE VARCHAR(100) NOT NULL
 ,EDIVERSION VARCHAR2(100) NOT NULL
 ,FILETYPE VARCHAR2(50) NOT NULL 
 ,DESCRIPTION VARCHAR2(500)   
 ,MAPPINGNAME VARCHAR2(100) 
 )
/
 PROMPT Creating Table 'COMMUNICATION'
CREATE TABLE COMMUNICATION
 (COMMUNICATION_ID NUMBER(8) NOT NULL
 ,PROTOCOL VARCHAR2(25) NOT NULL
 ,IP VARCHAR(100) 
 ,PORT NUMBER(8)
 ,FREQUENCY VARCHAR2(50) 
 ,FILEPATH VARCHAR2(500)  
 ,HTTPURL VARCHAR2(100)   
 ,USERNAME VARCHAR2(100)
 ,PASSWORD VARCHAR2(100)
 ,EMAIL VARCHAR2(100)
 ,FK_EDI_ID NUMBER(8) NOT NULL
 ,FK_SENDER_ID VARCHAR(100) NOT NULL
 )
/

--CREATE INDEXES ON PRIMARY AND FOREIGN KEYS

REM ## INDEXES AUTOMATICALLY CREATED COMMETNED OUT -cc ##

 --DECLARE PRIMARY KEY INDEXES
PROMPT Creating Index 'TERMINAL_ID_I'
CREATE INDEX TERMINAL_ID_I ON TERMINAL
 (TERMINAL_ID)
/

PROMPT Creating Index 'CONTACT_ID_I'
CREATE INDEX CONTACT_ID_I ON CONTACT
 (CONTACT_ID)
/

PROMPT Creating Index 'SENDER_ID_I'
CREATE INDEX SENDER_ID_I ON SENDER
 (SENDER_ID)
/

PROMPT Creating Index 'EDI_ID_I'
CREATE INDEX EDI_ID_I ON EDI
 (EDI_ID)
/

PROMPT Creating Index 'COMMUNICATION_ID_I'
CREATE INDEX COMMUNICATION_ID_I ON COMMUNICATION
 (COMMUNICATION_ID)
/

 --DECLARE FOREIGN KEY INDEXES
 PROMPT Creating Index 'FK_EDI_ID_I'
CREATE INDEX FK_EDI_ID_I ON COMMUNICATION
 (FK_EDI_ID)
/

PROMPT Creating Index 'FK_EDI_ID_I'
CREATE INDEX FK_SENDER_ID_I ON COMMUNICATION
 (FK_SENDER_ID)
/

 PROMPT Creating Index 'FK_CONTACT_ID_I'
CREATE INDEX FK_CONTACT_ID_I ON SENDER
 (FK_CONTACT_ID)
/

 PROMPT Creating Index 'FK_EDI_ID_I'
CREATE INDEX FK_EDI_SENDER_ID_I ON SENDER
 (FK_EDI_ID)
/

 
PROMPT Creating Index 'FK_TERMINAL_ID_I'
CREATE INDEX FK_TERMINAL_ID_I ON CONTACT
 (FK_TERMINAL_ID)
/


 --Create Primary Keys
PROMPT Creating Primary Key on 'TERMINAL'
ALTER TABLE TERMINAL
 ADD CONSTRAINT TERMINAL_PK PRIMARY KEY 
  (TERMINAL_ID)
/ 
  
PROMPT Creating Primary Key on 'SENDER'
ALTER TABLE SENDER
 ADD CONSTRAINT SENDER_PK PRIMARY KEY 
  (SENDER_ID)
/  
  
PROMPT Creating Primary Key on 'EDI'
ALTER TABLE EDI
 ADD CONSTRAINT GR_PK PRIMARY KEY 
  (EDI_ID)
/  
  
PROMPT Creating Primary Key on 'CONTACT'
ALTER TABLE CONTACT
 ADD CONSTRAINT CONTACT_PK PRIMARY KEY 
  (CONTACT_ID)
/

PROMPT Creating Primary Key on 'COMMUNICATION'
ALTER TABLE COMMUNICATION
 ADD CONSTRAINT COMMUNICATION_PK PRIMARY KEY 
  (COMMUNICATION_ID)
/  
  
  

--Create Foreign Key
PROMPT Creating Foreign Keys on 'COMMUNICATION'
ALTER TABLE COMMUNICATION ADD CONSTRAINT
 FK_EDI_COMMUNICATION_ID FOREIGN KEY 
  (FK_EDI_ID) REFERENCES EDI
  (EDI_ID)
/

PROMPT Creating Foreign Keys on 'COMMUNICATION'
ALTER TABLE COMMUNICATION ADD CONSTRAINT
 FK_EDI_SENDER_ID FOREIGN KEY 
  (FK_SENDER_ID) REFERENCES SENDER
  (SENDER_ID)
/


  PROMPT Creating Foreign Keys on 'SENDER'
ALTER TABLE SENDER ADD CONSTRAINT
 FK_SENDER_CONTACT_ID FOREIGN KEY 
  (FK_CONTACT_ID) REFERENCES CONTACT
  (CONTACT_ID)
/

  PROMPT Creating Foreign Keys on 'SENDER'
ALTER TABLE SENDER ADD CONSTRAINT
 FK_SENDER_EDI_ID FOREIGN KEY 
  (FK_EDI_ID) REFERENCES EDI
  (EDI_ID)
/

  PROMPT Creating Foreign Keys on 'CONTACT'
ALTER TABLE CONTACT ADD CONSTRAINT
 FK_CONTACT_AT_TERMINAL_EDI_ID FOREIGN KEY 
  (FK_TERMINAL_ID) REFERENCES TERMINAL
  (TERMINAL_ID)
/  
  



 --CREATE VIEWS
 CREATE VIEW VW_PARTNER_TRANSMISSION (SENDERID, COMPANY,MESSAGETYPE,PROTOCOL)
	AS SELECT
SENDER.SENDER_ID
,SENDER.COMPANY
,EDI.MESSAGETYPE
,COMMUNICATION.PROTOCOL
FROM
SENDER
,EDI
,COMMUNICATION
WHERE 
SENDER.FK_EDI_ID = EDI.EDI_ID
AND EDI.EDI_ID = COMMUNICATION.FK_EDI_ID
AND COMMUNICATION.FK_SENDER_ID = SENDER.SENDER_ID
/



CREATE VIEW VW_TERMINAL_CONTACTS (FIRSTNAME,LASTNAME,EMAIL,TERMINALCODE,UNLOCODE)
	AS SELECT
CONTACT.FIRSTNAME
,CONTACT.LASTNAME
,CONTACT.EMAIL
,TERMINAL.TERMINALCODE
,TERMINAL.UNLOCODE
FROM
TERMINAL
,CONTACT
WHERE 
TERMINAL.TERMINAL_ID = CONTACT.FK_TERMINAL_ID
/




--Create Sequence
PROMPT Creating Sequence 'TERMINAL_ID_SEQ'
CREATE SEQUENCE TERMINAL_ID_SEQ
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 MINVALUE 1
 NOCYCLE
 NOCACHE
/

 PROMPT Creating Sequence 'EDI_ID_SEQ'
CREATE SEQUENCE EDI_ID_SEQ
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 MINVALUE 1
 NOCYCLE
 NOCACHE
/

 PROMPT Creating Sequence 'SENDER_ID_SEQ'
CREATE SEQUENCE SENDER_ID_SEQ
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 MINVALUE 1
 NOCYCLE
 NOCACHE
/

 PROMPT Creating Sequence 'COMMUNICATION_ID_SEQ'
CREATE SEQUENCE COMMUNICATION_ID_SEQ
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 MINVALUE 1
 NOCYCLE
 NOCACHE
/

 PROMPT Creating Sequence 'CONTACT_ID_SEQ'
CREATE SEQUENCE CONTACT_ID_SEQ
 INCREMENT BY 1
 START WITH 1
 NOMAXVALUE
 MINVALUE 1
 NOCYCLE
 NOCACHE
/

 --CREATE TRIGGERS
CREATE TRIGGER TERMINAL_PK_TRIGGER
BEFORE INSERT ON TERMINAL
FOR EACH ROW
  BEGIN
    SELECT TERMINAL_ID_SEQ.NEXTVAL
    INTO :new.TERMINAL_ID
    FROM dual;
  END;
/


  

CREATE TRIGGER EDI_PK_TRIGGER
BEFORE INSERT ON EDI
FOR EACH ROW
  BEGIN
    SELECT EDI_ID_SEQ.NEXTVAL
    INTO :new.EDI_ID
    FROM dual;
  END;
/
  
  

CREATE TRIGGER CONTACT_PK_TRIGGER
BEFORE INSERT ON CONTACT
FOR EACH ROW
  BEGIN
    SELECT CONTACT_ID_SEQ.NEXTVAL
    INTO :new.CONTACT_ID
    FROM dual;
  END; 
/ 

CREATE TRIGGER COMMUNICATION_PK_TRIGGER
BEFORE INSERT ON COMMUNICATION
FOR EACH ROW
  BEGIN
    SELECT COMMUNICATION_ID_SEQ.NEXTVAL
    INTO :new.COMMUNICATION_ID
    FROM dual;
  END;
/
--END SCRIPT


SELECT * FROM user_objects
/
SELECT * FROM user_tables
/
  


REM Developer: Caleb Crickette


SET DEFINE OFF

PROMPT Inserting Terminal Data
INSERT INTO TERMINAL VALUES (1,'NETHERLANDS','ROTTERDAM',NULL,NULL,'NLRTM','RSZ','RST SOUTH TERMINAL',NULL,NULL,NULL);
INSERT INTO TERMINAL VALUES (2,'GERMANY','HAMBURG',NULL,NULL,'DEHAM','SWT','Am Kamerunkai 5 Sud-West Terminal',NULL,NULL,NULL);
INSERT INTO TERMINAL VALUES (3,'NETHERLANDS','ROTTERDAM',NULL,NULL,'NLRTM','RST','RST NORTH TERMINAL',NULL,NULL,NULL);   
INSERT INTO TERMINAL VALUES (4,'NETHERLANDS','ROTTERDAM',NULL,NULL,'NLRTM','DDE','ECT DELTA TERMINAL',NULL,NULL,NULL);   
INSERT INTO TERMINAL VALUES (5,'NETHERLANDS','ROTTERDAM',NULL,NULL,'NLRTM','RWG','ROTTERDAM WORLD GATEWAY',NULL,NULL,NULL);   
INSERT INTO TERMINAL VALUES (6,'GERMANY','HAMBURG',NULL,NULL,'DEHAM','CTB','HHLA Burchardkai',NULL,NULL,NULL);   
INSERT INTO TERMINAL VALUES (7,'SWEDEN','HELSINGBORG',NULL,NULL,'SEHEL','COTE','Combiterminalen',NULL,NULL,NULL);   
INSERT INTO TERMINAL VALUES (8,'MOROCCO','CASABLANCA',NULL,NULL,'MACAS','SOMAP','SOMAPORT',NULL,NULL,NULL);   
INSERT INTO TERMINAL VALUES (9,'BELGIUM','ANTWERP',NULL,NULL,'BEANR','K420','Churchill Terminal - K402-K428',NULL,NULL,NULL);   
INSERT INTO TERMINAL VALUES (10,'BELGIUM','ANTWERP',NULL,NULL,'BEANR','K869','Europa Terminal - K851-K869',NULL,NULL,NULL); 
INSERT INTO TERMINAL VALUES (11,'BELGIUM','ANTWERP',NULL,NULL,'BEANR','K1742','Deurganck Terminal - K1742',NULL,NULL,NULL);  
INSERT INTO TERMINAL VALUES (12,'BELGIUM','ANTWERP',NULL,NULL,'BEANR','K730','Home Terminal - K702-K730',NULL,NULL,NULL);  

COMMIT;

PROMPT Inserting CONTACT Data
INSERT INTO CONTACT VALUES (1,'JOE','SMITH','JSMITH@AOL.COM','(835)812-6129 x4381',NULL,NULL,'sender.me','GERMANY',NULL,NULL,NULL,1);
INSERT INTO CONTACT VALUES (2,'Johnny','Thiel','May.Schuppe@amparo.tv','199-644-9410 x9182',NULL,NULL,'sender.me','Mauritius',NULL,NULL,NULL,2);
INSERT INTO CONTACT VALUES (3,'Dillon','Mueller','Otto_Beier@phoebe.tv','445.599.3938 x14264',NULL,NULL,'sender.me','Mauritius',NULL,NULL,NULL,3);
INSERT INTO CONTACT VALUES (4,'Russell','Schaden','Oren@alana.biz','(165)087-6709',NULL,NULL,'sender.me','British Indian Ocean Territory',NULL,NULL,NULL,4);
INSERT INTO CONTACT VALUES (5,'Isai','Hackett','Eveline.Eichmann@natalia.info','1-751-579-7458 x5365',NULL,NULL,'sender.me','GERMANY',NULL,NULL,NULL,5);
INSERT INTO CONTACT VALUES (6,'Dejah','Lowe','Gay.Ferry@america.me','964.948.4350 x3391',NULL,NULL,'sender.me','Micronesia',NULL,NULL,NULL,6);
INSERT INTO CONTACT VALUES (7,'Rubye','Schuppe V','Estel_Beer@dino.tv','(210)729-5598',NULL,NULL,'sender.me','United Kingdom',NULL,NULL,NULL,7);
INSERT INTO CONTACT VALUES (8,'Emely','Koch','Zechariah_Koch@adele.co.uk','1-656-989-8558 x5900',NULL,NULL,'sender.me','Gambia',NULL,NULL,NULL,8);
INSERT INTO CONTACT VALUES (9,'Norberto','Hermiston I','Tressie_Harris@giles.biz','1-124-661-9893 x592',NULL,NULL,'sender.me','Serbia',NULL,NULL,NULL,9);
INSERT INTO CONTACT VALUES (10,'Keira','Stroman','Christy@logan.name','1-501-884-7660 x3198',NULL,NULL,'sender.me','Macau SAR China',NULL,NULL,NULL,10);

COMMIT;



PROMPT Inserting EDI Data
INSERT INTO EDI VALUES (1,'CODECO','D95B','EDIFACT','CONTAINER GATE MOVEMENT','CODECO TO CODECO');
INSERT INTO EDI VALUES (2,'COARRI','D99D','EDIFACT','CONTAINER LOAD DISCHARGE MESSAGE','COARRI TO COARRI');
INSERT INTO EDI VALUES (3,'IFTSAI','D95B','EDIFACT','SCHEDULE','XMLIFTSAI TO EDI-IFTSAI');
INSERT INTO EDI VALUES (4,'IFTSTA','D95B','EDIFACT','CONTAINER MOVEMENT','IFTSTA TO IFTSTA');
INSERT INTO EDI VALUES (5,'COPARN','D95B','EDIFACT','CONTAINER LOAD DISCHARGE ANNOUNCEMENT','COPARN TO COPARN');
INSERT INTO EDI VALUES (6,'COARRI','D95B','EDIFACT','CONTAINER LOAD DISCHARGE MOVEMENT','COARRI TO COARRI');
INSERT INTO EDI VALUES (7,'IFTSAI','D95B','EDIFACT','SCHEDULE','XMLIFTSAI TO EDI-IFTSAI');
INSERT INTO EDI VALUES (8,'COPARN','D95B','EDIFACT','CONTAINER ORDER ANNOUNCEMENT','COPARN TO COPARN');
INSERT INTO EDI VALUES (9,'IFCSUM','D95B','EDIFACT','CUSTOMS DECLARATION','IFCSUM TO IFCSUM');
INSERT INTO EDI VALUES (10,'IFTMBF','D95B','EDIFACT','BOOKING','IFTMBF TO IFTMBF');

COMMIT;


PROMPT Inserting SENDER Data
INSERT INTO SENDER VALUES ('FCPSYS','DESTIN8','PORT COMMUNITY SYSTEM','MPC',1,1);
INSERT INTO SENDER VALUES ('HOLOG','CMA-CGM','SHIPPING LINER',NULL,2,2);
INSERT INTO SENDER VALUES ('PREPROTEAM','OPDR','SHARED SERVICE CENTER',NULL,3,3);
INSERT INTO SENDER VALUES ('PSA','PSA ANTWERP TERMINALS','PORT COMMUNITY SYSTEM',NULL,4,4);
INSERT INTO SENDER VALUES ('HHALPORT','HHAL','HHAL HAMBURG TERMINAL','MPC',5,5);
INSERT INTO SENDER VALUES ('SOMAP','SOMAPORT','SOMAPORT MOROCCO',NULL,7,6);
INSERT INTO SENDER VALUES ('SEHAL32','HELSINGBORG SWEDEN TERMINAL','HELSINGBORG TERMINAL',NULL,6,7);
INSERT INTO SENDER VALUES ('COMPANYXYZ','SENDER-XYZ','XYZ EDI SENDER',NULL,7,8);
INSERT INTO SENDER VALUES ('FIRM123','EDI SENDER','SENDER EDI',NULL,10,9);
INSERT INTO SENDER VALUES ('SENDER321','EDI SENDER 2','EDIFACT SENDER 321',NULL,9,10);

COMMIT;


PROMPT Inserting COMMUNICATION Data
INSERT INTO COMMUNICATION VALUES (1,'SMTP','10.234.54.156','548','Hourly','/Incoming/EDI','www.NULL.se','username','password','edi@germany.de',1,'FCPSYS');
INSERT INTO COMMUNICATION VALUES (2,'FTP','10.234.400.156','21','Daily','/Outgoing/EDI','www.electronic-data-interchange.com','username','123456','edi@null.com',2,'HOLOG');
INSERT INTO COMMUNICATION VALUES (3,'SMTP',NULL,'100','Hourly','/',NULL,NULL,NULL,'edi@germany.de',3,'PREPROTEAM');
INSERT INTO COMMUNICATION VALUES (4,'SMTP',NULL,'98','Hourly','/',NULL,NULL,NULL,'edi@germany.de',4,'PSA');
INSERT INTO COMMUNICATION VALUES (5,'FTP',NULL,'41','Weekly','/',NULL,NULL,NULL,'edi@germany.de',5,'HHALPORT');
INSERT INTO COMMUNICATION VALUES (6,'SMTP',NULL,NULL,'Weekly','/EDI',NULL,NULL,NULL,'edi@germany.de',6,'SOMAP');
INSERT INTO COMMUNICATION VALUES (7,'FTP',NULL,NULL,'Daily','/EDI/CODECO','edifact-sender.com',NULL,NULL,'edi@germany.de',7,'SEHAL32');
INSERT INTO COMMUNICATION VALUES (8,'SFTP',NULL,NULL,'Daily','/COARRI/EDI','terminal-company.com','password','username','edi@germany.de',8,'COMPANYXYZ');
INSERT INTO COMMUNICATION VALUES (9,'SFTP','10.24.54.16','400','Hourly','/XML/EDI','freight-forwarding.com','admin','admin','edi@germany.de',9,'FIRM123');
INSERT INTO COMMUNICATION VALUES (10,'SFTP','10.14.100.6','58','Hourly','/EDIFACT/',NULL,'admin','password','edi@germany.de',10,'SENDER321');

COMMIT;



PROMPT Perform SELECT QUERIES

PROMPT **********************************************
PROMPT 1.Select all columns and all rows from one table.
PROMPT **********************************************
SELECT * FROM CONTACT;


PROMPT **********************************************
PROMPT 2.Select 5 columns and all rows from one table.
PROMPT **********************************************
SELECT * FROM (SELECT * FROM CONTACT) WHERE ROWNUM <= 5;


PROMPT **********************************************
PROMPT 3.Select all columns and all rows from one view.
PROMPT **********************************************
SELECT * FROM VW_TERMINAL_CONTACTS;

PROMPT **********************************************
PROMPT 4.Using a join on 2 tables, select all columns and all rows from the tables without the use of a Cartesian product. 
PROMPT **********************************************
SELECT 
* 
FROM TERMINAL 
LEFT JOIN CONTACT ON (CONTACT.COUNTRY <> TERMINAL.COUNTRY)
WHERE CONTACT.COUNTRY <> 'GERMANY' 
AND TERMINAL.COUNTRY = 'NETHERLANDS' AND TERMINAL.TERMINALCODE = 'RWG';

PROMPT **********************************************
PROMPT 5.Select and order data retrieved from one table.
PROMPT **********************************************
SELECT * FROM CONTACT ORDER BY FIRSTNAME ASC;

PROMPT **********************************************
PROMPT 6.Using a join on 3 tables, select 5 columns from the 3 tables. Use syntax that would limit the output to 10 rows.  
PROMPT **********************************************
SELECT
SENDER.SENDER_ID
,CONTACT.FIRSTNAME
,CONTACT.LASTNAME
,CONTACT.OFFICEPHONE
,TERMINAL.TERMINALFACILITY
FROM SENDER
LEFT JOIN CONTACT ON (SENDER.FK_CONTACT_ID = CONTACT.CONTACT_ID)
LEFT JOIN TERMINAL ON (CONTACT.FK_TERMINAL_ID = TERMINAL.TERMINAL_ID)
WHERE FIRSTNAME IS NOT NULL
ORDER BY SENDER_ID ASC;

PROMPT **********************************************
PROMPT 7.Select distinct rows using joins on 3 tables. 
PROMPT **********************************************
SELECT DISTINCT
*
FROM 
COMMUNICATION
LEFT JOIN EDI ON (COMMUNICATION.FK_EDI_ID = EDI.EDI_ID)
LEFT JOIN SENDER ON (COMMUNICATION.FK_SENDER_ID = SENDER.SENDER_ID);

PROMPT **********************************************
PROMPT 8.Use GROUP BY & HAVING in a select statement using one or more tables.
PROMPT **********************************************
SELECT
PROTOCOL
FROM 
COMMUNICATION
LEFT JOIN EDI ON (COMMUNICATION.FK_EDI_ID = EDI.EDI_ID)
LEFT JOIN SENDER ON (COMMUNICATION.FK_SENDER_ID = SENDER.SENDER_ID)
GROUP BY COMMUNICATION.PROTOCOL
HAVING COUNT(COMMUNICATION.PROTOCOL) > 1;

PROMPT **********************************************
PROMPT 9.Use IN clause to select data from one or more tables.
PROMPT **********************************************
SELECT
*
FROM 
COMMUNICATION
LEFT JOIN EDI ON (COMMUNICATION.FK_EDI_ID = EDI.EDI_ID)
LEFT JOIN SENDER ON (COMMUNICATION.FK_SENDER_ID = SENDER.SENDER_ID)
WHERE COMMUNICATION.PROTOCOL IN ('SFTP','SMTP');


PROMPT **********************************************
PROMPT 10.Select length of one column from one table (use LENGTH function).
PROMPT **********************************************
SELECT * FROM (
SELECT
LENGTH(COMMUNICATION.PROTOCOL)
FROM COMMUNICATION
)
WHERE ROWNUM = 1;

PROMPT **********************************************
PROMPT 11.Use the SQL DELETE statement to delete one record from one table. Add select statements to demonstrate the table contents before and after the DELETE statement. Make sure to use ROLLBACK afterwards so that the data will not be physically removed.
PROMPT **********************************************
PROMPT DISPLAY ALL ROWS 
SELECT count(*) AS TOTAL_ROWS_BEFORE_DELETION FROM TERMINAL WHERE TERMINALCODE = 'K730';

PROMPT DELETE THE ROW WITH TERMINALCODE = 'K730'
DELETE FROM TERMINAL WHERE TERMINALCODE = 'K730';

PROMPT SHOW THAT THE ROW WAS DELETED
SELECT count(*) AS TOTAL_ROWS_AFTER_DELETION FROM TERMINAL WHERE TERMINALCODE = 'K730';

PROMPT ROLLBACK THE DELETION
ROLLBACK;


PROMPT **********************************************
PROMPT 12.Use the SQL UPDATE statement to change some data. Add select statements to demonstrate the table contents before and after the UPDATE statement. You can either COMMIT or ROLLBACK afterwards.
PROMPT **********************************************
PROMPT DISPLAY ROW WITH TERMINAL = K730
SELECT TERMINALCODE FROM TERMINAL WHERE TERMINALCODE = 'K730';

PROMPT UPDATE THE ROW WITH TERMINALCODE = 'K730' to 'K100'
UPDATE TERMINAL SET TERMINALCODE = 'K100' WHERE TERMINALCODE = 'K730';

PROMPT SHOW THAT THE ROW WAS UPDATED to 'K100'
SELECT TERMINALCODE FROM TERMINAL WHERE TERMINALCODE = 'K100';

PROMPT ROLLBACK THE UPDATE
ROLLBACK;

PROMPT **********************************************
PROMPT Using Coronel, Morris and Rob’s definition of Advanced SQL (Chapter 8), perform 8 additional advanced (multiple table joins, sub-queries, aggregate, etc.) SQL statements.
PROMPT **********************************************

PROMPT **********************************************
PROMPT 13.SELECT WITH SUB QUERY IN WHERE CLAUSE AND WILD CARD
PROMPT **********************************************
SELECT 
C.*
FROM 
TERMINAL T
LEFT JOIN CONTACT C ON (C.COUNTRY = T.COUNTRY)
WHERE CONTACT_ID IS NOT NULL
AND (T.UNLOCODE LIKE 'DE%' OR T.COUNTRY IN (SELECT DISTINCT COUNTRY FROM TERMINAL WHERE COUNTRY LIKE 'NL%'));

PROMPT **********************************************
PROMPT 14. UNION
PROMPT **********************************************

SELECT UNLOCODE,COALESCE(PORTTYPE,'n/a'),CITY FROM TERMINAL WHERE UNLOCODE LIKE 'DE%'
UNION
SELECT UNLOCODE,COALESCE(PORTTYPE,'n/a'),CITY FROM TERMINAL WHERE UNLOCODE LIKE 'NL%'
UNION
SELECT UNLOCODE,COALESCE(PORTTYPE,'n/a'),CITY FROM TERMINAL WHERE UNLOCODE LIKE 'SE%';

PROMPT **********************************************
PROMPT 15. INTERSECT
PROMPT **********************************************

SELECT COALESCE(CITY,'HAMBURG') AS CITY FROM TERMINAL
INTERSECT
SELECT COALESCE(CITY,'HAMBURG') AS CITY FROM CONTACT;


PROMPT **********************************************
PROMPT 16. SUB-SELECT- SELECT ALL PHONE NUMBERS AND LOCATION OF CONTACTS OF SENDER 'HLOG'
PROMPT **********************************************

SELECT
(SELECT OFFICEPHONE FROM CONTACT WHERE CONTACT.FK_TERMINAL_ID = TERMINAL.TERMINAL_ID ) 
,TERMINAL.*
FROM TERMINAL
WHERE TERMINAL.UNLOCODE = (SELECT UNLOCODE FROM SENDER WHERE SENDER.SENDER_ID LIKE '%LOG%');



PROMPT **********************************************
PROMPT 17. CAPTURE ALL DATA RELATED TO THE SENDER
PROMPT **********************************************

SELECT  * FROM 
SENDER S
LEFT JOIN EDI E ON (S.FK_EDI_ID = E.EDI_ID)
LEFT JOIN CONTACT C ON (S.FK_EDI_ID = C.CONTACT_ID)
LEFT JOIN COMMUNICATION COM ON (COM.FK_EDI_ID = E.EDI_ID AND COM.FK_SENDER_ID = S.SENDER_ID)
LEFT JOIN TERMINAL T ON (T.TERMINAL_ID = C.FK_TERMINAL_ID);



PROMPT **********************************************
PROMPT 18. Show all senders who send IFTSAI and show the sender id, terminal name, protocol used, and telephone number of contact
PROMPT **********************************************

SELECT 
S.SENDER_ID, T.TERMINALFACILITY,COM.PROTOCOL,C.OFFICEPHONE
FROM 
SENDER S
LEFT JOIN EDI E ON (S.FK_EDI_ID = E.EDI_ID)
LEFT JOIN CONTACT C ON (S.FK_EDI_ID = C.CONTACT_ID)
LEFT JOIN COMMUNICATION COM ON (COM.FK_EDI_ID = E.EDI_ID AND COM.FK_SENDER_ID = S.SENDER_ID)
LEFT JOIN TERMINAL T ON (T.TERMINAL_ID = C.FK_TERMINAL_ID)
WHERE E.MESSAGETYPE = 'IFTSAI';


PROMPT **********************************************
PROMPT 19. Show all terminals that have an EDI connection in Antwerp,Belgium and show the message type. Sort alphabetically.
PROMPT **********************************************

SELECT 
S.SENDER_ID, T.TERMINALFACILITY,E.MESSAGETYPE,COM.PROTOCOL,C.OFFICEPHONE,C.EMAIL
FROM 
SENDER S
LEFT JOIN EDI E ON (S.FK_EDI_ID = E.EDI_ID)
LEFT JOIN CONTACT C ON (S.FK_EDI_ID = C.CONTACT_ID)
LEFT JOIN COMMUNICATION COM ON (COM.FK_EDI_ID = E.EDI_ID AND COM.FK_SENDER_ID = S.SENDER_ID)
LEFT JOIN TERMINAL T ON (T.TERMINAL_ID = C.FK_TERMINAL_ID)
WHERE T.UNLOCODE = 'BEANR'
ORDER BY SENDER_ID ASC;

PROMPT **********************************************
PROMPT 20. SELECT ONLY ALL EDI CONNECTIONS THAT SEND EDI ON AN HOURLY BASIS
PROMPT **********************************************

SELECT 
S.SENDER_ID, T.TERMINALFACILITY,E.MESSAGETYPE,COM.PROTOCOL,C.OFFICEPHONE,C.EMAIL
FROM 
SENDER S
LEFT JOIN EDI E ON (S.FK_EDI_ID = E.EDI_ID)
LEFT JOIN CONTACT C ON (S.FK_EDI_ID = C.CONTACT_ID)
LEFT JOIN COMMUNICATION COM ON (COM.FK_EDI_ID = E.EDI_ID AND COM.FK_SENDER_ID = S.SENDER_ID)
LEFT JOIN TERMINAL T ON (T.TERMINAL_ID = C.FK_TERMINAL_ID)
WHERE COM.FREQUENCY = 'Hourly';



