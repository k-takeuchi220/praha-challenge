## 課題1

<img src="./assets/task1.png" alt="ER図">

### 補足
- 注文テーブル
  - 注文情報が格納される。
- 注文詳細テーブル
  - 1つの注文に対し、複数のレコードが格納される。
- 商品テーブル
  - 商品ごとのデータが入るマスタテーブル。
  - カテゴリ1は、「セットメニュー, お好みずし」、カテゴリ2は、「盛り込み, 一皿...」の定数値が入る想定。（検索用）
  - 商品価格変更時は、新たにレコードを追加し、削除日時を登録する想定。
- 顧客テーブル
  - 顧客情報が格納される。
- 税率区分テーブル
  - 店内飲食、持ち帰りで税率が変化するため。
- 税率テーブル
  - 税率が変化する際に、レコードを追加。

---
## 課題2

課題1にあるOrderDetailテーブルにシャリのサイズを登録するカラムを追加する。

<img src="./assets/task2.png" alt="">


特定の商品の売上個数を取得する。
```
select sum(count) from order_details where product_id = 1;
```

お好み寿司内で一番売れている商品情報を取得する。
```
select sum(count) as max_count, product_id from order_details where product_id in (select id from products where category1 = 2) group by product_id order by sum(count) desc limit 1;
```


---
## 課題3

<details><summary>自分の考えた追加仕様</summary>

```rb
スタンプカードの導入。
1000円以上お買い上げごとにスタンプが押され、10個ごとに500円分のクーポンコードが発行されるようになった。
スタンプの有効期限は、1年間。
クーポンコード交換後の有効期限は、1ヶ月間となっている。
```
</details>


<details><summary>トリオが考えた追加仕様</summary>

```rb
出前の考慮
住所や郵便番号の追加が必要
Amazonで自宅住所以外にも配達ができることを考えると、顧客マスタの住所に届けるとは限らないため実際に届ける住所は注文履歴に持つべきかも
注文履歴に決済方法があるといいかも
優待セールで１週間だけ10%オフ（メニューはそのまま）
ポイントカード
メニューの追加
ex. 飲み物や汁物など
注文履歴、注文詳細は論理削除想定（注文後のキャンセルなど
キャンセルやっぱり論理削除じゃなくてステータスで判断の方が良さそう
セットメニューの「盛り込み」「にぎり」：お好みすしの組み合わせで構成されている場合、単にお好みすしの商品ID、個数を保持するテーブルでメニューの組み合わせを実現できるようにする？

・キャンセル状況を確認できる
・受け取り日時を確認できる
→ 注文〜受け取り時間とキャンセルの関係を分析を可能に
・ポイントカード・クーポンの割引
・会員優待
→ チェーン展開ならあるかなと
```
</details>

まとめた追加仕様
- スタンプ（ポイント）カードの導入。
- クーポン、会員優待などの割引券を追加。
- 店頭販売だけでなく、出前を考慮。
- 複数の住所を登録できるようにし、注文ごとに住所を選択できるようにする。
- 決済方法の追加（各住所に紐づくよう対応）
- 注文キャンセルを考慮し、注文履歴、詳細に倫理削除追加。
- 受け取り時間、注文キャンセル時間を追加。
- 優待セールの追加。

- セール期間中のクーポンは使用可能。
- 複数のクーポンは、併用不可。
- セールとクーポンで値引きされる商品は、対象を「全て」「カテゴリごと」「特定の商品」を設定でき、「割引率」と「割引価格」を設定できる。


濃い緑: 追加テーブル<br>
黄色: 追加カラム
<img src="./assets/task3.png" alt="">

追加部分について
- 注文テーブル
  - 配送先ID 設定された配送先一覧から選択された配送先IDが指定。
  - セールID セール適用の場合に指定　通常時は0。
  - クーポンID クーポン使用の場合に指定　未使用時は0。
  - 削除日時　購入取り消し時等に記録 デフォルトnull。
  - 配送日時　配送完了時に記録。
- 注文詳細テーブル
  - 削除日時　購入取り消し時等に記録 デフォルトnull。
- 配送先テーブル
  - 概要　顧客が登録している配送先一覧の情報を記録。
  - 支払い方法　1:現金, 2:クレジットカード等、処理内部に定数を配置する想定。
- セールテーブル
  - 概要　セール情報を登録。
- クーポンテーブル
  - 概要　顧客ごとのクーポン情報を登録。
- 割引テーブル
  - 概要 セール、クーポンの実際に適用されるデータを登録。
  - 割引金額、割引割合　各データごとに、どちらかのみが使用される想定、使用しない場合は0を指定。
  - 条件カテゴリ　カテゴリごと割引対象にする場合に指定。使用しない場合は0。
  - 条件商品ID　特定の商品のみ対象とする場合に指定。使用しない場合は0。
  - 全ての商品を指定する場合には、条件カテゴリ、条件商品IDを0に設定。
- スタンプカードテーブル
  - 概要　顧客ごとのスタンプ（ポイント）カード情報を登録。
  - 有効期限日時　最後にスタンプを押された日時 + 有効期限日時が記録される想定。

---
## 課題4

<details><summary>SQL</summary>

```rb
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

```
</details>
