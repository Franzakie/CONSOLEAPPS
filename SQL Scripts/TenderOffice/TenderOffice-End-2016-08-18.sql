ALTER TABLE AMSA_RFQ MODIFY VENDORNAME  VARCHAR2(50);
ALTER TABLE AMSA_RFQ MODIFY LOCATION   	VARCHAR2(50);

ALTER TABLE AMSA_RFQ ADD MATERIALNO   	VARCHAR2(100);  -- EMATN
ALTER TABLE AMSA_RFQ ADD RETFAXNO   	VARCHAR2(20);

ALTER TABLE AMSA_RFQ ADD MATERIALDESC	VARCHAR2(100);  -- MAKTX 

ALTER TABLE AMSA_RFQ MODIFY MATERIALNO	VARCHAR2(20);

ALTER TABLE AMSA_RFQ ADD BUYEREMAIL	VARCHAR2(50);  -- SMTP_ADDR

ALTER TABLE AMSA_RFQ ADD INITIALDATE DATE;

ALTER TABLE AMSA_RFQ ADD PRICE	VARCHAR2(20);

COMMIT;

select CLOSINGDATE, CONCAT(CONCAT('D/', TO_CHAR(CLOSINGDATE, 'YYYY/MM/DD')),':0:0:0') AS CSDATE from AMSA_RFQ where INITIALDATE is not null;

AMSA_CS_GENERIC_INT_U

    SELECT substr(ci.REGIONNAME, (INSTRC(ci.REGIONNAME,'_',1,2)+1)) 
    FROM CATREGIONMAP ci
    WHERE ci.CATNAME = 'RFQ Responses'
    AND ci.AttrName = 'Closing Date';

SELECT DATAID FROM DTREECORE WHERE NAME = '1001638185-6019855524-WIDE RANGE ENGINEERING CC' AND OWNERID=-2000;  -- OR SHOULD IT BE DTREE?

        SELECT SEGMENTBLOB FROM LLATTRBLOBDATA WHERE ID = 7971620 AND VERNUM = (SELECT MAX(VERNUM) FROM LLATTRBLOBDATA WHERE ID = 7971620 );
        SELECT '=' || Str_AttribNo || ',' INTO Str_Search FROM DUAL;
        SELECT INSTR(Str_Value, Str_Search) INTO Num_Pos FROM DUAL;
        SELECT SUBSTR(Str_Value, 0, INSTR(Str_Value, '{', Num_Pos)) INTO Str_Value_Start FROM DUAL;
        SELECT INSTR(Str_Value, '}', Num_Pos) INTO Num_Val_End FROM DUAL;
        SELECT SUBSTR(Str_Value, Num_Val_End, (LENGTH(Str_Value)-Num_Val_End +1)) INTO Str_Value_End FROM DUAL;
        SELECT Str_Value_Start || v_Value || Str_Value_End INTO Str_New_Value FROM DUAL;


=6,'Values'={D/2016/9/16:0:0:0}>,7=A<1,?,'ID'=7,'Values'={'14:00'}>,8=A<1,?,'ID'=8,'Values'={'0001159005'}>,9=A<1,?,'ID'=9,'Values'={'WIDE RANGE ENGINEERING CC'}>,10=A<1,?,'ID'=10,'

