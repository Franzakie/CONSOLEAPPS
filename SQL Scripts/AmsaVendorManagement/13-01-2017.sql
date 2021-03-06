DROP TABLE OTCS.AMSA_VENDORUPDATE CASCADE CONSTRAINTS;

CREATE TABLE OTCS.AMSA_VENDORUPDATE
(
  ID                      NUMBER(10)               NOT NULL,
  DESCRIPTION     VARCHAR2(50 BYTE),   --VENDOR_NAME
  VENDOR_NO       VARCHAR2(50 BYTE), --VENDOR_NO
  TELEPHONE_NO  VARCHAR2(50 BYTE), 
  FAX_NO             VARCHAR2(50 BYTE), 
  EMAIL                 VARCHAR2(50 BYTE), --EMAIL
  CHARACTERISTIC VARCHAR2(50 BYTE), --CERTIICATE
  NOTICE_STATUS VARCHAR2(20 BYTE), --STATUS
  EXPIRY_DATE      VARCHAR2(50 BYTE), --EXPIRY_DATE
  WF_INITIATED    NUMBER(10),
  WF_CS_ID          NUMBER(10),
  WF_STATUS_ID  NUMBER(10) DEFAULT 0,
  NEW_EXPIRY_DATE DATE
);

CREATE TABLE OTCS.AMSA_VENDORUPDATE_AUDIT
(
  SEQUENCENO    NUMBER(10)               NOT NULL,
  ID                      NUMBER(10)               NOT NULL,
  DESCRIPTION     VARCHAR2(50 BYTE),   --VENDOR_NAME
  VENDOR_NO       VARCHAR2(50 BYTE), --VENDOR_NO
  TELEPHONE_NO  VARCHAR2(50 BYTE), 
  FAX_NO             VARCHAR2(50 BYTE), 
  EMAIL                 VARCHAR2(50 BYTE), --EMAIL
  CHARACTERISTIC VARCHAR2(50 BYTE), --CERTIICATE
  NOTICE_STATUS VARCHAR2(20 BYTE), --STATUS
  EXPIRY_DATE      VARCHAR2(50 BYTE), --EXPIRY_DATE
  WF_INITIATED    NUMBER(10),
  WF_CS_ID          NUMBER(10),
  WF_STATUS_ID  NUMBER(10) DEFAULT 0,
  NEW_EXPIRY_DATE DATE
);

DROP TABLE OTCS.AMSA_VENDORINFO CASCADE CONSTRAINTS;

CREATE TABLE OTCS.AMSA_VENDORINFO
(
  VENDOR_NO       VARCHAR2(50 BYTE), --VENDOR_NO
  DESCRIPTION     VARCHAR2(50 BYTE),   --VENDOR_NAME
  TELEPHONE_NO  VARCHAR2(50 BYTE), 
  FAX_NO             VARCHAR2(50 BYTE), 
  EMAIL                 VARCHAR2(50 BYTE) --EMAIL
);

CREATE SEQUENCE  "AMSA_VENDORUPDATE_AUDIT_SEC"  MINVALUE 1 MAXVALUE 99999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE ;
   
DROP TRIGGER TR_AMSA_VENDORUPDATE_AUDIT;

CREATE OR REPLACE TRIGGER TR_AMSA_VENDORUPDATE_AUDIT BEFORE
  UPDATE ON AMSA_VENDORUPDATE FOR EACH ROW
  DECLARE
  TmpNewId Number;
  begin
    SELECT AMSA_VENDORUPDATE_AUDIT_SEC.NEXTVAL
    INTO TmpNewId
    FROM Dual;
    insert into AMSA_VENDORUPDATE_AUDIT 
    (
      SEQUENCENO,
      ID,
      DESCRIPTION,
      VENDOR_NO,
      TELEPHONE_NO,
      FAX_NO,
      EMAIL,
      CHARACTERISTIC,
      NOTICE_STATUS,
      EXPIRY_DATE,
      WF_INITIATED,
      WF_CS_ID,
      WF_STATUS_ID,
      NEW_EXPIRY_DATE
    ) 
    VALUES
    (
      TmpNewId
      ,:old.ID
      ,:old.DESCRIPTION
      ,:old.VENDOR_NO
      ,:old.TELEPHONE_NO
      ,:old.FAX_NO
      ,:old.EMAIL
      ,:old.CHARACTERISTIC
      ,:old.NOTICE_STATUS
      ,:old.EXPIRY_DATE
      ,:old.WF_INITIATED
      ,:old.WF_CS_ID
      ,:old.WF_STATUS_ID
      ,:old.NEW_EXPIRY_DATE
    );
  end;

CREATE SEQUENCE  "OTCS"."AMSA_VENDORUPDATE_SEC"  MINVALUE 1 MAXVALUE 99999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE ;

CREATE OR REPLACE PROCEDURE OTCS.AMSA_VENDORUPDATE_U
                   (v_VENDOR_NO     IN NVARCHAR2
                   ,v_CERTIFICATE    IN NVARCHAR2
                   ,v_VENDORNAME   IN NVARCHAR2
                   ,v_STATUS           IN NVARCHAR2
                   ,v_EMAIL              IN NVARCHAR2
                   ,v_EXPIRYDATE     IN NVARCHAR2)
AS
TmpNewId Number;
TmpRecExist Number;
BEGIN
            SELECT AMSA_VENDORUPDATE_SEC.NEXTVAL
            INTO TmpNewId
            FROM Dual;
            INSERT INTO AMSA_VENDORUPDATE ("ID", DESCRIPTION, VENDOR_NO, EMAIL, CHARACTERISTIC, NOTICE_STATUS, EXPIRY_DATE)
            VALUES (TmpNewId, v_VENDORNAME, v_VENDOR_NO, v_EMAIL, v_CERTIFICATE, v_STATUS, v_EXPIRYDATE);
            SELECT COUNT(*) INTO TmpRecExist FROM AMSA_VENDORINFO WHERE VENDOR_NO = v_VENDOR_NO;
            IF TmpRecExist = 0 THEN
                    INSERT INTO AMSA_VENDORINFO (DESCRIPTION, VENDOR_NO, EMAIL)
                    VALUES (v_VENDORNAME, v_VENDOR_NO, v_EMAIL);
            ELSE
                UPDATE AMSA_VENDORINFO
                    SET DESCRIPTION = v_VENDORNAME, 
                        EMAIL = v_EMAIL 
                WHERE VENDOR_NO = v_VENDOR_NO; 
            END IF;
  COMMIT;
END;

CREATE OR REPLACE PROCEDURE OTCS.AMSA_VendorCertificateList
                   (cv_1                OUT SYS_REFCURSOR)
AS
BEGIN
    OPEN cv_1 FOR
    SELECT ID,  DESCRIPTION, VENDOR_NO, EMAIL, CHARACTERISTIC, NOTICE_STATUS, NEW_EXPIRY_DATE AS EXPIRY_DATE
    FROM AMSA_VENDORUPDATE
    WHERE WF_STATUS_ID IN (90,120);
END;

CREATE OR REPLACE PROCEDURE OTCS.AMSA_VENDORSTATUSUPDATE_U
                   (v_ID     IN NUMBER,
                   v_STATUS IN NUMBER)
AS
BEGIN
    UPDATE AMSA_VENDORUPDATE
        SET WF_STATUS_ID = v_STATUS
    WHERE ID = v_ID; 
  COMMIT;
END;


/
