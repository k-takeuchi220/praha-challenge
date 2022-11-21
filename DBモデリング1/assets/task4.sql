CREATE DATABASE IF NOT EXISTS db_modering1;
use db_modering1;

-- ===== 注文テーブル =====
CREATE TABLE orders(
    id int unsigned NOT NULL AUTO_INCREMENT,
    customer_id int unsigned NOT NULL comment '顧客ID',
    tax_division_id smallint unsigned NOT NULL comment '税率区分ID',
    order_at datetime DEFAULT NULL comment '注文日時',
    is_payment tinyint(1) comment '支払い済みか',
    shipping_id int unsigned NOT NULL comment '配送先ID',
    sale_id int unsigned NOT NULL comment 'セールID',
    coupon_id int unsigned NOT NULL comment 'クーポンID',
    delete_at datetime DEFAULT NULL comment '削除日時',
    delivery_at datetime DEFAULT NULL comment '配送日時',
    PRIMARY KEY (id)
);

INSERT INTO orders VALUES
  (1, 1, 1, '2022-11-01 12:00', 0, 1, 0, 0, null, null),
  (2, 2, 2, '2022-11-01 13:05', 1, 1, 1, 0, '2022-11-01 13:10', null),
  (3, 3, 3, '2022-11-01 13:06', 1, 1, 1, 1, null, '2022-11-01 14:00');

-- ===== 注文詳細テーブル =====
CREATE TABLE IF NOT EXISTS order_details (
    id int unsigned NOT NULL AUTO_INCREMENT,
    order_id int unsigned NOT NULL comment '注文番号',
    product_id int unsigned NOT NULL comment '商品ID',
    count tinyint unsigned NOT NULL comment '注文個数',
    is_wasabi tinyint(1) comment 'サビ有りか',
    delete_at datetime DEFAULT NULL comment '削除日時',
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

-- ===== 税率テーブル =====
CREATE TABLE IF NOT EXISTS taxes (
    id int unsigned NOT NULL AUTO_INCREMENT,
    start_at datetime DEFAULT NULL comment '適応開始日時',
    end_at datetime DEFAULT NULL comment '適応終了日時',
    tax_division_id smallint comment '消費税区分ID',
    rate smallint(4) comment '税率（千分率）',
    name varchar(20) comment '税率区分名称',
    PRIMARY KEY (id)
);

INSERT INTO taxes VALUES
  (1, null, null, 1, 100, '標準税率'),
  (2, null, null, 2, 80, '軽減税率');

-- ===== 配送先テーブル =====
CREATE TABLE IF NOT EXISTS shippings (
    id int unsigned NOT NULL AUTO_INCREMENT,
    post_code int(7) NOT NULL comment '郵便番号',
    address text NOT NULL comment '住所',
    name varchar(20) comment '配送先名',
    payment_id int unsigned NOT NULL comment '支払い方法',
    customer_id int unsigned NOT NULL comment '顧客ID',
    PRIMARY KEY (id)
);

INSERT INTO shippings VALUES
  (1, 1008111, '東京都千代田区千代田１−１', '皇居', 1, 1),
  (2, 1000002, '東京都千代田区皇居外苑１−１', '皇居外苑', 2, 1);
  (3, 1008111, '東京都千代田区千代田１−１', '皇居', 1, 2),
  (4, 1008111, '東京都千代田区千代田１−１', '皇居', 1, 3);

-- ===== セールテーブル =====
CREATE TABLE IF NOT EXISTS sales (
    id int unsigned NOT NULL AUTO_INCREMENT,
    discount_id int unsigned NOT NULL comment '割引ID',
    start_at datetime DEFAULT NULL comment '開始日時',
    end_at datetime DEFAULT NULL comment '終了日時',
    PRIMARY KEY (id)
);

INSERT INTO shippings VALUES
  (1, 1, '2022-11-01 13:00', '2022-11-03 13:00');

-- ===== クーポンテーブル =====
CREATE TABLE IF NOT EXISTS coupons (
    id int unsigned NOT NULL AUTO_INCREMENT,
    discount_id int unsigned NOT NULL comment '割引ID',
    period_at datetime NOT NULL comment '有効期限',
    PRIMARY KEY (id)
);

INSERT INTO coupons VALUES
  (1, 2, '2022-11-03 13:00'),
  (2, 3, '2022-11-03 13:00');

-- ===== スタンプカードテーブル =====
CREATE TABLE IF NOT EXISTS stamp_cards (
    id int unsigned NOT NULL AUTO_INCREMENT,
    point int unsigned NOT NULL DEFAULT 0 comment 'ポイント',
    customer_id int unsigned NOT NULL comment '顧客ID',
    period_at datetime comment '有効期限',
    UNIQUE idx_customer_id(customer_id),
    PRIMARY KEY (id)
);

INSERT INTO stamp_cards VALUES
  (1, 200, 1, '2022-12-01 12:00'),
  (2, 0, 2, null),
  (3, 100, 3, '2022-12-01 13:06');

-- ===== 割引テーブル =====
CREATE TABLE IF NOT EXISTS discounts (
    id int unsigned NOT NULL AUTO_INCREMENT,
    name varchar(20) comment '割引名称',
    price smallint unsigned DEFAULT 0 comment '割引価格',
    rate smallint(3) unsigned DEFAULT 0 comment '割引価格',
    cound_category1 tinyint unsigned DEFAULT 0 comment '条件カテゴリ1',
    cound_category2 tinyint unsigned DEFAULT 0 comment '条件カテゴリ2',
    cound_product_id int unsigned DEFAULT 0 comment '条件商品ID',
    PRIMARY KEY (id)
);

INSERT INTO discounts VALUES
  (1, '大特化セール 50%オフ', 0, 50, 0, 0, 0),
  (2, '玉子 10円引きクーポン', 10, 0, 0, 0, 1),
  (3, 'セットメニュー全品 100円引きクーポン', 100, 0, 1, 0, 0);
