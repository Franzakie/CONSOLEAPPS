create or replace PROCEDURE AMSA_RFQ_R_ALL
                   (cv_1                OUT SYS_REFCURSOR)
AS
BEGIN
	OPEN cv_1 FOR
	SELECT ID, RFQNO, RFQ_GROUPNO, OURREF, DESCRIPTION, 
		CLOSINGDATE, VENDORNO, VENDORNAME, BUYERNO, BUYERNAME, 
		LOCATIONNO, "LOCATION", UPDATEDINSAP
	FROM AMSA_RFQ
	WHERE UPDATEDINSAP IN (1,2);
END;


create or replace PROCEDURE AMSA_CS_RFQ_DOCID_R(v_DOCID           IN NVARCHAR2
												,v_CategoryName 	IN NVARCHAR2
												,v_AttribName1  	IN NVARCHAR2
												,v_AttribName2  	IN NVARCHAR2
												,v_AttribName3  	IN NVARCHAR2
												,v_AttribName4  	IN NVARCHAR2
												,cv_1           	OUT SYS_REFCURSOR)
IS
  v_ID              NUMBER(19,0);
  myCount           NUMBER(19,0);
  Str_AttribNo      NVARCHAR2(10);
  Str_Value1        NVARCHAR2(50);
  Str_Value2        NVARCHAR2(50);
  Str_Value3        NVARCHAR2(50);
  Str_Value4        NVARCHAR2(50);
BEGIN
    Str_Value1 := '';
    Str_Value2 := '';
    Str_Value3 := '';
    Str_Value4 := '';
    v_ID := 0;
	SELECT COUNT(*) INTO myCount FROM DTREECORE WHERE NAME = v_DOCID;
  IF myCount > 0 THEN
    BEGIN
      SELECT DATAID INTO v_ID FROM DTREECORE WHERE NAME = v_DOCID; 
      IF v_ID > 0 THEN
        Str_AttribNo := '0';
        SELECT substr(ci.REGIONNAME, (INSTRC(ci.REGIONNAME,'_',1,2)+1)) INTO Str_AttribNo FROM CATREGIONMAP ci
        WHERE ci.CATNAME = v_CategoryName AND ci.AttrName = v_AttribName1;
        IF TO_NUMBER(Str_AttribNo) > 0 THEN
          SELECT VALSTR INTO Str_Value1 FROM LLATTRDATA WHERE ID = v_ID AND ATTRID = TO_NUMBER(Str_AttribNo)
          AND VERNUM = (SELECT MAX(VERNUM) FROM LLATTRDATA WHERE ID = v_ID );
        END IF;
    --		Str_AttribNo := '0';
    --		SELECT substr(ci.REGIONNAME, (INSTRC(ci.REGIONNAME,'_',1,2)+1)) INTO Str_AttribNo FROM CATREGIONMAP ci
    --		WHERE ci.CATNAME = v_CategoryName AND ci.AttrName = v_AttribName2;
    --		IF TO_NUMBER(Str_AttribNo) > 0 THEN
    --			SELECT VALSTR INTO Str_Value2 FROM LLATTRDATA WHERE ID = v_ID AND ATTRID = TO_NUMBER(Str_AttribNo)
    --			AND VERNUM = (SELECT MAX(VERNUM) FROM LLATTRDATA WHERE ID = v_ID );
    --		END IF;
    --		Str_AttribNo := '0';
    --		SELECT substr(ci.REGIONNAME, (INSTRC(ci.REGIONNAME,'_',1,2)+1)) INTO Str_AttribNo FROM CATREGIONMAP ci
    --		WHERE ci.CATNAME = v_CategoryName AND ci.AttrName = v_AttribName3;
    --		IF TO_NUMBER(Str_AttribNo) > 0 THEN
    --			SELECT VALSTR INTO Str_Value3 FROM LLATTRDATA WHERE ID = v_ID AND ATTRID = TO_NUMBER(Str_AttribNo)
    --			AND VERNUM = (SELECT MAX(VERNUM) FROM LLATTRDATA WHERE ID = v_ID );
    --		END IF;
    --		Str_AttribNo := '0';
    --		SELECT substr(ci.REGIONNAME, (INSTRC(ci.REGIONNAME,'_',1,2)+1)) INTO Str_AttribNo FROM CATREGIONMAP ci
    --		WHERE ci.CATNAME = v_CategoryName AND ci.AttrName = v_AttribName4;
    --		IF TO_NUMBER(Str_AttribNo) > 0 THEN
    --			SELECT VALSTR INTO Str_Value4 FROM LLATTRDATA WHERE ID = v_ID AND ATTRID = TO_NUMBER(Str_AttribNo)
    --			AND VERNUM = (SELECT MAX(VERNUM) FROM LLATTRDATA WHERE ID = v_ID );
    --		END IF;
      END IF;
    END;
  END IF;
	OPEN cv_1 FOR
	SELECT Str_Value1 AS "VALUE1", Str_Value2 AS "VALUE2", Str_Value3 AS "VALUE3", Str_Value4 AS "VALUE4"
	FROM DUAL;
END;


create or replace PROCEDURE AMSA_CS_GENERIC_INT_U(v_DOCID           IN NVARCHAR2
                                                    ,v_CategoryName IN NVARCHAR2
                                                    ,v_AttribName   IN NVARCHAR2
                                                    ,v_Value        IN NUMBER)
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
        SELECT Str_Value_Start || v_Value || Str_Value_End INTO Str_New_Value FROM DUAL;
        
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

