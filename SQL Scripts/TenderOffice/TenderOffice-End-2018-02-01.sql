drop table OTCS.AMSA_RFQ_Line;
CREATE TABLE OTCS.AMSA_RFQ_Line
(   
    ID            	number(10)    	NOT NULL,
	MASTERID		number(10)		NOT NULL, --LINK TO AMSA_RFQ TABLE
	LINENO      	VARCHAR2(20) 	NOT NULL,
	MATERIALNO      VARCHAR2(20) 	NOT NULL,
    DESCRIPTION     varchar2(200)  	NOT NULL,	--
	PRICE			varchar2(20)  	NULL,
	UPDATEDINSAP	number(1)		DEFAULT 0 NOT NULL 	--Indicator used to see which records have already been uploaded to SAP
);

drop sequence "AMSARFQLINES"
CREATE SEQUENCE  "AMSARFQLINES"  MINVALUE 1 MAXVALUE 99999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE ;


CREATE OR REPLACE PROCEDURE OTCS.AMSA_RFQ_U 
                    (v_ID                IN number
                    ,v_RFQNO            IN NVARCHAR2
                    ,v_RFQ_GROUPNO      IN NVARCHAR2
                    ,v_OURREF           IN NVARCHAR2
                    ,v_DESCRIPTION      IN NVARCHAR2
                    ,v_CLOSINGDATE      IN NVARCHAR2
                    ,v_VENDORNO         IN NVARCHAR2
                    ,v_VENDORNAME       IN NVARCHAR2
                    ,v_BUYERNO          IN NVARCHAR2
                    ,v_BUYERNAME        IN NVARCHAR2
                    ,v_LOCATIONNO       IN NVARCHAR2
                    ,v_LOCATION         IN NVARCHAR2
                    ,v_UPDATEDINSAP     IN NVARCHAR2
                    ,v_LINENO        	IN NVARCHAR2
                    ,v_MATERIALNO       IN NVARCHAR2
                    ,v_RETFAXNO         IN NVARCHAR2
                    ,v_BUYERMAIL        IN NVARCHAR2)
AS
TmpNewId Number;
TmpNewLineId Number;
TmpCount Number;
BEGIN
	SELECT Count(*) INTO TmpCount FROM AMSA_RFQ WHERE RFQNO = v_RFQNO;
	IF TmpCount = 0 THEN
		BEGIN
			SELECT AMSA_RFQ_SEC.NEXTVAL
			INTO TmpNewId
			FROM Dual;
			INSERT INTO AMSA_RFQ (ID, RFQNO, RFQ_GROUPNO, OURREF, DESCRIPTION, CLOSINGDATE, VENDORNO, VENDORNAME, BUYERNO, BUYERNAME, 
				LOCATIONNO, LOCATION, UPDATEDINSAP, MATERIALNO, RETFAXNO, BUYEREMAIL)
			SELECT TmpNewId, v_RFQNO, v_RFQ_GROUPNO, v_OURREF, v_DESCRIPTION, TO_DATE(v_CLOSINGDATE, 'yyyymmdd'), v_VENDORNO, v_VENDORNAME, v_BUYERNO, v_BUYERNAME, 
				v_LOCATIONNO, v_LOCATION, v_UPDATEDINSAP, v_MATERIALNO, v_RETFAXNO, v_BUYERMAIL FROM DUAL;
		END;
	ELSE
		BEGIN
			SELECT ID INTO TmpNewId FROM AMSA_RFQ WHERE RFQNO = v_RFQNO;
			IF ((v_VENDORNO = '') OR (v_VENDORNO  IS NULL)) THEN
				UPDATE AMSA_RFQ
				SET INITIALDATE = CLOSINGDATE,
					OURREF = v_OURREF
				WHERE RFQNO = v_RFQNO; 
				UPDATE AMSA_RFQ
				SET CLOSINGDATE = TO_DATE(v_CLOSINGDATE, 'yyyymmdd') 
				WHERE RFQNO = v_RFQNO; 
			ELSE
				UPDATE AMSA_RFQ
				SET RFQNO = v_RFQNO, 
					RFQ_GROUPNO = v_RFQ_GROUPNO, 
					OURREF = v_OURREF, 
					DESCRIPTION = v_DESCRIPTION, 
					CLOSINGDATE = TO_DATE(v_CLOSINGDATE, 'yyyymmdd'), 
					VENDORNO = v_VENDORNO, 
					VENDORNAME = v_VENDORNAME, 
					BUYERNO = v_BUYERNO, 
					BUYERNAME = v_BUYERNAME, 
					LOCATIONNO = v_LOCATIONNO, 
					"LOCATION" = v_LOCATION,
					UPDATEDINSAP = v_UPDATEDINSAP
				WHERE RFQNO = v_RFQNO; 
			END IF;
			IF ((v_UPDATEDINSAP <> '0') AND (v_UPDATEDINSAP  IS NOT NULL)) THEN
				UPDATE AMSA_RFQ
				SET UPDATEDINSAP = v_UPDATEDINSAP 
				WHERE RFQNO = v_RFQNO; 
			END IF;
		END;
	END IF;
    IF v_LINENO IS NOT NULL THEN
	BEGIN
		SELECT Count(*) INTO TmpCount FROM AMSA_RFQ_Line WHERE MASTERID = TmpNewId AND LINENO = v_LINENO;
		IF TmpCount = 0 THEN
			BEGIN
				SELECT AMSARFQLINES.NEXTVAL
				INTO TmpNewLineId
				FROM Dual;
				INSERT INTO AMSA_RFQ_Line (ID, MASTERID, LINENO, MATERIALNO, DESCRIPTION, UPDATEDINSAP )
				SELECT TmpNewLineId, TmpNewId, v_LINENO, v_MATERIALNO, v_DESCRIPTION, v_UPDATEDINSAP  FROM DUAL;
			END;
		ELSE
			BEGIN
				UPDATE AMSA_RFQ_Line
				SET MATERIALNO = v_MATERIALNO, 
				DESCRIPTION = v_DESCRIPTION, 
				UPDATEDINSAP = v_UPDATEDINSAP
				WHERE MASTERID = TmpNewId AND LINENO = v_LINENO;
			END;
		END IF;
	END;
	END IF;
	COMMIT;
END;

CREATE OR REPLACE PROCEDURE OTCS.AMSA_RFQ_R_ALL
                   (cv_1                OUT SYS_REFCURSOR)
AS
BEGIN
    OPEN cv_1 FOR
    -- If multilines have not been maintained then the price captured on the header will be assigned to every line...
    SELECT A.ID, A.RFQNO, A.RFQ_GROUPNO, A.OURREF, NVL(L.DESCRIPTION, A.DESCRIPTION) AS DESCRIPTION,
        A.CLOSINGDATE, A.VENDORNO, A.VENDORNAME, A.BUYERNO, A.BUYERNAME, 
        A.LOCATIONNO, "LOCATION", L.MATERIALNO, L.LINENO, NVL(L.PRICE,A.PRICE) AS PRICE, NVL(L.UPDATEDINSAP, A.UPDATEDINSAP) AS UPDATEDINSAP
    FROM AMSA_RFQ A LEFT OUTER JOIN AMSA_RFQ_Line L ON A.ID = L.MASTERID
    WHERE NVL(L.UPDATEDINSAP, A.UPDATEDINSAP) IN (1,2) AND NVL(L.PRICE, A.PRICE) IS NOT NULL
    ORDER BY A.ID, L.LINENO;
END;

CREATE OR REPLACE PROCEDURE OTCS.AMSA_RFQLINE_U 
                    (v_ID                IN number
                    ,v_PRICE      IN NVARCHAR2
                    ,v_UPDATEDINSAP         IN NVARCHAR2)
AS
BEGIN
    UPDATE AMSA_RFQ_Line
    SET PRICE = v_PRICE,
    UPDATEDINSAP = v_UPDATEDINSAP
    WHERE ID = v_ID; 
    COMMIT;
END;

CREATE OR REPLACE PROCEDURE OTCS.AMSA_RFQLINE_R
                   (v_RFQNO            IN NVARCHAR2
                   ,cv_1                OUT SYS_REFCURSOR)
AS
BEGIN
    OPEN cv_1 FOR
    SELECT L.ID, L.MASTERID, L.LINENO, L.MATERIALNO, L.DESCRIPTION, L.PRICE, L.UPDATEDINSAP
    FROM AMSA_RFQ A LEFT OUTER JOIN AMSA_RFQ_Line L ON A.ID = L.MASTERID
    WHERE A.RFQNO = v_RFQNO
    ORDER BY L.LINENO;
END;

CREATE OR REPLACE PROCEDURE OTCS.AMSA_RFQGETURL
                   (v_ID                IN NUMBER
                   ,cv_1                OUT SYS_REFCURSOR)
AS
BEGIN
    OPEN cv_1 FOR
        SELECT AF.*,
            d.dataid,         
--            d.Name,
--            (Select la.valstr from llattrdata la where la.id = d.dataid and la.attrid = 2 and la.Vernum = d.VersionNum) as "CollectiveNo",
--            AF.RFQNO,
--            AF.closingdate,
--            AF.OURREF,
--            (Select lc.valstr from llattrdata lc where lc.id = d.dataid and lc.attrid = 26 and lc.Vernum = d.VersionNum) as "RFQType",
--            (Select ld.valstr from llattrdata ld where ld.id = d.dataid and ld.attrid = 22 and ld.Vernum = d.VersionNum) as "MaterialNo",
--            (Select lg.valstr from llattrdata lg where lg.id = d.dataid and lg.attrid = 9 and lg.Vernum = d.VersionNum) as "VendorNo",
--            (Select lh.valstr from llattrdata lh where lh.id = d.dataid and lh.attrid = 10 and lh.Vernum = d.VersionNum) as "VendorName",
--            (Select li.valstr from llattrdata li where li.id = d.dataid and li.attrid = 18 and li.Vernum = d.VersionNum) as "BuyerName",
--            (Select lj.valstr from llattrdata lj where lj.id = d.dataid and lj.attrid = 20 and lj.Vernum = d.VersionNum) as "ScanPC",
--            (Select lk.valstr from llattrdata lk where lk.id = d.dataid and lk.attrid = 21 and lk.Vernum = d.VersionNum) as "ScanDate",
--            (Select ll.valstr from llattrdata ll where ll.id = d.dataid and ll.attrid = 30 and ll.Vernum = d.VersionNum) as "CreateDate",
--            (Select le.valstr from llattrdata le where le.id = d.dataid and le.attrid = 5 and le.Vernum = d.VersionNum) as "Location",
--            (Select lm.ValDate from llattrdata lm where lm.id = d.dataid and lm.attrid = 31 and lm.Vernum = d.VersionNum) as "test",
--            (Select ln.ValDate from llattrdata ln where ln.id = d.dataid and ln.attrid = 32 and ln.Vernum = d.VersionNum) as "test2",
--            (Select lb.valstr from llattrdata lb where lb.id = d.dataid and lb.attrid = 3 and lb.Vernum = d.VersionNum) as "test3",
--            (Select lf.ValDate from llattrdata lf where lf.id = d.dataid and lf.attrid = 7 and lf.Vernum = d.VersionNum) as "ClosingDate",
                CAST (
                'http://156.8.245.220:8080/archive?get'
             || '&'
             || 'pVersion=0046'
             || '&'
             || 'contRep=L1'
             || '&'
             || 'docId='
             || SUBSTR (
                   p.providerdata,
                   INSTR (p.providerdata, '@') + 1,
                     INSTR (p.providerdata, ''',''')
                   - INSTR (p.providerdata, '@')
                   - 1) AS VARCHAR2 (255))
             AS DOCURL
from 
        dtreecore d  
    inner join llattrdata l on d.dataid = l.id
    inner join dversdata v on l.ID = v.DocID and l.vernum = v.Version and v.FileType not in ('JPG', '.JPG') and v.FileName <> '200x200-1.JPG' 
    inner join providerdata p on v.ProviderId = p.providerID
    inner join AMSA_RFQ AF on AF.RFQNO = l.valstr
    where 
        d.subtype=144
        and l.defid=7355322
        and l.attrid = 3
        and d.versionnum = l.VerNum
        and AF.ID = v_ID
        ORDER BY CreateDate DESC;
END;
/
        
CREATE OR REPLACE PROCEDURE OTCS.AMSA_RFQMULTILINES
                   (cv_1                    OUT SYS_REFCURSOR)
AS
BEGIN
    OPEN cv_1 FOR
    SELECT * FROM AMSA_RFQ WHERE RFQNO IN (
    SELECT R.RFQNO FROM AMSA_RFQ R INNER JOIN AMSA_RFQ_LINE L ON R.ID = L.MASTERID
    WHERE L.UPDATEDINSAP < 6
    AND L.PRICE IS NULL
    GROUP BY R.RFQNO, R.CLOSINGDATE, R.OURREF, R.DESCRIPTION
    HAVING COUNT(*) > 1)
    AND CLOSINGDATE > SYSDATE -1 ;
END;
/

CREATE OR REPLACE PROCEDURE OTCS.AMSA_RFQLINE_U 
                    (v_ID                IN number
                    ,v_PRICE      IN NVARCHAR2
                    ,v_UPDATEDINSAP         IN NVARCHAR2)
AS
BEGIN
    UPDATE AMSA_RFQ_Line
    SET PRICE = v_PRICE,
    UPDATEDINSAP = v_UPDATEDINSAP
    WHERE ID = v_ID; 
    COMMIT;
END;
        
		
CREATE OR REPLACE PROCEDURE OTCS.AMSA_RFQGETRFQ
                   (v_RFQNO                IN VARCHAR2
                   ,cv_1                OUT SYS_REFCURSOR)
AS
BEGIN
    OPEN cv_1 FOR
        SELECT AF.* from AMSA_RFQ AF 
        where AF.RFQNO = v_RFQNO;
END;
/

CREATE OR REPLACE PROCEDURE OTCS.AMSA_RFQ_I_Only
                   (v_ID                IN number
                   ,v_RFQNO                IN NVARCHAR2
                   ,v_RFQ_GROUPNO       IN NVARCHAR2
                   ,v_OURREF               IN NVARCHAR2
                   ,v_DESCRIPTION       IN NVARCHAR2
                   ,v_CLOSINGDATE       IN NVARCHAR2
                   ,v_VENDORNO          IN NVARCHAR2
                   ,v_VENDORNAME        IN NVARCHAR2
                   ,v_BUYERNO           IN NVARCHAR2
                   ,v_BUYERNAME         IN NVARCHAR2
                   ,v_LOCATIONNO        IN NVARCHAR2
                   ,v_LOCATION          IN NVARCHAR2
                   ,v_UPDATEDINSAP        IN NVARCHAR2
                   ,v_LINENO            IN NVARCHAR2
                   ,v_MATERIALNO        IN NVARCHAR2
                   ,v_RETFAXNO            IN NVARCHAR2
                   ,v_BUYERMAIL            IN NVARCHAR2)
AS
TmpNewId Number;
TmpNewLineId Number;
TmpCount Number;
BEGIN
    SELECT Count(*) INTO TmpCount FROM AMSA_RFQ WHERE RFQNO = v_RFQNO;
    IF TmpCount = 0 THEN
    BEGIN
        SELECT AMSA_RFQ_SEC.NEXTVAL
        INTO TmpNewId
        FROM Dual;
        INSERT INTO AMSA_RFQ (ID, RFQNO, RFQ_GROUPNO, OURREF, DESCRIPTION, CLOSINGDATE, VENDORNO, VENDORNAME, BUYERNO, BUYERNAME, 
        LOCATIONNO, LOCATION, UPDATEDINSAP, MATERIALNO, RETFAXNO, BUYEREMAIL)
        SELECT TmpNewId, v_RFQNO, v_RFQ_GROUPNO, v_OURREF, v_DESCRIPTION, TO_DATE(v_CLOSINGDATE, 'yyyymmdd'), v_VENDORNO, v_VENDORNAME, v_BUYERNO, v_BUYERNAME, 
        v_LOCATIONNO, v_LOCATION, v_UPDATEDINSAP, v_MATERIALNO, v_RETFAXNO, v_BUYERMAIL FROM DUAL;
    END;
    ELSE
    BEGIN
        SELECT ID INTO TmpNewId FROM AMSA_RFQ WHERE RFQNO = v_RFQNO;
        UPDATE AMSA_RFQ
        SET RFQNO = v_RFQNO, 
        RFQ_GROUPNO = v_RFQ_GROUPNO, 
        OURREF = v_OURREF, 
        DESCRIPTION = v_DESCRIPTION, 
        CLOSINGDATE = TO_DATE(v_CLOSINGDATE, 'yyyymmdd'), 
        VENDORNO = v_VENDORNO, 
        VENDORNAME = v_VENDORNAME, 
        BUYERNO = v_BUYERNO, 
        BUYERNAME = v_BUYERNAME, 
        LOCATIONNO = v_LOCATIONNO, 
        "LOCATION" = v_LOCATION,
        MATERIALNO = v_MATERIALNO,
        RETFAXNO = v_RETFAXNO,
        BUYEREMAIL = v_BUYERMAIL
        WHERE RFQNO = v_RFQNO; 
    END;
    END IF;
    IF v_LINENO IS NOT NULL THEN
    BEGIN 
        SELECT Count(*) INTO TmpCount FROM AMSA_RFQ_Line WHERE MASTERID = TmpNewId AND LINENO = v_LINENO;
        IF TmpCount = 0 THEN
            BEGIN
                SELECT AMSARFQLINES.NEXTVAL
                INTO TmpNewLineId
                FROM Dual;
                INSERT INTO AMSA_RFQ_Line (ID, MASTERID, LINENO, MATERIALNO, DESCRIPTION, UPDATEDINSAP )
                SELECT TmpNewLineId, TmpNewId, v_LINENO, v_MATERIALNO, v_DESCRIPTION, v_UPDATEDINSAP  FROM DUAL;
            END;
        ELSE
            BEGIN
                UPDATE AMSA_RFQ_Line
                SET MATERIALNO = v_MATERIALNO, 
                DESCRIPTION = v_DESCRIPTION, 
                UPDATEDINSAP = v_UPDATEDINSAP
                WHERE MASTERID = TmpNewId AND LINENO = v_LINENO;
            END;
        END IF;
    END;
    END IF;
  COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE OTCS.AMSA_RFQ_STATUS_U
AS
BEGIN
    UPDATE AMSA_RFQ SET UPDATEDINSAP = 1 WHERE (CLOSINGDATE + 1) <= sysdate AND UPDATEDINSAP = 3 and scanpc IS NOT NULL;
    Commit;
    UPDATE AMSA_RFQ SET UPDATEDINSAP = 2 WHERE scanpc IS NOT NULL AND ((CLOSINGDATE <= sysdate  AND '1059' < TO_CHAR (SYSDATE, 'HH24MI') AND (OURREF = '11:00' AND UPDATEDINSAP = 3)) or UPDATEDINSAP = 4  or UPDATEDINSAP = 6);
    Commit;
    UPDATE AMSA_RFQ SET UPDATEDINSAP = 2 WHERE scanpc IS NOT NULL AND (CLOSINGDATE <= sysdate  AND '1059' < TO_CHAR (SYSDATE, 'HH24MI') AND (OURREF = '11:00' AND UPDATEDINSAP = 14)) ;
    Commit;
    UPDATE AMSA_RFQ_Line SET AMSA_RFQ_Line.UPDATEDINSAP = ( SELECT R.UPDATEDINSAP FROM      AMSA_RFQ R
                            WHERE AMSA_RFQ_LINE.MASTERID = R.ID) 
    WHERE EXISTS ( SELECT * FROM      AMSA_RFQ R
                            WHERE AMSA_RFQ_LINE.MASTERID = R.ID AND R.UPDATEDINSAP IN (1,2));
END;
/

