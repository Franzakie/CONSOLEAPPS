drop table AMSA_COKEANDCHEMICALS;
CREATE TABLE AMSA_COKEANDCHEMICALS
(   
    ID            number(10)    NOT NULL,
    loadnumber    varchar2(20)  NULL,
    saporder      varchar2(20)  NULL,
    delNo         varchar2(20)  NULL,
    deldate       date          NULL,
    accnr         varchar2(255) NULL,
    accname       varchar2(255) NULL,
    returned      number(1)     NULL,  
    cancelled     varchar2(1)   NULL, 
    sequencenr    number(10)    NULL, 
    invoicenumber varchar2(20)  NULL, 
    nippsorder    varchar2(20)  NULL, 
    truckregnr    varchar2(20)  NULL, 
    trailernr     varchar2(20)  NULL, 
    status        varchar2(1)   NULL, 
    class         varchar2(10)  NULL, 
    scanpc        varchar2(255) NULL, 
    scandate      date          NULL 
);

--drop procedure UPDATE_AMSA_COKEANDCHEMICALS;
create or replace PROCEDURE AMSA_CandC_U
                   (v_ID                IN NUMBER
                   ,v_loadnumber        IN NVARCHAR2
                   ,v_saporder          IN NVARCHAR2
                   ,v_delNo             IN NVARCHAR2
                   ,v_deldate           IN date
                   ,v_accnr             IN NVARCHAR2
                   ,v_accname           IN NVARCHAR2
                   ,v_returned          IN NUMBER
                   ,v_cancelled         IN NVARCHAR2
                   ,v_sequencenr        IN NUMBER
                   ,v_invoicenumber     IN NVARCHAR2
                   ,v_nippsorder        IN NVARCHAR2
                   ,v_truckregnr        IN NVARCHAR2
                   ,v_trailernr         IN NVARCHAR2
                   ,v_status            IN NVARCHAR2
                   ,v_class             IN NVARCHAR2
                   ,v_scanpc            IN NVARCHAR2)
AS
BEGIN
   UPDATE AMSA_COKEANDCHEMICALS
      SET AMSA_COKEANDCHEMICALS.loadnumber = v_loadnumber
      ,AMSA_COKEANDCHEMICALS.saporder = v_saporder
      ,AMSA_COKEANDCHEMICALS.delNo = v_delNo
      ,AMSA_COKEANDCHEMICALS.deldate = v_deldate
      ,AMSA_COKEANDCHEMICALS.accnr = v_accnr
      ,AMSA_COKEANDCHEMICALS.accname = v_accname
      ,AMSA_COKEANDCHEMICALS.returned = v_returned
      ,AMSA_COKEANDCHEMICALS.cancelled = v_cancelled
      ,AMSA_COKEANDCHEMICALS.sequencenr = v_sequencenr
      ,AMSA_COKEANDCHEMICALS.invoicenumber = v_invoicenumber
      ,AMSA_COKEANDCHEMICALS.nippsorder = v_nippsorder
      ,AMSA_COKEANDCHEMICALS.truckregnr = v_truckregnr
      ,AMSA_COKEANDCHEMICALS.trailernr = v_trailernr
      ,AMSA_COKEANDCHEMICALS.status = v_status
      ,AMSA_COKEANDCHEMICALS.class = v_class
      ,AMSA_COKEANDCHEMICALS.scanpc = v_scanpc
   WHERE AMSA_COKEANDCHEMICALS.ID = v_ID; 
   COMMIT;
END;
/
CREATE SEQUENCE  "OTCS"."AMSA_CANDC_SEC"  MINVALUE 1 MAXVALUE 99999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE ;

--drop procedure AMSA_I_COKEANDCHEMICALS
create or replace PROCEDURE AMSA_CandC_I 
                   (v_loadnumber        IN NVARCHAR2
                   ,v_saporder          IN NVARCHAR2
                   ,v_delNo             IN NVARCHAR2
                   ,v_deldate           IN NVARCHAR2
                   ,v_accnr             IN NVARCHAR2
                   ,v_accname           IN NVARCHAR2
                   ,v_returned          IN NVARCHAR2
                   ,v_cancelled         IN NVARCHAR2
                   ,v_sequencenr        IN NVARCHAR2
                   ,v_invoicenumber     IN NVARCHAR2
                   ,v_nippsorder        IN NVARCHAR2
                   ,v_truckregnr        IN NVARCHAR2
                   ,v_trailernr         IN NVARCHAR2
                   ,v_status            IN NVARCHAR2
                   ,v_class             IN NVARCHAR2)
AS
TmpNewId Number;
BEGIN

    SELECT AMSA_CANDC_SEC.NEXTVAL
    INTO TmpNewId
    FROM Dual;
    
    IF NVL(v_loadnumber,'-') != '-' THEN
      INSERT INTO AMSA_COKEANDCHEMICALS 
      (
        ID
        ,loadnumber
        ,saporder
        ,delNo
        ,deldate
        ,accnr
        ,accname
        ,returned
        ,cancelled
        ,sequencenr
        ,invoicenumber
        ,nippsorder
        ,truckregnr
        ,trailernr
        ,status
        ,class
      )
      SELECT TmpNewId
        ,v_loadnumber
        ,v_saporder
        ,v_delNo
        ,TO_DATE(v_deldate, 'yyyymmdd')
        ,v_accnr
        ,v_accname
        ,TO_NUMBER(v_returned)
        ,v_cancelled
        ,TO_NUMBER(v_sequencenr)
        ,v_invoicenumber
        ,v_nippsorder
        ,v_truckregnr
        ,v_trailernr
        ,v_status
        ,v_class
      FROM DUAL
      WHERE NOT EXISTS (SELECT * FROM AMSA_COKEANDCHEMICALS COKE
                        WHERE COKE.loadnumber = v_loadnumber);
    END IF;
    IF NVL(v_delNo,'-') != '-' THEN
      INSERT INTO AMSA_COKEANDCHEMICALS 
      (
        ID
        ,loadnumber
        ,saporder
        ,delNo
        ,deldate
        ,accnr
        ,accname
        ,returned
        ,cancelled
        ,sequencenr
        ,invoicenumber
        ,nippsorder
        ,truckregnr
        ,trailernr
        ,status
        ,class
      )
      SELECT TmpNewId
        ,v_loadnumber
        ,v_saporder
        ,v_delNo
        ,TO_DATE(v_deldate, 'yyyymmdd')
        ,v_accnr
        ,v_accname
        ,TO_NUMBER(v_returned)
        ,v_cancelled
        ,TO_NUMBER(v_sequencenr)
        ,v_invoicenumber
        ,v_nippsorder
        ,v_truckregnr
        ,v_trailernr
        ,v_status
        ,v_class
      FROM DUAL
      WHERE NOT EXISTS (SELECT * FROM AMSA_COKEANDCHEMICALS COKE
                        WHERE COKE.delNo = v_delNo);
    END IF;
    COMMIT;
END;
/

--drop procedure SELECT_AMSA_COKEANDCHEMICALS
create or replace PROCEDURE AMSA_CandC_S (cv_1 OUT SYS_REFCURSOR)
IS
BEGIN
  INSERT INTO AMSA_COKEANDCHEMICALS (ID, DELNO, class, status)
  SELECT ll.id, ll.ValStr, 'SAP', 'N'
  FROM CATREGIONMAP ci
    ,LLATTRDATA ll
    ,DVersData dv
  WHERE dv.VERTYPE is null
  AND dv.DocID = ll.ID
  AND  ll.DefID = ci.CatID
  AND ll.AttrID = substr(ci.REGIONNAME, (INSTRC(ci.REGIONNAME,'_',1,2)+1))
  AND LENGTH(ll.ValStr) > 0  --status is null or empty
  AND ci.CATNAME = 'Coke and Chemicals'
  AND ci.AttrName = 'Delivery Note Number'
  AND NOT EXISTS
  (
    SELECT * FROM AMSA_COKEANDCHEMICALS Coke 
    WHERE Coke.Id = ll.id
    AND Coke.class = 'SAP'
  )
  AND NOT EXISTS    -- WHERE A STATUS DOES NOT YET EXIST FOR THIS DELIVERY NUMBER
  (
    SELECT * FROM CATREGIONMAP ci2
      ,LLATTRDATA ll2
      ,DVersData dv2
    WHERE dv2.VERTYPE is null
    AND dv2.DocID = ll2.ID
    AND  ll2.DefID = ci2.CatID
    AND ll2.AttrID = substr(ci2.REGIONNAME, (INSTRC(ci2.REGIONNAME,'_',1,2)+1))
    AND NVL(ll.ValStr,'N') = 'N'
    AND ci2.CATNAME = 'Coke and Chemicals'
    AND ci2.AttrName = 'Status'
    AND ll.id = ll2.id
  )
  AND EXISTS    -- IS ALSO PART OF THE SAP CLASS
  (
    SELECT * FROM CATREGIONMAP ci3
      ,LLATTRDATA ll3
      ,DVersData dv3
    WHERE dv3.VERTYPE is null
    AND dv3.DocID = ll3.ID
    AND  ll3.DefID = ci3.CatID
    AND ll3.AttrID = substr(ci3.REGIONNAME, (INSTRC(ci3.REGIONNAME,'_',1,2)+1))
    AND ll3.ValStr = 'SAP'
    AND ci3.CATNAME = 'Coke and Chemicals'
    AND ci3.AttrName = 'Class'
    AND ll.id = ll3.id
    );
  COMMIT;
  OPEN cv_1 FOR
  SELECT AMSA_COKEANDCHEMICALS.ID,
    AMSA_COKEANDCHEMICALS.loadnumber,
    AMSA_COKEANDCHEMICALS.saporder,
    AMSA_COKEANDCHEMICALS.delNo,
    AMSA_COKEANDCHEMICALS.deldate,
    AMSA_COKEANDCHEMICALS.accnr,
    AMSA_COKEANDCHEMICALS.accname,
    AMSA_COKEANDCHEMICALS.returned,
    AMSA_COKEANDCHEMICALS.cancelled,
    AMSA_COKEANDCHEMICALS.sequencenr,
    AMSA_COKEANDCHEMICALS.invoicenumber,
    AMSA_COKEANDCHEMICALS.nippsorder,
    AMSA_COKEANDCHEMICALS.truckregnr,
    AMSA_COKEANDCHEMICALS.trailernr,
    AMSA_COKEANDCHEMICALS.status,
    AMSA_COKEANDCHEMICALS.class,
    AMSA_COKEANDCHEMICALS.scanpc,
    AMSA_COKEANDCHEMICALS.scandate
  FROM AMSA_COKEANDCHEMICALS
  WHERE NVL(AMSA_COKEANDCHEMICALS.status,'N') = 'N'
  AND NVL(AMSA_COKEANDCHEMICALS.DelNo,'-') <> '-'
  AND AMSA_COKEANDCHEMICALS.CLASS = 'SAP'; 
END;
/

