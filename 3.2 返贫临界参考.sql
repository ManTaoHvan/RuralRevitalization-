
/**
 * 为潜在返贫表获取参考标准序号：1.1
 * 目标：获取参考值，为潜在返贫表提供参考标准 ，根据总行数的八分位数原则。在中间 上下合各取80% （经验证 当然 取60%~80%比较合适 ），比较趋于稳定 
 */
-- ‘如果下次 还要变更范围的话 只要取改变n=7就够可以了,其他配置好的数字不要动  
set @n=8
set @dbs = (select FLOOR(count(*)/@n) - 1 from  a_je_zh) -- 顶部数 FLOOR(X) -- 表示向下取整，这里奇偶的顶部都一样. 由于最后涉及的左闭右开情况 所以 这里 要减1，包装自己也取到。而且取的行数是一样的。
set @hs = ( select FLOOR(count(*)/@n) * CEILING(@n/2-1) + FLOOR(count(*)/@n) / 2    from  a_je_zh)  -- 向下取的行数，其实就是取到中间位置的范围，如果总数 不是 4的倍数，那么久可能 不会取到中间 ，这里的话我们就在往下多取几条(  因为后面 可以用去重的函数,，多取没有关系，一般来讲是多取一次4的倍数就够了(但可能会出现中间数据取少了一点)，但我们这里用 FLOOR(count(*)/八分位) / 2表示在多取点， )

SELECT @dbs 
SELECT @hs 

-- dbs顶部行号是有序规则的 ，hs行数没有规则的 ，但范围不会很大 因为加了 浮动数 
-- 5分情况 @dbs -- 236 ，@hs -- 592
-- 6分情况 @dbs -- 196 ，@hs -- 492
-- 7分情况 @dbs -- 168 ，@hs -- 589
-- 8分情况 @dbs -- 147 ，@hs -- 518
-- 9分情况 @dbs -- 130 ，@hs -- 589


create table a_ck_tmp0 as (
	select * from (
		-- 这个要注意是降序  limit 不支持 传入变量 
		(select * from a_je_zh order by zh_offset desc  limit 147,518) -- 左闭右开 ，从一个表的降序自上而下  ，顶部数往下取的行数   (@dbs ,hs] 这里的最后一行是中间数  ，其实就是整个表的上取25%
		union   -- （这里对重复取的数据进行去重 ，因为我们多取了数据）
		-- 这个要注意是升序
		(select * from a_je_zh order by zh_offset  asc  limit 147,518 ) -- 从一个表的降序自下而上(或者是升序，自上而下取) ，其实就是整个表的下取25%
		) as res11 
	order by res11.zh_offset desc
	) 

	
/**
 * 为潜在返贫表获取参考标准序号：1.2
 * 目标：做表数据拼接 ，把这些 成员身份证的不同维度关键指标 获取到 
 */
create table a_ck_tmp1 as (
	select a_ck_tmp0.*,(YLFZE-ifNULL(GRZF,0)) as dmfy 
	from  a_ck_tmp0 left join T_XCZXJ_YBSJXX 
	on a_ck_tmp0.CYSFZ = T_XCZXJ_YBSJXX.SFZH  -- 拼接医疗抵免费用数据 
	)
	
create table a_ck_tmp2 as (
	select a_ck_tmp1.*,szje 
	from  a_ck_tmp1 left join T_XCZXJ_JYBMXX 
	on a_ck_tmp1.CYSFZ = T_XCZXJ_JYBMXX.SFZH -- 拼接助学金数据
	)

create table a_ck_tmp3 as (
	select a_ck_tmp2.*, LPJE
	from  a_ck_tmp2 left join T_XCZXJ_FPBXLPQDXX 
	on a_ck_tmp2.CYSFZ = T_XCZXJ_FPBXLPQDXX.SFZH  -- 拼接理赔金额数据 
	)

create table a_ck_tmp4 as (
	select a_ck_tmp3.*, HJBZJE -- 注意HJBZJE和 HBZJE这个单词 不一样 
	from  a_ck_tmp3 left join T_XCZXJ_DBHXX 
	on a_ck_tmp3.CYSFZ = T_XCZXJ_DBHXX.SFZH  -- 拼接户保障金额数据 
	)
	 
create table a_ck_tmp5 as (
	select a_ck_tmp4.*, HBZJE -- 注意HJBZJE和 HBZJE这个单词 不一样 
	from  a_ck_tmp4 left join T_XCZXJ_TKGYDXHMCXX 
	on a_ck_tmp4.CYSFZ = T_XCZXJ_TKGYDXHMCXX.SFZH  -- 拼接户保障金额数据 
	)

select * from a_ck_tmp5


/**
 * 原始平均数和过滤后的平均数对比序号：1.3
 * 目标：验证 医疗的平均是否合理
 * 结果：（经验证 当然 取60%~80%比较合适 ），比较趋于稳定 80%比较趋于稳定，兼容全部 
 */

-- 调到5分位，平均数为 30391.627272727274
-- 调到6分位，平均数为 28546.513333333332
-- 调到7分位，平均数为 27854.064171122995
-- 调到8分位，平均数为  27400.265116279068  
-- 调到9分位，平均数为  34899.0847107438


select sum(dmfy)/count(dmfy) as PJ_dmfy into @CKPJ_dmfy  from a_ck_tmp5 -- PJ_dmfy 表示 平均抵免费用 ， CKPJ_dmfy 表示参考费用 
where dmfy is not null  


select sum(YLFZE-ifNULL(GRZF,0)) /count(YLFZE)  from T_XCZXJ_YBSJXX
where YLFZE is not null -- 源始不做任何的过滤 平均数据为  36854.486 

/**
 *  原始平均数和过滤后的平均数对比序号：1.4
 * 目标：验证 家庭受助金额平均是否合理
 * 结果：（经验证 当然 取60%~80%比较合适 ），比较趋于稳定 80%比较趋于稳定，兼容全部 
 */
			
select sum(SZJE)/count(SZJE)  as PJ_SZJE into @CKPJ_SZJE from a_ck_tmp5 -- CKPJ_SZJE 参考平均受助金额 
where SZJE is not null  -- 8分位 ，平均数为 1066.6739130434783


select sum(SZJE) /count(SZJE) from T_XCZXJ_JYBMXX
where SZJE is not null -- 源始不做任何的过滤 平均数据为  1066.6739130434783


/**
 *  原始平均数和过滤后的平均数对比序号：1.5
 * 目标：验证 理赔金额偏平均是否合理
 * 结果：（经验证 当然 取60%~80%比较合适 ），比较趋于稳定 80%比较趋于稳定，兼容全部 
 */

select sum(LPJE)/count(LPJE) as PJ_LPJE into @CKPJ_LPJE from a_ck_tmp5 -- CKPJ_SZJE 参考平均理赔金额
where LPJE is not null  -- 8分位 ，平均数为 9861.775569230767


select sum(LPJE) /count(LPJE) from T_XCZXJ_FPBXLPQDXX
where LPJE is not null -- 源始不做任何的过滤 平均数据为 15562.077146853151


/**
 *  原始平均数和过滤后的平均数对比序号：1.6
 * 目标：验证 户保障金额平均是否合理
 * 结果：（经验证 当然 取60%~80%比较合适 ），比较趋于稳定 80%比较趋于稳定，兼容全部 
 */

select sum(HJBZJE)/count(HJBZJE) as PJ_HBZJE into @CKPJ_HBZJE from a_ck_tmp5 -- into @CKPJ_LPJE 参考平均户保障金额(一般困难户)
where HJBZJE is not null  -- 8分位 ，平均数为884.8494208494209


select sum(HJBZJE) /count(HJBZJE) from T_XCZXJ_DBHXX
where HJBZJE is not null -- 源始不做任何的过滤 平均数据为882.9389312977099


/**
 *  原始平均数和过滤后的平均数对比序号：1.7
 * 目标：验证 特困户户保障金额平均是否合理
 * 结果：（经验证 当然 取60%~80%比较合适 ），80%比较趋于稳定，兼容全部 
 */

select sum(HBZJE)/count(HBZJE) as PJ_TKHBZJE  into @CKPJ_TKHBZJE from a_ck_tmp5 -- into @CKPJ_LPJE 参考平均特困户保障金额
where HBZJE is not null  -- 8分位 ，平均数为876.8571428571429


select sum(HBZJE) /count(HBZJE) from T_XCZXJ_TKGYDXHMCXX
where HBZJE is not null -- 源始不做任何的过滤 平均数据为 876.8571428571429


/**
 * 获取最终的临界参考值：1.8
 * 目标：验证 特困户户保障金额平均是否合理
 * 结果：（经验证 当然 取60%~80%比较合适 ），比较趋于稳定 
 */

create table a_ck as (
	select 
	round(@CKPJ_dmfy,2) as CKPJ_dmfy, --  平均抵免费用 保留两位小数 
	round(@CKPJ_SZJE,2)  as  CKPJ_SZJE, --  平均受助金额  保留两位小数
	round(@CKPJ_LPJE,2) as CKPJ_LPJE, --  平均理赔金额 保留两位小数 
	round(@CKPJ_HBZJE,2)  as CKPJ_HBZJE, --  平均户保障金额  保留两位小数 
	round(@CKPJ_TKHBZJE,2) as CKPJ_TKHBZJE --  平均特困户保障金额 保留两位小数 
	)



