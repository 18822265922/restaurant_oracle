DROP SEQUENCE NKCS_PERSONNEL_ID_SEQ;
DROP SEQUENCE NKCS_TABLE_ID_SEQ;
DROP SEQUENCE NKCS_MENU_ID_SEQ;
DROP SEQUENCE NKCS_CATEGORY_ID_SEQ;
DROP SEQUENCE NKCS_ORDER_ID_SEQ;
DROP SEQUENCE NKCS_ACCOUNT_ITEM_ID_SEQ;
DROP SEQUENCE NKCS_WAREHOUSE_LOG_ID_SEQ;
DROP SEQUENCE NKCS_WAREHOUSE_ID_SEQ;
DROP SEQUENCE NKCS_MESSAGE_ID_SEQ;

--1.自增长序列NKCS_PERSONNEL（可自定义id）
CREATE SEQUENCE NKCS_PERSONNEL_ID_SEQ 
MINVALUE 1 
NOMAXVALUE 
INCREMENT BY 1 
START WITH 1
NOCACHE; 
CREATE OR REPLACE TRIGGER NKCS_PERSONNEL_INS_TRG_BI 
BEFORE INSERT ON NKCS_PERSONNEL 
FOR EACH ROW 
BEGIN
    if :NEW.personnel_id is null then
        SELECT NKCS_PERSONNEL_ID_SEQ.NEXTVAL INTO :NEW.personnel_id FROM DUAL;
    end if;
END;

--2.自增长序列NKCS_TABLE（可自定义id）
CREATE SEQUENCE NKCS_TABLE_ID_SEQ 
MINVALUE 1 
NOMAXVALUE 
INCREMENT BY 1 
START WITH 1 
NOCACHE; 
CREATE OR REPLACE TRIGGER NKCS_TABLE_INS_TRG_BI 
BEFORE INSERT ON NKCS_TABLE 
FOR EACH ROW 
DECLARE
    v_table_status_exp    exception;
BEGIN
    if :NEW.table_id is null then
        SELECT NKCS_TABLE_ID_SEQ.NEXTVAL INTO :NEW.table_id FROM DUAL;
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

--3.检验预订时间
CREATE OR REPLACE TRIGGER NKCS_RESERVASION_INS_TRG_BI 
BEFORE INSERT ON NKCS_RESERVASION 
FOR EACH ROW 
DECLARE
  	cursor cur_reservasion_time is select table_id,starttime,endtime from NKCS_RESERVASION;
  	v_reservasion_time_Row cur_reservasion_time%ROWTYPE;
    v_reservasion_time_exp    exception;
    v_reservasion_num_exp     exception;
    max_people_number         INTEGER;
BEGIN
    --检查预定人数是否符合
    select people_number into max_people_number from NKCS_TABLE where table_id=:NEW.table_id;
    if :NEW.people_number>max_people_number then
        raise v_reservasion_num_exp;
    end if;

    --检查预定时间
  	if cur_reservasion_time%isopen then
  	  	null;
  	else
        open cur_reservasion_time;
  	end if;
  	fetch cur_reservasion_time into v_reservasion_time_Row;
  	while cur_reservasion_time%found loop 
        if v_reservasion_time_Row.table_id=:NEW.table_id then   
            if :NEW.starttime between v_reservasion_time_Row.starttime and v_reservasion_time_Row.endtime then
                raise v_reservasion_time_exp;
            end if;
            if :NEW.endtime between v_reservasion_time_Row.starttime and v_reservasion_time_Row.endtime then
                raise v_reservasion_time_exp;
            end if; 
        end if;
    		fetch cur_reservasion_time into v_reservasion_time_Row;
  	end loop;
  	close cur_reservasion_time;	
END;

--4.自增长序列NKCS_CATEGORY
CREATE SEQUENCE NKCS_CATEGORY_ID_SEQ 
MINVALUE 1 
NOMAXVALUE 
INCREMENT BY 1 
START WITH 1 
NOCACHE; 
CREATE OR REPLACE TRIGGER NKCS_CATEGORY_INS_TRG_BI 
BEFORE INSERT ON NKCS_CATEGORY 
FOR EACH ROW 
BEGIN
    SELECT NKCS_CATEGORY_ID_SEQ.NEXTVAL INTO :NEW.category_id FROM DUAL;
END;
--4.2不允许改变id
CREATE OR REPLACE TRIGGER NKCS_CATEGORY_INS_TRG_BU
BEFORE INSERT ON NKCS_CATEGORY 
FOR EACH ROW 
DECLARE
    v_category_id_exp   exception;
BEGIN
    if :OLD.category_id<>:NEW.category_id then
        raise v_category_id_exp;
    end if;
END;

--5.自增长序列NKCS_MENU,记录更新时间
CREATE SEQUENCE NKCS_MENU_ID_SEQ 
MINVALUE 1 
NOMAXVALUE 
INCREMENT BY 1 
START WITH 1 
NOCACHE; 
CREATE OR REPLACE TRIGGER NKCS_MENU_INS_TRG_BI 
BEFORE INSERT ON NKCS_MENU 
FOR EACH ROW 
BEGIN
    SELECT NKCS_MENU_ID_SEQ.NEXTVAL INTO :NEW.dish_id FROM DUAL;
    select sysdate into :NEW.updatetime from dual;
END;
--5.2不允许改变id
CREATE OR REPLACE TRIGGER NKCS_MENU_INS_TRG_BU
BEFORE INSERT ON NKCS_MENU 
FOR EACH ROW 
DECLARE
    v_menu_id_exp   exception;
BEGIN
    if :OLD.dish_id<>:NEW.dish_id then
        raise v_menu_id_exp;
    end if;
END;

--6.自增长序列NKCS_ORDER,插入时状态只能为ordering
CREATE SEQUENCE NKCS_ORDER_ID_SEQ 
MINVALUE 1 
NOMAXVALUE 
INCREMENT BY 1 
START WITH 1 
NOCACHE; 
CREATE OR REPLACE TRIGGER NKCS_ORDER_INS_TRG_BI 
BEFORE INSERT ON NKCS_ORDER 
FOR EACH ROW 
DECLARE
    v_order_status_exp    exception;
BEGIN
    SELECT NKCS_ORDER_ID_SEQ.NEXTVAL INTO :NEW.order_id FROM DUAL;
    if :NEW.status is null then
        :NEW.status:='ordering';
    else
        if :NEW.status<>'ordering' then
            raise v_order_status_exp;
        end if;
    end if;
END;

--NKCS_MENU_SALE 记录
CREATE OR REPLACE PROCEDURE NKCS_MENU_SALE_PRO(paid_order_id in INTEGER) AS
    cursor cur_menu_sale is 
        select NKCS_MENU.dish_id,NKCS_ORDER_ITEM.quantity
        from NKCS_ORDER_ITEM,NKCS_MENU
        where NKCS_ORDER_ITEM.dish_id=NKCS_MENU.dish_id
            and NKCS_ORDER_ITEM.order_id=paid_order_id;
    v_menu_sale_Row cur_menu_sale%ROWTYPE;
    current_quantity    INTEGER;
    current_sale_date   DATE;
    exp_flag            INTEGER;--0:没有异常
BEGIN
    select sysdate into current_sale_date from dual;
    if cur_menu_sale%isopen then
        null;
    else
        open cur_menu_sale;
    end if;
    fetch cur_menu_sale into v_menu_sale_Row;
  	while cur_menu_sale%found loop 
        exp_flag:=0;
    BEGIN
        select sale_quantity into current_quantity 
            from NKCS_MENU_SALE 
            where dish_id=v_menu_sale_Row.dish_id and sale_date=current_sale_date;
    EXCEPTION
        when no_data_found then
            exp_flag:=1;
            insert into NKCS_MENU_SALE 
                values(v_menu_sale_Row.dish_id,current_sale_date,v_menu_sale_Row.quantity);
    END;
        if exp_flag=0 then
            current_quantity:=current_quantity+v_menu_sale_Row.quantity;
            update NKCS_MENU_SALE 
                set sale_quantity=current_quantity
                where dish_id=v_menu_sale_Row.dish_id 
                    and sale_date=current_sale_date;
    		end if;
        fetch cur_menu_sale into v_menu_sale_Row;
  	end loop;
  	close cur_menu_sale;	
END;

--6.2不允许改变id,计算订单金额，改变订单状态
CREATE OR REPLACE TRIGGER NKCS_ORDER_INS_TRG_BU 
BEFORE UPDATE ON NKCS_ORDER 
FOR EACH ROW 
DECLARE
    ordering_status       VARCHAR2(10);
    waiting_status        VARCHAR2(10);
    completed_status      VARCHAR2(10);
    paid_status           VARCHAR2(10);
    total_payment         NUMBER(7,2);
    v_order_status_exp    exception;
    v_order_id_exp   exception;
    
BEGIN
    total_payment:=0;
    ordering_status:='ordering';
    waiting_status:='waiting';
    completed_status:='completed';
    paid_status:='paid';
    --不允许改变id
    if :OLD.order_id<>:NEW.order_id then
        raise v_order_id_exp;
    end if;
    
    if :NEW.status is null then
        raise v_order_status_exp;
    end if;
    if ordering_status=:NEW.status then
        raise v_order_status_exp;
    elsif waiting_status=:NEW.status then
        if :OLD.status<>ordering_status then
            raise v_order_status_exp;
        end if;
        update NKCS_ORDER_ITEM set status='preparing' where order_id=:OLD.order_id;
        select sysdate into :NEW.wait_starttime from dual;
    elsif completed_status=:NEW.status then
        if :OLD.status<>waiting_status then
            raise v_order_status_exp;
        end if;
        select sysdate into :NEW.wait_endtime from dual;
    elsif paid_status=:NEW.status then  
        if :OLD.status<>completed_status then
            raise v_order_status_exp;
        end if;
        select sum(each_payment) into :NEW.payment from NKCS_ORDER_ITEM where order_id=:OLD.order_id;
        select sysdate into :NEW.paid_date from dual;
        --NKCS_MENU_SALE添加
        NKCS_MENU_SALE_PRO(:OLD.order_id);
    else
        raise v_order_status_exp;
    end if;
END;

--6.3.关系profit_details
CREATE OR REPLACE TRIGGER NKCS_ORDER_INS_TRG_AU 
AFTER UPDATE ON NKCS_ORDER 
FOR EACH ROW 
DECLARE
    paid_status   VARCHAR2(10);
BEGIN
    paid_status:='paid';
    if paid_status=:NEW.status then
        insert into NKCS_ACCOUNT_ITEM(record_date,profit) values(:NEW.paid_date,:NEW.payment);
    end if;
END;

--7.确定NKCS_ORDER_ITEM初始状态
CREATE OR REPLACE TRIGGER NKCS_ORDER_ITEM_INS_TRG_BI 
BEFORE INSERT ON NKCS_ORDER_ITEM 
FOR EACH ROW 
DECLARE
    v_order_item_status_exp   exception;
    each_price                NUMBER(7,2);
BEGIN
    --确定初始状态
    if :NEW.status is null then
        :NEW.status:='ordering';
    else
        if :NEW.status<>'ordering' then
            raise v_order_item_status_exp;
        end if;
    end if;
    --计算单项价格
    select price into each_price from NKCS_MENU where dish_id=:NEW.dish_id;
    :NEW.each_payment:=each_price*:NEW.quantity;
END;

--7.2.确定NKCS_ORDER_ITEM状态顺序
CREATE OR REPLACE TRIGGER NKCS_ORDER_ITEM_INS_TRG_BU 
BEFORE UPDATE ON NKCS_ORDER_ITEM 
FOR EACH ROW 
DECLARE
    v_order_item_status_exp    exception;
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
            raise v_order_item_status_exp;
        end if;
    elsif :NEW.status=preparing_status then
        if :OLD.status<>ordering_status then
            raise v_order_item_status_exp;
        end if;
    elsif :NEW.status=cooking_status then
        if :OLD.status<>preparing_status then
            raise v_order_item_status_exp;
        end if;
    elsif :NEW.status=finished_status then
        if :OLD.status<>cooking_status then
            raise v_order_item_status_exp;
        end if;
    else
        raise v_order_item_status_exp;
    end if;
    --计算价格
    select price into each_price from NKCS_MENU where dish_id=:NEW.dish_id;
    :NEW.each_payment:=each_price*:NEW.quantity;
END;

--8.NKCS_MENU_SALE 记录

--9.自增长序列account_item
CREATE SEQUENCE NKCS_ACCOUNT_ITEM_ID_SEQ 
MINVALUE 1 
NOMAXVALUE 
INCREMENT BY 1 
START WITH 1 
NOCACHE; 
CREATE OR REPLACE TRIGGER NKCS_ACCOUNT_ITEM_INS_TRG_BI 
BEFORE INSERT ON NKCS_ACCOUNT_ITEM 
FOR EACH ROW 
BEGIN
    SELECT NKCS_ACCOUNT_ITEM_ID_SEQ.NEXTVAL INTO :NEW.item_id FROM DUAL;
END;
--9.2不允许改变NKCS_ACCOUNT_ITEM
CREATE OR REPLACE TRIGGER NKCS_ACCOUNT_ITEM_INS_TRG_BU 
BEFORE UPDATE ON NKCS_ACCOUNT_ITEM 
FOR EACH ROW 
DECLARE
    v_account_item_exp    exception;
BEGIN
    raise v_account_item_exp;
END;

--10.自增长序列warehouse_log
CREATE SEQUENCE NKCS_WAREHOUSE_LOG_ID_SEQ 
MINVALUE 1 
NOMAXVALUE 
INCREMENT BY 1 
START WITH 1 
NOCACHE; 
CREATE OR REPLACE TRIGGER NKCS_WAREHOUSE_LOG_INS_TRG_BI 
BEFORE INSERT ON NKCS_WAREHOUSE_LOG 
FOR EACH ROW 
DECLARE
    v_warehouse_unitprice_exp  exception;
BEGIN
    if :NEW.quantity>0 then
        if :NEW.unit_price is null then
        raise v_warehouse_unitprice_exp;
        end if;
    end if;
    SELECT NKCS_WAREHOUSE_LOG_ID_SEQ.NEXTVAL INTO :NEW.log_id FROM DUAL;
    select sysdate into :NEW.record_date from dual;
END;

--10.2 关系集change 和 loss_details
CREATE OR REPLACE TRIGGER NKCS_WAREHOUSE_LOG_INS_TRG_AI 
AFTER INSERT ON NKCS_WAREHOUSE_LOG 
FOR EACH ROW 
DECLARE
    current_quantity          INTEGER;
    add_quantity              INTEGER;
    loss_cal                  NUMBER(7,2);
    v_warehouse_quantity_exp  exception;
BEGIN
    add_quantity:=:NEW.quantity;
    select quantity into current_quantity from NKCS_WAREHOUSE 
            where warehouse_item_name=:NEW.log_name;
    current_quantity:=current_quantity+add_quantity;
    if current_quantity<0 then
        raise v_warehouse_quantity_exp;
    end if;
    update NKCS_WAREHOUSE set NKCS_WAREHOUSE.quantity=current_quantity 
            where warehouse_item_name=:NEW.log_name;
    if add_quantity>0 then
        
        loss_cal:=(:NEW.quantity)*(:NEW.unit_price);
        insert into NKCS_ACCOUNT_ITEM(record_date,loss) 
            values(:NEW.record_date,loss_cal);
    elsif add_quantity=0 then       
        raise v_warehouse_quantity_exp;
    end if;
    
EXCEPTION
    when no_data_found then
        if add_quantity<0 then
            raise v_warehouse_quantity_exp;
        end if;
        insert into NKCS_WAREHOUSE(warehouse_item_name,quantity) values(:NEW.log_name,:NEW.quantity);
        loss_cal:=(:NEW.quantity)*(:NEW.unit_price);
        insert into NKCS_ACCOUNT_ITEM(record_date,loss) values(:NEW.record_date,loss_cal);
END;
--10.3不允许改变NKCS_WAREHOUSE_LOG
CREATE OR REPLACE TRIGGER NKCS_WAREHOUSE_LOG_INS_TRG_BU 
BEFORE UPDATE ON NKCS_WAREHOUSE_LOG 
FOR EACH ROW 
DECLARE
    v_warehouse_log_exp    exception;
BEGIN
    raise v_warehouse_log_exp;
END;

--11 自增长序列NKCS_WAREHOUSE
CREATE SEQUENCE NKCS_WAREHOUSE_ID_SEQ 
MINVALUE 1 
NOMAXVALUE 
INCREMENT BY 1 
START WITH 1 
NOCACHE; 
CREATE OR REPLACE TRIGGER NKCS_WAREHOUSE_INS_TRG_BI 
BEFORE INSERT ON NKCS_WAREHOUSE 
FOR EACH ROW 
BEGIN
    SELECT NKCS_WAREHOUSE_ID_SEQ.NEXTVAL INTO :NEW.warehouse_item_id FROM DUAL;
END;

--12自增长序列NKCS_MESSAGE
CREATE SEQUENCE NKCS_MESSAGE_ID_SEQ 
MINVALUE 1 
NOMAXVALUE 
INCREMENT BY 1 
START WITH 1 
NOCACHE; 
CREATE OR REPLACE TRIGGER NKCS_MESSAGE_INS_TRG 
BEFORE INSERT ON NKCS_MESSAGE 
FOR EACH ROW 
BEGIN
    SELECT NKCS_MESSAGE_ID_SEQ.NEXTVAL INTO :NEW.message_id FROM DUAL;
END;

--13检验工作计划人员是否正确(服务员、清洁工）
CREATE OR REPLACE TRIGGER NKCS_SCHEDULE_INS_TRG 
BEFORE INSERT ON NKCS_SCHEDULE 
FOR EACH ROW 
DECLARE
    v_schedule_exp   exception;
    job_type        VARCHAR2(30);
BEGIN
    select personnel_job into job_type from NKCS_PERSONNEL where personnel_id=:NEW.waiter_id;
    if job_type<>'服务员' and job_type<>'清洁工' then
        raise v_schedule_exp;
    end if;
END;  

