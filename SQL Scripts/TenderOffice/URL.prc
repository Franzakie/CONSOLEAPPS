SELECT d.dataid,         
            d.Name,
            (Select la.valstr from llattrdata la where la.id = d.dataid and la.attrid = 2 and la.Vernum = d.VersionNum) as "CollectiveNo",
            AF.RFQNO,
            AF.closingdate,
            AF.OURREF,
            (Select lc.valstr from llattrdata lc where lc.id = d.dataid and lc.attrid = 26 and lc.Vernum = d.VersionNum) as "RFQType",
            (Select ld.valstr from llattrdata ld where ld.id = d.dataid and ld.attrid = 22 and ld.Vernum = d.VersionNum) as "MaterialNo",
            (Select lg.valstr from llattrdata lg where lg.id = d.dataid and lg.attrid = 9 and lg.Vernum = d.VersionNum) as "VendorNo",
            (Select lh.valstr from llattrdata lh where lh.id = d.dataid and lh.attrid = 10 and lh.Vernum = d.VersionNum) as "VendorName",
            (Select li.valstr from llattrdata li where li.id = d.dataid and li.attrid = 18 and li.Vernum = d.VersionNum) as "BuyerName",
            (Select lj.valstr from llattrdata lj where lj.id = d.dataid and lj.attrid = 20 and lj.Vernum = d.VersionNum) as "ScanPC",
            (Select lk.valstr from llattrdata lk where lk.id = d.dataid and lk.attrid = 21 and lk.Vernum = d.VersionNum) as "ScanDate",
            (Select ll.valstr from llattrdata ll where ll.id = d.dataid and ll.attrid = 30 and ll.Vernum = d.VersionNum) as "CreateDate",
            (Select le.valstr from llattrdata le where le.id = d.dataid and le.attrid = 5 and le.Vernum = d.VersionNum) as "Location",
--            (Select lm.ValDate from llattrdata lm where lm.id = d.dataid and lm.attrid = 31 and lm.Vernum = d.VersionNum) as "test",
--            (Select ln.ValDate from llattrdata ln where ln.id = d.dataid and ln.attrid = 32 and ln.Vernum = d.VersionNum) as "test2",
--            (Select lb.valstr from llattrdata lb where lb.id = d.dataid and lb.attrid = 3 and lb.Vernum = d.VersionNum) as "test3",
            (Select lf.ValDate from llattrdata lf where lf.id = d.dataid and lf.attrid = 7 and lf.Vernum = d.VersionNum) as "ClosingDate",
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
    inner join dversdata v on l.ID = v.DocID and l.vernum = v.Version and v.FileType not in ('JPG')
    inner join providerdata p on v.ProviderId = p.providerID
    inner join AMSA_RFQ AF on AF.RFQNO = l.valstr
    where 
        d.subtype=144
        and l.defid=7355322
        and l.attrid = 3
        and d.versionnum = l.VerNum
        and d.Name in ('1001741671-6019981948-NATIONAL INDUSTRIAL SUPPLIES')
        ORDER BY CreateDate DESC
