
/**
 * 扶贫记录综合表构建序号：1.1
 *目标：将所有的指标表 的身份证 都合并起来，并重复 的进行去重  ，并且加入 家庭的id
 *注意定：>>> 以下代码 最后 都建立相应的索引 不然运行很慢 <<<
 */
create table a_je_zh_tmp as (-- 综合临时表 
	select  *  from  (
		select res11.CYSFZ  ,txj.JTXX_ID from ( 
			select CYSFZ from a_je_zxj  
			union 
			select CYSFZ from a_je_tkhbzje  
			union
			select CYSFZ from a_je_hbzje
			union
			select CYSFZ from a_je_lpje 
			union
			select CYSFZ from a_je_dmfy 
			) as res11 left join t_xczxj_jtcyxx txj 
			on res11.CYSFZ = txj.CYSFZ 
		) as res22
		where CYSFZ is not null 
	)
	
select *  from a_je_zh_tmp 

/**
 * 扶贫记录综合表构建序号：1.2
 * 目标：对表的数据进行拼接操作
 */
create or replace view res11 as ( -- 第一次拼接 
	select a_je_zh_tmp.CYSFZ,a_je_zh_tmp.JTXX_ID,offset as dmfy_offset from 
	a_je_zh_tmp  left join a_je_dmfy on a_je_zh_tmp.CYSFZ =a_je_dmfy.CYSFZ 
	)  

		
create or replace view res22 as ( -- 第二次拼接 
	select res11.*, offset  as lpje_offset from 
	res11  left join a_je_lpje on res11.CYSFZ =a_je_lpje.CYSFZ
	) 

create or replace view res33 as ( -- 第三次拼接 
	select res22.*, offset  as hbzje_offset from 
	res22  left join a_je_hbzje on res22.CYSFZ =a_je_hbzje.CYSFZ
	) 


create or replace view res44 as ( -- 第四次拼接 
	select res33.*, offset  as tkhbzje_offset from 
	res33  left join a_je_tkhbzje on res33.CYSFZ =a_je_tkhbzje.CYSFZ
	) 

create or replace view res55 as ( -- 第五次拼接 
	select res44.*, offset  as zxj_offset from 
	res44  left join a_je_zxj on res44.CYSFZ =a_je_zxj.CYSFZ
	) 

select * from res55
	
/**
 * 扶贫记录综合表构建序号：1.3
 * 目标：计算加权分配的权重
 * 公式：数值占比权重分配：维度1某百分比 = 维度1数值和 / (维度1数值和 + 维度2数值和 + 维度3数值和) ，但维度1和维度2和维度3之间不是一个平级关系(存在重要和不重要之分)。
 */


select sum(cast(YLFZE as SIGNED) - ifNULL(GRZF,0)) as dmfy into @s1 from T_XCZXJ_YBSJXX -- 医疗费总额（不包括个人支付）
select sum(cast(LPJE as SIGNED))  into @s2 from  T_XCZXJ_FPBXLPQDXX  -- 理赔金额总额
-- hbzje户保障金额(本人改的) 和 HJBZJE户籍保障金额(源数据库的) 单词注意 区分
select sum(cast(HJBZJE as SIGNED)) as hbzje into @s3 from t_xczxj_dbhxx  -- 低保户 户保障金额总额 -- 平均值 。注意点：这里用低保户 的户保障金额( 如果用人均包装金额的话 但自己家人成员是没有人均包装金额的信息的。 还是低保人有数据信息，最终还是他一个人的信息   )  
-- tkhbzje特困-户保障金额(本人改的) 和 HBZJE户保障金额(源数据库的) 单词注意 区分
select sum(cast(HBZJE as SIGNED)) as astkhbzje into @s4  from T_XCZXJ_TKGYDXHMCXX -- 特困户 户保障金额总额
select sum(cast(SZJE as SIGNED)) as zxj  into @s5 from T_XCZXJ_JYBMXX -- 受助金额总额

select @s1 -- 18427243
select @s2 -- 2225320
select @s3 -- 231330
select @s4 -- 18414
select @s5 -- 294402

set @s =  @s1+@s2+@s3+@s4+@s5 -- 总金额 

set @qz_dmfy = @s1/@s -- 权重 
set @qz_LPJE = @s2/@s
set @qz_hbzje = @s3/@s
set @qz_astkhbzje = @s4/@s
set @qz_zxj = @s5/@s

select @qz_dmfy -- 医疗费权重 0.8738834504202524 
select @qz_LPJE -- 理赔金额权重0.10498422184311725 -- 注意：Q2经过另一种测试 如果用 平均数来衡量的话 不用总数 那么 Q2为26% ，但这样 平均数 就造成 不分重要的情况 , 整地幅度就是10%的上下 
select @qz_hbzje -- 人均保障金额权重 0.010970466856366793
select @qz_astkhbzje -- 特困户人均保障金额权重 0.0008732554216623
select @qz_zxj -- 受助金额权重0.013961558740535583


/**
 * 扶贫记录综合表序号：1.4
 * 目标：实现 金额综合算法
 * 公式：某学生综合实力 = 某学生在A类中的"K属性数值偏差" x a% + 某学生B类的"R属性数值偏差" x b% + … 
 */
create table a_je_zh_tmp1 as ( -- 金额综合表 
	select res55.cysfz,res55.jtxx_id,
		(ifNULL(dmfy_offset,0) * @qz_dmfy +
		ifNULL(lpje_offset,0) * @qz_LPJE +
		ifNULL(hbzje_offset,0) * @qz_hbzje +
		ifNULL(tkhbzje_offset,0)* @qz_astkhbzje +
		ifNULL(zxj_offset,0) * @qz_zxj) as zh_offset -- 扶贫程度系数
	from res55 
	order by zh_offset desc 
	)

create table a_je_zh as ( 
	select CYSFZ,JTXX_ID,sum(zh_offset ) as zh_offset from a_je_zh_tmp1
	group by CYSFZ 
	order by  zh_offset desc
	)
	
-- drop table a_yxj_zh_tmp -- 删除临时表  可选 ，但建议 不要删除，删除的话 又要重新运行一遍，比较麻烦
-- drop table a_yxj_zh_tmp1 -- 删除临时表 

/**
 * 扶贫记录综合表归并 构建序号：1.5 
 * 目标：对存在有相同的家庭的人员 ，进行系数合并
 */
create or replace view a_je_zh_tmp2 as (
	select JTXX_ID ,count(*) as JT_RS ,sum(zh_offset) as  zh_offset -- JT_RS 表示家庭的人数 
	from  a_je_zh  where JTXX_ID is not null  -- 这里之所以存在空 是因为之前做了全面的匹配过了 没有 对应的家庭id 
	group by JTXX_ID
	)
	
create table  a_je_zh_JT as (
	select  a_je_zh_tmp2.JTXX_ID,JT_RS,zh_offset -- 
		from  a_je_zh_tmp2 left join t_xczxj_jtxx  -- t_xczxj_jtxx 表的id 还是不全面 ，是缺漏的 
		on  a_je_zh_tmp2.JTXX_ID = t_xczxj_jtxx.ID   
		order by zh_offset desc 
	) 
















