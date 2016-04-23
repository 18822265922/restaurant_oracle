DROP TABLE SCHEDULE PURGE;
DROP TABLE ORDER_ITEM PURGE;
DROP TABLE LOCATION PURGE;
DROP TABLE RESERVASION PURGE;
DROP TABLE MENU_SALE PURGE;
DROP TABLE PERSONNEL PURGE;
DROP TABLE MYORDER PURGE;
DROP TABLE DINING_TABLE PURGE;
DROP TABLE MENU PURGE;
DROP TABLE ACCOUNT_ITEM PURGE;
DROP TABLE WAREHOUSE_LOG PURGE;
DROP TABLE WAREHOUSE PURGE;
DROP TABLE MESSAGE PURGE;

DROP SEQUENCE PERSONNEL_ID_SEQ;
DROP SEQUENCE DINING_TABLE_ID_SEQ;
DROP SEQUENCE MENU_ID_SEQ;
DROP SEQUENCE MYORDER_ID_SEQ;
DROP SEQUENCE ACCOUNT_ITEM_ID_SEQ;
DROP SEQUENCE WAREHOUSE_LOG_ID_SEQ;
DROP SEQUENCE WAREHOUSE_ID_SEQ;
DROP SEQUENCE MESSAGE_ID_SEQ;

CREATE TABLE PERSONNEL (
	id		    INTEGER,
	name		  VARCHAR2(30) NOT NULL,
	job		    VARCHAR2(30) NOT NULL,
	salary		NUMBER(7,2) NOT NULL,
	status		VARCHAR2(1000),           --记录打卡信息
	CONSTRAINT pk_personnelid PRIMARY KEY(id),
  CONSTRAINT ck_personnel_salary 	check(salary>0)
);

CREATE TABLE DINING_TABLE(
	id		        INTEGER,
	status		    VARCHAR2(10),       --free,reserved,dirty,occupied
	people_number	INTEGER NOT NULL,
	CONSTRAINT pk_tableid PRIMARY KEY(id),
  CONSTRAINT ck_table_peoplenumber check(people_number between 1 and 20),
  CONSTRAINT ck_table_status check (status in ('free','reserved','dirty','occupied'))
);

CREATE TABLE LOCATION(
	id		  INTEGER NOT NULL,
	floor		INTEGER NOT NULL,
	x		    NUMBER(7,2) NOT NULL,
	y		    NUMBER(7,2) NOT NULL,
	CONSTRAINT pk_locationid PRIMARY KEY(id),
	CONSTRAINT fk_locationid FOREIGN KEY(id) REFERENCES DINING_TABLE(id),
  CONSTRAINT ck_location_floor check(floor>0),
  CONSTRAINT ck_location_x  check(x>0),
  CONSTRAINT ck_location_y  check(y>0)
);

CREATE TABLE RESERVASION(
	id		              INTEGER NOT NULL,
	people_number	      INTEGER NOT NULL,
  customer_name       VARCHAR2(30) NOT NULL,
  customer_telephone  VARCHAR2(11) NOT NULL,
	starttime	          DATE NOT NULL,
	endtime		          DATE NOT NULL,
	CONSTRAINT pk_reservasionid_time PRIMARY KEY(id,starttime),
	CONSTRAINT fk_reservasionid FOREIGN KEY(id) REFERENCES DINING_TABLE(id),
	CONSTRAINT ck_reservasion_time 	check(starttime<endtime),
  CONSTRAINT ck_reservasion_peoplenumber check(people_number between 1 and 20)
);

CREATE TABLE MENU(
	id		      INTEGER,
	name		    VARCHAR2(30) NOT NULL,
	category	  VARCHAR2(30) NOT NULL,
	price		    NUMBER(7,2) NOT NULL,
  updatetime	DATE NOT NULL,
	CONSTRAINT pk_menuid PRIMARY KEY(id),
  CONSTRAINT ck_menu_price check(price>0)
);

CREATE TABLE MYORDER(
  id		          INTEGER,
  paid_date       DATE,
  payment         NUMBER(7,2),
  status          VARCHAR2(10),        --ordering,waiting,completed,paid
  wait_starttime  DATE,
  wait_endtime    DATE,
  table_id        INTEGER NOT NULL,
  CONSTRAINT pk_orderid PRIMARY KEY(id),
  CONSTRAINT fk_order_tableid FOREIGN KEY(table_id) REFERENCES DINING_TABLE(id),
  CONSTRAINT ck_order_status check (status in ('ordering','waiting','completed','paid'))
);

CREATE TABLE MENU_SALE(
  id              INTEGER NOT NULL,
  sale_date       DATE NOT NULL,
  saleQuantity    INTEGER,
  CONSTRAINT pk_menu_saleid_time PRIMARY KEY(id,sale_date),
  CONSTRAINT fk_menu_saleid FOREIGN KEY(id) REFERENCES MENU(id),
  CONSTRAINT ck_menu_sale_quantity check(saleQuantity>0)
);

CREATE TABLE ACCOUNT_ITEM(
  id            INTEGER,
  record_date   DATE NOT NULL,
  profit        NUMBER(7,2),
  loss          NUMBER(7,2),
  CONSTRAINT pk_account_item_id PRIMARY KEY(id),
  CONSTRAINT ck_account_item_profit check(profit>0),
  CONSTRAINT ck_account_item_loss   check(loss>0)
);

CREATE TABLE WAREHOUSE_LOG(
  id          INTEGER,
  name        VARCHAR2(30) NOT NULL,
  quantity    INTEGER NOT NULL,
  record_date DATE,
  unit_price  NUMBER(7,2) NOT NULL,
  CONSTRAINT pk_warehouse_log_id PRIMARY KEY(id),
  CONSTRAINT ck_warehouse_log_quantity check(quantity>0),
  CONSTRAINT ck_warehouse_log_unitprice check(unit_price>0)
);

CREATE TABLE WAREHOUSE(
  id        INTEGER,
  name      VARCHAR2(30),
  quantity  INTEGER,
  CONSTRAINT pk_warehouse_id PRIMARY KEY(id)
);

CREATE TABLE MESSAGE(
  id                  INTEGER,
  customer_name       VARCHAR2(30),
  customer_telephone  VARCHAR2(11),
  message_date      DATE NOT NULL,
  message_type        VARCHAR2(50) NOT NULL,
  description         VARCHAR2(150) NOT NULL,
  CONSTRAINT pk_message_id PRIMARY KEY(id),
  CONSTRAINT ck_message_type check (message_type in ('ingredients shortage','change shifts','customer complaints','employee advise'))
);

--关系集schedule
CREATE TABLE SCHEDULE(
  waiter_id   INTEGER NOT NULL,
  table_id    INTEGER NOT NULL,
  work_date   DATE NOT NULL,
  period      VARCHAR2(50) NOT NULL,
  CONSTRAINT pk_schedule PRIMARY KEY(waiter_id,table_id,work_date),
  CONSTRAINT fk_schedule_waiterid FOREIGN KEY(waiter_id) REFERENCES PERSONNEL(id),
  CONSTRAINT fk_schedule_tableid FOREIGN KEY(table_id) REFERENCES DINING_TABLE(id),
  CONSTRAINT ck_schedule_period check (period in ('morning','afternoon','night','morning_afternoon','morning_night','afternoon_night','all_day'))
);

--关系集order_item
CREATE TABLE ORDER_ITEM(
  order_id      INTEGER NOT NULL,
  dish_id       INTEGER NOT NULL,
  quantity      INTEGER NOT NULL,
  status        VARCHAR2(10),    --ordering,preparing,cooking,finished
  each_payment  NUMBER(7,2),
  CONSTRAINT pk_orderitem_order_dish PRIMARY KEY(order_id,dish_id),
  CONSTRAINT fk_orderitem_orderid FOREIGN KEY(order_id) REFERENCES MYORDER(id),
  CONSTRAINT fk_orderitem_dishid FOREIGN KEY(dish_id) REFERENCES MENU(id),
  CONSTRAINT ck_orderitem_quantity check(quantity>0),
  CONSTRAINT ck_orderitem_status check (status in ('ordering','preparing','cooking','finished'))
);

--自增长序列personnel（可自定义id）
CREATE SEQUENCE PERSONNEL_ID_SEQ 
MINVALUE 1 
NOMAXVALUE 
INCREMENT BY 1 
START WITH 1
NOCACHE; 
CREATE OR REPLACE TRIGGER PERSONNEL_INS_TRG 
BEFORE INSERT ON PERSONNEL 
FOR EACH ROW 
BEGIN
    if :NEW.id is null then
        SELECT PERSONNEL_ID_SEQ.NEXTVAL INTO :NEW.id FROM DUAL;
    end if;
END;

--自增长序列dining_table（可自定义id）
CREATE SEQUENCE DINING_TABLE_ID_SEQ 
MINVALUE 1 
NOMAXVALUE 
INCREMENT BY 1 
START WITH 1 
NOCACHE; 
CREATE OR REPLACE TRIGGER DINING_TABLE_INS_TRG 
BEFORE INSERT ON DINING_TABLE 
FOR EACH ROW 
DECLARE
    v_table_status_exp    exception;
BEGIN
    if :NEW.id is null then
        SELECT DINING_TABLE_ID_SEQ.NEXTVAL INTO :NEW.id FROM DUAL;
    end if;
    --初始化状态
    if :NEW.status is null then
        :NEW.status:='free';
    else
        if :NEW.status<>'free' then
            raise v_table_status_exp;
        end if;
    end if;
END;

--自增长序列menu
CREATE SEQUENCE MENU_ID_SEQ 
MINVALUE 1 
NOMAXVALUE 
INCREMENT BY 1 
START WITH 1 
NOCACHE; 
CREATE OR REPLACE TRIGGER MENU_INS_TRG 
BEFORE INSERT ON MENU 
FOR EACH ROW 
BEGIN
    SELECT MENU_ID_SEQ.NEXTVAL INTO :NEW.id FROM DUAL;
    select sysdate into :NEW.updatetime from dual;
END;

--自增长序列myorder,插入时状态只能为ordering
CREATE SEQUENCE MYORDER_ID_SEQ 
MINVALUE 1 
NOMAXVALUE 
INCREMENT BY 1 
START WITH 1 
NOCACHE; 
CREATE OR REPLACE TRIGGER MYORDER_INS_TRG 
BEFORE INSERT ON MYORDER 
FOR EACH ROW 
DECLARE
    v_myorder_status_exp    exception;
BEGIN
    SELECT MYORDER_ID_SEQ.NEXTVAL INTO :NEW.id FROM DUAL;
    if :NEW.status is null then
        :NEW.status:='ordering';
    else
        if :NEW.status<>'ordering' then
            raise v_myorder_status_exp;
        end if;
    end if;
END;

--计算订单金额，改变订单状态
CREATE OR REPLACE TRIGGER MYORDER_INS_TRG_BEFORE 
BEFORE UPDATE ON MYORDER 
FOR EACH ROW 
DECLARE
    ordering_status       VARCHAR2(10);
    waiting_status        VARCHAR2(10);
    completed_status      VARCHAR2(10);
    paid_status           VARCHAR2(10);
    total_payment         NUMBER(7,2);
    v_myorder_status_exp  exception;
    
BEGIN
    total_payment:=0;
    ordering_status:='ordering';
    waiting_status:='waiting';
    completed_status:='completed';
    paid_status:='paid';
    
    if :NEW.status is null then
        raise v_myorder_status_exp;
    end if;
    if ordering_status=:NEW.status then
        raise v_myorder_status_exp;
    elsif waiting_status=:NEW.status then
        if :OLD.status<>ordering_status then
            raise v_myorder_status_exp;
        end if;
        update order_item set status='preparing' where order_id=:OLD.id;
        select sysdate into :NEW.wait_starttime from dual;
    elsif completed_status=:NEW.status then
        if :OLD.status<>waiting_status then
            raise v_myorder_status_exp;
        end if;
        select sysdate into :NEW.wait_endtime from dual;
    elsif paid_status=:NEW.status then  
        if :OLD.status<>completed_status then
            raise v_myorder_status_exp;
        end if;
        select sum(each_payment) into :NEW.payment from order_item where order_id=:OLD.id;
        select sysdate into :NEW.paid_date from dual;
    else
        raise v_myorder_status_exp;
    end if;
END;

--关系profit_details
CREATE OR REPLACE TRIGGER MYORDER_INS_TRG_AFTER 
AFTER UPDATE ON MYORDER 
FOR EACH ROW 
DECLARE
    paid_status   VARCHAR2(10);
BEGIN
    paid_status:='paid';
    if paid_status=:NEW.status then
        insert into account_item(record_date,profit) values(:NEW.paid_date,:NEW.payment);       
    end if;
END;

--order_item status
CREATE OR REPLACE TRIGGER ORDERITEM_INS_TRG 
BEFORE INSERT ON ORDER_ITEM 
FOR EACH ROW 
DECLARE
    v_orderitem_status_exp    exception;
    each_price                NUMBER(7,2);
BEGIN
    if :NEW.status is null then
        :NEW.status:='ordering';
    else
        if :NEW.status<>'ordering' then
            raise v_orderitem_status_exp;
        end if;
    end if;
    --计算单项价格
    select price into each_price from menu where id=:NEW.dish_id;
    :NEW.each_payment:=each_price*:NEW.quantity;
END;

CREATE OR REPLACE TRIGGER ORDERITEM_INS_TRG_UPDATE 
BEFORE UPDATE ON ORDER_ITEM 
FOR EACH ROW 
DECLARE
    v_orderitem_status_exp    exception;
    ordering_status           VARCHAR2(10);
    preparing_status          VARCHAR2(10);
    cooking_status            VARCHAR2(10);
    finished_status           VARCHAR2(10);
    each_price                NUMBER(7,2);
BEGIN
    ordering_status:='ordering';
    preparing_status:='preparing';
    cooking_status:='cooking';
    finished_status:='finished';
    
    if :NEW.status=ordering_status then
        if :OLD.status<>ordering_status then
            raise v_orderitem_status_exp;
        end if;
        select price into each_price from menu where id=:NEW.dish_id;
        :NEW.each_payment:=each_price*:NEW.quantity;
    elsif :NEW.status=preparing_status then
        if :OLD.status<>ordering_status then
            raise v_orderitem_status_exp;
        end if;
    elsif :NEW.status=cooking_status then
        if :OLD.status<>preparing_status then
            raise v_orderitem_status_exp;
        end if;
    elsif :NEW.status=finished_status then
        if :OLD.status<>cooking_status then
            raise v_orderitem_status_exp;
        end if;
    else
        raise v_orderitem_status_exp;
    end if;
END;

--自增长序列account_item
CREATE SEQUENCE ACCOUNT_ITEM_ID_SEQ 
MINVALUE 1 
NOMAXVALUE 
INCREMENT BY 1 
START WITH 1 
NOCACHE; 
CREATE OR REPLACE TRIGGER ACCOUNT_ITEM_INS_TRG 
BEFORE INSERT ON ACCOUNT_ITEM 
FOR EACH ROW 
BEGIN
    SELECT ACCOUNT_ITEM_ID_SEQ.NEXTVAL INTO :NEW.id FROM DUAL;
END;

--自增长序列warehouse_log
CREATE SEQUENCE WAREHOUSE_LOG_ID_SEQ 
MINVALUE 1 
NOMAXVALUE 
INCREMENT BY 1 
START WITH 1 
NOCACHE; 
CREATE OR REPLACE TRIGGER WAREHOUSE_LOG_INS_TRG 
BEFORE INSERT ON WAREHOUSE_LOG 
FOR EACH ROW 
BEGIN
    SELECT WAREHOUSE_LOG_ID_SEQ.NEXTVAL INTO :NEW.id FROM DUAL;
    select sysdate into :NEW.record_date from dual;
END;

CREATE OR REPLACE TRIGGER WAREHOUSE_LOG_INS_TRG_AFTER 
AFTER INSERT ON WAREHOUSE_LOG 
FOR EACH ROW 
DECLARE
    current_quantity  INTEGER;
    add_quantity      INTEGER;
    loss_cal          NUMBER(7,2);
BEGIN
    select quantity into current_quantity from warehouse where name=:NEW.name;
    add_quantity:=:NEW.quantity;
    current_quantity:=current_quantity+add_quantity;
    update warehouse set warehouse.quantity=current_quantity where name=:NEW.name;         
    loss_cal:=(:NEW.quantity)*(:NEW.unit_price);
    insert into account_item(record_date,loss) values(:NEW.record_date,loss_cal);
EXCEPTION
    when no_data_found then
        insert into warehouse(name,quantity) values(:NEW.name,:NEW.quantity);
        loss_cal:=(:NEW.quantity)*(:NEW.unit_price);
        insert into account_item(record_date,loss) values(:NEW.record_date,loss_cal);
END;

--自增长序列warehouse
CREATE SEQUENCE WAREHOUSE_ID_SEQ 
MINVALUE 1 
NOMAXVALUE 
INCREMENT BY 1 
START WITH 1 
NOCACHE; 
CREATE OR REPLACE TRIGGER WAREHOUSE_INS_TRG 
BEFORE INSERT ON WAREHOUSE 
FOR EACH ROW 
BEGIN
    SELECT WAREHOUSE_ID_SEQ.NEXTVAL INTO :NEW.id FROM DUAL;
END;

--自增长序列customer_complaint
CREATE SEQUENCE MESSAGE_ID_SEQ 
MINVALUE 1 
NOMAXVALUE 
INCREMENT BY 1 
START WITH 1 
NOCACHE; 
CREATE OR REPLACE TRIGGER MESSAGE_INS_TRG 
BEFORE INSERT ON MESSAGE 
FOR EACH ROW 
BEGIN
    SELECT MESSAGE_ID_SEQ.NEXTVAL INTO :NEW.id FROM DUAL;
END;

--检验工作计划人员是否正确(服务员、清洁工）
CREATE OR REPLACE TRIGGER SCHEDULE_INS_TRG 
BEFORE INSERT ON SCHEDULE 
FOR EACH ROW 
DECLARE
    v_scheduleexp   exception;
    job_type        VARCHAR2(30);
BEGIN
    select job into job_type from personnel where id=:NEW.waiter_id;
    if job_type<>'服务员' and job_type<>'清洁工' then
        raise v_scheduleexp;
    end if;
END;  

--检验预订时间
CREATE OR REPLACE TRIGGER RESERVASION_INS_TRG 
BEFORE INSERT ON RESERVASION 
FOR EACH ROW 
DECLARE
  	cursor cur_reservasion_time is select id,starttime,endtime from reservasion;
  	v_reservasionRowtime cur_reservasion_time%ROWTYPE;
    v_reservasiontimeexp    exception;
    v_reservasionnumexp     exception;
    max_people_number       INTEGER;
BEGIN
    select people_number into max_people_number from dining_table where id=:NEW.id;
    if :NEW.people_number>max_people_number then
        raise v_reservasionnumexp;
    end if;

  	if cur_reservasion_time%isopen then
  	  	null;
  	else
        open cur_reservasion_time;
  	end if;
  	fetch cur_reservasion_time into v_reservasionRowtime;
  	while cur_reservasion_time%found loop 
        if v_reservasionRowtime.id=:NEW.id then   
            if :NEW.starttime between v_reservasionRowtime.starttime and v_reservasionRowtime.endtime then
                raise v_reservasiontimeexp;
            end if;
            if :NEW.endtime between v_reservasionRowtime.starttime and v_reservasionRowtime.endtime then
                raise v_reservasiontimeexp;
            end if; 
        end if;
    		fetch cur_reservasion_time into v_reservasionRowtime;
  	end loop;
  	close cur_reservasion_time;	
END;

--关系集change 和 loss_details

DESC PERSONNEL;
DESC ORDER_ITEM;
SELECT * FROM USER_CONSTRAINTS;
SELECT * FROM USER_SEQUENCES;
SELECT * FROM USER_TRIGGERS;