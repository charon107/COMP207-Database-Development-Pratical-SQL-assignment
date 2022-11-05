-- question 1
-- auto-generated definition

create table customers
(
    birth_day  date        not null,
    first_name varchar(20) not null,
    last_name  varchar(20) not null,
    c_id       int auto_increment
        primary key
);

-- auto-generated definition
create table employees
(
    birth_day  date        not null,
    first_name varchar(20) not null,
    last_name  varchar(20) not null,
    e_id       int auto_increment
        primary key
);

-- auto-generated definition
create table items
(
    price_for_each  int         not null,
    type            int         not null,
    amount_in_stock int         not null,
    name            varchar(20) not null
        primary key
);

-- auto-generated definition
create table transactions
(
    e_id int  not null,
    c_id int  not null,
    date date not null,
    t_id int auto_increment
        primary key,
    constraint Transactions_FK
        foreign key (c_id) references customers (c_id),
    constraint Transactions_FK_1
        foreign key (e_id) references employees (e_id)
);

-- auto-generated definition
create table itemsintransactions
(
    name   varchar(20) not null,
    t_id   int         not null,
    iit_id int         not null
        primary key,
    constraint ItemsInTransactions_FK
        foreign key (name) references items (name),
    constraint ItemsInTransactions_FK_1
        foreign key (t_id) references transactions (t_id)
);

-- auto-generated definition
create table promotion
(
    number_to_buy     int not null,
    how_many_are_free int not null,
    type              int not null
        primary key
);





-- question 2

create definer = root@localhost view louistransactions as
select count(0) AS `number_of_transactions`
from `cs_store`.`employees`
         join `cs_store`.`transactions`
where ((`cs_store`.`employees`.`first_name` = 'Louis') and (`cs_store`.`employees`.`last_name` = 'Davies') and
       (`cs_store`.`employees`.`e_id` = `cs_store`.`transactions`.`e_id`) and
       (year(`cs_store`.`transactions`.`date`) = '2022') and (month(`cs_store`.`transactions`.`date`) = '09'));

-- question 3

create definer = root@localhost view peopleinshop as
select `cs_store`.`employees`.`birth_day`  AS `birth_day`,
       `cs_store`.`employees`.`first_name` AS `first_name`,
       `cs_store`.`employees`.`last_name`  AS `last_name`
from `cs_store`.`employees`
         join `cs_store`.`transactions`
where ((`cs_store`.`employees`.`e_id` = `cs_store`.`transactions`.`e_id`) and
       (year(`cs_store`.`transactions`.`date`) = '2022') and (month(`cs_store`.`transactions`.`date`) = '09') and
       (dayofmonth(`cs_store`.`transactions`.`date`) = '28'))
union
select `cs_store`.`customers`.`birth_day`  AS `birth_day`,
       `cs_store`.`customers`.`first_name` AS `first_name`,
       `cs_store`.`customers`.`last_name`  AS `last_name`
from `cs_store`.`customers`
         join `cs_store`.`transactions`
where ((`cs_store`.`customers`.`c_id` = `cs_store`.`transactions`.`c_id`) and
       (year(`cs_store`.`transactions`.`date`) = '2022') and (month(`cs_store`.`transactions`.`date`) = '09') and
       (dayofmonth(`cs_store`.`transactions`.`date`) = '28'))
order by `birth_day`;


-- question 4

create definer = root@localhost view view1question4 as
select `cs_store`.`itemsintransactions`.`name` AS `name`, count(0) AS `amount`
from `cs_store`.`itemsintransactions`
group by `cs_store`.`itemsintransactions`.`name`;


create definer = root@localhost view itemsleft1 as
select `cs_store`.`items`.`name`                                        AS `name`,
       `cs_store`.`items`.`type`                                        AS `type`,
       (`cs_store`.`items`.`amount_in_stock` - `cs_store`.`v`.`amount`) AS `amount_left`
from (`cs_store`.`items` left join `cs_store`.`view1question4` `v`
      on ((`cs_store`.`items`.`name` = `cs_store`.`v`.`name`)))
where ((`cs_store`.`items`.`type` = '1') or (`cs_store`.`items`.`type` = '2'))
order by `cs_store`.`items`.`type`;

-- question 5

create definer = root@localhost view itemsleft2 as
select `cs_store`.`items`.`name`                                                       AS `name`,
       `cs_store`.`items`.`type`                                                       AS `type`,
       (`cs_store`.`items`.`amount_in_stock` - coalesce(`cs_store`.`v`.`amount`, '0')) AS `amount_left`
from (`cs_store`.`items` left join `cs_store`.`view1question4` `v`
      on ((`cs_store`.`items`.`name` = `cs_store`.`v`.`name`)))
where ((`cs_store`.`items`.`type` = '3') or (`cs_store`.`items`.`type` = '4'))
order by `cs_store`.`items`.`type`;



-- question 6

create definer = root@localhost view view1question6 as
select `cs_store`.`itemsintransactions`.`iit_id` AS `iit_id`,
       `cs_store`.`itemsintransactions`.`t_id`   AS `t_id`,
       `cs_store`.`items`.`type`                 AS `type`,
       `cs_store`.`items`.`price_for_each`       AS `price`
from (`cs_store`.`items` join `cs_store`.`itemsintransactions`
      on ((`cs_store`.`items`.`name` = `cs_store`.`itemsintransactions`.`name`)))
order by `cs_store`.`itemsintransactions`.`t_id` desc;

create definer = root@localhost view iitranking as
select `cs_store`.`a`.`iit_id` AS `iit_id`,
       `cs_store`.`a`.`t_id`   AS `t_id`,
       `cs_store`.`a`.`type`   AS `type`,
       `cs_store`.`a`.`price`  AS `price`,
       count(1)                AS `rnk`
from (`cs_store`.`view1question6` `a` left join `cs_store`.`view1question6` `b`
      on (((`cs_store`.`a`.`t_id` = `cs_store`.`b`.`t_id`) and (`cs_store`.`a`.`type` = `cs_store`.`b`.`type`) and
           ((`cs_store`.`a`.`price` < `cs_store`.`b`.`price`) or ((`cs_store`.`a`.`price` = `cs_store`.`b`.`price`) and
                                                                  (`cs_store`.`a`.`iit_id` <= `cs_store`.`b`.`iit_id`))))))
group by `cs_store`.`a`.`t_id`, `cs_store`.`a`.`type`, `cs_store`.`a`.`iit_id`
order by `cs_store`.`a`.`t_id` desc, `cs_store`.`a`.`type` desc, `cs_store`.`a`.`price` desc,
         `cs_store`.`a`.`iit_id` desc;

-- qustion7
    create view view1question7 as select any_value(iit_id),t_id,type,count(type) as count from iitranking where type in (select type from promotion)
    group by type,t_id order by t_id desc, type desc;
-- 筛选出type3 的交易，因为它不参与折扣，并且将每一组参与折扣的商品进行计数

create view view2question7 as select * from view1question7 natural join promotion where count>promotion.number_to_buy;
-- 筛选出type1 3 4 中数量满足折扣数量的交易的 t_id 筛选出的是t_id=2, 3

create view view3question7 as select * from  iitranking natural join promotion where t_id in (select t_id from view2question7);
-- 从iitranking 中筛选出可以进行折扣的交易，并且 natural join promotion 表

create view view4question7 as select * from view3question7
where rnk % view3question7.number_to_buy=0 or rnk % view3question7.number_to_buy>view3question7.number_to_buy-view3question7.how_many_are_free;
-- 找出需要免费的项目

create view TransactionCost as select t_id , sum(price) as cost from iitranking where iit_id not in (select iit_id from view4question7) group by t_id order by t_id;







