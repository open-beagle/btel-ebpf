ALTER TABLE az MODIFY lcuuid CHAR(64) DEFAULT '' UNIQUE;
ALTER TABLE epc MODIFY lcuuid CHAR(64) DEFAULT '' UNIQUE;

UPDATE db_version SET version = '6.1.8.12';
