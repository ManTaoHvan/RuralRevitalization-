
/**
 * ΪǱ�ڷ�ƶ���ȡ�ο���׼��ţ�1.1
 * Ŀ�꣺��ȡ�ο�ֵ��ΪǱ�ڷ�ƶ���ṩ�ο���׼ �������������İ˷�λ��ԭ�����м� ���ºϸ�ȡ80% ������֤ ��Ȼ ȡ60%~80%�ȽϺ��� �����Ƚ������ȶ� 
 */
-- ������´� ��Ҫ�����Χ�Ļ� ֻҪȡ�ı�n=7�͹�������,�������úõ����ֲ�Ҫ��  
set @n=8
set @dbs = (select FLOOR(count(*)/@n) - 1 from  a_je_zh) -- ������ FLOOR(X) -- ��ʾ����ȡ����������ż�Ķ�����һ��. ��������漰������ҿ���� ���� ���� Ҫ��1����װ�Լ�Ҳȡ��������ȡ��������һ���ġ�
set @hs = ( select FLOOR(count(*)/@n) * CEILING(@n/2-1) + FLOOR(count(*)/@n) / 2    from  a_je_zh)  -- ����ȡ����������ʵ����ȡ���м�λ�õķ�Χ��������� ���� 4�ı�������ô�ÿ��� ����ȡ���м� ������Ļ����Ǿ������¶�ȡ����(  ��Ϊ���� ������ȥ�صĺ���,����ȡû�й�ϵ��һ�������Ƕ�ȡһ��4�ı����͹���(�����ܻ�����м�����ȡ����һ��)�������������� FLOOR(count(*)/�˷�λ) / 2��ʾ�ڶ�ȡ�㣬 )

SELECT @dbs 
SELECT @hs 

-- dbs�����к����������� ��hs����û�й���� ������Χ����ܴ� ��Ϊ���� ������ 
-- 5����� @dbs -- 236 ��@hs -- 592
-- 6����� @dbs -- 196 ��@hs -- 492
-- 7����� @dbs -- 168 ��@hs -- 589
-- 8����� @dbs -- 147 ��@hs -- 518
-- 9����� @dbs -- 130 ��@hs -- 589


create table a_ck_tmp0 as (
	select * from (
		-- ���Ҫע���ǽ���  limit ��֧�� ������� 
		(select * from a_je_zh order by zh_offset desc  limit 147,518) -- ����ҿ� ����һ����Ľ������϶���  ������������ȡ������   (@dbs ,hs] ��������һ�����м���  ����ʵ�������������ȡ25%
		union   -- ��������ظ�ȡ�����ݽ���ȥ�� ����Ϊ���Ƕ�ȡ�����ݣ�
		-- ���Ҫע��������
		(select * from a_je_zh order by zh_offset  asc  limit 147,518 ) -- ��һ����Ľ������¶���(�������������϶���ȡ) ����ʵ�������������ȡ25%
		) as res11 
	order by res11.zh_offset desc
	) 

	
/**
 * ΪǱ�ڷ�ƶ���ȡ�ο���׼��ţ�1.2
 * Ŀ�꣺��������ƴ�� ������Щ ��Ա���֤�Ĳ�ͬά�ȹؼ�ָ�� ��ȡ�� 
 */
create table a_ck_tmp1 as (
	select a_ck_tmp0.*,(YLFZE-ifNULL(GRZF,0)) as dmfy 
	from  a_ck_tmp0 left join T_XCZXJ_YBSJXX 
	on a_ck_tmp0.CYSFZ = T_XCZXJ_YBSJXX.SFZH  -- ƴ��ҽ�Ƶ���������� 
	)
	
create table a_ck_tmp2 as (
	select a_ck_tmp1.*,szje 
	from  a_ck_tmp1 left join T_XCZXJ_JYBMXX 
	on a_ck_tmp1.CYSFZ = T_XCZXJ_JYBMXX.SFZH -- ƴ����ѧ������
	)

create table a_ck_tmp3 as (
	select a_ck_tmp2.*, LPJE
	from  a_ck_tmp2 left join T_XCZXJ_FPBXLPQDXX 
	on a_ck_tmp2.CYSFZ = T_XCZXJ_FPBXLPQDXX.SFZH  -- ƴ������������ 
	)

create table a_ck_tmp4 as (
	select a_ck_tmp3.*, HJBZJE -- ע��HJBZJE�� HBZJE������� ��һ�� 
	from  a_ck_tmp3 left join T_XCZXJ_DBHXX 
	on a_ck_tmp3.CYSFZ = T_XCZXJ_DBHXX.SFZH  -- ƴ�ӻ����Ͻ������ 
	)
	 
create table a_ck_tmp5 as (
	select a_ck_tmp4.*, HBZJE -- ע��HJBZJE�� HBZJE������� ��һ�� 
	from  a_ck_tmp4 left join T_XCZXJ_TKGYDXHMCXX 
	on a_ck_tmp4.CYSFZ = T_XCZXJ_TKGYDXHMCXX.SFZH  -- ƴ�ӻ����Ͻ������ 
	)

select * from a_ck_tmp5


/**
 * ԭʼƽ�����͹��˺��ƽ�����Ա���ţ�1.3
 * Ŀ�꣺��֤ ҽ�Ƶ�ƽ���Ƿ����
 * �����������֤ ��Ȼ ȡ60%~80%�ȽϺ��� �����Ƚ������ȶ� 80%�Ƚ������ȶ�������ȫ�� 
 */

-- ����5��λ��ƽ����Ϊ 30391.627272727274
-- ����6��λ��ƽ����Ϊ 28546.513333333332
-- ����7��λ��ƽ����Ϊ 27854.064171122995
-- ����8��λ��ƽ����Ϊ  27400.265116279068  
-- ����9��λ��ƽ����Ϊ  34899.0847107438


select sum(dmfy)/count(dmfy) as PJ_dmfy into @CKPJ_dmfy  from a_ck_tmp5 -- PJ_dmfy ��ʾ ƽ��������� �� CKPJ_dmfy ��ʾ�ο����� 
where dmfy is not null  


select sum(YLFZE-ifNULL(GRZF,0)) /count(YLFZE)  from T_XCZXJ_YBSJXX
where YLFZE is not null -- Դʼ�����κεĹ��� ƽ������Ϊ  36854.486 

/**
 *  ԭʼƽ�����͹��˺��ƽ�����Ա���ţ�1.4
 * Ŀ�꣺��֤ ��ͥ�������ƽ���Ƿ����
 * �����������֤ ��Ȼ ȡ60%~80%�ȽϺ��� �����Ƚ������ȶ� 80%�Ƚ������ȶ�������ȫ�� 
 */
			
select sum(SZJE)/count(SZJE)  as PJ_SZJE into @CKPJ_SZJE from a_ck_tmp5 -- CKPJ_SZJE �ο�ƽ��������� 
where SZJE is not null  -- 8��λ ��ƽ����Ϊ 1066.6739130434783


select sum(SZJE) /count(SZJE) from T_XCZXJ_JYBMXX
where SZJE is not null -- Դʼ�����κεĹ��� ƽ������Ϊ  1066.6739130434783


/**
 *  ԭʼƽ�����͹��˺��ƽ�����Ա���ţ�1.5
 * Ŀ�꣺��֤ ������ƫƽ���Ƿ����
 * �����������֤ ��Ȼ ȡ60%~80%�ȽϺ��� �����Ƚ������ȶ� 80%�Ƚ������ȶ�������ȫ�� 
 */

select sum(LPJE)/count(LPJE) as PJ_LPJE into @CKPJ_LPJE from a_ck_tmp5 -- CKPJ_SZJE �ο�ƽ��������
where LPJE is not null  -- 8��λ ��ƽ����Ϊ 9861.775569230767


select sum(LPJE) /count(LPJE) from T_XCZXJ_FPBXLPQDXX
where LPJE is not null -- Դʼ�����κεĹ��� ƽ������Ϊ 15562.077146853151


/**
 *  ԭʼƽ�����͹��˺��ƽ�����Ա���ţ�1.6
 * Ŀ�꣺��֤ �����Ͻ��ƽ���Ƿ����
 * �����������֤ ��Ȼ ȡ60%~80%�ȽϺ��� �����Ƚ������ȶ� 80%�Ƚ������ȶ�������ȫ�� 
 */

select sum(HJBZJE)/count(HJBZJE) as PJ_HBZJE into @CKPJ_HBZJE from a_ck_tmp5 -- into @CKPJ_LPJE �ο�ƽ�������Ͻ��(һ�����ѻ�)
where HJBZJE is not null  -- 8��λ ��ƽ����Ϊ884.8494208494209


select sum(HJBZJE) /count(HJBZJE) from T_XCZXJ_DBHXX
where HJBZJE is not null -- Դʼ�����κεĹ��� ƽ������Ϊ882.9389312977099


/**
 *  ԭʼƽ�����͹��˺��ƽ�����Ա���ţ�1.7
 * Ŀ�꣺��֤ �����������Ͻ��ƽ���Ƿ����
 * �����������֤ ��Ȼ ȡ60%~80%�ȽϺ��� ����80%�Ƚ������ȶ�������ȫ�� 
 */

select sum(HBZJE)/count(HBZJE) as PJ_TKHBZJE  into @CKPJ_TKHBZJE from a_ck_tmp5 -- into @CKPJ_LPJE �ο�ƽ�����������Ͻ��
where HBZJE is not null  -- 8��λ ��ƽ����Ϊ876.8571428571429


select sum(HBZJE) /count(HBZJE) from T_XCZXJ_TKGYDXHMCXX
where HBZJE is not null -- Դʼ�����κεĹ��� ƽ������Ϊ 876.8571428571429


/**
 * ��ȡ���յ��ٽ�ο�ֵ��1.8
 * Ŀ�꣺��֤ �����������Ͻ��ƽ���Ƿ����
 * �����������֤ ��Ȼ ȡ60%~80%�ȽϺ��� �����Ƚ������ȶ� 
 */

create table a_ck as (
	select 
	round(@CKPJ_dmfy,2) as CKPJ_dmfy, --  ƽ��������� ������λС�� 
	round(@CKPJ_SZJE,2)  as  CKPJ_SZJE, --  ƽ���������  ������λС��
	round(@CKPJ_LPJE,2) as CKPJ_LPJE, --  ƽ�������� ������λС�� 
	round(@CKPJ_HBZJE,2)  as CKPJ_HBZJE, --  ƽ�������Ͻ��  ������λС�� 
	round(@CKPJ_TKHBZJE,2) as CKPJ_TKHBZJE --  ƽ�����������Ͻ�� ������λС�� 
	)



