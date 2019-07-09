-- Example queries

----------------------------------------------------
-- Query no 1 v 1
----------------------------------------------------
-- How many copies of books by Gabriele Meola
-- is currently on loan and
-- is archived (was previously borrowed)

select count(c.copyno) as "1: On loan / 2: Archived"
from copyonloan c, bookcopy bc, booktitle bt
where c.copyno = bc.copyno
and bc.isbn = bt.isbn
and bt.author = 'Gabriele Meola'
UNION
select count(la.copyno) 
from loanarchive la, bookcopy bc, booktitle bt
where la.copyno = bc.copyno
and bc.isbn = bt.isbn
and bt.author = 'Gabriele Meola';


----------------------------------------------------
-- Query no 1 v 2
----------------------------------------------------
-- How many copies of books by Gabriele Meola
-- is currently on loan and
-- is archived (was previously borrowed)

select /*+ INDEX (bookcopy pk_bookcopy)*/ count(c.copyno) as "1: On loan / 2: Archived"
from copyonloan c, bookcopy bc, booktitle bt
where c.copyno = bc.copyno
and bc.isbn = bt.isbn
and bt.author = 'Gabriele Meola'
UNION
select count(la.copyno) 
from loanarchive la, bookcopy bc, booktitle bt
where la.copyno = bc.copyno
and bc.isbn = bt.isbn
and bt.author = 'Gabriele Meola';


create index bookcopy_isbn_idx on bookcopy(isbn);
create index booktitle_author_idx on booktitle(author);

drop index bookcopy_isbn_idx;
----------------------------------------------------
-- Query no 2 v 1
----------------------------------------------------
-- How many times copies of books by Gabriele Meola was borrowed in total
SELECT sum(copies) as "Total Borrowed"
FROM (
    select count(c.copyno) as copies
    from copyonloan c, bookcopy bc, booktitle bt
    where c.copyno = bc.copyno
    and bc.isbn = bt.isbn
    and bt.author = 'Gabriele Meola'
UNION
    select count(la.copyno) as copies
    from loanarchive la, bookcopy bc, booktitle bt
    where la.copyno = bc.copyno
    and bc.isbn = bt.isbn
    and bt.author = 'Gabriele Meola');


----------------------------------------------------
-- Query no 3
----------------------------------------------------
-- What was total turnover from borrowing copies
-- of dvds between 1-1-2010 and 31-12-2015

select /* + gather_plan_statistics */ sum(loancharge) as "Total 2010 - 2015"
from loanarchive al, dvdcopy dc
where al.copyno IN (   select dc.copyno
                    from dvdcopy)
and al.loanstartdate >= TO_DATE('2010-01-01', 'YYYY-MM-DD')
and al.duedate <= TO_DATE('2015-12-31', 'YYYY-MM-DD');

select * from table(dbms_xplan.display_cursor(format=>'allstats last'));

-- Query no.3 using BETWEEN
-- What was total turnover from borrowing copies
-- of dvds between 1-1-2010 and 31-12-2015

select /*+ INDEX (LOANARCHIVE al PK_LOANARCHIVE) gather_plan_statistics */ sum(loancharge) as "Total 2010 - 2015"
from loanarchive al, dvdcopy dc
where al.copyno IN (    select dc.copyno
                        from dvdcopy)
and al.loanstartdate BETWEEN TO_DATE('2010-01-01', 'YYYY-MM-DD') AND TO_DATE('2015-12-31', 'YYYY-MM-DD');

-- Query no.3 Join order changed
-- What was total turnover from borrowing copies
-- of dvds between 1-1-2010 and 31-12-2015

select /* + gather_plan_statistics */ sum(loancharge) as "Total 2010 - 2015"
from loanarchive al, dvdcopy dc
where al.loanstartdate BETWEEN TO_DATE('2010-01-01', 'YYYY-MM-DD') AND TO_DATE('2015-12-31', 'YYYY-MM-DD')
and al.copyno IN (    select dc.copyno
                        from dvdcopy);

----------------------------------------------------
-- Query no 4 v1
----------------------------------------------------
-- retunrs entire loanarchive table
-- very inefficient
-- forced using index which is very bad
-- increases cost by order of magnitude

-- because query returns large amount of tuples
-- using index is inefficient as we are doubling on IO's
-- firstly every row in index has to be accessed and then 
-- full physical table scan is done on top
-- index only makes sense if few tupes to be retrieved

-- another problem is very inaccurate cardinality estimation
-- oracle estimates to only fetch not even 90 rows
-- and actually over 1700 rows returned

-- probematic histogram algorithms in Oracle 11g
-- frequency and height-balanced

-- much improved HYBRID in 12c

select /*+ INDEX (loanarchive loanarchive_copyno_idx)*/ *
from loanarchive where copyno LIKE '%CN%';

----------------------------------------------------
-- Query no 4 v2
----------------------------------------------------
-- retunrs entire loanarchive table
-- very inefficient
-- this time we're not using index
-- let oracle assess the situation
-- and perform
-- full tabel scan

-- because query returns large amount of tuples
-- using index is inefficient as we are doubling on IO's
-- firstly every row in index has to be accessed and then 
-- full physical table scan is done on top
-- index only makes sense if few tupes to be retrieved

-- another problem is very inaccurate cardinality estimation
-- oracle estimates to only fetch not even 90 rows
-- and actually over 1700 rows returned

-- probematic histogram algorithms in Oracle 11g
-- frequency and height-balanced

-- much improved HYBRID in 12c

explain plan for select * from loanarchive where copyno LIKE '%CN%';

select * from loanarchive where copyno LIKE '%CN%';

select count(*) from loanarchive;

select * from loanarchive where copyno LIKE '%CN%';

select * from table(dbms_xplan.display);

select copyno, count(copyno) from loanarchive where copyno LIKE '%CN%' group by copyno;

select * from table(dbms_xplan.display_cursor(format=>'allstats last'));






----------------------------------------------------
-- Query no 5 v1
----------------------------------------------------
-- Find all authors of books in the category 'Fiction'

-- this query has to access the following tables:
-- title category in order to find association between
-- title identifier and category identifier
-- first we need to go to the category table
-- to find identifier for the 'Fiction' category
-- next we need to filter the titlecategory
-- to only select book titles
-- and finally apply predicate to booktitle to only
-- select titles in the 'Fiction' category.

select distinct author
from category cat, titlecategory tcat, booktitle bt
where categoryname = 'Fiction'
and cat.categoryid = tcat.categoryid
and tcat.titleid = bt.isbn;

----------------------------------------------------
-- Query no 5 v2
----------------------------------------------------
select distinct author
from category cat, titlecategory tcat, booktitle bt
where cat.categoryid = tcat.categoryid
and tcat.titleid = bt.isbn
and categoryname = 'Fiction';


----------------------------------------------------
-- Query no 6 v1
----------------------------------------------------
-- What books do you have in the 'Fiction' category
-- by author 'Lynn Conrad'. Show publication date
-- and ISBN as well

select booktitle, publisher, publicationdate
from category cat, titlecategory tcat, booktitle bt
where tcat.categoryid = cat.categoryid
and tcat.titleid = bt.isbn
and categoryname = 'Fiction'
and author = 'Lynn Conrad';

----------------------------------------------------
-- Query no 6 v 2
----------------------------------------------------
-- What books do you have in the 'Fiction' category
-- by author 'Lynn Conrad'. Show publication date
-- and ISBN as well

select booktitle, publisher, publicationdate
from category cat, titlecategory tcat, booktitle bt
where categoryname = 'Fiction'
and author = 'Lynn Conrad'
and tcat.categoryid = cat.categoryid
and tcat.titleid = bt.isbn;




-- dont know what this query is for???

select m.membername, la.loanstartdate, bt.isbn, bt.booktitle, bc.copyno, i.invoiceno
from member m, invoice i, loanarchive la, booktitle bt, bookcopy bc
where m.memberid = i.memberid
and i.invoiceno = la.invoiceno
and la.copyno = bc.copyno
and bc.isbn = bt.isbn;
