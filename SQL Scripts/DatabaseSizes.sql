 select sum(bytes/1024/1024/1024) from dba_data_files;


select b.tablespace_name, tbs_size SizeMb, a.free_space FreeMb
from 
(select tablespace_name, round(sum(bytes)/1024/1024/1024 ,2) as free_space 
from dba_free_space group by tablespace_name) a, 
(select tablespace_name, sum(bytes)/1024/1024/1024 as tbs_size 
from dba_data_files group by tablespace_name
UNION
select tablespace_name, sum(bytes)/1024/1024/1024 tbs_size
from dba_temp_files
group by tablespace_name ) b
where a.tablespace_name(+)=b.tablespace_name;

Declare
Documents          PLS_INTEGER;
l_today_date        DATE;
BEGIN
    select Sysdate Into l_today_date from Dual;
    select  count(*) Into Documents from dtreecore where trunc(l_today_date - createdate) < 29;
    dbms_output.put_line( 'New Content Server Documents in the last 4 weeks = ' ||  to_char( Documents));
    select count(*) Into Documents from dtreecore where trunc(l_today_date - createdate) < 8;
    dbms_output.put_line( 'New Content Server Documents in the last week = ' ||  to_char( Documents));
    select count(*) Into Documents from dtreecore where trunc(l_today_date - createdate) > 7 and trunc(l_today_date - createdate) < 15;
    dbms_output.put_line( 'New Content Server Documents Created two weeks ago = ' ||  to_char( Documents));
    select count(*) Into Documents from dtreecore where trunc(l_today_date - createdate) > 14 and trunc(l_today_date - createdate) < 22;
    dbms_output.put_line( 'New Content Server Documents Created three weeks ago = ' ||  to_char( Documents));
    select count(*) Into Documents from dtreecore where trunc(l_today_date - createdate) > 21 and trunc(l_today_date - createdate) < 29;
    dbms_output.put_line( 'New Content Server Documents Created four weeks ago = ' ||  to_char( Documents));
END;
/
