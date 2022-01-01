package test2;

import com.alibaba.fastjson.JSONObject;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;

public class javaHttp{

    /**
     * 该方法 主要使用于 带了json参数(不带也行)的get或post请求
     * @param url 传入的URL地址
     * @return
     */

    static String url="http://icard.ylapi.cn/id_card/query.u?uid=11979&appkey=6088ec0db9793af8db23534f0864d7c6&idnumber=";

    public static JSONObject deviceRequest(String id) throws IOException {

        JSONObject result = null;

        // 创建httpclient
        @SuppressWarnings({"resource"})
        HttpClient httpClient = new DefaultHttpClient();

        // 传入post
        HttpPost post = new HttpPost(url+id);

        // 执行请求
        HttpResponse response = httpClient.execute(post);

        // 获取请求结果
        String data = EntityUtils.toString(response.getEntity());
        result = (JSONObject) JSONObject.parse(data);

        return result;
    }

    public static  void writer (String filePatch,Object data) throws IOException {
        // 数据写出
        FileWriter fileWriter = new FileWriter(filePatch); // 写出文件的时候 要注意记得 flush和close 否则数据会丢失部分
        BufferedWriter bufferedWriter = new BufferedWriter(fileWriter);
        bufferedWriter.write(jsonFormatPrint.formatOut(data.toString()));
        bufferedWriter.flush();
        bufferedWriter.close();
        System.out.println(data);
    }
}


