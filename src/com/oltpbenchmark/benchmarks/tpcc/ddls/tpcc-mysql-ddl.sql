-- woonhak, turn off foreign key check, reference tpcc-mysql and tpcc specification
set @old_unique_checks=@@unique_checks, unique_checks=0;
set @old_foreign_key_checks=@@foreign_key_checks, foreign_key_checks=0;

drop table if exists customer;
drop table if exists district;
drop table if exists history;
drop table if exists item;
drop table if exists new_order;
drop table if exists oorder;
drop table if exists order_line;
drop table if exists stock;
drop table if exists warehouse;


create table heartbeat (
  heartbeat_id int not null AUTO_INCREMENT,
  master_ts timestamp not null,
  slave_ts timestamp not null,
  primary key (heartbeat_id)
);



create table customer (
  c_w_id int not null,
  c_d_id int not null,
  c_id int not null,
  c_discount decimal(4,4) not null,
  c_credit char(2) not null,
  c_last varchar(16) not null,
  c_first varchar(16) not null,
  c_credit_lim decimal(12,2) not null,
  c_balance decimal(12,2) not null,
  c_ytd_payment float not null,
  c_payment_cnt int not null,
  c_delivery_cnt int not null,
  c_street_1 varchar(20) not null,
  c_street_2 varchar(20) not null,
  c_city varchar(20) not null,
  c_state char(2) not null,
  c_zip char(9) not null,
  c_phone char(16) not null,
  c_since timestamp not null default current_timestamp,
  c_middle char(2) not null,
  c_data varchar(500) not null,
  primary key (c_w_id,c_d_id,c_id)
);


create table district (
  d_w_id int not null,
  d_id int not null,
  d_ytd decimal(12,2) not null,
  d_tax decimal(4,4) not null,
  d_next_o_id int not null,
  d_name varchar(10) not null,
  d_street_1 varchar(20) not null,
  d_street_2 varchar(20) not null,
  d_city varchar(20) not null,
  d_state char(2) not null,
  d_zip char(9) not null,
  primary key (d_w_id,d_id)
);

-- todo: h_date on update current_timestamp

create table history (
  h_c_id int not null,
  h_c_d_id int not null,
  h_c_w_id int not null,
  h_d_id int not null,
  h_w_id int not null,
  h_date timestamp not null default current_timestamp,
  h_amount decimal(6,2) not null,
  h_data varchar(24) not null
);


create table item (
  i_id int not null,
  i_name varchar(24) not null,
  i_price decimal(5,2) not null,
  i_data varchar(50) not null,
  i_im_id int not null,
  primary key (i_id)
);


create table new_order (
  no_w_id int not null,
  no_d_id int not null,
  no_o_id int not null,
  primary key (no_w_id,no_d_id,no_o_id)
);

-- todo: o_entry_d  on update current_timestamp

create table oorder (
  o_w_id int not null,
  o_d_id int not null,
  o_id int not null,
  o_c_id int not null,
  o_carrier_id int default null,
  o_ol_cnt decimal(2,0) not null,
  o_all_local decimal(1,0) not null,
  o_entry_d timestamp not null default current_timestamp,
  primary key (o_w_id,o_d_id,o_id),
  unique (o_w_id,o_d_id,o_c_id,o_id)
);


create table order_line (
  ol_w_id int not null,
  ol_d_id int not null,
  ol_o_id int not null,
  ol_number int not null,
  ol_i_id int not null,
  ol_delivery_d timestamp null default null,
  ol_amount decimal(6,2) not null,
  ol_supply_w_id int not null,
  ol_quantity decimal(2,0) not null,
  ol_dist_info char(24) not null,
  primary key (ol_w_id,ol_d_id,ol_o_id,ol_number)
);

create table stock (
  s_w_id int not null,
  s_i_id int not null,
  s_quantity decimal(4,0) not null,
  s_ytd decimal(8,2) not null,
  s_order_cnt int not null,
  s_remote_cnt int not null,
  s_data varchar(50) not null,
  s_dist_01 char(24) not null,
  s_dist_02 char(24) not null,
  s_dist_03 char(24) not null,
  s_dist_04 char(24) not null,
  s_dist_05 char(24) not null,
  s_dist_06 char(24) not null,
  s_dist_07 char(24) not null,
  s_dist_08 char(24) not null,
  s_dist_09 char(24) not null,
  s_dist_10 char(24) not null,
  primary key (s_w_id,s_i_id)
);

create table warehouse (
  w_id int not null,
  w_ytd decimal(12,2) not null,
  w_tax decimal(4,4) not null,
  w_name varchar(10) not null,
  w_street_1 varchar(20) not null,
  w_street_2 varchar(20) not null,
  w_city varchar(20) not null,
  w_state char(2) not null,
  w_zip char(9) not null,
  primary key (w_id)
);

-- indexes
create index idx_customer_name on customer (c_w_id,c_d_id,c_last,c_first);

-- woohak, add constraints. mysql/innodb storage engine is kind of iot.
-- and add constraints and make indexes later aretoo slow when running a single thread.
-- so i just add create index and foreign key constraints before loading data.

-- already created
-- create index idx_customer on customer (c_w_id,c_d_id,c_last,c_first);
create index idx_order on oorder (o_w_id,o_d_id,o_c_id,o_id);
-- tpcc-mysql create two indexes for the foreign key constraints, is it really necessary?
-- create index fkey_stock_2 on stock (s_i_id);
-- create index fkey_order_line_2 on order_line (ol_supply_w_id,ol_i_id);

-- add 'on delete cascade'  to clear table work correctly

alter table district  add constraint fkey_district_1 foreign key(d_w_id) references warehouse(w_id) on delete cascade;
alter table customer add constraint fkey_customer_1 foreign key(c_w_id,c_d_id) references district(d_w_id,d_id)  on delete cascade ;
alter table history  add constraint fkey_history_1 foreign key(h_c_w_id,h_c_d_id,h_c_id) references customer(c_w_id,c_d_id,c_id) on delete cascade;
alter table history  add constraint fkey_history_2 foreign key(h_w_id,h_d_id) references district(d_w_id,d_id) on delete cascade;
alter table new_order add constraint fkey_new_order_1 foreign key(no_w_id,no_d_id,no_o_id) references oorder(o_w_id,o_d_id,o_id) on delete cascade;
alter table oorder add constraint fkey_order_1 foreign key(o_w_id,o_d_id,o_c_id) references customer(c_w_id,c_d_id,c_id) on delete cascade;
alter table order_line add constraint fkey_order_line_1 foreign key(ol_w_id,ol_d_id,ol_o_id) references oorder(o_w_id,o_d_id,o_id) on delete cascade;
alter table order_line add constraint fkey_order_line_2 foreign key(ol_supply_w_id,ol_i_id) references stock(s_w_id,s_i_id) on delete cascade;
alter table stock add constraint fkey_stock_1 foreign key(s_w_id) references warehouse(w_id) on delete cascade;
alter table stock add constraint fkey_stock_2 foreign key(s_i_id) references item(i_id) on delete cascade;


set foreign_key_checks=@old_foreign_key_checks;
set unique_checks=@old_unique_checks;

