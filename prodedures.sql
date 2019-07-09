
-- maximum number copies on loan constrint
-- maximum number of copies on loan 15 constraint
create or replace trigger max_number_copies_trigger
before insert
on copyonloan for each row

declare

    v_copyno varchar2(7);
    v_copies_borrowed number(2);
    v_member_name VARCHAR2(50);
    
begin
    -- for purpose of this demonstration I have assigned name to the variable
    v_member_name := 'Darsh Rice';
    -- count how many copies member has on loan
    select count(copyno) into v_copies_borrowed
    from copyonloan cl, invoice i, member m
    where cl.invoiceno = i.invoiceno
    and i.memberid = m.memberid
    and membername = v_member_name;
    
    -- if member has 15 copies on loan throw exception
    -- formula: if 15 - copies_borrowed =  0 then maximum number
    -- of copies on loan already
    if ((15 - v_copies_borrowed) = 0) then
        raise_application_error(-20000, 'Maximum number of copies borrowed already');
    end if;
end;
/


drop trigger max_number_copies_trigger;

-- create procedure insert into copyonloan
-- that is customer borrowing copy
create or replace procedure new_member_loan
(   nml_copyno in copyonloan.copyno%TYPE,
    nml_loan_start in DATE,
    nml_due_date in DATE,
    nml_loancharge in copyonloan.loancharge%TYPE,
    nml_invoice in copyonloan.invoiceno%TYPE)
is
begin
    insert into copyonloan values (nml_copyno, nml_loan_start, nml_due_date, nml_loancharge, nml_invoice);
    DBMS_OUTPUT.PUT_LINE ('Record inserted');
end;
--compile
/

set serveroutput on;

describe new_member_loan

--copyno	loanstartdate	duedate	loancharge	invoiceno
--CN20291	25/04/2019	06/05/2019	10.89	invNo02673
--CN30230	25/04/2019	06/05/2019	10.89	invNo02673
--CN30394	25/04/2019	06/05/2019	10.89	invNo02673
--
-- at the same time system would add a record for
-- the new invoice for the loan

execute new_member_loan('CN10088', TO_DATE('2019-04-25', 'YYYY-MM-DD'), TO_DATE('2019-05-06', 'YYYY-MM-DD'), 10.89, 'invNo02673');
execute new_member_loan('CN20158', TO_DATE('2019-04-25', 'YYYY-MM-DD'), TO_DATE('2019-05-06', 'YYYY-MM-DD'), 10.89, 'invNo02673');
execute new_member_loan('CN20204', TO_DATE('2019-04-25', 'YYYY-MM-DD'), TO_DATE('2019-05-06', 'YYYY-MM-DD'), 10.89, 'invNo02673');
rollback;



delete from invoice where invoiceno = 'invNo02673';

select * from invoice where invoiceno = 'invNo02673';

insert into invoice values('invNo02673', 'mId12225',  TO_DATE('2019-04-25', 'YYYY-MM-DD'), 32.67);

select * from copyonloan
where copyno = 'CN20158';

select count(copyno)
from copyonloan cl, invoice i, member m
where cl.invoiceno = i.invoiceno
and i.memberid = m.memberid
and m.membername = 'Darsh Rice';

select cl.*
from copyonloan cl, invoice i, member m
where cl.invoiceno = i.invoiceno
and i.memberid = m.memberid
and m.membername = 'Darsh Rice'
and i.invoiceno = 'invNo00209';

set autotrace on;

set autotrace off

select * from copyonloan
where invoiceno in (select invoiceno
                    from invoice
                    where invoiceno = 'invNo00209'
                    and memberid in (select memberid
                                     from member
                                     where membername = 'Darsh Rice'));

alter system flush buffer_cache;
alter system flush shared_pool;

select * from table(dbms_xplan.display);


select cl.*, m.membername
from copyonloan cl, invoice i, member m
where cl.invoiceno = i.invoiceno
and i.memberid = m.memberid
and m.membername = 'Darsh Rice';

