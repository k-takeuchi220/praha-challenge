CREATE DATABASE IF NOT EXISTS db_modering1 ;
use db_modering1;

-- ===== 注文テーブル =====
CREATE TABLE orders(
    id int unsigned NOT NULL AUTO_INCREMENT,
    customer_id int unsigned NOT NULL comment '顧客ID',
    tax_division_id smallint unsigned NOT NULL comment '税率区分ID',
    order_at datetime DEFAULT NULL comment '注文日時',
    is_payment tinyint(1) comment '支払い済みか',
    PRIMARY KEY (id)
);

INSERT INTO orders VALUES
  (1, 1, 1, '2022-11-01', 0),
  (2, 2, 2, '2022-11-02', 1),
  (3, 3, 3, '2022-11-03', 1);

-- ===== 注文詳細テーブル =====
CREATE TABLE IF NOT EXISTS order_details (
    id int unsigned NOT NULL AUTO_INCREMENT,
    order_id int unsigned NOT NULL comment '注文番号',
    product_id int unsigned NOT NULL comment '商品ID',
    count tinyint unsigned NOT NULL comment '注文個数',
    is_wasabi tinyint(1) comment 'サビ有りか',
    PRIMARY KEY (id)
);

INSERT INTO order_details VALUES
  (1, 1, 1, 1, 0),
  (2, 1, 1, 1, 1),
  (3, 1, 2, 1, 1),

  (4, 2, 3, 1, 0),
  (5, 2, 4, 1, 0),

  (6, 3, 5, 1, 0);

-- ===== 商品テーブル =====
CREATE TABLE IF NOT EXISTS products (
    id int unsigned NOT NULL AUTO_INCREMENT,
    name varchar(20) comment '商品名',
    price smallint unsigned NOT NULL comment '価格',
    category1 tinyint unsigned NOT NULL comment 'カテゴリ1',
    category2 tinyint unsigned NOT NULL comment 'カテゴリ2',
    delete_at datetime DEFAULT NULL comment '削除日時',
    PRIMARY KEY (id)
);

INSERT INTO products VALUES
  (1, '玉子', 100, 2, 1, null),
  (2, 'いなり', 100, 2, 1, null),
  (3, '納豆軍艦', 100, 2, 1, null),
  (4, 'ゆでげそ', 150, 2, 2, null),
  (5, 'とびっこ', 150, 2, 2, null),
  (6, 'はな', 8650, 1, 1, null);

-- ===== 顧客テーブル =====
CREATE TABLE IF NOT EXISTS customers (
    id int unsigned NOT NULL AUTO_INCREMENT,
    name varchar(20) comment '顧客氏名',
    phone_number varchar(15) comment '電話番号',
    PRIMARY KEY (id)
);

INSERT INTO customers VALUES
  (1, '田中 太郎', '080-xxxx-xxxx'),
  (2, '小林 二郎', '090-xxxx-xxxx'),
  (3, '山田 三郎', '090-xxxx-xxxx');

-- ===== 税率区分テーブル =====
CREATE TABLE IF NOT EXISTS tax_divisions (
    id int unsigned NOT NULL AUTO_INCREMENT,
    name varchar(20) comment '税率区分名称',
    PRIMARY KEY (id)
);

INSERT INTO tax_divisions VALUES
  (1, '標準税率'),
  (2, '軽減税率');

-- ===== 税率テーブル =====
CREATE TABLE IF NOT EXISTS tax (
    id int unsigned NOT NULL AUTO_INCREMENT,
    start_at datetime NOT NULL comment '適応開始日時',
    end_at datetime NOT NULL comment '適応終了日時',
    tax_division_id smallint comment '消費税区分ID',
    rate smallint(4) comment '税率（千分率）',
    PRIMARY KEY (id)
);

INSERT INTO tax VALUES
  (1, '1000-01-01 00:00:00', '9999-12-31 23:59:59', 1, 100),
  (2, '1000-01-01 00:00:00', '9999-12-31 23:59:59', 2, 80);
