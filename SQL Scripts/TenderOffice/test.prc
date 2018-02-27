--DELETE FROM AMSA_RFQ ;

--DELETE FROM AMSA_RFQ_LINE;

COMMIT;

SELECT * FROM AMSA_RFQ where rfqno = '6019501353';

SELECT * FROM AMSA_RFQ_LINE where masterid = 328;

SELECT MASTERID, COUNT(*) FROM AMSA_RFQ_LINE GROUP BY MASTERID HAVING COUNT(*) > 1

COMMIT;

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
                    ,v_LINENO            IN NVARCHAR2
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
    IF ((v_MATERIALNO IS NOT NULL) AND (v_MATERIALNO <> '0')) THEN
        BEGIN
            SELECT Count(*) INTO TmpCount FROM AMSA_RFQ_Line WHERE MASTERID = TmpNewId AND MATERIALNO = v_MATERIALNO;
            IF TmpCount = 0 THEN
                BEGIN
                    SELECT AMSARFQLINES.NEXTVAL
                    INTO TmpNewLineId
                    FROM Dual;
                    INSERT INTO AMSA_RFQ_Line (ID, MASTERID, LINENO, MATERIALNO, DESCRIPTION )
                    SELECT TmpNewLineId, TmpNewId, v_LINENO, v_MATERIALNO, v_DESCRIPTION  FROM DUAL;
                END;
            ELSE
                BEGIN
                    UPDATE AMSA_RFQ_Line
                    SET DESCRIPTION = v_DESCRIPTION
                    WHERE MASTERID = TmpNewId AND MATERIALNO = v_MATERIALNO;
                END;
            END IF;
        END;
    END IF;
    COMMIT;
END;
/

