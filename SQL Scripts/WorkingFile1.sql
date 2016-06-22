DECLARE
  v_ID           NUMBER(12,0) := 244031;
  v_CategoryName NVARCHAR2(255) := 'Coke and Chemicals';
  v_AttribName   NVARCHAR2(255) := 'Account Name';
  v_Value        NVARCHAR2(255) := 'CARRY ON SOFTWARE';
  Str_AttribNo      Varchar2(10);
  Str_Search        VARCHAR2(10); 
  Num_Pos          NUMBER;
  Num_Val_Start    NUMBER;
  Num_Val_End      NUMBER;
  Str_Value        CLOB;
  Str_New_Value    CLOB;
  Str_Value_Start  CLOB;
  Str_Value_End    CLOB;
BEGIN
    DBMS_OUTPUT.ENABLE;

    SELECT substr(ci.REGIONNAME, (INSTRC(ci.REGIONNAME,'_',1,2)+1)) 
    INTO Str_AttribNo
    FROM CATREGIONMAP ci
    WHERE ci.CATNAME = v_CategoryName
    AND ci.AttrName = v_AttribName;

    SELECT SEGMENTBLOB INTO Str_Value FROM LLATTRBLOBDATA WHERE ID = v_ID;
    SELECT '=' || Str_AttribNo || ',' INTO Str_Search FROM DUAL;
    SELECT INSTR(Str_Value, Str_Search) INTO Num_Pos FROM DUAL;
    SELECT SUBSTR(Str_Value, 0, INSTR(Str_Value, '{', Num_Pos)) INTO Str_Value_Start FROM DUAL;
    SELECT INSTR(Str_Value, '}', Num_Pos) INTO Num_Val_End FROM DUAL;
    SELECT SUBSTR(Str_Value, Num_Val_End, (LENGTH(Str_Value)-Num_Val_End)) INTO Str_Value_End FROM DUAL;
    SELECT SUBSTR(Str_Value, Num_Val_End, (LENGTH(Str_Value)-Num_Val_End)) INTO Str_Value_End FROM DUAL;
    SELECT Str_Value_Start || '''' || v_Value || '''' || Str_Value_End INTO Str_New_Value FROM DUAL;
    
    dbms_output.put_line(Str_AttribNo);
    dbms_output.put_line(Str_Search);
    dbms_output.put_line(TO_CHAR(Num_Pos));
    dbms_output.put_line(Str_Value);
    dbms_output.put_line(Str_Value_Start);
    dbms_output.put_line(v_Value);
    dbms_output.put_line(Str_Value_End);
    dbms_output.put_line(Str_New_Value);
    --UPDATE LLATTRBLOBDATA SET SEGMENTBLOB = Str_New_Value WHERE ID = v_ID;
    
    --UPDATE LLATTRDATA SET VALSTR =  v_Value WHERE ID = v_ID AND ATTRID = Str_AttribNo;

END;

/*
set serveroutput on;

SELECT * FROM LLATTRBLOBDATA WHERE ID = 244031;

SELECT * FROM CATREGIONMAP WHERE CATNAME = 'Coke and Chemicals'

SELECT * FROM CATREGIONMAP WHERE upper(CATNAME) like 'COKE%'

SELECT * FROM LLATTRDATA WHERE DEFID = 241132 AND ID = 241141;

select * FROM CATREGIONMAP ci
      ,LLATTRDATA ll
      WHERE ll.DefID = ci.CatID
      AND ll.AttrID = substr(ci.REGIONNAME, (INSTRC(ci.REGIONNAME,'_',1,2)+1))
      AND ci.CATNAME = 'Coke and Chemicals'
      AND ci.AttrName = 'Load Number'
--      AND ci.AttrName = 'Account Name'
--      AND ci.AttrName = 'Delivery Note Number'
      AND ll.ValStr = '@0001092205'
      AND ll.ID = 244031
order by ll.id
      


    
    
    delete from AMSA_COKEANDCHEMICALS WHERE ID = 242640;
    
    INSERT INTO AMSA_COKEANDCHEMICALS (ID, DELNO, SCANPC) VALUES (1, '80445849', 'PC1');
    INSERT INTO AMSA_COKEANDCHEMICALS (ID, DELNO, SCANPC) VALUES (2, '80445848', 'PC2');
    COMMIT;
    
    UPDATE AMSA_COKEANDCHEMICALS SET STATUS = 'N';
    COMMIT;
    
    SELECT * FROM AMSA_COKEANDCHEMICALS WHERE CLASS = 'SAP';


*/