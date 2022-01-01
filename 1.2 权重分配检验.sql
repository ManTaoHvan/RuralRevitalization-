/**
 * 引导引出：在优先级综合算法里面涉及到了一个权重分配的情况，为什么是人为定义这个权重？
 * 助力问题：数据过少 , 通过 机器学习 0.8%的完整数据 很难正确的 决定 99.2%的大量缺失的数据( 甚至大量数据 存在 多维度的空缺少 )。
 */

-- 分配权重的前提验证 ===========================================
 /**
  * 目标：首先 查看有效数据是多少
  * 结果：数据过少 , 通过 机器学习 0.8%的完整数据 很难正确的 决定 99.2%的大量缺失的数据( 甚至有些数据 存在 多维度的空缺少 )。
 */
create  or replace view  ldrrq  as ( 
	select  cysfz,CJDJ,JKZK,LDJN,WHCD from t_xczxj_jtcyxx txj  
	where   -- 残疾等级 可以为 null 
	JKZK is not  null -- 健康 不能是null
	and LDJN is not null  -- 劳动能力 不能是null
	and WHCD  is not null -- 初中文化 
)  -- 共53030条, 而 有效数据 448条数据太少 select count(*) from t_xczxj_jtcyxx txj  -- 共 53030 条 
 
/**
 *  目标：检查 单维度的数据缺失情况 
 */
select   count(*)  from  t_xczxj_jtcyxx txj 
where CJDJ is null  -- 0

 select  count(*) from  t_xczxj_jtcyxx txj 
 where jkzk  is null  -- 11233 

 select  count(*) from  t_xczxj_jtcyxx txj 
 where LDJN  is null  -- 28110 
 
 select  count(*) from  t_xczxj_jtcyxx txj 
 where whcd  is null  -- 52506 

 /**
  * 目标：检查 两维度以上的数据缺失情况 
  */
select count(*) from t_xczxj_jtcyxx 
where jkzk is null and (LDJN is null ) -- 10482


select count(*) from t_xczxj_jtcyxx 
where (jkzk is null) and (whcd is null )  -- 11186


select count(*)  from t_xczxj_jtcyxx 
where (LDJN is null) and (jkzk is null )  -- 10482

select count(*) from t_xczxj_jtcyxx 
where (LDJN is null) and (whcd is null )  -- 28078


/**
 *先用控制变量法定义：先定义一个公共属性，对每一个维度进行单一的测量(将其他的维度限制为正常的情况),衡量这个单一维度对公共属性的影响程度。
 * 这里定公共属性为成员费用消耗情况(包括支出和收入)。根据影响程度的情况，就可以衡量这个权重的大小。
 * 但目前测试发现，匹配的数据都为null, 数据少，数据缺失严重，所以机器学习也很训练适合的模型，倘若数据量足够大 乡村振兴 也可以改变成算法赛道 
 * 
 *控制变量法验证第一遍验证
 * 目标：查询健康维度人群的经济状况 ，其他的维度都是正常的情况下数据 
 * 阻力难点：运行的结果数据都是null,没有匹配到如何的数据，数据缺失严重 
 * 主要用途：通过控制变量法原理，来分配权重，但目前可无法使用，没有数据。所以 机器学习 也不是很方便。
 */
create  or replace view  jkrq  as (-- 健康人群 
	select  cysfz from t_xczxj_jtcyxx txj  
	where  CJDJ is  null  -- 残疾等级 必须是null
	and(JKZK<=2 or JKZK is null) -- 健康条件，  null是健康, 但JKZK<=1的数据实在太少，(这里放松下限制条件，允许生活存在小病),JKZK<=2数据相差24条 ，未后面的匹配依赖匹配不到
	and(cast(LDJN  as SIGNED) <= 3 ) -- 劳动能力为可以包括 1技能劳动力 2普通劳动力 3弱劳动力或半劳动力
	and(cast(WHCD  as SIGNED) <= 3 ) -- 初中文化下 
)  -- 246 条

-- 查询 医保数据信息 的医疗费信息
 select cysfz,YLFZE  from jkrq left join t_xczxj_ybsjxx  
 on jkrq.cysfz = t_xczxj_ybsjxx.SFZH  
 where YLFZE is not null  -- 0条
 
 -- 教育部门信息 的受助金额信息
 select cysfz,SZJE  from jkrq left join T_XCZXJ_JYBMXX  
 on jkrq.cysfz = T_XCZXJ_JYBMXX.SFZH  
 where T_XCZXJ_JYBMXX.SZJE is not null  -- 1条 
 
 -- 防贫保险理赔清单信息 的理赔金额信息
 select cysfz,LPJE  from jkrq left join T_XCZXJ_FPBXLPQDXX  
 on jkrq.cysfz = T_XCZXJ_FPBXLPQDXX.SFZH  
 where T_XCZXJ_FPBXLPQDXX.LPJE is not null -- 0条
 
 -- 低保户信息 的户保障金额
 select cysfz,HJBZJE  from jkrq left join T_XCZXJ_DBHXX				
 on jkrq.cysfz = T_XCZXJ_DBHXX.SFZH 
 where T_XCZXJ_DBHXX.HJBZJE is not null  -- 1条 
 
 -- 特困户信息 的户保障金额
  select cysfz,HBZJE  from jkrq left join T_XCZXJ_TKGYDXHMCXX								
 on jkrq.cysfz = T_XCZXJ_TKGYDXHMCXX.SFZH 
 where T_XCZXJ_TKGYDXHMCXX.HBZJE is not null  -- 0条
 
 
 
 
 /**
  * 控制变量法验证第二遍验证
 * 目标：查询 残疾人群的经济状况  ，其他的维度都是正常的情况下数据 
 * 阻力难点：运行的结果数据都是null,没有匹配到如何的数据
 */
create  or replace view  cjrq  as (
	select  cysfz from t_xczxj_jtcyxx txj  
	where CJDJ is not null  -- 残疾的 
	and(JKZK != 1 and JKZK is not null) -- 是健康的 
	and(cast(LDJN  as SIGNED) <= 3 ) -- 劳动能力为可以包括 1技能劳动力 2普通劳动力 3弱劳动力或半劳动力
	and(cast(WHCD  as SIGNED) <= 3   ) -- 初中文化下 
) -- 44条 


-- 查询 医保数据信息 的医疗费信息
 select cysfz,YLFZE  from cjrq left join t_xczxj_ybsjxx  
 on cjrq.cysfz = t_xczxj_ybsjxx.SFZH  
 where YLFZE is not null  -- 0条
 
 -- 教育部门信息 的受助金额信息
 select cysfz,SZJE  from cjrq left join T_XCZXJ_JYBMXX  
 on cjrq.cysfz = T_XCZXJ_JYBMXX.SFZH  
 where T_XCZXJ_JYBMXX.SZJE is not null  -- 0条 
 
 -- 防贫保险理赔清单信息 的理赔金额信息
 select cysfz,LPJE  from cjrq left join T_XCZXJ_FPBXLPQDXX  
 on cjrq.cysfz = T_XCZXJ_FPBXLPQDXX.SFZH  
 where T_XCZXJ_FPBXLPQDXX.LPJE is not null -- 1条
 
 -- 低保户信息 的户保障金额
 select cysfz,HJBZJE  from cjrq left join T_XCZXJ_DBHXX				
 on cjrq.cysfz = T_XCZXJ_DBHXX.SFZH 
 where T_XCZXJ_DBHXX.HJBZJE is not null  -- 1条 
 
 -- 特困户信息 的户保障金额
 select cysfz,HBZJE  from cjrq left join T_XCZXJ_TKGYDXHMCXX								
 on cjrq.cysfz = T_XCZXJ_TKGYDXHMCXX.SFZH 
 where T_XCZXJ_TKGYDXHMCXX.HBZJE is not null  -- 0条
 
 
 /**
  * 控制变量法验证第三遍验证
 * 目标：查询劳动技能落的人群的经济状况 ，其他的维度都是正常的情况下数据 
 * 阻力难点：运行的结果数据都是null,没有匹配到如何的数据，数据缺失严重 
 * 主要用途：通过控制变量法原理，来分配权重，但目前可无法使用，没有数据。所以 机器学习 也不是很方便。
 */
create  or replace view  ldrrq  as ( 
	select  cysfz from t_xczxj_jtcyxx txj  
	where  CJDJ is not null  -- 残疾等级 不能是null
	and(JKZK=1 or JKZK is null) -- 是健康的，  null 认为是健康
	and(cast(LDJN  as SIGNED) > 3 ) -- 劳动能力为很落的以上
	and(cast(WHCD  as SIGNED) <= 3   ) -- 初中文化 
)  -- 4 条 数据太少 无法衡量 匹配查询无意义  


 
 