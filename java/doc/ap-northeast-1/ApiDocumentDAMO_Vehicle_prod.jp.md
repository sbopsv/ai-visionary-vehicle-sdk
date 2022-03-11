# 1. API グループ: DAMO_Vehicle_prod

# 2. API リスト

<div>
    <table>
        <tr>
            <th >API 名</th>
            <th >認証方法</th>
            <th >説明</th>
        </tr>
        <tr>
            <td>SBCPartDetection_prod</td>
            <td>署名</td>
            <td>車両部品識別 API。本番公開中。</td>
        </tr>
        <tr>
            <td>SBCDamageRfcn_prod</td>
            <td>署名</td>
            <td>車両破損判定 API。本番公開中。</td>
        </tr>
    </table>
</div>

<br />

# 3. API 呼び出し
## 3.1. パブリック入力パラメータ
API ごとにパブリックリクエストパラメータが必要です。

パラメータ名 | 位置 | 必須 | 説明
-------|------|--------|----
X-Ca-Key        |Header| はい   |AppKey。[Alibaba Cloud API Gateway コンソール](https://apigateway.console.aliyun.com/#/apps/list)で申請可能な API 呼び出し用のID。申請はサービスプロバイダーへお問い合わせください。
X-Ca-Signature  |Header| はい   |署名ルールに則り計算されたリクエスト用の署名文字列。詳しくは<a href="#Signature">署名ルール</a>をご覧ください。
<span id='Timestamp'>X-Ca-Timestamp</span>  |Header| いいえ |API を呼び出した時刻(タイムスタンプ、ミリ秒単位、1970年1月1日から現在までの経過ミリ秒)。タイムスタンプの有効期限は、デフォルトで15分。
X-Ca-Nonce      |Header| いいえ |API リクエストの一意なID。X-Ca-Nonce は、15分以内に繰り返し使用することはできません。UUID の利用を推奨します。タイムスタンプと併用することでリプレイを防止することができます。
<span id='md5'>Content-MD5</span>     |Header| いいえ |リクエスト内の Body が Form 形式でない場合、Body の MD5 検証を行うために Body の MD5 値を計算し、Clouud Gateway に配信する必要があります。
X-Ca-Signature-Headers|Header|いいえ|署名に含まれる Header リスト。異なる値はカンマ(,)で区切られる。デフォルトでは X-Ca-Key だけが含まれます。例えばセキュリティを確保するため、X-Ca-Timestamp, X-Ca-Nonce を署名に追加する場合は (例：X-X-Ca-Signature-Headers:Ca-Timestamp,X-Ca-Nonce) のようになります。

<br />

# 4. 署名

## 4.1. <span id='Signature'>署名ルール</span>
リクエストに含まれる署名で、リクエストの内容に基づいて算出されるデジタル署名。API がユーザを識別するために使用する。クライアントが API を呼び出す際に、計算された署名をリクエストに付加する（X-Ca-Signature）。

## 4.2. 署名処理のプロセス
_________________________________________________________
> AppKey の準備 -> stringToSign の作成 -> AppSecret を用いた署名計算
_________________________________________________________

### 4.3.1. AppKey の準備

AppKey は API 呼び出し用の ID です。[Alibaba Cloud API Gateway コンソール](https://apigateway.console.aliyun.com/#/apps/list)上で申請できます。

### 4.3.2. <span id='stringToSign'>stringToSign の作成</span>

````java
String stringToSign =
                    HTTPMethod      + "\n" +
                    Accept          + "\n" + 
                    // 'Accept' ヘッダーを設定することを推奨します。
                    // もし Accept が空だと、HTTP クライアントはデフォルト値 */* を Accept に設定します。 
                    // 結果として署名の検証処理が失敗します。
                    Content-MD5     + "\n" +
                    Content-Type    + "\n" +
                    Date            + "\n" +
                    Headers +
                    Url
````

> ### HTTPMethod
値は大文字 (例：POST)

````
Accept, Content-MD5, Content-Type, Date が空の場合は、改行 "\n" を追加します。Header が空の場合、"\n" は必要ありません。
````

> ### Content-MD5

Content-MD5 とは、Body の MD5 値のことです。Body が Form 形式でない場合のみ、MD5 値を計算します。計算方法は以下の通りです。:

```java
String content-MD5 = Base64.encodeBase64(MD5(bodyStream.getbytes("UTF-8")));
```
bodyStream はバイト配列を示す。

> ### Headers

Header とは、署名付きのヘッダーのキーと値で構成される文字列を指します。X-Ca で始まるヘッダーやカスタムヘッダーに対して署名を計算することをお勧めします。

なお、以下のパラメータは署名の計算には使用できません。ご注意ください。: 
```
X-Ca-Signature, X-Ca-Signature-Headers, Accept, Content-MD5, Content-Type, and Date.
```

> ### ヘッダーを構成するメソッド

署名計算に使用されるキーをアルファベット順に並べ替え、次のルールに従って文字列を構成します。:

Header の値が空の場合、HeaderKey + ":" + "\n" で署名が計算されます。キーとコロン(:)は削除できません。

````java
String headers =
                HeaderKey1 + ":" + HeaderValue1 + "\n" +
                HeaderKey2 + ":" + HeaderValue2 + "\n" +
                ...
                HeaderKeyN + ":" + HeaderValueN + "\n"
````

署名計算に使用される Header リストはカンマ(,)で区切り、リクエストの Header に配置する。配置する先の Key は X-Ca-Signature-Headers です。

例：X-X-Ca-Signature-Headers:Ca-Timestamp,X-Ca-Nonce

> ### Url

URLは Path + Query + Body の Form 形式パラメータを指します。
URLは次のように構成されています。:

Query + Form 形式パラメータの場合、キーはアルファベット順に並べ替えられます。
Query または Form 形式パラメータが null の場合、URL は Path に設定されます。その際、クエスチョンマーク(?)は必須ではありません。
パラメータの値が null の場合、キーのみが署名用に確保されます。その際、署名に等号(=)を追加する必要はありません。

````java
String url =
            Path + "?" +
            Key1 + "=" + Value1 + "&" + 
            Key2 + "=" + Value2 + "&" + 
            ...
            KeyN + "=" + ValueN
````

Query 形式や Form 形式は複数の値を持つことができることにご注意ください。複数の値がある場合、最初の値が署名の計算に使用されます。

### 4.3.3. <span id='calSignature'>署名を計算するために AppSecret を使用</span>

````java
Mac hmacSha256 = Mac.getInstance("HmacSHA256");
byte[] keyBytes = secret.getBytes("UTF-8");
hmacSha256.init(new SecretKeySpec(keyBytes, 0, keyBytes.length, "HmacSHA256"));
String sign = new String(Base64.encodeBase64(Sha256.doFinal(stringToSign.getBytes("UTF-8")),"UTF-8"));
````

AppSecret は APP の鍵で、[アプリケーション(AppKey)管理](https://apigateway.console.aliyun.com/#/apps/list)から取得できます。API サービスプロバイダーへお問い合わせください。

<br />

# 5. API 一覧

## 5.1. API 名: SBCPartDetection_prod

### 5.1.1. *説明*

- 車両部品識別 API。本番公開中。

### 5.1.2. *リクエスト情報*

- HTTP プロトコル: HTTPS
- 呼び出しアドレス: vehicle.ai-visionary.com/parts-detection
- Method: POST

<br />

### 5.1.3. *リクエストパラメータ*

<div>
    <table>
        <tr>
            <th style="width: 5%;">パラメータ</th>
            <th style="width: 5%;">位置</th>
            <th style="width: 5%;">タイプ</th>
            <th style="width: 30%;">必須</th>
            <th style="width: 40%;">説明</th>
        </tr>
        <tr>
            <td>url</td>
            <td>body</td>
            <td>string</td>
            <td>いいえ、但し、"url" か "image" のどちらかが指定される必要があります。</td>
            <td>OSS(Alibaba Cloud Object Storage Service)上に保存された画像の URL</td>
        </tr>
        <tr>
            <td>image</td>
            <td>body</td>
            <td>string</td>
            <td>いいえ、但し、"url" か "image" のどちらかが指定される必要があります。</td>
            <td>画像を Base64 エンコードした文字列</td>
        </tr>
    </table>
</div>

<br />

### 5.1.3. *リクエスト Body の説明 (non-Form 形式)*

````json title="url parameter"
{"url": "https ://your-bucket.oss-apnortheast1.aliyuncs.com/test/test.jpeg?Expires=1632884604&OSSAccessKeyId=TMP.3KiZfX36fUfXGBct4m9DKdzV2NcwoKcXAGDKr9wh4F6TPnDQH1LMG5qY36Qn&Signature=3BBs1tee%2F9L1kN%2BWuO0JvVvJp"}
````

````json title="image parameter"
{"image": "/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAMCAAwMEBQgFBQQEBQoMDAsK…………CwsND4RDgsLEBYQERMUFRUVDA8XGBUFRTYuwH/ADqqWPo//9k="}
````

<br />

### 5.1.4.  *レスポンンス情報*

#### レスポンスパラメータのタイプ

- JSON

#### 正常終了したレスポンスのサンプル

```json title="JSON Format"
HTTP/1.1 200
Connection: keep-alive
Server: Kaede/3.5.3.578 (an0a7rlhw)
X-Ca-Request-Id: CF23D759-E6BC-4ECA-A5D2-9E27656E14B8 
Content-Type: text/plain;charset=UTF-8
Content-Length: 766
Date: Wed, 29 Sep 2021 02:52:43 GMT

{
    "message": "",
    "version": "v0", 
    "results": {
        "modelName": "part_comp_direct",
        "ret": 0, 
        "image_id": "", 
        "bbox": [
            {
                "score": 0.9929782748222351, 
                "type": "front_bumper", 
                "location": [ 84, 186, 944, 481 ],
                "poly": "" 
            },
            {
                "score": 0.9893203973770142, 
                "type": "right_front_tire", 
                "location": [ 4, 128, 216, 439 ],
                "poly": "" 
            },
            {
                "score": 0.8613800406455994, 
                "type": "grates",
                "location": [ 737, 377, 940, 441 ],
                "poly": "" 
            }
        ],
        "image_info": {
          "orig_shape": [ 531, 944 ]
        },
        "message": "" 
    },
    "ret": 0 
}
```

#### 異常終了したレスポンスのサンプル

````

````

<br />

### 5.1.5. *エラーコード*

<div>
    <table>
        <tr>
            <th style="width: 15%;">エラーコード</th>
            <th style="width: 20%;">エラーメッセージ</th>
            <th style="width: 25%;">説明</th>
        </tr>
        <tr>
            <td>Public error codes</td>
            <td>--</td>
            <td>API パブリックエラーコードについては <a href="#pubError">パブリックエラーコード</a>をご参照ください。</td>
        </tr>
    </table>
</div>

<br />

## 5.2. API 名: SBCDamageRfcn_prod

### 5.2.1. *説明*

- 車両破損判定 API。本番公開中。

### 5.2.2. *リクエスト情報*

- HTTP プロトコル: HTTPS
- 呼び出しアドレス: vehicle.ai-visionary.com/damage-detection
- Method: POST

<br />

<div>
    <table>
        <tr>
            <th style="width: 5%;">パラメータ</th>
            <th style="width: 5%;">位置</th>
            <th style="width: 5%;">タイプ</th>
            <th style="width: 30%;">必須</th>
            <th style="width: 40%;">説明</th>
        </tr>
        <tr>
            <td>url</td>
            <td>body</td>
            <td>string</td>
            <td>いいえ、但し、"url" か "image" のどちらかが指定される必要があります。</td>
            <td>OSS(Alibaba Cloud Object Storage Service)上に保存された画像の URL</td>
        </tr>
        <tr>
            <td>image</td>
            <td>body</td>
            <td>string</td>
            <td>いいえ、但し、"url" か "image" のどちらかが指定される必要があります。</td>
            <td>画像を Base64 エンコードした文字列</td>
        </tr>
    </table>
</div>

<br />

### 5.2.3. *リクエスト Body の説明 (non-Form 形式)*

````json title="url parameter"
{"url": "https ://your-bucket.oss-apnortheast1.aliyuncs.com/test/test.jpeg?Expires=1632884604&OSSAccessKeyId=TMP.3KiZfX36fUfXGBct4m9DKdzV2NcwoKcXAGDKr9wh4F6TPnDQH1LMG5qY36Qn&Signature=3BBs1tee%2F9L1kN%2BWuO0JvVvJp"}
````

````json title="image parameter"
{"image": "/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAMCAAwMEBQgFBQQEBQoMDAsK…………CwsND4RDgsLEBYQERMUFRUVDA8XGBUFRTYuwH/ADqqWPo//9k="}
````

<br />

### 5.2.4.  *レスポンンス情報*

#### レスポンスパラメータのタイプ

- JSON

#### 正常終了したレスポンスのサンプル

```json title="JSON Format"
HTTP/1.1 200
Connection: keep-alive
Server: Kaede/3.5.3.578 (an0a7rlhw)
X-Ca-Request-Id: CF23D759-E6BC-4ECA-A5D2-9E27656E14B8 
Content-Type: text/plain;charset=UTF-8
Content-Length: 766
Date: Wed, 29 Sep 2021 02:52:43 GMT

{
  "message": "",
  "version": "v0", 
  "results": {
    "image_id": "", 
    "modelName": "damage_A", 
    "bbox": [
      {
        "score": 0.656955, "type": "2",
        "location": [192,　181, 242, 258],
        "scores": "0,0.656955,0,0,0,0,0,0,0,0,0,0,0,0,0"
      },
      {
        "score": 0.472695, "type": "4", 
        "location": [283, 334, 504, 449],
        "scores": "0,0,0,0.472695,0,0,0,0,0,0,0,0,0,0,0"
      },
      {
        "score": 0.903846, "type": "5", 
        "location": [282, 12, 755, 194],
        "scores": "0,0,0,0,0.903846,0,0,0,0,0,0,0,0,0,0" },
      {
        "score": 0.887738, "type": "6", 
        "location": [491, 276, 655, 438],
        "scores": "0,0,0,0,0,0.887738,0,0,0,0,0,0,0,0,0"
      },
      {
        "score": 0.410555, "type": "11",
        "location": [233, 159, 357, 275],
        "scores": "0,0,0,0,0,0,0,0,0,0,0.410555,0,0,0,0"
      }
    ] 
  },
  "ret": 0 
}
```

#### 異常終了したレスポンスのサンプル

````

````

<br />

### 5.1.5. *エラーコード*

<div>
    <table>
        <tr>
            <th style="width: 15%;">エラーコード</th>
            <th style="width: 20%;">エラーメッセージ</th>
            <th style="width: 25%;">説明</th>
        </tr>
        <tr>
            <td>Public error codes</td>
            <td>--</td>
            <td>API パブリックエラーコードについては <a href="#pubError">パブリックエラーコード</a>をご参照ください。</td>
        </tr>
    </table>
</div>

<br />

# 5. <span id='pubError'>パブリックエラー</span>

## 5.1. パブリックエラーの取得方法
API リクエストが Alibaba Cloud API Gateway に到達している限り、それはリクエスト結果のメッセージを返します。

返ってきたレスポンスの中のリクエストヘッダーを確認する必要があります。以下は返ってきたパラメータのサンプルです:

    // リクエストのユニークな ID。
    // リクエストが API Gateway に到達すると、API Gateway はリクエスト ID を生成し、それをレスポンスヘッダーを介してクライアントに返します。
    // トラブルシューティングやトレースのために、リクエスト ID はクライアントとバックエンドサーバの両方で記録しておくことをお勧めします。
	X-Ca-Request-Id: 7AD052CB-EE8B-4DFD-BBAF-EFB340E0A5AF

    // API Gateway から返されたエラーメッセージ。
    // リクエストが失敗すると、それをレスポンスヘッダーを介してクライアントに返します。
	X-Ca-Error-Message: Invalid Url

    // デバッグモードが有効になっている場合に返されるデバッグメッセージ。
    // このメッセージは後で変更される可能性があり、デバッグ段階での参照用としてのみ使用されます。
	X-Ca-Debug-Info: {"ServiceLatency":0,"TotalLatency":2}

X-Ca-Error-Message ヘッダーは基本的にエラー原因を明確にするものです。X-Ca-Request-Id ヘッダーはログ検索のためにテクニカルサポートエンジニアに提供することができます。

<br />

## 5.2. パブリックエラーコード
### 5.2.1. クライアントエラー

エラーコード | HTTP ステータスコード | 意味 | 解決方法
------|-----------|---|------
Throttled by USER Flow Control  |403|ユーザフロー制御による制限|呼び出し頻度が高いため、フロー制御がトリガーされます。フロー制御制限を増やすには、API サービスプロバイダーにお問い合わせください。
Throttled by APP Flow Control   |403|APP フロー制御による制限 |呼び出し頻度が高いため、フロー制御がトリガーされます。フロー制御制限を増やすには、API サービスプロバイダーにお問い合わせください。
Throttled by API Flow Control   |403|API フロー制御による制限 |呼び出し頻度が高いため、フロー制御がトリガーされます。フロー制御制限を増やすには、API サービスプロバイダーにお問い合わせください。
Throttled by DOMAIN Flow Control|403|2nd レベルドメインでのアクセス制限|API 呼び出しに使用される2ndレベルドメインは1日に最大1,000回までアクセスできます。
Throttled by GROUP Flow Control |403|グループを基にしたフロー制御による制限|呼び出し頻度が高いため、フロー制御がトリガーされます。フロー制御制限を増やすには、API サービスプロバイダーにお問い合わせください。
Quota Exhausted	|403|呼び出しクォータを使い切りました     |購入した呼び出しクォータを使い切りました。
Quota Expired	|403|呼び出しクォータの有効期限が切れている|購入したクォータが期限切れになりました。
User Arrears	|403|アカウントに延滞してます            |できるだけ早くアカウントを再チャージしてください。
Empty Request Body	    |400|Body が空                |リクエスト Body の内容を確認してください。
Invalid Request Body	|400|Body が無効              |リクエスト Body の内容を確認してください。
Invalid Param Location	|400|パラメータの位置が正しくない |リクエストパラメータの位置が正しくありません。
Unsupported Multipart	|400|ファイルアップロード未対応   |ファイルのアップロードはサポートされていません。
Invalid Url	        |400|URL が無効           |リクエストされたMethod、Path、または環境が正しくありません。エラーの詳細については、[無効なURL]をご参照ください。
Invalid Domain	    |400|無効なドメイン名       |リクエストされたドメイン名が無効であり、ドメイン名に基づいて API を見つけることができません。API サービスプロバイダーにお問い合わせください。
Invalid HttpMethod	|400|無効な HTTPMethod    |入力した Method が正しくありません。
Invalid AppKey      |400|AppKey が無効であるか、存在しない|AppKey を確認してください。パラメータの両側にスペースは必要ありません。
Invalid AppSecret	|400|AppSecret が正しくない |AppSecret を確認してください。パラメータの両側にスペースは必要ありません。
Timestamp Expired   |400|タイムスタンプの有効期限が切れている|リクエストのシステム時刻が標準時刻であるかどうかを確認してください。
Invalid Timestamp	|400|無効なタイムスタンプ    |詳しくは <a href="#Timestamp">X-Ca-Timestamp</a> の説明をご覧ください。
Empty Signature	    |404|空の署名              |署名(文字列)を入力してください。詳しくは<a href="#calSignature">署名を計算するために AppSecret を使用</a>の説明をご覧ください。
Invalid Signature, Server StringToSign:%s|400|無効な署名|署名が無効です。詳しくは <a href="#stringToSign">stringToSign の作成</a>の説明をご覧ください。
Invalid Content-MD5 |400|無効な Content-MD5    |リクエスト Body は空だがその MD5 値が入力されている、または MD5 値が正しくありません。詳しくは <a href="#md5">Content-MD5</a> の説明をご覧ください。
Unauthorized	    |403|許可されていない操作    |アプリケーション(AppKey)には API を呼び出す権限が付与されてません。API サービスプロバイダーにお問い合わせください。
Nonce Used          |400|使用済みの署名 Nonce   |署名 Nonce は繰り返し使用することはできません。
API Not Found       |400|API が見つからない     |入力した API アドレスまたは HttpMethod が正しくない、または API がオフラインです。

<br />

### 5.2.2. サーバエラー (API 呼び出し)

以下は API サーバでのエラーです。頻繁にエラーが発生する場合は、API サービスプロバイダーにお問い合わせください。

エラーコード | HTTP ステータスコード | 意味 | 解決方法
------|-----------|---|------
Internal Error	                |500|内部エラー                   |再度お試しいただくか、API サービスプロバイダーにお問い合わせいただくことをお勧めします。
Failed To Invoke Backend Service|500|根本的なサービスエラー         |基盤となる API サービスでエラーが発生してます。再度お試しください。それでも問題が解決しない場合は、API サービスプロバイダーに解決策をお問い合わせください。
Service Unavailable             |503|サービスが利用で来ません       |再度お試しいただくか、API サービスプロバイダーにお問い合わせいただくことをお勧めします。
Async Service	                |504|バックエンドサーバのタイムアウト|再度お試しいただくか、API サービスプロバイダーにお問い合わせいただくことをお勧めします。