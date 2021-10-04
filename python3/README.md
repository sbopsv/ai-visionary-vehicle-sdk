# Python3からAPIを実行する方法

本プロジェクトはPython3側でAPI実行結果をハンドリングできるようにしたものです。

処理内容はあくまでも１例を提起したものです。適宜、改良してお使い下さい。

## 1. フォルダー構成

以下の構成になるようセットアップしていきます。

```
[Project Root]
 +-[com]
    +- [aliyun]			(署名ロジック：参照リポジトリーメイン ※ライセンス注意※)
    +- [sbc]			(API実行ツール群：本プロジェクト主体で追加)
 +- ApiClientDemo.py	(メイン実行ファイル)
 +- config.ini          (設定ファイル)
 +- test_image.jpg
```

## 2. config.ini を作成

[Project Root] ディレクトリー内にある config_example.ini をリネームし、API認証情報を設定して下さい。

### 2.1. Base64 画像

config.ini 内の [imgFile] 設定は [Project Root] ディレクトリー直下に置かれた画像をBase64データとして読み込む際に利用できます。下記のように設定して下さい。

```
[PARAM]
imgFile = test_image.jpg
```

## 3. API 実行

以下をターミナルで実行することで、API処理結果を確認する事ができます。

```python
$ python3 ApiClientDemo.php
```

本プロジェクトでは利便性を図るために、APIが返してきた結果をフィルターする機能を追加してます。ご活用下さい。

```python
/** ApiExecutor **/

# execute with file_name
response = ApiExecutor.postStream(host, parts_path, appKey, appSecret, file_name=file_name)

/*
* ApiExecutor.dumpResponse(response, filter_type, filter_score)
* - filter_type:    指定したtypeのラベルだけをフィルターして残す (None: フィルターなし)
* - filter_score:   指定したscore以上のスコアだけをフィルターして残す (0.0: フィルターなし)
*/
ApiExecutor.dumpResponse(response, None, 0.0)
ApiExecutor.dumpResponse(response, 'hood', 0.4)

class ApiExecutor():

    def dumpResponse(response, type, score):
        converter = ResponseConverter(response)

        ・・・(略)・・・

        DebugUtil.debug('----------------------------------', None)
        bboxIterator = converter.get_bbox_iterator(None, 0.0)		// フィルターなし結果を出力
        for bbox_ in bboxIterator :
            DebugUtil.debug('BOX', bbox_.get_info())
	
        DebugUtil.debug('----------------------------------', None)
        bboxIterator = converter.get_bbox_iterator(type, score)		// フィルター後の結果を出力
        for bbox_ in bboxIterator :
            DebugUtil.debug('BOX', bbox_.get_info())

        DebugUtil.debug('DONE', None)
```

## 4. ライセンス

本プロジェクトは Apache 2.0 ライセンスです。([LICENSE] ファイルに記載)

## 5. ユーザ認証における署名ロジック

本プロジェクトは、ユーザ認証に必要な「署名ロジック」を下記リポジトリーから参照しています。

現時点(2021年10月)での動作検証は行いましたが、コードに関するメンテナンス状況(更新・改修・問題)は下記リポジトリーをご参照下さい。
また「署名ロジック」に関するコードのライセンスは下記リポジトリーのものをそのまま継承してます。([LICENSE_Citation] ファイルに記載)

(参照リポジトリー：Python2.7のみ対応)

https://github.com/aliyun/api-gateway-demo-sign-python
