/**
 * 前言注意点：大部分数据是字符型 但发现 自动类型转换的时候 存在数据 漏掉，但加入了强制类型转换 有全部转换成功 所以这点 要注意 尽量用强制 类型转换
 *身份证号是字符型 里面还可能包含字母 在进行表表连接 要注意 这点 
 */

-- 1.残疾等级偏差指标===========================================================
/*
 * 数据初始化序号：1.1
 * 目标：官网数据异常，对原表的数据进行一个更新操作， 残疾等级 进行一个数据替换，发现里面的数据标识不统一
 * 涉及表：a_gy_jxcyxx 
 */
UPDATE t_xczxj_jtcyxx SET CJDJ = 
	    CASE CJDJ 
	        WHEN '无' THEN 0 
	        WHEN '肆级' THEN 1 
	        WHEN '一级' THEN 1 
	        WHEN '二级' THEN 2 
	        WHEN '三级' THEN 3
	        WHEN '四级' THEN 4
	    end 
	WHERE CJDJ IN ('无','肆级','一级','三级','二级','四级');

UPDATE t_xczxj_jtcyxx 	SET CJDJ =0  where CJDJ is null;

/**
 * 残疾等级偏差指标 序号：1.2
 * 目标：获取家庭残疾等级， 扶贫等级越高表明残疾越严重，那么偏差也就越高 
 */
create table a_yxj_cjdj_tmp ( 
	select -- 先获取一个子查询 
		res1.JTXX_ID, -- 家庭id
		res1.CYSFZ, -- 成员身份证 
		res1.CJDJ, -- 残疾等级 共1-4级 0是正常 
		CASE -- 以下是3条判断条件 
		  WHEN @Tmp = res1.CJDJ  THEN  @grade  -- 第一次CJDJTmp 是为null，不会走这条语句
		  WHEN @Tmp := res1.CJDJ  THEN  @grade := @grade + 1 -- := 非0的赋值为true，为0的赋值为false。第一次CJDJTmp 
		  WHEN @Tmp = 0  THEN  @grade := @grade + 1 -- := 如果上面的为false 那么 就走这条语句 
		END AS grade
	FROM (select 
	    JTXX_ID,
	    CYSFZ,
	    cast(txj.CJDJ as SIGNED) as CJDJ
	    from t_xczxj_jtcyxx txj 
		ORDER by cast(txj.CJDJ as SIGNED)   asc 
		) as res1, --  第一个结果集合 
		(SELECT
		 @grade := 0, -- 设置初始值为0 表示等级 
		 @Tmp := null -- 临时保存上条数据的排名, 第一次设置为null 
		) as res2  -- 第二个结果集合 res2这个名字 一定要取名, 虽然前面 不需要 用到这个别名 ，但这是必要的
	);
select * from a_yxj_cjdj_tmp;

/**
 * 残疾等级偏差指标序号：1.3
 * 目标：计算等级偏差，扶贫等级越高表明残疾越严重，那么偏差也就越高 
 */
select sum(grade)/count(grade)  into @PJ_CJDJ from a_yxj_cjdj_tmp where grade is not null  ; -- 设置一个变量 保存 这个 等级平均数  ,但 为了保证 代码的规范 这里过滤下 null 。
select @PJ_CJDJ; -- 查询 这个 平均数  
create table a_yxj_cjdj as( select JTXX_ID,CYSFZ,CJDJ ,grade,(grade-@PJ_CJDJ) as offset  from a_yxj_cjdj_tmp);  -- 偏差 = 单个值 - 平均值
select * from a_yxj_cjdj; -- 查询
drop table a_yxj_cjdj_tmp; -- 删除临时表 

-- 2.不健康等级偏差指标===========================================================
/**
 * 不健康等级偏差指标 序号：2.1
 * 目标：获取不健康状况等级， 扶贫等级越高表明不健康等级越高，那么偏差也就越高 
 */
create table a_yxj_jkzkDJ_tmp ( 
	select -- 先获取一个子查询 
		res1.JTXX_ID, -- 家庭id
		res1.CYSFZ, -- 成员身份证 
		res1.JKZK, -- 健康状况  1健康、2长期慢性病、3大病、4残疾
		CASE -- 以下是3条判断条件 
		  WHEN @Tmp = res1.JKZK  THEN  @grade  -- 第一次CJDJTmp 是为null，不会走这条语句
		  WHEN @Tmp := res1.JKZK  THEN  @grade := @grade + 1 -- := 非0的赋值为true，为0的赋值为false。第一次CJDJTmp 
		  WHEN @Tmp = 0  THEN  @grade := @grade + 1 -- := 如果上面的为false 那么 就走这条语句 
		END AS grade
	FROM (select 
	    JTXX_ID,
	    CYSFZ,
	    cast(txj.JKZK  as SIGNED) as JKZK
	    from t_xczxj_jtcyxx txj 
		ORDER by cast(txj.JKZK as SIGNED)   asc 
		) as res1, --  第一个结果集合 
		(SELECT
		 @grade := 0, -- 设置初始值为0 表示等级 
		 @Tmp := null -- 临时保存上条数据的排名, 第一次设置为null 
		) as res2 -- 第二个结果集合 res2这个名字 一定要取名, 虽然前面 不需要 用到这个别名 ，但这是必要的
	); 
select * from a_yxj_jkzkDJ_tmp;

/**
 * 不健康状况等级偏差指标序号：2.2
 * 目标：计算等级偏差， 扶贫等级越高表明不健康等级越高，那么偏差也就越高 
 */
select sum(grade)/count(grade)  into @PJ_JKZK from a_yxj_jkzkDJ_tmp where  grade is not null  ; -- 设置一个变量 保存 这个 等级平均数  注意成员支持在部分表没有数据，指标统计的时候，也会照样统计为null ,即 该成员 在最后放弃部分加权的维度，这样 扶贫的等级也会降低。 
select @PJ_JKZK; -- 查询 这个 平均数  
create table a_yxj_jkzkDJ as(select JTXX_ID,CYSFZ,JKZK ,grade,(grade-@PJ_JKZK) as offset  from a_yxj_jkzkDJ_tmp ); -- 偏差 = 单个值 - 平均值
select * from a_yxj_jkzkDJ; -- 查询表 
drop table a_yxj_jkzkDJ_tmp; -- 删除临时表 

-- 3.劳动技能弱等级偏差指标===========================================================
/**
 * 序号：3.1
 *  目标：官网数据异常，做因更新
 */
update  t_xczxj_jtcyxx set LDJN = null where cast(LDJN as SIGNED)  = 0  -- 劳动技能 0在官网 为提供 数据含义 目前 本人 推测是null的含义 ，劳动技能（1技能劳动力 2普通劳动力 3弱劳动力或半劳动力 4丧失劳动力 5无劳动力） 

/**
 * 劳动技能弱等级偏差指标 序号：3.1
 * 目标：获取劳动技能弱的等级 ，扶贫等级越高表明劳动技能越弱，那么偏差也就越高 
 */
create table a_yxj_ldjnDJ_tmp ( 
	select -- 先获取一个子查询 
		res1.JTXX_ID, -- 家庭id
		res1.CYSFZ, -- 成员身份证 
		res1.LDJN, -- 劳动技能（1技能劳动力 2普通劳动力 3弱劳动力或半劳动力 4丧失劳动力 5无劳动力）
		CASE -- 以下是3条判断条件 
		  WHEN @Tmp = res1.LDJN  THEN  @grade  -- 第一次CJDJTmp 是为null，不会走这条语句
		  WHEN @Tmp := res1.LDJN  THEN  @grade := @grade + 1 -- := 非0的赋值为true，为0的赋值为false。第一次CJDJTmp 
		  WHEN @Tmp = 0  THEN  @grade := @grade + 1 -- := 如果上面的为false 那么 就走这条语句 
		END AS grade
	FROM (select 
	    JTXX_ID,
	    CYSFZ,
	    cast(txj.LDJN  as SIGNED) as LDJN
	    from t_xczxj_jtcyxx txj 
		ORDER by cast(txj.LDJN as SIGNED)   asc 
		) as res1, --  第一个结果集合 
		(SELECT
		 @grade := 0, -- 设置初始值为0 表示等级 
		 @Tmp := null -- 临时保存上条数据的排名, 第一次设置为null 
		) as res2 -- 第二个结果集合 res2这个名字 一定要取名, 虽然前面 不需要 用到这个别名 ，但这是必要的
	); 
select * from a_yxj_ldjnDJ_tmp;

/**
 * 劳动技能弱等级偏差指标序号：3.2
 * 目标：计算等级偏差，扶贫等级越高表明劳动技能越弱，那么偏差也就越高 
 */
select sum(grade)/count(grade)  into @PJ_LDJN from a_yxj_ldjnDJ_tmp where grade is not null ; -- 设置一个变量 保存 这个 等级平均数 
select @PJ_LDJN; -- 查询 这个 平均数  
create table a_yxj_ldjnDJ as(select JTXX_ID,CYSFZ,LDJN ,grade,(grade-@PJ_LDJN) as offset  from a_yxj_ldjnDJ_tmp ); -- 偏差 = 单个值 - 平均值
select * from a_yxj_ldjnDJ; -- 查询表 
drop table a_yxj_ldjnDJ_tmp; -- 删除临时表 

-- 4.文化程度低等级偏差指标===========================================================

/**
 * 文化程度低等级偏差指标 序号：4.1
 * 目标：获取文化程度低的等级 ，扶贫等级越高表明文化程度低越低，那么偏差也就越高 
 */
create table a_yxj_whcdDJ_tmp ( 
	select -- 先获取一个子查询 
		res1.JTXX_ID, -- 家庭id
		res1.CYSFZ, -- 成员身份证 
		res1.whcd, -- 文化程度 1文盲或半文盲、2小学，3初中，4高中，5大专，6本科以上
		CASE -- 以下是3条判断条件 
		  WHEN @Tmp = res1.WHCD  THEN  @grade  -- 第一次CJDJTmp 是为null，不会走这条语句
		  WHEN @Tmp := res1.WHCD  THEN  @grade := @grade + 1 -- := 非0的赋值为true，为0的赋值为false。第一次CJDJTmp 
		  WHEN @Tmp = 0  THEN  @grade := @grade + 1 -- := 如果上面的为false 那么 就走这条语句 
		END AS grade
	FROM (select 
	    JTXX_ID,
	    CYSFZ,
	    cast(txj.whcd  as SIGNED) as WHCD
	    from t_xczxj_jtcyxx txj 
		ORDER by cast(txj.whcd as SIGNED)   desc -- 注意 这里是降序 和前面是不一样的  
		) as res1, --  第一个结果集合 
		(SELECT
		 @grade := 0, -- 设置初始值为0 表示等级 
		 @Tmp := null -- 临时保存上条数据的排名, 第一次设置为null 
		) as res2 -- 第二个结果集合 res2这个名字 一定要取名, 虽然前面 不需要 用到这个别名 ，但这是必要的
	); 
select * from a_yxj_whcdDJ_tmp;

/**
 * 文化程度低等级偏差指标序号：4.2
 * 目标：计算等级偏差，扶贫等级越高表明文化程度低，那么偏差也就越高 
 */
select sum(grade)/count(grade)  into @PJ_WHCD from a_yxj_whcdDJ_tmp where grade is not null ; -- 设置一个变量 保存 这个 等级平均数 
select @PJ_WHCD; -- 查询 这个 平均数  
create table a_yxj_whcdDJ as(select JTXX_ID,CYSFZ,WHCD ,grade,(grade-@PJ_WHCD) as offset  from a_yxj_whcdDJ_tmp ); -- 偏差 = 单个值 - 平均值
select * from a_yxj_whcdDJ; -- 查询表 
drop table a_yxj_whcdDJ_tmp; -- 删除临时表 



-- 5.人员自身病死家庭占比高等级偏差指标===========================================================


/**
 * 目标：获取家庭的总人数 
 *  备注：疑问：家庭成员信息 里面 是否 含有户主身份证 ，答：含有户主身份证，(但发现 有部分数据  是同一家家庭,却没户主身份证的标识)
 */
create or replace view  JTRYcountTmp as (
	select  JTXX_ID,count(*) as JTRYcount  from t_xczxj_jtcyxx txj 
	group by JTXX_ID 
)
select * from  JTRYcountTmp

/**
 * 目标：获取死亡原因和对应的家庭 id
 */
create or replace view  JTRYSWWTmp as (
	select  
		txj.JTXX_ID,
		txw.CYSFZH,
		txw.SWYY
	from t_xczxj_jtcyxx txj right join  t_xczxj_wjbmxx  txw -- where 放在效率高 但这就不支持 视图
	on txj.CYSFZ = txw.CYSFZH 
	where SWYY is not null 
)
select * from  JTRYSWWTmp -- 306 条


/**
 * 目标：统计人数占比
 */
create table JTRYSWZBtmp as 
	( select JTRYSWWTmp.JTXX_ID,JTRYSWWTmp.CYSFZH,JTRYSWWTmp.SWYY, 1/JTRYcountTmp.JTRYcount as JTRYSWZB -- JTRYSWZB 表示 人员自身在家庭中的死亡占比 
	from  JTRYSWWTmp left join JTRYcountTmp   -- 这里 为什么是 1/JTRYcountTmp.JTRYcount 因为 1表示他自己一人 
	on JTRYSWWTmp.JTXX_ID= JTRYcountTmp.JTXX_ID -- 306条  
	)
select * from JTRYSWZBtmp


/**
 * 人员自身病死家庭占比高等级偏差指标 序号：5.1
 * 目标：获取人员自身病死家庭占比高的等级 ，扶贫等级越高表明人员自身病死家庭占比高，那么偏差也就越高 
 */
create table a_yxj_jtryswzbDJ_tmp as  (
	select -- 先获取一个子查询 
		res1.JTXX_ID, -- 家庭id
		res1.CYSFZ, -- 成员身份证 
		res1.JTRYSWZB, -- 家庭成员死亡占比 (这里指自身占比) 
		CASE -- 以下是3条判断条件 
		  WHEN @Tmp = res1.JTRYSWZB  THEN  @grade  -- 第一次CJDJTmp 是为null，不会走这条语句
		  WHEN @Tmp := res1.JTRYSWZB  THEN  @grade := @grade + 1 -- := 非0的赋值为true，为0的赋值为false。第一次CJDJTmp 
		  WHEN @Tmp = 0  THEN  @grade := @grade + 1 -- := 如果上面的为false 那么 就走这条语句 
		END AS grade
	FROM (select 
	    JTXX_ID,
	    CYSFZH as CYSFZ,
	    JTRYSWZB 
	    from JTRYSWZBtmp 
	    where JTRYSWZB <1 or JTRYSWZB is null   -- （注意 这里小于1 会null也自动过滤）死亡占比高达100% 那么 就无法实施扶贫 这里先过滤掉   当然 这里 支持 有null , 在后面的维度加权 可以 认为 放弃 这个维度 
		ORDER by JTRYSWZB asc 
		) as res1, --  第一个结果集合 
		(SELECT
		 @grade := 0, -- 设置初始值为0 表示等级 
		 @Tmp := null -- 临时保存上条数据的排名, 第一次设置为null 
		) as res2 -- 第二个结果集合 res2这个名字 一定要取名, 虽然前面 不需要 用到这个别名 ，但这是必要的
	); 
select * from a_yxj_jtryswzbDJ_tmp; 

/**
 * 员自身病死家庭占比高等级偏差指标序号：5.2
 * 目标：计算等级偏差，员自身病死家庭占比高等级越高表明死亡占比越高，那么偏差也就越高 
 */
select sum(grade)/count(grade)  into @PJ_SWZB from a_yxj_jtryswzbDJ_tmp where grade is not null ; -- 设置一个变量 保存 这个 等级平均数 
select @PJ_SWZB; -- 查询 这个 平均数  
create table a_yxj_jtryswzbDJ as(select JTXX_ID,CYSFZ, JTRYSWZB,grade,(grade-@PJ_SWZB) as offset  from a_yxj_jtryswzbDJ_tmp ); -- 偏差 = 单个值 - 平均值
select * from a_yxj_jtryswzbDJ; -- 查询表 
drop table a_yxj_jtryswzbDJ_tmp; -- 删除临时表 

-- 6.交通事故等级偏差指标===========================================================

/**
 * 目标：获取交通事故和对应的家庭id
 */
create or replace view JTSGTmp1 as (
	select  
		txj.JTXX_ID ,
		txg.SFZH  as cysfz ,
		txg.xx as sgdd -- 事故地点 
	from t_xczxj_jtcyxx  txj  right join    t_xczxj_gajjbmxx txg -- where 放在效率高 但这就不支持 视图
	on txj.cysfz = txg.SFZH  -- 注意 匹配为null的 确实是没有家庭id的 共9条数据 
	)

/**
 * 目标：统计 该成员 对应的发送交通事故的次数 
 */
create or replace view  JTSGTmp2 as (
	select JTXX_ID,cysfz,count(cysfz) as JTSGcount  from JTSGTmp1
	group by cysfz  -- 统计 该成员 对应的发送交通事故的次数 
	) 
	
select * from  JTSGTmp2 -- 3 条

/**
 * 交通事故等级偏差指标 序号：6.1
 * 目标：获取 交通事故的等级 ，扶贫等级越高表明事故等级越高，那么偏差也就越高 
 */
create table a_yxj_jtsgDJ_tmp ( 
	select -- 先获取一个子查询 
		res1.JTXX_ID, -- 家庭id
		res1.CYSFZ, -- 成员身份证 
		res1.JTSGcount, -- 
		CASE -- 以下是3条判断条件 
		  WHEN @Tmp = res1.JTSGcount  THEN  @grade  -- 第一次CJDJTmp 是为null，不会走这条语句
		  WHEN @Tmp := res1.JTSGcount  THEN  @grade := @grade + 1 -- := 非0的赋值为true，为0的赋值为false。第一次CJDJTmp 
		  WHEN @Tmp = 0  THEN  @grade := @grade + 1 -- := 如果上面的为false 那么 就走这条语句 
		END AS grade
	FROM (select 
	    JTXX_ID,
	    CYSFZ,
	    JTSGcount
	    from JTSGTmp2
		ORDER by  JTSGTmp2.JTSGcount  asc 
		) as res1, --  第一个结果集合 
		(SELECT
		 @grade := 0, -- 设置初始值为0 表示等级 
		 @Tmp := null -- 临时保存上条数据的排名, 第一次设置为null 
		) as res2 -- 第二个结果集合 res2这个名字 一定要取名, 虽然前面 不需要 用到这个别名 ，但这是必要的
	); 
select * from a_yxj_jtsgDJ_tmp;

/**
 * 交通事故等级偏差指标序号：6.2
 * 目标：计算等级偏差，扶贫等级越高表明交通事故越高，那么偏差也就越高 
 */
select sum(grade)/count(grade)  into @PJ_JTSG from a_yxj_jtsgDJ_tmp where grade is not null ; -- 设置一个变量 保存 这个 等级平均数 
select @PJ_JTSG; -- 查询 这个 平均数  
create table a_yxj_jtsgDJ as(select JTXX_ID,CYSFZ,JTSGcount ,grade,(grade-@PJ_JTSG) as offset  from a_yxj_jtsgDJ_tmp ); -- 偏差 = 单个值 - 平均值
select * from a_yxj_jtsgDJ; -- 查询表 
drop table a_yxj_jtsgDJ_tmp; -- 删除临时表 


-- 7.边缘户评级档次低等级偏差偏差指标===========================================================

/**
 * 目标：获取边缘户评级档次低等和对应的家庭id
 */
create or replace view SXDCTmp1 as (
	select  
		txj.JTXX_ID ,
		t_xczxj_yhbmxx.SFZH  as cysfz ,
		t_xczxj_yhbmxx.PJSXDC 
	from t_xczxj_jtcyxx  txj  right join  t_xczxj_yhbmxx    -- where 放在效率高 但这就不支持 视图
	on txj.cysfz = t_xczxj_yhbmxx.SFZH  -- 注意 匹配为null的 确实是没有家庭id的 共9条数据 
	)


/**
 * 获取边缘户评级档次低等级偏差指标 序号：7.1
 * 目标：获取 获取边缘户评级档次低等级 ，扶贫等级越高表明获取边缘户评级档次低等级越高，那么偏差也就越高 
 */
create table a_yxj_sxdcDJ_tmp ( 
	select -- 先获取一个子查询 
		res1.JTXX_ID, -- 家庭id
		res1.CYSFZ, -- 成员身份证 
		res1.pjsxdc, -- 评级授信档次 A-D,D表面越困难,信用不好   
		CASE -- 以下是3条判断条件 
		  WHEN @Tmp = res1.pjsxdc  THEN  @grade  -- 第一次CJDJTmp 是为null，不会走这条语句
		  WHEN @Tmp := res1.pjsxdc  THEN  @grade := @grade + 1 -- := 非0的赋值为true，为0的赋值为false。第一次CJDJTmp 
		  WHEN @Tmp = 0  THEN  @grade := @grade + 1 -- := 如果上面的为false 那么 就走这条语句 
		END AS grade
	FROM (select 
	    JTXX_ID,
	    CYSFZ,
	    pjsxdc
	    from SXDCTmp1
		ORDER by  pjsxdc  asc 
		) as res1, --  第一个结果集合 
		(SELECT
		 @grade := 0, -- 设置初始值为0 表示等级 
		 @Tmp := null -- 临时保存上条数据的排名, 第一次设置为null 
		) as res2 -- 第二个结果集合 res2这个名字 一定要取名, 虽然前面 不需要 用到这个别名 ，但这是必要的
	); 
select * from a_yxj_sxdcDJ_tmp;

/**
 * 获取边缘户评级档次低等级偏差指标序号：7.2
 * 目标：计算等级偏差，扶贫等级越高表明获取边缘户评级档次约低，那么偏差也就越高 
 */
select sum(grade)/count(grade)  into @PJ_SXDC from a_yxj_sxdcDJ_tmp where grade is not null ; -- 设置一个变量 保存 这个 等级平均数 
select @PJ_SXDC; -- 查询 这个 平均数  
create table a_yxj_sxdcDJ as(select JTXX_ID,CYSFZ,pjsxdc ,grade,(grade-@PJ_SXDC) as offset  from a_yxj_sxdcDJ_tmp ); -- 偏差 = 单个值 - 平均值
select * from a_yxj_sxdcDJ; -- 查询表 
drop table a_yxj_sxdcDJ_tmp; -- 删除临时表 





