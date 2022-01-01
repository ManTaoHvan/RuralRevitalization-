
/**
 * ��ƶ��¼�ۺϱ�����ţ�1.1
 *Ŀ�꣺�����е�ָ��� �����֤ ���ϲ����������ظ� �Ľ���ȥ��  �����Ҽ��� ��ͥ��id
 *ע�ⶨ��>>> ���´��� ��� ��������Ӧ������ ��Ȼ���к��� <<<
 */
create table a_je_zh_tmp as (-- �ۺ���ʱ�� 
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
 * ��ƶ��¼�ۺϱ�����ţ�1.2
 * Ŀ�꣺�Ա�����ݽ���ƴ�Ӳ���
 */
create or replace view res11 as ( -- ��һ��ƴ�� 
	select a_je_zh_tmp.CYSFZ,a_je_zh_tmp.JTXX_ID,offset as dmfy_offset from 
	a_je_zh_tmp  left join a_je_dmfy on a_je_zh_tmp.CYSFZ =a_je_dmfy.CYSFZ 
	)  

		
create or replace view res22 as ( -- �ڶ���ƴ�� 
	select res11.*, offset  as lpje_offset from 
	res11  left join a_je_lpje on res11.CYSFZ =a_je_lpje.CYSFZ
	) 

create or replace view res33 as ( -- ������ƴ�� 
	select res22.*, offset  as hbzje_offset from 
	res22  left join a_je_hbzje on res22.CYSFZ =a_je_hbzje.CYSFZ
	) 


create or replace view res44 as ( -- ���Ĵ�ƴ�� 
	select res33.*, offset  as tkhbzje_offset from 
	res33  left join a_je_tkhbzje on res33.CYSFZ =a_je_tkhbzje.CYSFZ
	) 

create or replace view res55 as ( -- �����ƴ�� 
	select res44.*, offset  as zxj_offset from 
	res44  left join a_je_zxj on res44.CYSFZ =a_je_zxj.CYSFZ
	) 

select * from res55
	
/**
 * ��ƶ��¼�ۺϱ�����ţ�1.3
 * Ŀ�꣺�����Ȩ�����Ȩ��
 * ��ʽ����ֵռ��Ȩ�ط��䣺ά��1ĳ�ٷֱ� = ά��1��ֵ�� / (ά��1��ֵ�� + ά��2��ֵ�� + ά��3��ֵ��) ����ά��1��ά��2��ά��3֮�䲻��һ��ƽ����ϵ(������Ҫ�Ͳ���Ҫ֮��)��
 */


select sum(cast(YLFZE as SIGNED) - ifNULL(GRZF,0)) as dmfy into @s1 from T_XCZXJ_YBSJXX -- ҽ�Ʒ��ܶ����������֧����
select sum(cast(LPJE as SIGNED))  into @s2 from  T_XCZXJ_FPBXLPQDXX  -- �������ܶ�
-- hbzje�����Ͻ��(���˸ĵ�) �� HJBZJE�������Ͻ��(Դ���ݿ��) ����ע�� ����
select sum(cast(HJBZJE as SIGNED)) as hbzje into @s3 from t_xczxj_dbhxx  -- �ͱ��� �����Ͻ���ܶ� -- ƽ��ֵ ��ע��㣺�����õͱ��� �Ļ����Ͻ��( ������˾���װ���Ļ� ���Լ����˳�Ա��û���˾���װ������Ϣ�ġ� ���ǵͱ�����������Ϣ�����ջ�����һ���˵���Ϣ   )  
-- tkhbzje����-�����Ͻ��(���˸ĵ�) �� HBZJE�����Ͻ��(Դ���ݿ��) ����ע�� ����
select sum(cast(HBZJE as SIGNED)) as astkhbzje into @s4  from T_XCZXJ_TKGYDXHMCXX -- ������ �����Ͻ���ܶ�
select sum(cast(SZJE as SIGNED)) as zxj  into @s5 from T_XCZXJ_JYBMXX -- ��������ܶ�

select @s1 -- 18427243
select @s2 -- 2225320
select @s3 -- 231330
select @s4 -- 18414
select @s5 -- 294402

set @s =  @s1+@s2+@s3+@s4+@s5 -- �ܽ�� 

set @qz_dmfy = @s1/@s -- Ȩ�� 
set @qz_LPJE = @s2/@s
set @qz_hbzje = @s3/@s
set @qz_astkhbzje = @s4/@s
set @qz_zxj = @s5/@s

select @qz_dmfy -- ҽ�Ʒ�Ȩ�� 0.8738834504202524 
select @qz_LPJE -- ������Ȩ��0.10498422184311725 -- ע�⣺Q2������һ�ֲ��� ����� ƽ�����������Ļ� �������� ��ô Q2Ϊ26% �������� ƽ���� ����� ������Ҫ����� , ���ط��Ⱦ���10%������ 
select @qz_hbzje -- �˾����Ͻ��Ȩ�� 0.010970466856366793
select @qz_astkhbzje -- �������˾����Ͻ��Ȩ�� 0.0008732554216623
select @qz_zxj -- �������Ȩ��0.013961558740535583


/**
 * ��ƶ��¼�ۺϱ���ţ�1.4
 * Ŀ�꣺ʵ�� ����ۺ��㷨
 * ��ʽ��ĳѧ���ۺ�ʵ�� = ĳѧ����A���е�"K������ֵƫ��" x a% + ĳѧ��B���"R������ֵƫ��" x b% + �� 
 */
create table a_je_zh_tmp1 as ( -- ����ۺϱ� 
	select res55.cysfz,res55.jtxx_id,
		(ifNULL(dmfy_offset,0) * @qz_dmfy +
		ifNULL(lpje_offset,0) * @qz_LPJE +
		ifNULL(hbzje_offset,0) * @qz_hbzje +
		ifNULL(tkhbzje_offset,0)* @qz_astkhbzje +
		ifNULL(zxj_offset,0) * @qz_zxj) as zh_offset -- ��ƶ�̶�ϵ��
	from res55 
	order by zh_offset desc 
	)

create table a_je_zh as ( 
	select CYSFZ,JTXX_ID,sum(zh_offset ) as zh_offset from a_je_zh_tmp1
	group by CYSFZ 
	order by  zh_offset desc
	)
	
-- drop table a_yxj_zh_tmp -- ɾ����ʱ��  ��ѡ �������� ��Ҫɾ����ɾ���Ļ� ��Ҫ��������һ�飬�Ƚ��鷳
-- drop table a_yxj_zh_tmp1 -- ɾ����ʱ�� 

/**
 * ��ƶ��¼�ۺϱ�鲢 ������ţ�1.5 
 * Ŀ�꣺�Դ�������ͬ�ļ�ͥ����Ա ������ϵ���ϲ�
 */
create or replace view a_je_zh_tmp2 as (
	select JTXX_ID ,count(*) as JT_RS ,sum(zh_offset) as  zh_offset -- JT_RS ��ʾ��ͥ������ 
	from  a_je_zh  where JTXX_ID is not null  -- ����֮���Դ��ڿ� ����Ϊ֮ǰ����ȫ���ƥ����� û�� ��Ӧ�ļ�ͥid 
	group by JTXX_ID
	)
	
create table  a_je_zh_JT as (
	select  a_je_zh_tmp2.JTXX_ID,JT_RS,zh_offset -- 
		from  a_je_zh_tmp2 left join t_xczxj_jtxx  -- t_xczxj_jtxx ���id ���ǲ�ȫ�� ����ȱ©�� 
		on  a_je_zh_tmp2.JTXX_ID = t_xczxj_jtxx.ID   
		order by zh_offset desc 
	) 
















