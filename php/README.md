# PHPからAPIを実行する方法

本プロジェクトはPHP側でAPI実行結果をハンドリングできるようにしたものです。

処理内容はあくまでも１例を提起したものです。適宜、改良してお使い下さい。

## 1. フォルダー構成

以下の構成になるようセットアップしていきます。

```
[Project Root]
 +-[Client]
 +-[Config]
    +- common.php       (設定ファイル)
 +-[Constant]
 +-[Http]
 +-[Util]
 +- ApiClientDemo.php	(メイン実行ファイル)
 +- test_image.jpg
```

## 2. common.php を作成

[Config] ディレクトリー内にある common_example.php をリネームし、API認証情報を設定して下さい。

### 2.1. Base64画像

common.php 内の [file_name] 設定は [Project Root] ディレクトリー直下に置かれた画像をBase64データとして読み込む際に利用できます。下記のように設定して下さい。

```
return [
    'host' => 'https://[API DOMAIN]',
    'parts_path' => '/[PARTS API PATH]',
    'damage_path' => '/[DAMAGE API PATH]',

    'appKey' => '[APP_KEY for you]',
    'appSecret' => '[APP_SECRET for you]',


    'file_name' => 'test_image.jpg',
    'file_url' => '[url of image file on OSS bucket]'
];
```

## 3. API 実行

以下をターミナルで実行することで、API処理結果を確認する事ができます。
``` php
$ php ApiClientDemo.php
```

本プロジェクトでは利便性を図るために、APIが返してきた結果をフィルターする機能を追加してます。ご活用下さい。

``` php
/** ApiExecutor **/

// execute with file_name
$response= ApiExecutor::doPostStream($host, $parts_path, $appKey, $appSecret, $file_name, NULL);

/*
* ApiExecutor::dumpResponse($response, filter_type, filter_score)
* - filter_type:    指定したtypeのラベルだけをフィルターして残す (NULL: フィルターなし)
* - filter_score:   指定したscore以上のスコアだけをフィルターして残す (0.0: フィルターなし)
*/
ApiExecutor::dumpResponse($response, NULL, 0.0);
ApiExecutor::dumpResponse($response, 'hood', 0.4);

class APIExecutor {
	public static function dumpResponse($response, $type, $score) {
		$converter = new ResponseConverter($response);

        ・・・(略)・・・

		DebugUtil::debug('----------------------------------', NULL);
		$bboxIterator = $converter->getBBoxIterator(NULL, 0.0);         // フィルターなし結果を出力
		foreach ($bboxIterator as $bbox_) {
			DebugUtil::debug('BOX', $bbox_->getInfo());
		}

		DebugUtil::debug('----------------------------------', NULL);
		$bboxIterator = $converter->getBBoxIterator($type, $score);     // フィルター後の結果を出力
		foreach ($bboxIterator as $bbox_) {
			DebugUtil::debug('BOX', $bbox_->getInfo());
		}

		DebugUtil::debug('DONE', NULL);
	}
}
```

## 4. ライセンス

本プロジェクトは Apache 2.0 ライセンスです。

## 5. ユーザ認証における署名ロジック

本プロジェクトは、ユーザ認証に必要な「署名ロジック」を下記リポジトリーから参照しています。

現時点(2021年10月)での動作検証は行いましたが、コードに関するメンテナンス状況(更新・改修・問題)は下記リポジトリーをご参照下さい。
また「署名ロジック」に関するコードのライセンスは下記リポジトリーのものをそのまま継承してます。

https://github.com/aliyun/api-gateway-demo-sign-ph