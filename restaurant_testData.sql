delete from nkcs_schedule;
delete from nkcs_order_item;
delete from nkcs_personnel;
delete from nkcs_location;
delete from nkcs_reservasion;
delete from nkcs_table;
delete from nkcs_menu_sale;
delete from nkcs_menu;
delete from nkcs_category;
delete from nkcs_order;
delete from nkcs_account_item;
delete from nkcs_warehouse_log;
delete from nkcs_warehouse;
delete from nkcs_message;
commit;
insert into nkcs_personnel(personnel_name,personnel_job,salary) values('����','����',10000);
insert into nkcs_personnel(personnel_name,personnel_job,salary) values('����','��ʦ',6000);
insert into nkcs_personnel(personnel_name,personnel_job,salary) values('�ŷ�','����Ա',6000);
insert into nkcs_personnel(personnel_name,personnel_job,salary) values('�����','����Ա',7000);
insert into nkcs_personnel(personnel_name,personnel_job,salary) values('����','����Ա',5000);
insert into nkcs_personnel(personnel_name,personnel_job,salary) values('��','��๤',4000);
insert into nkcs_personnel(personnel_name,personnel_job,salary) values('����','��๤',3000);
insert into nkcs_personnel(personnel_name,personnel_job,salary) values('��ͳ','��๤',3500);

--��������ʱ���֪��id�Ӷ�ȷ��λ��
insert into nkcs_table(people_number) values(2);
insert into nkcs_table(people_number) values(2);
insert into nkcs_table(people_number) values(2);
insert into nkcs_table(people_number) values(2);
insert into nkcs_table(people_number) values(4);
insert into nkcs_table(people_number) values(4);
insert into nkcs_table(people_number) values(4);
insert into nkcs_table(people_number) values(8);
insert into nkcs_table(people_number) values(8);

insert into nkcs_location(table_id,floor,x,y) values(1,1,1,1);
insert into nkcs_location(table_id,floor,x,y) values(2,1,1,3);
insert into nkcs_location(table_id,floor,x,y) values(3,1,1,5);
insert into nkcs_location(table_id,floor,x,y) values(4,1,1,7);
insert into nkcs_location(table_id,floor,x,y) values(5,1,3,1);
insert into nkcs_location(table_id,floor,x,y) values(6,1,3,5);
insert into nkcs_location(table_id,floor,x,y) values(7,1,3,9);
insert into nkcs_location(table_id,floor,x,y) values(8,2,1,1);
insert into nkcs_location(table_id,floor,x,y) values(9,2,5,1);

insert into nkcs_reservasion(table_id,people_number,customer_name,customer_telephone,starttime,endtime)
    values(2,2,'�ܲ�','13111112222',to_date('2016-04-14 08:40:00','yyyy-mm-dd hh24:mi:ss'),
    to_date('2016-04-14 10:00:00','yyyy-mm-dd hh24:mi:ss'));
insert into nkcs_reservasion(table_id,people_number,customer_name,customer_telephone,starttime,endtime)
    values(1,2,'��Ȩ','13111112222',to_date('2016-04-14 08:40:00','yyyy-mm-dd hh24:mi:ss'),
    to_date('2016-04-14 10:00:00','yyyy-mm-dd hh24:mi:ss'));
insert into nkcs_reservasion(table_id,people_number,customer_name,customer_telephone,starttime,endtime)
    values(3,2,'��ا','13111112222',to_date('2016-04-14 09:40:00','yyyy-mm-dd hh24:mi:ss'),
    to_date('2016-04-14 10:00:00','yyyy-mm-dd hh24:mi:ss'));
insert into nkcs_reservasion(table_id,people_number,customer_name,customer_telephone,starttime,endtime)
    values(1,2,'��ا','13111112222',to_date('2016-04-14 09:40:00','yyyy-mm-dd hh24:mi:ss'),
    to_date('2016-04-14 10:00:00','yyyy-mm-dd hh24:mi:ss'));
    
insert into nkcs_category(category_name) values('��ʳ');
insert into nkcs_category(category_name) values('����');
insert into nkcs_category(category_name) values('����');
insert into nkcs_category(category_name) values('�Ȳ�');

insert into nkcs_menu(dish_name,category_id,price) values('���������',1,50);
insert into nkcs_menu(dish_name,category_id,price) values('è���Ž���',1,20);
insert into nkcs_menu(dish_name,category_id,price) values('������',3,30);
insert into nkcs_menu(dish_name,category_id,price) values('��������˿',2,20);
insert into nkcs_menu(dish_name,category_id,price) values('������˿',4,30);
insert into nkcs_menu(dish_name,category_id,price) values('�Ǵ��Ｙ',4,20);

insert into nkcs_schedule values(3,1,to_date('2016-04-14','yyyy-mm-dd'),'morning');
insert into nkcs_schedule values(4,1,to_date('2016-04-14','yyyy-mm-dd'),'morning');
insert into nkcs_schedule values(3,2,to_date('2016-04-14','yyyy-mm-dd'),'afternoon');
    
--�������1
    --������ţ�
insert into nkcs_order(table_id) values(1);
select * from nkcs_order;
    --��ö����ţ����
insert into nkcs_order_item(order_id,dish_id,quantity) values(1,1,2);
insert into nkcs_order_item(order_id,dish_id,quantity) values(1,2,1);
insert into nkcs_order_item(order_id,dish_id,quantity) values(1,3,3);
delete from nkcs_order_item where order_id=1 and dish_id=2;
update nkcs_order_item set quantity=2 where order_id=1 and dish_id=3;
select * from nkcs_order;
select * from nkcs_order_item;
    --�ύ����
update nkcs_order set status='waiting' where order_id=1;
select * from nkcs_order;
select * from nkcs_order_item;
    --��ʦ����
update nkcs_order_item set status='cooking' where order_id=1 and dish_id=1;
update nkcs_order_item set status='cooking' where order_id=1 and dish_id=3;
select * from nkcs_order_item;
    --���
update nkcs_order_item set status='finished' where order_id=1 and dish_id=1;
update nkcs_order_item set status='finished' where order_id=1 and dish_id=3;
update nkcs_order set status='completed' where order_id=1;
select * from nkcs_order;
select * from nkcs_order_item;
    --����
update nkcs_order set status='paid' where order_id=1;
select * from nkcs_order;
select * from nkcs_menu_sale;
select * from nkcs_account_item;

--�ֿ����(����д���ۣ��������ã�
insert into nkcs_warehouse_log(LOG_name,quantity,unit_price) values('��',100,1);
insert into nkcs_warehouse_log(LOG_name,quantity,unit_price) values('��',50,1.5);
insert into nkcs_warehouse_log(LOG_name,quantity) values('��',-50);
insert into nkcs_warehouse_log(LOG_name,quantity) values('��',-150);
insert into nkcs_warehouse_log(LOG_name,quantity) values('��',100);
select * from nkcs_account_item;
select * from nkcs_warehouse_log;
select * from nkcs_warehouse;

select * from nkcs_personnel;
select * from nkcs_table;
select * from nkcs_location;
select * from nkcs_category;
select * from nkcs_menu;
select * from nkcs_reservasion;
select * from nkcs_schedule;
select * from nkcs_order;
select * from nkcs_order_item;
select * from nkcs_menu_sale;
select * from nkcs_account_item;
select * from nkcs_warehouse_log;
select * from nkcs_warehouse;
