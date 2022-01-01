
/**
 * ���������������ȼ��ۺ��㷨�����漰����һ��Ȩ�ط���������Ϊʲô����Ϊ�������Ȩ�أ�
 * �������⣺���ݹ��� , ͨ�� ����ѧϰ 0.8%���������� ������ȷ�� ���� 99.2%�Ĵ���ȱʧ������( ������������ ���� ��ά�ȵĿ�ȱ�� )��
��a_yxj_cjdj �м��ȼ�Ȩ�� 25%
��a_yxj_jkzkdj ����״��Ȩ�� 20%   
��a_yxj_ldjndj �Ͷ�����Ȩ�� 20%
��a_yxj_jtryswzbdj ��ͥ��Ա����ռ��Ȩ��  15%
�� a_yxj_whcddj �Ļ��̶ȵȼ�Ȩ�� 10%   
��a_yxj_sxdcdj ���ŵ���Ȩ�� 5% 
��a_yxj_jtsgdj ��ͨ�¹�Ȩ�� 5% 
 */ 


/**
 * Ǳ�ڷ�ƶ������ţ�1.1
 *Ŀ�꣺�����е�ָ��� �����֤ ���ϲ����������ظ� �Ľ���ȥ��  
 *ע�ⶨ�����´��� ��� ��������Ӧ������ ��Ȼ���к��� 
 */
create table a_yxj_zh_tmp as (-- �ۺ���ʱ�� 
	select CYSFZ from ( -- 53792�� 
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
 * Ǳ�ڷ�ƶ��  ������ţ�1.2
 * Ŀ�꣺�Ա�����ݽ���ƴ�Ӳ���
 */
create or replace view res1 as ( -- ��һ��ƴ�� 
	select a_yxj_zh_tmp.CYSFZ,JTXX_ID,offset as cjdj_offset from 
	a_yxj_zh_tmp  left join a_yxj_cjdj on a_yxj_zh_tmp.CYSFZ =a_yxj_cjdj.CYSFZ
	)  

		
create or replace view res2 as ( -- �ڶ���ƴ�� 
	select res1.*, offset  as jkzkdj_offset from 
	res1  left join a_yxj_jkzkdj on res1.CYSFZ =a_yxj_jkzkdj.CYSFZ
	) 

create or replace view res3 as ( -- ������ƴ�� 
	select res2.*, offset  as ldjndj_offset from 
	res2  left join a_yxj_ldjndj on res2.CYSFZ =a_yxj_ldjndj.CYSFZ
	) 


create or replace view res4 as ( -- ���Ĵ�ƴ�� 
	select res3.*, offset  as jtryswzbdj_offset from 
	res3  left join a_yxj_jtryswzbdj on res3.CYSFZ =a_yxj_jtryswzbdj.CYSFZ
	) 

create or replace view res5 as ( -- �����ƴ�� 
	select res4.*, offset  as whcddj_offset from 
	res4  left join a_yxj_whcddj on res4.CYSFZ =a_yxj_whcddj.CYSFZ
	) 

create or replace view res6 as ( -- ������ƴ�� 
	select res5.*, offset  as sxdcdj_offset from 
	res5  left join a_yxj_sxdcdj on res5.CYSFZ =a_yxj_sxdcdj.CYSFZ
	) 

create or replace view res7 as ( -- ���ߴ�ƴ�� 
	select res6.*, offset  as jtsgdj_offset from 
	res6  left join a_yxj_jtsgdj on res6.CYSFZ =a_yxj_jtsgdj.CYSFZ
	) 

/**
 *  Ǳ�ڷ�ƶ��  ������ţ�1.3
 * Ŀ�꣺ʵ�� ���ȼ��ۺ��㷨
 * ��ʽ���ۺ����ȼ���ʽ = ĳѧ����A���"M���������ȼ�ƫ��" x a% + ĳѧ����B���"N���������ȼ���ƫ��" x b% + ������������=���ȼ�
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
		) as zh_offset -- Ǳ�ڷ�ƶ����ϵ�� ifNULL(�ֶ�,δnull�������arg2)
	 from res7
	 order by zh_offset desc 
 )
 

 
/**
 * Ǳ�ڷ�ƶ��  ������ţ�1.4
 * Ŀ�꣺�Դ�������ͬ�����֤ ������ϵ���ϲ� ����Ϊ��Щά�� ��Щ ���ڳ�Ա�����������ϣ�
 */
select count( distinct CYSFZ) from a_yxj_zh_tmp1   -- 53791
select count(  CYSFZ) from a_yxj_zh_tmp1   -- 53794 

create table a_yxj_zh as ( 
	select CYSFZ,JTXX_ID,sum(zh_offset ) as zh_offset from a_yxj_zh_tmp1
	group by CYSFZ 
	order by  zh_offset desc
	)

-- drop table a_yxj_zh_tmp -- ɾ����ʱ��  ��ѡ �������� ��Ҫɾ����ɾ���Ļ� ��Ҫ��������һ�飬�Ƚ��鷳
-- drop table a_yxj_zh_tmp1 -- ɾ����ʱ�� 

/**
 * Ǳ�ڷ�ƶ��ͥ�鲢��  ������ţ�1.6
 * Ŀ�꣺�Դ�������ͬ�ļ�ͥ����Ա ������ϵ���ϲ�
 */
create or replace view a_yxj_zh_tmp2 as (
	select JTXX_ID ,count(*) as JT_RS ,sum(zh_offset) as  zh_offset -- JT_RS ��ʾ��ͥ������ 
	from a_yxj_zh  where JTXX_ID is not null   -- ����֮���Դ��ڿ� ����Ϊ֮ǰ����ȫ���ƥ����� û�� ��Ӧ�ļ�ͥid 
	group by JTXX_ID
	)
	
create table a_yxj_zh_JT as (
	select a_yxj_zh_tmp2.JTXX_ID,JT_RS,zh_offset -- 
		from a_yxj_zh_tmp2 left join t_xczxj_jtxx  -- t_xczxj_jtxx ���id ���ǲ�ȫ�� ����ȱ©�� 
		on a_yxj_zh_tmp2.JTXX_ID = t_xczxj_jtxx.ID   
		order by zh_offset desc 
	)












