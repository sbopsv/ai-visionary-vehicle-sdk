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
		* sdk-core-java-1.1.7.jar `coreパッケージ、このSDKの依存パッケージ`
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
public void test06HttpCommon() throws Exception {
	HttpsClientUnitTest.getInstance().getUser(userId , new ApiCallback() {
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

//　Example of synchronous call
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

## 3.1 もっと詳細な ApacheHttpClient の設定

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

## 3.2 カスタマイズ HttpClient の使用

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

# 4.	サポート
サポートが必要な場合は、お問い合わせください。