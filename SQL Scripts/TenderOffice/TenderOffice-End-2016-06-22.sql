create or replace PROCEDURE TEMP_UPDATE_TC_NUM
AS
    Tmp_CattName      varchar2(50) := 'Test Certificate';  
    Tmp_ATTName       varchar2(50) := 'Test Certificate Number';  
    Tmp_DocId         varchar2(50);
    Tmp_TCNR          varchar2(50);
  CURSOR CaC_Cursor IS 
  SELECT TC.DOCID, 
    TC.TC_NR
  FROM V_TC_SCAN@tcp TC
  where TC.DOCID = 'alp133ppwltfcjozkjwrzp33bd14e'; 
--  WHERE TC.DOCID IS NOT NULL;;
BEGIN
   OPEN  CaC_Cursor;
   LOOP
      BEGIN
          FETCH CaC_Cursor 
          INTO  Tmp_DocId, Tmp_TCNR;
          EXIT WHEN CaC_Cursor%NOTFOUND;
          IF LENGTH(Tmp_TCNR) > 0 THEN Temp_AMSA_CS_GENERIC_U(Tmp_DocId, Tmp_CattName, Tmp_ATTName, Tmp_TCNR); END IF; 
      END;
   END LOOP;
   CLOSE CaC_Cursor;
   COMMIT;
END;

EXECUTE TEMP_UPDATE_TC_NUM;
SELECT * FROM DTREE WHERE NAME = 'alp133ppwltfcjozkjwrzp33bd14e';

create or replace PROCEDURE Temp_AMSA_CS_GENERIC_U(v_DOCID           IN NVARCHAR2
                                                    ,v_CategoryName IN NVARCHAR2
                                                    ,v_AttribName   IN NVARCHAR2
                                                    ,v_Value        IN NVARCHAR2)
IS
  v_ID              VARCHAR2(50);
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
    Str_AttribNo := '0';
    SELECT substr(ci.REGIONNAME, (INSTRC(ci.REGIONNAME,'_',1,2)+1)) 
    INTO Str_AttribNo
    FROM CATREGIONMAP ci
    WHERE ci.CATNAME = v_CategoryName
    AND ci.AttrName = v_AttribName;
    IF TO_NUMBER(Str_AttribNo) > 0 THEN
        SELECT DATAID INTO v_ID FROM DTREECORE WHERE NAME = v_DOCID;  -- OR SHOULD IT BE DTREE?
        SELECT SEGMENTBLOB INTO Str_Value FROM LLATTRBLOBDATA WHERE ID = v_ID;
        SELECT '=' || Str_AttribNo || ',' INTO Str_Search FROM DUAL;
        SELECT INSTR(Str_Value, Str_Search) INTO Num_Pos FROM DUAL;
        SELECT SUBSTR(Str_Value, 0, INSTR(Str_Value, '{', Num_Pos)) INTO Str_Value_Start FROM DUAL;
        SELECT INSTR(Str_Value, '}', Num_Pos) INTO Num_Val_End FROM DUAL;
        SELECT SUBSTR(Str_Value, Num_Val_End, (LENGTH(Str_Value)-Num_Val_End +1)) INTO Str_Value_End FROM DUAL;
        SELECT Str_Value_Start || '''' || v_Value || '''' || Str_Value_End INTO Str_New_Value FROM DUAL;
        
        UPDATE LLATTRBLOBDATA SET SEGMENTBLOB = Str_New_Value WHERE ID = v_ID 
        AND VERNUM = (SELECT MAX(VERNUM) FROM LLATTRBLOBDATA WHERE ID = v_ID );
        UPDATE LLATTRDATA SET VALSTR =  v_Value WHERE ID = v_ID AND ATTRID = TO_NUMBER(Str_AttribNo)
        AND VERNUM = (SELECT MAX(VERNUM) FROM LLATTRDATA WHERE ID = v_ID );
        dbms_output.put_line(Str_Search);
        dbms_output.put_line(Str_New_Value);
        COMMIT;
    END IF;
    dbms_output.put_line('----DONE----');
END;
