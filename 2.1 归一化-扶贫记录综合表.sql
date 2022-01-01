/**
 * 前言注意点：大部分数据是字符型 但发现 自动类型转换的时候 存在数据 漏掉，但加入了强制类型转换 有全部转换成功 所以这点 要注意 尽量用强制 类型转换
 *身份证号是字符型 里面还可能包含字母 在进行表表连接 要注意 这点 
 */

-- 1.医疗总抵免费用金额偏差指标===========================================================
/*
 * 数据验证序号：1.1
 * 目标：官网数据未提供的公式关系，对原表的数据进行一个检查 ，在医保数据信息表寻找合适的数据公式
 * 运行结果：医疗费总额 ≈ (基本医保支付+ 大病报销金额+健康扶贫政策内报销金额+健康扶贫政策外报销金额+医疗救助+财政兜底+定点机构承担+个人自付) ,（由测试反推出大概公式， 两者的差值范围在 -183 ~ -30 元之间 ）
 *注意点： 这里的医疗总抵免费用（不包括这个支付的费用） ，即 医疗总抵免费 = 医疗费总额 - 个人自付 
 */
select YLFZE,JBYBZF+DBBX+NBX+WBX+YLJZ+CZDD+DDJGCD+GRZF as sum1,YLFZE - (JBYBZF+DBBX+NBX+WBX+YLJZ+CZDD+DDJGCD+GRZF) as  sub1
from t_xczxj_ybsjxx txy  

/*
 * 医疗总抵免费用金额偏差序号：1.2
 * 目标：计算抵医疗政府帮抵免费用的偏差 ，偏差=单个值-平均值 
 */
select sum(YLFZE - ifNULL(GRZF,0)) / count(YLFZE) into @PJ_DM from T_XCZXJ_YBSJXX where YLFZE is not null   -- 政府实际发补的费用 ， 一定要过滤下null 否则 null 会直接跳过， 在任何的sql 涉及null的这一行 不会 去执行的该sql , 
select @PJ_DM; -- 查询 这个 平均数  

create  table a_je_DMFY as ( -- DMFY表示抵免费用
	 select  SFZH as CYSFZ,txj.JTXX_ID, (YLFZE-GRZF) as DMFY,(YLFZE-GRZF) - @PJ_DM as offset  from T_XCZXJ_YBSJXX -- 偏差 
	 left join t_xczxj_jtcyxx txj on T_XCZXJ_YBSJXX.SFZH = txj.CYSFZ
) 

-- 2.受助金额偏差指标===========================================================

/*
 * 受助金额偏差指标序号：2.1 
 * 目标：计算政府对家庭学生的受助金额偏差 ，偏差=单个值-平均值 
 */
select sum(SZJE) / count(SZJE) into @PJ_ZXJ from T_XCZXJ_JYBMXX where SZJE is not null   
select @PJ_ZXJ; -- 查询 这个 平均数  

create  table a_je_ZXJ as ( --  ZXJ表示助学金 
	select  SFZH as CYSFZ,txj.JTXX_ID, SZJE ,SZJE- @PJ_ZXJ as offset  from T_XCZXJ_JYBMXX 
	left join t_xczxj_jtcyxx txj on T_XCZXJ_JYBMXX.SFZH = txj.CYSFZ
	) 
	
-- 3.理赔金额偏差偏差指标===========================================================

/*
 * 理赔金额偏差偏差指标序号：3.1 
 * 目标：计算成员理赔金额偏差 ，偏差=单个值-平均值 
 */
select sum(LPJE) / count(LPJE) into @PJ_LPJE from T_XCZXJ_FPBXLPQDXX where LPJE is not null   -- 平均值

select @PJ_LPJE; -- 查询 这个 平均数  

create  table a_je_LPJE as ( -- LPJE表示 理赔金额
	select  SFZH as CYSFZ,txj.JTXX_ID, LPJE ,LPJE- @PJ_LPJE as offset  from T_XCZXJ_FPBXLPQDXX 
	left join t_xczxj_jtcyxx txj on T_XCZXJ_FPBXLPQDXX.SFZH = txj.CYSFZ
	) 

select * from a_je_LPJE

-- 4.低保户保障金额偏差指标===========================================================


/*
 * 低保户 户保障金额 偏差指标序号：4.1 
 * 目标：计算成员低保户 户保障金额 ，偏差=单个值-平均值 
 */
select sum(HJBZJE) / count(HJBZJE) into @PJ_HJBZJE from T_XCZXJ_DBHXX  where HJBZJE is not null   -- 平均值 。注意点：这里用低保户 的户保障金额( 如果用人均包装金额的话 但自己家人成员是没有人均包装金额的信息的。 还是低保人有数据信息，最终还是他一个人的信息   )  
select @PJ_HJBZJE; 

create  table a_je_HBZJE as ( -- 户保障金额 
	select  SFZH as CYSFZ,txj.JTXX_ID,  HJBZJE ,HJBZJE- @PJ_HJBZJE as offset  from T_XCZXJ_DBHXX		
	left join t_xczxj_jtcyxx txj on T_XCZXJ_DBHXX.SFZH = txj.CYSFZ
	) 

select * from a_je_HJBZJE 

-- 5.特困保户保障金额偏差指标===========================================================

/*
 * 特困保户人均保障金额偏差指标序号：5.1 
 * 目标：计算成员特困保户人均保障金额 ，偏差=单个值-平均值 
 */
select sum(HBZJE) / count(HBZJE) into @PJ_HBZJE from T_XCZXJ_TKGYDXHMCXX  where HBZJE is not null   -- 平均值

select @PJ_HBZJE; -- 查询 这个 平均数   876.8571428571429

create  table a_je_TKHBZJE as ( -- 特困户保障金额 
	select  SFZH as CYSFZ,txj.JTXX_ID, HBZJE ,HBZJE- @PJ_HBZJE as offset  from T_XCZXJ_TKGYDXHMCXX	
	left join t_xczxj_jtcyxx txj on T_XCZXJ_TKGYDXHMCXX.SFZH = txj.CYSFZ
	) 

select * from a_je_TKHJBZJE 



