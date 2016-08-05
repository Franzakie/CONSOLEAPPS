drop table AMSA_RFQ;
CREATE TABLE AMSA_RFQ
(   
    ID            	number(10)    	NOT NULL,
    RFQNO      		varchar2(10)  	NULL,	--EBELN   Purchasing Document Number
    RFQ_GROUPNO    	varchar2(10)  	NULL,	--SUBMI  Collective Number
	OURREF			varchar2(12)  	NULL,	--UNSEZ  Our Reference
    DESCRIPTION     varchar2(200)  	NULL,	--**Doesn't exist in SAP
    CLOSINGDATE     date          	NULL,	--ANGDT Deadline for Submission of Bid/Quotation
    VENDORNO        varchar2(10) 	NULL,	--LIFNR    Vendor Account Number
    VENDORNAME      varchar2(35) 	NULL,	--NAME1 Name 1
	BUYERNO 		varchar2(3) 	NULL,	--EKGRP  Purchasing Group
    BUYERNAME      	varchar2(18)    NULL,  	--EKNAM Description of purchasing group
	LOCATIONNO		varchar2(4)     NULL,  	--BUKRS  Purchasing Organization
    LOCATION     	varchar2(20)  	NULL,	--BUTXT   Description of Purchasing Organization
    scanpc        	varchar2(200) 	NULL, 	--**To be populated by Scan client (Optional)
    scandate      	date          	NULL, 	--**To be populated by Scan client (Optional)
    ReturnedDate  	date          	NULL, 	--**Must be populated by Scan client 
    Source  		varchar2(20)    NULL, 	--**To be populated by Scan client (Optional)
	UPDATEDINSAP	number(1)		DEFAULT 0 NOT NULL 	--Indicator used to see which records have already been uploaded to SAP
);

CREATE SEQUENCE  "OTCS"."AMSA_RFQ_SEC"  MINVALUE 1 MAXVALUE 99999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE ;

create or replace PROCEDURE AMSA_RFQ_U
                   (v_ID				IN number
				   ,v_RFQNO		        IN NVARCHAR2
                   ,v_RFQ_GROUPNO       IN NVARCHAR2
				   ,v_OURREF       		IN NVARCHAR2
                   ,v_DESCRIPTION       IN NVARCHAR2
                   ,v_CLOSINGDATE       IN NVARCHAR2
                   ,v_VENDORNO          IN NVARCHAR2
                   ,v_VENDORNAME        IN NVARCHAR2
                   ,v_BUYERNO           IN NVARCHAR2
                   ,v_BUYERNAME         IN NVARCHAR2
                   ,v_LOCATIONNO        IN NVARCHAR2
                   ,v_LOCATION          IN NVARCHAR2
				   ,v_UPDATEDINSAP		IN NVARCHAR2)
AS
TmpNewId Number;
BEGIN
	IF v_ID = 0 THEN
		BEGIN
			SELECT AMSA_RFQ_SEC.NEXTVAL
			INTO TmpNewId
			FROM Dual;
			INSERT INTO AMSA_RFQ (ID, RFQNO, RFQ_GROUPNO, OURREF, DESCRIPTION, CLOSINGDATE, VENDORNO, VENDORNAME, BUYERNO, BUYERNAME, 
					LOCATIONNO, LOCATION, UPDATEDINSAP)
			SELECT TmpNewId, v_RFQNO, v_RFQ_GROUPNO, v_OURREF, v_DESCRIPTION, TO_DATE(v_CLOSINGDATE, 'yyyymmdd'), v_VENDORNO, v_VENDORNAME, v_BUYERNO, v_BUYERNAME, 
				v_LOCATIONNO, v_LOCATION, v_UPDATEDINSAP FROM DUAL WHERE NOT EXISTS (SELECT * FROM AMSA_RFQ WHERE RFQNO = v_RFQNO);
		END;
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
		WHERE ID = v_ID; 
	END IF;
   COMMIT;
END;

create or replace PROCEDURE AMSA_RFQ_R
                   (cv_1                OUT SYS_REFCURSOR)
AS
BEGIN
	OPEN cv_1 FOR
	SELECT ID, RFQNO, RFQ_GROUPNO, OURREF, DESCRIPTION, 
		CLOSINGDATE, VENDORNO, VENDORNAME, BUYERNO, BUYERNAME, 
		LOCATIONNO, "LOCATION", UPDATEDINSAP
	FROM AMSA_RFQ
	WHERE RFQNO = (SELECT MAX(RFQNO) FROM AMSA_RFQ);
END;

/

