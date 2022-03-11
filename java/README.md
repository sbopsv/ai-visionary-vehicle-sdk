# Java から API を実行する方法

本プロジェクトは API を実行するための Java SDK を提供しています。

## 1. 概要
- Java SDK の詳細については、[Java SDK ユーザガイド](Readme.jp.md) をご覧ください。
- API 自体の詳細については、[API ドキュメント](doc/ap-northeast-1/ApiDocumentDAMO_Vehicle_prod.jp.md) をご覧ください。

## 2. サンプルコード

サンプル用に Maven プロジェクトを用意しました。
- フォルダー：java-sdk-sample

## 3. ライセンス

本プロジェクトは Apache 2.0 ライセンスです。

## 4. 参考) サーバレスアーキテクチャへの組込み

各種クラウドベンダーが提供するサーバレスアーキテクチャへの Maven プロジェクトを組み込む際にご参考ください。

**※ 注意： 参考として列挙していますが、本プロジェクト内で動作検証はしてません。各自の責任の元、ご参考ください。**

**※ 注意： 参考先に関するお問い合わせには回答しかねます。**

- Alibaba Cloud / Function Compute
    - ドキュメント: [Java runtime environment](https://partners-intl.aliyun.com/help/en/doc-detail/113519.htm)
    - ドキュメント: [Java](https://partners-intl.aliyun.com/help/en/doc-detail/58887.htm)
    - Github: [aliyun/fc-java-sdk](https://github.com/aliyun/fc-java-sdk)

- GCP / App Engine
    - ドキュメント: [Using Apache Maven and the App Engine Plugin (App Engine SDK-based)](https://cloud.google.com/appengine/docs/standard/java/tools/maven)

- Azure / Azure Functions
    - ドキュメント: [Quickstart: Create a Java function in Azure from the command line](https://docs.microsoft.com/en-us/azure/azure-functions/create-first-function-cli-java)