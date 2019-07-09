--------------------------------------------------------------------------
-- 6WCM0029 CS Final Project Artefact
-- Jakub Bachniak 14024497
--------------------------------------------------------------------------
-- Rental Company Database Data Declaration
-- 2019-03-28
--------------------------------------------------------------------------

-- 1) Create Member table
CREATE TABLE member (
    memberId        VARCHAR2(8)     NOT NULL,
    memberName      VARCHAR2(50)    NOT NULL,
    address         VARCHAR2(150)   NOT NULL,
    town            VARCHAR2(25)    NOT NULL,
    email           VARCHAR2(50)    NOT NULL,
    phoneNo         VARCHAR2(11)    NOT NULL,
    CONSTRAINT PK_member PRIMARY KEY (memberId)
);
-- 2) Create RentCharge table
CREATE TABLE rentcharge (
    chargeBandNo    VARCHAR2(4)     NOT NULL,
    chargeBandDesc  VARCHAR2(80)    NOT NULL,
    bandDailyCharge NUMBER(4,2)     NOT NULL,
    CONSTRAINT PK_rentcharge PRIMARY KEY (chargeBandNo)
);
-- 3) Create BookTitle table
CREATE TABLE booktitle (
    isbn            VARCHAR2(13)    NOT NULL,
    bookTitle       VARCHAR2(80)    NOT NULL,
    author          VARCHAR2(50)    NOT NULL,
    publisher       VARCHAR2(50)    NOT NULL,
    publicationDate DATE            NOT NULL,
    chargeBandNo    VARCHAR2(4)     NOT NULL,
    CONSTRAINT PK_booktitle PRIMARY KEY (isbn),
    CONSTRAINT FK_book_charge_band
        FOREIGN KEY (chargeBandNo) REFERENCES rentcharge(chargeBandNo)
        ON DELETE SET NULL
);
-- 4) Create DvdTitle table
CREATE TABLE dvdtitle (
    ean             VARCHAR2(13)    NOT NULL,
    dvdTitle        VARCHAR2(80)    NOT NULL,
    director        VARCHAR2(50)    NOT NULL,
    releaseDate     DATE            NOT NULL,
    chargeBandNo    VARCHAR2(4)     NOT NULL,
    CONSTRAINT PK_dvdtitle PRIMARY KEY (ean),
    CONSTRAINT FK_dvd_charge_band
        FOREIGN KEY (chargeBandNo) REFERENCES rentcharge(chargeBandNo)
        ON DELETE SET NULL
);
-- 5) Create MagazineTitle table
CREATE TABLE magazinetitle (
    ean             VARCHAR2(13)    NOT NULL,
    magazineTitle   VARCHAR2(80)    NOT NULL,
    publisher       VARCHAR2(50)    NOT NULL,
    issueDate       DATE            NOT NULL,
    chargeBandNo    VARCHAR2(4)     NOT NULL,
    CONSTRAINT PK_magazinetitle PRIMARY KEY (ean),
    CONSTRAINT FK_magazine_charge_band
        FOREIGN KEY (chargeBandNo) REFERENCES rentcharge(chargeBandNo)
        ON DELETE SET NULL
);
-- 6) Create BookCopy table
CREATE TABLE bookcopy (
    copyNo          VARCHAR2(7)     NOT NULL,
    isbn            VARCHAR2(13)    NOT NULL,
    CONSTRAINT PK_bookcopy PRIMARY KEY (copyNo),
    CONSTRAINT FK_book_copy
        FOREIGN KEY (isbn) REFERENCES booktitle (isbn)
        ON DELETE CASCADE
);
-- 7) Create DvdCopy table
CREATE TABLE dvdcopy (
    copyNo          VARCHAR2(7)     NOT NULL,
    ean             VARCHAR2(13)    NOT NULL,
    CONSTRAINT PK_dvdcopy PRIMARY KEY (copyNo),
    CONSTRAINT FK_dvd_copy
        FOREIGN KEY (ean) REFERENCES dvdtitle (ean)
        ON DELETE CASCADE
);
-- 8) Create MagazineCopy table
CREATE TABLE magazinecopy (
    copyNo          VARCHAR2(7)     NOT NULL,
    ean             VARCHAR2(13)    NOT NULL,
    CONSTRAINT PK_magazinecopy PRIMARY KEY (copyNo),
    CONSTRAINT FK_magazine_copy
        FOREIGN KEY (ean) REFERENCES magazinetitle (ean)
        ON DELETE CASCADE
);
-- 9) Create Category table
CREATE TABLE category (
    categoryId      VARCHAR2(7)     NOT NULL,
    categoryName    VARCHAR2(25)    NOT NULL,
    CONSTRAINT PK_category PRIMARY KEY (categoryId)
);
-- 10) Create TitleCaategory table
CREATE TABLE titlecategory (
    titleId         VARCHAR2(13)    NOT NULL,
    categoryId      VARCHAR(7)      NOT NULL,
    CONSTRAINT PK_titlecategory
        PRIMARY KEY (titleId, categoryId),
    CONSTRAINT FK_book_category
        FOREIGN KEY (titleId) REFERENCES booktitle (isbn)
        ON DELETE CASCADE,
    CONSTRAINT FK_dvd_category
        FOREIGN KEY (titleId) REFERENCES dvdtitle (ean)
        ON DELETE CASCADE,
    CONSTRAINT FK_magazine_category
        FOREIGN KEY (titleId) REFERENCES magazinetitle (ean)
        ON DELETE CASCADE
);
-- 11) Create Reservation table
CREATE TABLE reservation (
    memberId        VARCHAR2(8)     NOT NULL,
    titleId         VARCHAR2(13)    NOT NULL,
    reservationDate DATE            NOT NULL,
    CONSTRAINT PK_reservation
        PRIMARY KEY (memberId, titleId),
    CONSTRAINT FK_reservation_member
        FOREIGN KEY (memberId) REFERENCES member (memberId)
);
-- 12) Create Invoice table
CREATE TABLE invoice (
    invoiceNo       VARCHAR2(10)    NOT NULL,
    memberId        VARCHAR2(8)     NOT NULL,
    invoiceDate     DATE            NOT NULL,
    totalInvoiced   NUMBER(4,2)     NOT NULL,
    CONSTRAINT PK_invoice PRIMARY KEY (invoiceNo),
    CONSTRAINT FK_invoice_member
        FOREIGN KEY (memberId) REFERENCES member (memberId)
        -- on delete no action (default behaviour)
        -- prevent deleting parent where there are children
        -- if there have been invoices issued for a member
        -- record for that member cannot be deleted from database
);
-- 13) Create CopyOnLoan table
CREATE TABLE copyonloan (
    copyNo          VARCHAR2(7)     NOT NULL,
    loanStartDate   DATE            NOT NULL,
    dueDate         DATE            NOT NULL,
    loanCharge      NUMBER(4,2)     NOT NULL,
    invoiceNo       VARCHAR(10)     NOT NULL,
    CONSTRAINT PK_copyonloan
        PRIMARY KEY (copyNo, loanStartDate),
    CONSTRAINT FK_copyonloan_invoice
        FOREIGN KEY (invoiceNo) REFERENCES invoice (invoiceNo)
);
-- 14) Create LoanArchive table
CREATE TABLE loanarchive(
    copyNo          VARCHAR2(7)     NOT NULL,
    loanStartDate   DATE            NOT NULL,    
    dueDate         DATE            NOT NULL,    
    dateReturned    DATE            NOT NULL,
    loanCharge      NUMBER(4,2)     NOT NULL,
    invoiceNo       VARCHAR2(10)    NOT NULL,
    CONSTRAINT PK_loanarchive
        PRIMARY KEY (copyno, loanStartDate),
    CONSTRAINT FK_loanarchive_invoice
        FOREIGN KEY (invoiceNo) REFERENCES invoice (invoiceNo)
);
-- 15) Create OverdueCharge table
CREATE TABLE overduecharge (
    copyNo              VARCHAR2(7)     NOT NULL,
    loanStartDate       DATE            NOT NULL,
    noDaysOverdue       NUMBER(4,0)     NOT NULL,
    overdueChargeAmount NUMBER(4,2)     NOT NULL,
    invoiceNo           VARCHAR2(10)    NOT NULL,
    CONSTRAINT PK_overduecharge
        PRIMARY KEY (copyNo, loanStartDate),
    CONSTRAINT FK_overduecharge_loanarchive
        FOREIGN KEY (copyNo, loanStartDate) REFERENCES loanarchive (copyNo, loanStartDate),
    CONSTRAINT FK_overduecharge_invoice
        FOREIGN KEY (invoiceNo) REFERENCES invoice (invoiceNo)
);
-- 16) Create DisposedCopyArchive table
CREATE TABLE disposedcopyarchive(
    copyNo          VARCHAR2(7)     NOT NULL,
    titleId         VARCHAR2(13)    NOT NULL,
    dateDisposedOf  DATE            NOT NULL,
    CONSTRAINT PK_disposedcopyarchive PRIMARY KEY (copyNo)
);