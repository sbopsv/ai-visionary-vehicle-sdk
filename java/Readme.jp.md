# 1. Java SDK ユーザガイド 概要

この SDK は `AI-Visionary が提供する全ての API` に対して、 `Alibaba Cloud API Gateway` の SDK 自動生成機能を利用して生成した Java 用の SDK です。

API Gateway Java SDK は github 上にも公開しています。参照：[Github](https://github.com/aliyun/apigateway-sdk-core)

> **注意**

- 全ての API は `グループ`、`リージョン` で管理されます。

- `{{groupName}}` は API が所属しているグループ名で、`{{regionId}}` はグループが所属しているリージョンを表します。

- `{{locale}}` は ロケール/言語を表します。

ソースコード構造は以下になります：

* SDK ディレクトリ
	* sdk/{{regionId}}		`Java SDK ディレクトリ，グループ内の全 API リクエスト用コードを含めています`
		* HttpsApiClient{{groupName}}.java	`グループに所属している API のリクエスト実装(同期/非同期)`
		* ApiExecutor{{groupName}}.java	`リクエストの例`
	* doc/{{regionId}}
		* ApiDocument{{groupName}}.{{locale}}.md	`グループに所属している API のドキュメント`
	* lib
		* sdk-core-java-1.1.7.jar `core パッケージ、この SDK の依存パッケージ`
		* sdk-core-java-1.1.7-javadoc.jar		`上記のパッケージのドキュメント`
        * sdk-core-java-1.1.7-sources.jar		`上記のパッケージのソースコード`
	* Readme.{{locale}}.md	`SDK ユーザガイド`
	* LICENSE `ライセンスの説明`

# 2. SDK 使用
## 2.1. 事前準備

 1. Alibaba Cloud API Gateway の Java SDK を利用するには `JDK 1.6` 以上のバージョンが必要です。
 2. 署名のために権限付与済みのキーペアを用意する必要があります。参照：[AppKeyとAppSecretについて](https://www.alibabacloud.com/help/en/doc-detail/44396.html)

    > **注意：APP_KEY と APP_SECRET は Alibaba Cloud API Gateway がユーザのリクエストを認証する鍵であり、クライアント側に保存する場合、暗号化する必要があります。**

 3. pom.xmlファイルに追加：

    ```xml
    <dependency>
        <groupId>com.aliyun.api.gateway</groupId>
        <artifactId>sdk-core-java</artifactId>
        <version>1.1.7</version>
    </dependency>
    <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
            <version>2.13.1</version>
    </dependency>
    ```

## 2.2. API リクエスト用 SDK クラス導入

1. sdk フォルダの中の `HttpsApiClient*.java` をプロジェクトフォルダにコピーします。
2. 必要に応じてpackageを更新します。

## 2.3. Api Client 初期化
Alibaba Cloud API Gateway にリクエストを送信するため、`ApiClient` オブジェクトを作成する必要があります。`ApiExecutor*.java` のサンプルコードをご参考にできます。`newBuilder()` を使って `ApiClientBuilder` オブジェクトで `ApiClient` を作成できます。

```java
public ApiExecutor{{group}}() {
    this.asyncClient = HttpsApiClient{{group}}.newBuilder()
        .appKey("your app key here")
        .appSecret("your app secret here")
        .build();
}
```

> **注意**
- `ApiClientBuilder` の大部分のメソッドはカレントオブジェクトを返すようにしています。メソッドを組み合わせて呼び出すと利便性と可読性が向上します。
- 必要なプロパティを全部設定したら、`build()` をコールすることでクライアントを作成できます。作成した `ApiClient` は変更できません。
- `ApiClientBuilder` は同じ設定を使って複数のクライアントを作成できます。利用する際に注意すべきなのは、`ApiClientBuilder` は可変ノンスレッドセーフであることです。
- 作成した `ApiClient` は**スレッドセーフ**なもの，独立なコネクションプール/スレッドプールのリソースを持ち、パフォーマンス向上のため、永続オブジェクトにすべきです。

## 2.4. API インターフェース

SDK は Alibaba Cloud API Gateway で定義したパラメータに基づいて生成したものです。各 API をそれぞれメソッドにラップしました。`ApiExecutor*.java` 内のサンプルコードをご参考に呼び出す事ができます。

そして、SDK はシングルトンモードでパッケージングしました。`HttpsApiClient{{group}}.getInstance()` を利用することでチャネルクラスの ApiClient オブジェクトを取得できます。各APIには、同期と非同期の呼び出しメソッドが用意されており、呼び出しの例を以下に示します。

````java
//　Example of asynchronous call
// 非同期呼び出しの例
public void test06HttpCommon() throws Exception {
	HttpsClientUnitTest.getInstance().getUser(userId, new ApiCallback() {
		@Override
		public void onFailure(ApiRequest request, Exception e) {
			e.printStackTrace();
		}

		@Override
		public void onResponse(ApiRequest request, ApiResponse response) {
			try {
				System.out.println(response.getCode());
				System.out.println(response.getMessage());
				System.out.println(response.getFirstHeaderValue("x-ca-request-id"));
			}catch (Exception ex){
				ex.printStackTrace();
			}
		}
	});
}

// Example of synchronous call
// 同期呼び出しの例
public void test06HttpGetUser(int userId) throws Exception {
	ApiResponse response = HttpsClientUnitTest.getInstance().getUserSyncMode(userId);
	System.out.println(response.getCode());
	System.out.println(response.getMessage());
	System.out.println(response.getFirstHeaderValue("x-ca-request-id"));
}
````

> **注意**
- まず一つのオブジェクトを `build()` してから、`getInstance()` をご利用できるようになります。そうしないとエラーになります。
- 複数の同じ ApiClient を `build()` したら、`getInstance()` は最後の一回の `build()` で生成したオブジェクトを返します。
- メインスレッドが応答待ちの間ずっとハングアップしないように、非同期呼び出しを使用することが推奨されます。

# 3. 高度な使用シーン
`sdk-core-java-1.1.7` は ApacheHttpClient_4.5.2 を基礎 HTTP クライアントとして用いて、いろんな設定を含めています。`ApiClientBuilder` はメジャーなシーンしかカバーしていませんが、柔軟で便利なインタフェースを提供しています。それらのインタフェースを使って OkHttp3 などの基礎 HTTP クライアントを利用することもできます。

## 3.1. もっと詳細な ApacheHttpClient の設定

こちらの [ApacheHttpClientドキュメント](https://hc.apache.org/httpcomponents-client-4.5.x/current/tutorial/html/index.html) の方法に基づいて自分で作成できます。自分で作成した [HttpClientBuilder](https://hc.apache.org/httpcomponents-client-4.5.x/current/httpclient/apidocs/org/apache/http/impl/client/HttpClientBuilder.html) を、2.3章の `ApiClientBuilder` に `builder.setExtraParam("apache.httpclient.builder", ${apacheBuilder})` をコールします。そうすることで `HttpClientBuilder` の全てのパラメータを `ApiClientBuilder` に導入できます。

```java
HttpClientBuilder apacheHttpClientBuilder = HttpClientBuilder.create()
    .setHttpProcessor(new MyHttpProcessor())
    .setDefaultRequestConfig(
        RequestConfig.custom()
            .setConnectTimeout(5000)
            .build())
    .disableAuthCaching();

SyncApiClient{{group}} syncClient = SyncApiClient{{group}}.newBuilder()
    .appKey("your app key here")
    .appSecret("your app secret here")
    .connectionTimeoutMillis(10000L) //this will overwrite 5000 to 10000
    .setExtParams("apache.httpclient.builder", apacheHttpClientBuilder)
    .build();
```

> **注意**
- もし `HttpClientBuilder` と `ApiClientBuilder` の同じパラメータに違う値を設定したら、順番に関係なく、`ApiClientBuilder` が優先されます。
- 上記のサンプルコードの中に作成した `SyncApiClient` の `connectionTimeout` は `10000L`。

## 3.2. カスタマイズ HttpClient の使用

カスタマイズ HttpClient (例えば OkHttp3) を利用したい場合、`com.alibaba.cloudapi.sdk.core.HttpClient` を継承すれば利用できます。

builder にパラメータを渡す場合、`setExtParams` でカスタマイズパラメータを渡すことができます。これらのパラメータは `HttpClient` の `init()` メソッドのパラメータとして渡されます。具体的にはこちらをご参考にできます: `com.alibaba.cloudapi.sdk.core.http.ApacheHttpClient`。

カスタマイズ HttpClient を使う場合、サービスを起動するときに、`-Daliyun.sdk.httpclient="${class}"` パラメータを追加します。`${class}` はカスタマイズ `HttpClient` のインタフェース実装クラスのフルネームです（パッケージを含む）。

> `-Daliyun.sdk.httpclient` のデフォルト値は `"com.alibaba.cloudapi.sdk.core.http.ApacheHttpClient"`

```java
import com.alibaba.cloudapi.sdk.core.HttpClient

public class MyHttpClient extends HttpClient {

    private CustomHttpClient customHttpClient;

    @Override
    protected void init(BuilderParams builderParams) {
        // init your customHttpClient with params
        Object config1 = builderParams.getExtra("key1");
        Object config2 = builderParams.getExtra("key2");
        customHttpClient = new CustomHttpClient(config1, config2);
    }

    @Override
    public ApiResponse syncInvoke(ApiRequest request) throws IOException {
        // parse request
        CustomeHttpRequest httpRequest = parseToHttpRequest(request);

        // send http request
        CustomeHttpResponse httpResponse = customHttpClient.execute(httpRequest);

        // parse response
        return parseToApiResponse(httpResponse);
    }

    @Override
    public Future<ApiResponse> asyncInvoke(ApiRequest request, ApiCallBack callback) {
        // do async
    }

    @Override
    public void shutdown() {
        // release your custom httpclient
        customHttpClient.shutdown();
    }
}
```

# 4. よくある質問
## 4.1. 高い同時実行処理(High Concurrency)シナリオのための SDK の設定方法
Java SDK では、開発者は要求された HTTP 接続プールの詳細を設定して、`高い同時実行性`のシナリオに対応することができます。例えば次のような一般的な構成が可能です。

```java
HttpClientBuilderParams httpsParam = new HttpClientBuilderParams();
httpsParam.setAppKey("");
httpsParam.setAppSecret("");

// Thread pool in connection pool
// 接続プール内のスレッドプール
httpsParam.setExecutorService(Executors.newFixedThreadPool(100));
// Maximum number of simultaneous connections overall
// 全体の最大同時接続数
httpsParam.setDispatchMaxRequests(200);
// Maximum number of simultaneous connections per backend domain
// バックエンドドメインごとの最大同時接続数
httpsParam.setDispatchMaxRequestsPerHost(200);
// Read timeout of request
// リクエストの読み込みタイムアウト
httpsParam.setReadTimeout(15000L);

HttpsApiClientWithThreadPool.getInstance().init(httpsParam);
```
接続プールのスレッド数や最大同時接続数は、実際の状況に応じて設定する必要があり、大きければ大きいほど良いというわけではなく、高い同時実効処理の経験を持つエンジニアが設定する必要があります。

なお、通常のクライアント呼び出しシナリオで高い同時実行性が要求されない場合は、スレッドプールや同時接続数を設定する必要はなく、デフォルトの設定で最適です。

## 4.2. クライアントタイムアウトの設定
SDK のデフォルトのタイムアウトは `10秒` ですが、個別に設定する必要がある場合は、以下のコードを参照してください。

バックエンドからレスポンスが戻る前にクライアントがタイムアウトしたと思って切断してしまわないように、API 定義ではクライアントのタイムアウトをバックエンドのタイムアウトより長く設定することが重要である。

```java
HttpClientBuilderParams httpsParam = new HttpClientBuilderParams();
httpsParam.setAppKey("");
httpsParam.setAppSecret("");

// Read timeout of request
// リクエストの読み込みタイムアウト
httpsParam.setReadTimeout(15000L);
// Write timeout of request
// リクエストの書き込みタイムアウト
httpsParam.setWriteTimeout(15000L);
// Timeout for connection establishment
// 接続確立のためのタイムアウト
httpsParam.setConnectionTimeout(15000L);

HttpsApiClientWithThreadPool.getInstance().init(httpsParam);
```

## 4.3. 自動リトライの設定
ネットワークの問題で Alibaba Cloud API Gateway へのリクエスト送信が失敗した場合、SDK が自動的に対応するリクエストを再送信する自動リトライを設定することが可能です。

```java
HttpRequestRetryHandler myRetryHandler = new HttpRequestRetryHandler() {

    public boolean retryRequest(IOException exception, int executionCount, HttpContext context) {
        if (exception == null) {
                throw new IllegalArgumentException("Exception parameter may not be null");
        }
        if (context == null) {
                throw new IllegalArgumentException("HTTP context may not be null");
        }

        /**
         * It is recommended to do idempotent judgment, 
         * 　　　　　non-idempotent request is not recommended to retry, 
         * 　　　　　code omitted
         * 偶発的な判定を推奨、非偶発的なリクエストは再試行を推奨しない、コード省略
         */

        // It is recommended to retry at most once
        // リトライの推奨回数は最大1回
        if (executionCount < 2) {
                return true;
        }

        // TCP connection is broken, retry is recommended
        // TCP 接続不良、リトライを推奨
        if (exception instanceof NoHttpResponseException) {
                return true;
        }

        // Connection is disconnected by the server, retry according to the situation
        // サーバによって接続が切断、状況に応じてリトライ
        //if (exception instanceof ConnectionResetException) {
        //	return true;
        //}

        return false;
    }
};

HttpClientBuilderParams httpsParam = new HttpClientBuilderParams();
httpsParam.setAppKey("");
httpsParam.setAppSecret("");
httpsParam.setRequestRetryHandler(myRetryHandler);
HttpsApiClientWithThreadPool.getInstance().init(httpsParam);
```

## 4.4. 同じクライアントオブジェクトに複数の HOST 呼び出しが必要な場合
バックエンドの1つの HOST と通信する際、クライアントが長い接続を張るように SDK は設計されていますが、同じクライアントオブジェクトに対して複数の HOST を呼び出す必要があるシナリオでは、次のように設定することが可能です。

```java
public void invokeApi(String CaMarketExperiencePlan, byte[] body, ApiCallback callback) {
    String path = "/rest/160601/ocr/ocr_vehicle.json";
    ApiRequest request = new ApiRequest(HttpMethod.POST_BODY, path, body);
    request.addParam("CaMarketExperiencePlan", CaMarketExperiencePlan, ParamPosition.HEAD, false);
    request.setHttpConnectionMode(HttpConnectionModel.MULTIPLE_CONNECTION);
    request.setScheme(Scheme.HTTPS);
    request.setHost("www.aliyun.com");

    sendAsyncRequest(request, callback);
}
```

## 4.5. ContentType の設定
SDK はデフォルトでいろんな Body に対して ContentType を追加しますが、ContentType ヘッダーを追加することで、ユーザ独自の ContentType を定義することも可能です。

```java
public void invokeApi(String CaMarketExperiencePlan, byte[] body, ApiCallback callback) {
    String path = "/postXml";
    ApiRequest request = new ApiRequest(HttpMethod.POST_BODY, path, body);
    request.addHeader(HttpConstant.CLOUDAPI_HTTP_HEADER_CONTENT_TYPE, HttpConstant.CLOUDAPI_CONTENT_TYPE_XML);

    sendAsyncRequest(request, callback);
}
```

# 5. サポート
サポートが必要な場合は、お問い合わせください。