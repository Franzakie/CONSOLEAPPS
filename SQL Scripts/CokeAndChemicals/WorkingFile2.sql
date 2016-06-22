DECLARE
  v_ID           NUMBER(12,0) := 244031;
  v_CategoryName NVARCHAR2(255) := 'Coke and Chemicals';
  v_AttribName   NVARCHAR2(255) := 'Account Name';
--  v_AttribName   NVARCHAR2(255) := 'Status';
  v_Value        NVARCHAR2(255) := 'EOH';
BEGIN
    AMSA_CS_GENERIC_U(v_ID, v_CategoryName, v_AttribName, v_Value);
END;


DECLARE
  v_ID           NUMBER(12,0) := 244031;
BEGIN
    AMSA_CandC_U_CS;
END;



/*
COMMIT;

set serveroutput on;

A<1,?,{242641,4}=A<1,?,'CustomID'=0,'ID'=1,'Values'={A<1,?,2=A<1,?,'ID'=2,'Values'={?}>,4=A<1,?,'ID'=4,'Values'={?}>,5=A<1,?,'ID'=5,'Values'={?}>,6=A<1,?,'ID'=6,'Values'={?}>,7=A<1,?,'ID'=7,'Values'={?}>,8=A<1,?,'ID'=8,'Values'={?}>,9=A<1,?,'ID'=9,'Values'={?}>,10=A<1,?,'ID'=10,'Values'={?}>,11=A<1,?,'ID'=11,'Values'={?}>,12=A<1,?,'ID'=12,'Values'={'N'}>,13=A<1,?,'ID'=13,'Values'={'SAP'}>,14=A<1,?,'ID'=14,'Values'={'PCTEST'}>,15=A<1,?,'ID'=15,'Values'={'2015/11/26'}>,16=A<1,?,'ID'=16,'Values'={?}>,17=A<1,?,'ID'=17,'Values'={?}>,18=A<1,?,'ID'=18,'Values'={'123456'}>,19=A<1,?,'ID'=19,'Values'={?}>>}>>
A<1,?,{242641,4}=A<1,?,'CustomID'=0,'ID'=1,'Values'={A<1,?,2=A<1,?,'ID'=2,'Values'={?}>,4=A<1,?,'ID'=4,'Values'={?}>,5=A<1,?,'ID'=5,'Values'={?}>,6=A<1,?,'ID'=6,'Values'={?}>,7=A<1,?,'ID'=7,'Values'={?}>,8=A<1,?,'ID'=8,'Values'={?}>,9=A<1,?,'ID'=9,'Values'={?}>,10=A<1,?,'ID'=10,'Values'={?}>,11=A<1,?,'ID'=11,'Values'={?}>,12=A<1,?,'ID'=12,'Values'={'N'}>,13=A<1,?,'ID'=13,'Values'={'SAP'}>,14=A<1,?,'ID'=14,'Values'={'PCTEST'}>,15=A<1,?,'ID'=15,'Values'={'2015/11/26'}>,16=A<1,?,'ID'=16,'Values'={?}>,17=A<1,?,'ID'=17,'Values'={?}>,18=A<1,?,'ID'=18,'Values'={'123456'}>,19=A<1,?,'ID'=19,'Values'={'CARRY ON SOFTWARE'}>>}>>
A<1,?,{242641,4}=A<1,?,'CustomID'=0,'ID'=1,'Values'={A<1,?,2=A<1,?,'ID'=2,'Values'={?}>,4=A<1,?,'ID'=4,'Values'={?}>,5=A<1,?,'ID'=5,'Values'={?}>,6=A<1,?,'ID'=6,'Values'={?}>,7=A<1,?,'ID'=7,'Values'={?}>,8=A<1,?,'ID'=8,'Values'={?}>,9=A<1,?,'ID'=9,'Values'={?}>,10=A<1,?,'ID'=10,'Values'={?}>,11=A<1,?,'ID'=11,'Values'={?}>,12=A<1,?,'ID'=12,'Values'={'N'}>,13=A<1,?,'ID'=13,'Values'={'SAP'}>,14=A<1,?,'ID'=14,'Values'={'PCTEST'}>,15=A<1,?,'ID'=15,'Values'={'2015/11/26'}>,16=A<1,?,'ID'=16,'Values'={?}>,17=A<1,?,'ID'=17,'Values'={?}>,18=A<1,?,'ID'=18,'Values'={'123456'}>,19=A<1,?,'ID'=19,'Values'={'CARRY ON SOFTWARE'}>>}>>

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => '"OTCS"."CokeAndChemicals"',
            job_type => 'STORED_PROCEDURE',
            job_action => 'OTCS.AMSA_CANDC_U_CS',
            number_of_arguments => 0,
            start_date => NULL,
            repeat_interval => 'FREQ=HOURLY;INTERVAL=2;BYDAY=MON,TUE,WED,THU,FRI',
            end_date => NULL,
            enabled => FALSE,
            auto_drop => FALSE,
            comments => 'Test CokeAndChemicals Stored Proc that updates  Content Server');

         
     
 
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => '"OTCS"."CokeAndChemicals"', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_OFF);
      
  
    
    DBMS_SCHEDULER.enable(
             name => '"OTCS"."CokeAndChemicals"');
END;

  SELECT ll.ID,
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
    AMSA_COKEANDCHEMICALS.class
  FROM AMSA_COKEANDCHEMICALS
    ,CATREGIONMAP ci
    ,LLATTRDATA ll
  WHERE ll.DefID = ci.CatID
  AND ll.AttrID = substr(ci.REGIONNAME, (INSTRC(ci.REGIONNAME,'_',1,2)+1))
  AND ll.ValStr = TO_CHAR(AMSA_COKEANDCHEMICALS.loadnumber)
  AND ci.CATNAME = 'Coke and Chemicals'
  AND ci.AttrName = 'Load Number'
  AND NVL(AMSA_COKEANDCHEMICALS.status,'N') = 'N'
  AND AMSA_COKEANDCHEMICALS.class = 'NIPPS';


SELECT TO_CHAR(DELDATE, 'yyyy/MM/dd') FROM AMSA_COKEANDCHEMICALS WHERE LOADNUMBER = '@0001092205';

UPDATE AMSA_COKEANDCHEMICALS
SET STATUS = 'N'
WHERE LOADNUMBER = '@0001092205';
COMMIT;

SELECT * FROM AMSA_COKEANDCHEMICALS WHERE CLASS = 'SAP' ORDER BY ID DESC 


DELETE FROM AMSA_COKEANDCHEMICALS WHERE CLASS = 'NIPPS' 


  SELECT ci.AttrName, ll.id, ll.ValStr, 'SAP', 'N'
  FROM CATREGIONMAP ci
    ,LLATTRDATA ll
    ,DVersData dv
  WHERE dv.VERTYPE is null
  AND dv.DocID = ll.ID
  AND  ll.DefID = ci.CatID
  AND ll.AttrID = substr(ci.REGIONNAME, (INSTRC(ci.REGIONNAME,'_',1,2)+1))
--  AND LENGTH(ll.ValStr) > 0  --status is null or empty
  AND ci.CATNAME = 'Coke and Chemicals'
  AND ci.AttrName = 'Delivery Note Number'


*/
