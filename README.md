# Dplan

独学で個人開発した旅行計画アプリとなります。

2019 年ごろまで実際に iOS アプリストアにリリースしていたものの、収益化に失敗したため、現在は取り下げているアプリとなります。

プログラミング初心者の時に製作したものであるため、技術スタックの選定やコードは初心者ライクなところが多々あります。
あらかじめあらかじめ、ご了承ください。

今後、必要に応じて、リファクタリング、ライブラリのアップデート、技術スタックの再選定等を行い、リエンジニアリングします。

当コードを参考に異なるプロダクトを製作していただいて結構ですが、コードの流用はご遠慮ください。

iOS アプリの内容の詳細はは`/promotion/`ディレクトリを参照ください。

![iosAPP](/promotion/app_store.png)
![promotion](/promotion/promotion_1.png)

![01](/promotion/review/app_review_1.jpeg)
![02](/promotion/review/app_review_2.jpeg)
![03](/promotion/review/app_review_3.jpeg)
![04](/promotion/review/app_review_4.jpeg)
![05](/promotion/review/app_review_5.jpeg)

## ローカルでのセットアップ方法

Github レポジトリの clone

```bash
git clone https://github.com/s-hirano-ist/Dplan.git
```

Cocoapods の開発環境をセットアップ

```bash
sudo gem install cocoapods
```

> https://guides.cocoapods.org/using/getting-started.html
>
> https://qiita.com/ryamate/items/e51c77fbabc2aec185fc

Cocoapodsのライブラリをインストール

```bash
pod install
pod update
```
