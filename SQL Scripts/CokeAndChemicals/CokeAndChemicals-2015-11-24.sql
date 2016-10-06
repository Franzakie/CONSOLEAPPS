create or replace PROCEDURE AMSA_CS_GENERIC_U(v_ID           IN NUMBER
                                                    ,v_CategoryName IN NVARCHAR2
                                                    ,v_AttribName   IN NVARCHAR2
                                                    ,v_Value        IN NVARCHAR2)
IS
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
/

create or replace PROCEDURE AMSA_CandC_U_CS
AS
    Tmp_Id             Number(19,0);
    Tmp_CattName      varchar2(20) := 'Coke and Chemicals';  
    Tmp_loadnumber    varchar2(20);  
    Tmp_saporder      varchar2(20);  
    Tmp_delNo         varchar2(20);  
    Tmp_deldate       date;          
    Tmp_accnr         varchar2(255); 
    Tmp_accname       varchar2(255); 
    Tmp_returned      number(1);     
    Tmp_cancelled     varchar2(1);   
    Tmp_sequencenr    number(10);    
    Tmp_invoicenumber varchar2(20);  
    Tmp_nippsorder    varchar2(20);  
    Tmp_truckregnr    varchar2(20);  
    Tmp_trailernr     varchar2(20);  
    Tmp_status        varchar2(1);   
    Tmp_class         varchar2(10);  
    Tmp_AttNo         Number(15,0);
  CURSOR CaC_Cursor IS 
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
    AMSA_COKEANDCHEMICALS.class
  FROM AMSA_COKEANDCHEMICALS
  WHERE NVL(AMSA_COKEANDCHEMICALS.status,'N') <> 'Y'
  AND AMSA_COKEANDCHEMICALS.class = 'SAP'
  UNION
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

BEGIN
   OPEN  CaC_Cursor;
   LOOP
      BEGIN
          FETCH CaC_Cursor 
          INTO  Tmp_Id, Tmp_loadnumber, Tmp_saporder, Tmp_delNo, Tmp_deldate, Tmp_accnr, Tmp_accname, Tmp_returned
                , Tmp_cancelled, Tmp_sequencenr, Tmp_invoicenumber, Tmp_nippsorder, Tmp_truckregnr, Tmp_trailernr
                , Tmp_status, Tmp_class;
          EXIT WHEN CaC_Cursor%NOTFOUND;
          IF Tmp_class = 'SAP' THEN
              IF LENGTH(Tmp_saporder) > 0 THEN AMSA_CS_GENERIC_U(Tmp_Id, Tmp_CattName, 'SAP Order Number', Tmp_saporder); END IF;
              AMSA_CS_GENERIC_U(Tmp_Id, Tmp_CattName, 'Delivery Note Date', TO_CHAR(Tmp_deldate, 'yyyy/MM/dd'));
              IF LENGTH(Tmp_accnr) > 0 THEN AMSA_CS_GENERIC_U(Tmp_Id, Tmp_CattName, 'Account Number', Tmp_accnr); END IF;
              IF LENGTH(Tmp_accname) > 0 THEN AMSA_CS_GENERIC_U(Tmp_Id, Tmp_CattName, 'Account Name', Tmp_accname); END IF;
              IF LENGTH(Tmp_invoicenumber) > 0 THEN AMSA_CS_GENERIC_U(Tmp_Id, Tmp_CattName, 'Invoice Number', Tmp_invoicenumber); END IF;
              IF LENGTH(Tmp_truckregnr) > 0 THEN AMSA_CS_GENERIC_U(Tmp_Id, Tmp_CattName, 'Truck Registration Number', Tmp_truckregnr); END IF;
              IF Tmp_status = 'E' THEN 
                  AMSA_CS_GENERIC_U(Tmp_Id, Tmp_CattName, 'Status', 'E'); 
              ELSE
                  AMSA_CS_GENERIC_U(Tmp_Id, Tmp_CattName, 'Status', 'Y'); 
              END IF;
              UPDATE AMSA_COKEANDCHEMICALS SET status = 'Y' WHERE ID = Tmp_Id AND CLASS = 'SAP';
          END IF;
          IF Tmp_class = 'NIPPS' THEN
              IF LENGTH(Tmp_saporder) > 0 THEN AMSA_CS_GENERIC_U(Tmp_Id, Tmp_CattName, 'SAP Order Number', Tmp_saporder); END IF;
              AMSA_CS_GENERIC_U(Tmp_Id, Tmp_CattName, 'Delivery Note Date', TO_CHAR(Tmp_deldate, 'yyyy/MM/dd'));
              IF LENGTH(Tmp_accnr) > 0 THEN AMSA_CS_GENERIC_U(Tmp_Id, Tmp_CattName, 'Account Number', Tmp_accnr); END IF;
              IF LENGTH(Tmp_returned) > 0 THEN AMSA_CS_GENERIC_U(Tmp_Id, Tmp_CattName, 'Returned', Tmp_returned); END IF;
              IF LENGTH(Tmp_cancelled) > 0 THEN AMSA_CS_GENERIC_U(Tmp_Id, Tmp_CattName, 'Cancelled', Tmp_cancelled); END IF;
              IF LENGTH(Tmp_sequencenr) > 0 THEN AMSA_CS_GENERIC_U(Tmp_Id, Tmp_CattName, 'Sequence Number', Tmp_sequencenr); END IF;
              IF LENGTH(Tmp_nippsorder) > 0 THEN AMSA_CS_GENERIC_U(Tmp_Id, Tmp_CattName, 'NIPPS Order Number', Tmp_nippsorder); END IF;
              IF LENGTH(Tmp_trailernr) > 0 THEN AMSA_CS_GENERIC_U(Tmp_Id, Tmp_CattName, 'Trailer Number', Tmp_trailernr); END IF;
              IF LENGTH(Tmp_invoicenumber) > 0 THEN AMSA_CS_GENERIC_U(Tmp_Id, Tmp_CattName, 'Invoice Number', Tmp_invoicenumber); END IF;
              IF LENGTH(Tmp_truckregnr) > 0 THEN AMSA_CS_GENERIC_U(Tmp_Id, Tmp_CattName, 'Truck Registration Number', Tmp_truckregnr); END IF;
              IF LENGTH(Tmp_status) > 0 THEN AMSA_CS_GENERIC_U(Tmp_Id, Tmp_CattName, 'Status', 'Y'); END IF;
              UPDATE AMSA_COKEANDCHEMICALS SET status = 'Y' WHERE LOADNUMBER = Tmp_loadnumber AND CLASS = 'NIPPS';
          END IF;
      END; 
   END LOOP;
   CLOSE CaC_Cursor;
   COMMIT;
END;
/
