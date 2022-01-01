
/**
 * 引导引出：在优先级综合算法里面涉及到了一个权重分配的情况，为什么是人为定义这个权重？
 * 助力问题：数据过少 , 通过 机器学习 0.8%的完整数据 很难正确的 决定 99.2%的大量缺失的数据( 甚至大量数据 存在 多维度的空缺少 )。
表：a_yxj_cjdj 残疾等级权重 25%
表：a_yxj_jkzkdj 健康状况权重 20%   
表：a_yxj_ldjndj 劳动技能权重 20%
表：a_yxj_jtryswzbdj 家庭人员死亡占比权重  15%
表： a_yxj_whcddj 文化程度等级权重 10%   
表：a_yxj_sxdcdj 授信档次权重 5% 
表：a_yxj_jtsgdj 交通事故权重 5% 
 */ 


/**
 * 潜在返贫表构建序号：1.1
 *目标：将所有的指标表 的身份证 都合并起来，并重复 的进行去重  
 *注意定：以下代码 最后 都建立相应的索引 不然运行很慢 
 */
create table a_yxj_zh_tmp as (-- 综合临时表 
	select CYSFZ from ( -- 53792条 
		select CYSFZ from a_yxj_cjdj   -- 53030
		union 
		select CYSFZ from a_yxj_jkzkdj  
		union
		select CYSFZ from a_yxj_ldjndj
		union
		select CYSFZ from a_yxj_jtryswzbdj 
		union
		select CYSFZ from a_yxj_whcddj 
		union
		select CYSFZ from a_yxj_sxdcdj 
		union
		select CYSFZ from a_yxj_jtsgdj 
		) as res1 
		where  CYSFZ is not null 
	)
	
select * from a_yxj_zh_tmp
	
/**
 * 潜在返贫表  构建序号：1.2
 * 目标：对表的数据进行拼接操作
 */
create or replace view res1 as ( -- 第一次拼接 
	select a_yxj_zh_tmp.CYSFZ,JTXX_ID,offset as cjdj_offset from 
	a_yxj_zh_tmp  left join a_yxj_cjdj on a_yxj_zh_tmp.CYSFZ =a_yxj_cjdj.CYSFZ
	)  

		
create or replace view res2 as ( -- 第二次拼接 
	select res1.*, offset  as jkzkdj_offset from 
	res1  left join a_yxj_jkzkdj on res1.CYSFZ =a_yxj_jkzkdj.CYSFZ
	) 

create or replace view res3 as ( -- 第三次拼接 
	select res2.*, offset  as ldjndj_offset from 
	res2  left join a_yxj_ldjndj on res2.CYSFZ =a_yxj_ldjndj.CYSFZ
	) 


create or replace view res4 as ( -- 第四次拼接 
	select res3.*, offset  as jtryswzbdj_offset from 
	res3  left join a_yxj_jtryswzbdj on res3.CYSFZ =a_yxj_jtryswzbdj.CYSFZ
	) 

create or replace view res5 as ( -- 第五次拼接 
	select res4.*, offset  as whcddj_offset from 
	res4  left join a_yxj_whcddj on res4.CYSFZ =a_yxj_whcddj.CYSFZ
	) 

create or replace view res6 as ( -- 第六次拼接 
	select res5.*, offset  as sxdcdj_offset from 
	res5  left join a_yxj_sxdcdj on res5.CYSFZ =a_yxj_sxdcdj.CYSFZ
	) 

create or replace view res7 as ( -- 第七次拼接 
	select res6.*, offset  as jtsgdj_offset from 
	res6  left join a_yxj_jtsgdj on res6.CYSFZ =a_yxj_jtsgdj.CYSFZ
	) 

/**
 *  潜在返贫表  构建序号：1.3
 * 目标：实现 优先级综合算法
 * 公式：综合优先级公式 = 某学生在A类的"M属性排名等级偏差" x a% + 某学生在B类的"N属性排名等级的偏差" x b% + …。排名降序=优先级
 */
create table a_yxj_zh_tmp1 as (
	select 
		CYSFZ,
		JTXX_ID,
		(ifNULL(cjdj_offset,0) * 0.25 + 
		ifNULL(jkzkdj_offset,0) * 0.2 + 
		ifNULL(ldjndj_offset,0) * 0.2 + 
		ifNULL(jtryswzbdj_offset,0) * 0.15 +
		ifNULL( whcddj_offset,0) * 0.1 + 
		ifNULL(sxdcdj_offset,0) * 0.05 + 
		ifNULL(jtsgdj_offset,0) * 0.05
		) as zh_offset -- 潜在返贫风险系数 ifNULL(字段,未null情况返回arg2)
	 from res7
	 order by zh_offset desc 
 )
 

 
/**
 * 潜在返贫表  构建序号：1.4
 * 目标：对存在有相同的身份证 ，进行系数合并 （因为有些维度 有些 存在成员存在两次以上）
 */
select count( distinct CYSFZ) from a_yxj_zh_tmp1   -- 53791
select count(  CYSFZ) from a_yxj_zh_tmp1   -- 53794 

create table a_yxj_zh as ( 
	select CYSFZ,JTXX_ID,sum(zh_offset ) as zh_offset from a_yxj_zh_tmp1
	group by CYSFZ 
	order by  zh_offset desc
	)

-- drop table a_yxj_zh_tmp -- 删除临时表  可选 ，但建议 不要删除，删除的话 又要重新运行一遍，比较麻烦
-- drop table a_yxj_zh_tmp1 -- 删除临时表 

/**
 * 潜在返贫家庭归并表  构建序号：1.6
 * 目标：对存在有相同的家庭的人员 ，进行系数合并
 */
create or replace view a_yxj_zh_tmp2 as (
	select JTXX_ID ,count(*) as JT_RS ,sum(zh_offset) as  zh_offset -- JT_RS 表示家庭的人数 
	from a_yxj_zh  where JTXX_ID is not null   -- 这里之所以存在空 是因为之前做了全面的匹配过了 没有 对应的家庭id 
	group by JTXX_ID
	)
	
create table a_yxj_zh_JT as (
	select a_yxj_zh_tmp2.JTXX_ID,JT_RS,zh_offset -- 
		from a_yxj_zh_tmp2 left join t_xczxj_jtxx  -- t_xczxj_jtxx 表的id 还是不全面 ，是缺漏的 
		on a_yxj_zh_tmp2.JTXX_ID = t_xczxj_jtxx.ID   
		order by zh_offset desc 
	)












