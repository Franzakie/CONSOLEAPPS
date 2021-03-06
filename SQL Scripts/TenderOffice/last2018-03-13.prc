SELECT A.RFQNO, COUNT(*) FROM AMSA_RFQ_Line B INNER JOIN AMSA_RFQ A ON A.ID = B.MASTERID 
GROUP BY A.RFQNO HAVING COUNT(*) > 1;

select * from amsa_rfq_line where masterid = (select id from amsa_rfq where rfqno = '6019501353')

select * from amsa_rfq where rfqno = '6019501283'

UPDATE amsa_rfq SET UPDATEDINSAP = 2 
where rfqno = '6019501283'

6019501275

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
    WHERE A.UPDATEDINSAP IN (1,2) AND NVL(L.PRICE, A.PRICE) IS NOT NULL
    ORDER BY A.ID, L.LINENO;
END;

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
