# PerlからPHPを経由してAPIを実行する方法

本プロジェクトは既に検証済みPHPプロジェクトを利用して、Perl側でAPI実行結果をハンドリングできるようにしたものです。

処理内容はあくまでも１例を提起したものです。適宜、改良してお使い下さい。

## 1. フォルダー構成

以下の構成になるようセットアップしていきます。

```
[Project Root]
 +-[php]
    +- PerlReceiver.php
 +-[util]
 +- ApiClientDemo.pl    (メイン実行ファイル)
 +- config.ini          (設定ファイル)
 +- test_image.jpg
```

### 1.1. phpプロジェクトをコピー

[Project Root] ディレクトリーの１階層上に [php] プロジェクトがあります。[php] ディレクトリーをリネームせずそのままコピーして下さい。

[[php] プロジェクトはこちら](https://github.com/sbcloud/ai-visionary-vehicle-sdk/tree/master/php)

### 1.2. PerlReceiver.php をコピー

[Project Root] ディレクトリー内にある PerlReceiver.php を [php] ディレクトリー直下へコピー、もしくは移動して下さい。

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
``` perl
$ perl ApiClientDemo.pl
```

本プロジェクトでは利便性を図るために、APIが返してきた結果をフィルターする機能を追加してます。ご活用下さい。

``` perl
# execute with file_url
$file = '@@';
$url  = $file_url;
$response = `/usr/bin/php -f $php_receiver $host $parts_path $appKey $appSecret $file $url`;

/*
* util::DebugUtil::dump($response, $filter_type, $filter_score)
* - filter_type:    指定したtypeのラベルだけをフィルターして残す (undef: フィルターなし)
* - filter_score:   指定したscore以上のスコアだけをフィルターして残す (0.0: フィルターなし)
*/

util::DebugUtil::dump($response, undef, 0.0);
util::DebugUtil::dump($response, 'grille', 0.4);
```

## 4. ライセンス

本プロジェクトは Apache 2.0 ライセンスです。