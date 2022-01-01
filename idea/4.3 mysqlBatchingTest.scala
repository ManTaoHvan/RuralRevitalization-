package test2

import org.apache.flink.api.common.typeinfo.BasicTypeInfo
import org.apache.flink.api.java.io.jdbc.{JDBCInputFormat}
import org.apache.flink.api.java.typeutils.RowTypeInfo
import org.apache.flink.api.scala.{DataSet, ExecutionEnvironment}
import org.apache.flink.types.Row

import scala.language.postfixOps
import org.apache.flink.streaming.api.scala._


object mysqlBatchingTest {

  // 存储get的jison 数据
  val strData = new StringBuilder

  def main(args: Array[String]): Unit = {

    // 创建环境
    val env = ExecutionEnvironment.getExecutionEnvironment

    // 创建对象读取数据库
    val sqldataRead:DataSet[Row] = env.createInput(new mysqlsource().jdbcInputFormat)

    // 读取数据库的数据
    val data1= sqldataRead.map(
      a =>{ new mysqlReadData(a.getField(0).toString) //getField(int) 返回的是对象类型 所以参数就要求是Any类型 ，数组索引从零开始 ，但获取mysql的数据要多取一列，因为最后的一列是不能读取的
      })

    var i=0
    // 存储数据
    data1.map({ a =>
      // 请求数据 获取人员的基本信息
      val data = javaHttp.deviceRequest(a.idcard)
      strData.append(data + ",\n")
      println("请求中...." + i)
      i=i+1
    }).collect()

    // 数据写出
    javaHttp.writer("C:\\Users\\HMTX\\Desktop\\tmp\\3.json", "{" + "\"getdata\"" + ":" + "[" + strData.dropRight(2) + "]}") // 拼接下jison 数据要求的个格式 ,dropRight(2)是输出最后的一个分号和换行

    // 环境执行
    env.execute()

  }

}

/**
  * 连接数据的环读取境
  */
class mysqlsource() {

  def jdbcInputFormat:JDBCInputFormat = { // 创建自定义的输入类型
    val data=JDBCInputFormat.buildJDBCInputFormat.setDrivername("com.mysql.jdbc.Driver") // 设置驱动、url、用户名、密码以及查询语句
      .setDBUrl("jdbc:mysql://localhost:3306/xczx") // 地址
      .setUsername("root") // 账号
      .setPassword("a") // 密码
      .setQuery("select distinct CYSFZ,JTXX_ID,CYXM from  t_xczxj_jtcyxx  where CYSFZ is not null limit 1,2000  ")
        .setRowTypeInfo(new RowTypeInfo(BasicTypeInfo.STRING_TYPE_INFO, BasicTypeInfo.STRING_TYPE_INFO, BasicTypeInfo.INT_TYPE_INFO))  //设置类型
      .finish
    return data
  }
}

/**
  * 数据库读取身份证的样本类
  * @param idcard
  */
case  class  mysqlReadData(idcard:String){  // 读取数据库的 身份证 // AnyVal代表值类型，AnyRef代表引用类型
  override def toString(): String ={"idcard: "+ idcard }
}



