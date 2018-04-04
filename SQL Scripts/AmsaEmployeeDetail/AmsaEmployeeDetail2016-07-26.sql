ALTER TABLE AMSA_EMPLOYEE_DETAIL ADD EMAIL VARCHAR2(250);  
ALTER TABLE AMSA_EMPLOYEE_DETAIL ADD PHONE VARCHAR2(250);  
ALTER TABLE AMSA_EMPLOYEE_DETAIL ADD FAX VARCHAR2(250);  
ALTER TABLE AMSA_EMPLOYEE_DETAIL ADD PASSPORTNO VARCHAR2(50);  
ALTER TABLE AMSA_EMPLOYEE_DETAIL ADD ACTIVESTATUS NUMBER(10);  


--ACTIVESTATUS 0 = Withdrawn, 1 = InActive,2 = Retiree,3 = Active

drop table AMSA_EMPLOYEE_DETAIL;
CREATE TABLE AMSA_EMPLOYEE_DETAIL
(   
    ID                        number(10)        NOT NULL,
    PERNO                        varchar2(50)      NULL,    --PERNR 
    NAME                      varchar2(50)      NULL,    --VORNA 
    SURNAME                        varchar2(50)      NULL,    --NACHN 
    NATIONALID              varchar2(20)      NULL,    --PERID
    ORGUNIT                 varchar2(50)    NULL,    --ORGEH 
    OBJABREV                varchar2(50)       NULL,    --SHORT 
    OBJNAME                 varchar2(50)       NULL,    --STEXT 
    INITIALS                     varchar2(20)       NULL,    --INITS 
    PERSONALAREA              varchar2(50)    NULL, --WERKS 
    PERSONALAREADESC            varchar2(200)   NULL, --NAME1 
    PERSONALSUBAREA           varchar2(50)      NULL,    --BTRTL 
    PERSONALSUBAREADESC     varchar2(200)     NULL  --BTEXT 
);

CREATE SEQUENCE  "OTCS"."AMSA_EMP_DETAIL_SEC"  MINVALUE 1 MAXVALUE 99999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE ;

create or replace PROCEDURE AMSA_EMPLOYEE_DETAIL_U
                   (v_PERNO                      IN NVARCHAR2
                   ,v_NAME                  IN NVARCHAR2
                   ,v_SURNAME                   IN NVARCHAR2
                   ,v_NATIONALID            IN NVARCHAR2
                   ,v_PASSPORTNO            IN NVARCHAR2
                   ,v_EMAIL                    IN NVARCHAR2
                   ,v_PHONE                    IN NVARCHAR2
                   ,v_FAX                    IN NVARCHAR2
                   ,v_ORGUNIT               IN NVARCHAR2
                   ,v_OBJABREV              IN NVARCHAR2
                   ,v_OBJNAME               IN NVARCHAR2
                   ,v_INITIALS              IN NVARCHAR2
                   ,v_PERSONALAREA          IN NVARCHAR2
                   ,v_PERSONALAREADESC      IN NVARCHAR2
                   ,v_PERSONALSUBAREA       IN NVARCHAR2
                   ,v_PERSONALSUBAREADESC      IN NVARCHAR2
                   ,v_ACTIVESTATUS      IN NUMBER)
AS
TmpNewId Number;
TmpRecExist Number;
BEGIN
  SELECT COUNT(*) INTO TmpRecExist FROM AMSA_EMPLOYEE_DETAIL WHERE PERNO = v_PERNO;
    IF TmpRecExist = 0 THEN
        BEGIN
            SELECT AMSA_EMP_DETAIL_SEC.NEXTVAL
            INTO TmpNewId
            FROM Dual;
            INSERT INTO AMSA_EMPLOYEE_DETAIL ("ID", PERNO, "NAME", SURNAME, NATIONALID, PASSPORTNO, EMAIL, ORGUNIT, OBJABREV, OBJNAME, INITIALS, PERSONALAREA, PERSONALAREADESC, PERSONALSUBAREA, PERSONALSUBAREADESC, PHONE, FAX, ACTIVESTATUS)
            VALUES (TmpNewId, v_PERNO, v_NAME, v_SURNAME, v_NATIONALID, v_PASSPORTNO, v_EMAIL, v_ORGUNIT, v_OBJABREV, v_OBJNAME, v_INITIALS, v_PERSONALAREA, v_PERSONALAREADESC, v_PERSONALSUBAREA, v_PERSONALSUBAREADESC, v_PHONE, v_FAX, v_ACTIVESTATUS);
        END;
    ELSE
        UPDATE AMSA_EMPLOYEE_DETAIL
            SET PERNO = v_PERNO, 
                "NAME" = v_NAME, 
                SURNAME = v_SURNAME, 
                NATIONALID = v_NATIONALID, 
                PASSPORTNO = v_PASSPORTNO, 
                EMAIL = v_EMAIL, 
                PHONE = v_PHONE, 
                FAX = v_FAX, 
                ORGUNIT = v_ORGUNIT, 
                OBJABREV = v_OBJABREV, 
                OBJNAME = v_OBJNAME, 
                INITIALS = v_INITIALS, 
                PERSONALAREA = PERSONALAREA, 
                PERSONALAREADESC = v_PERSONALAREADESC, 
                PERSONALSUBAREA = v_PERSONALSUBAREA,
                PERSONALSUBAREADESC = v_PERSONALSUBAREADESC,
				ACTIVESTATUS = v_ACTIVESTATUS
        WHERE PERNO = v_PERNO; 
    END IF;
  COMMIT;
END;

