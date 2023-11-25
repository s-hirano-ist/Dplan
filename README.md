# Dplan

2019年ごろまで実際にiOSアプリストアにリリースしていたものの、収益化に失敗したため、現在は取り下げているアプリとなります。

プログラミング初心者の時に製作したものであるため、技術スタックの選定やコードは初学者ライクなところが多々あります。
あらかじめあらかじめ、ご了承ください。

当コードを参考に異なるプロダクトを製作していただいて結構ですが、コードの流用はご遠慮ください。

iOS アプリの内容の詳細は`/promotion/`ディレクトリを参照ください。

![iosAPP](/promotion/app_store.png)
![promotion](/promotion/promotion_1.png)

![01](/promotion/review/app_review_1.jpeg)
![02](/promotion/review/app_review_2.jpeg)
![03](/promotion/review/app_review_3.jpeg)
![04](/promotion/review/app_review_4.jpeg)
![05](/promotion/review/app_review_5.jpeg)

## ローカルでのセットアップ方法

Github レポジトリのclone

```bash
git clone https://github.com/s-hirano-ist/d-plan
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
