/**
 * ���������������ȼ��ۺ��㷨�����漰����һ��Ȩ�ط���������Ϊʲô����Ϊ�������Ȩ�أ�
 * �������⣺���ݹ��� , ͨ�� ����ѧϰ 0.8%���������� ������ȷ�� ���� 99.2%�Ĵ���ȱʧ������( ������������ ���� ��ά�ȵĿ�ȱ�� )��
 */

-- ����Ȩ�ص�ǰ����֤ ===========================================
 /**
  * Ŀ�꣺���� �鿴��Ч�����Ƕ���
  * ��������ݹ��� , ͨ�� ����ѧϰ 0.8%���������� ������ȷ�� ���� 99.2%�Ĵ���ȱʧ������( ������Щ���� ���� ��ά�ȵĿ�ȱ�� )��
 */
create  or replace view  ldrrq  as ( 
	select  cysfz,CJDJ,JKZK,LDJN,WHCD from t_xczxj_jtcyxx txj  
	where   -- �м��ȼ� ����Ϊ null 
	JKZK is not  null -- ���� ������null
	and LDJN is not null  -- �Ͷ����� ������null
	and WHCD  is not null -- �����Ļ� 
)  -- ��53030��, �� ��Ч���� 448������̫�� select count(*) from t_xczxj_jtcyxx txj  -- �� 53030 �� 
 
/**
 *  Ŀ�꣺��� ��ά�ȵ�����ȱʧ��� 
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
  * Ŀ�꣺��� ��ά�����ϵ�����ȱʧ��� 
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
 *���ÿ��Ʊ��������壺�ȶ���һ���������ԣ���ÿһ��ά�Ƚ��е�һ�Ĳ���(��������ά������Ϊ���������),���������һά�ȶԹ������Ե�Ӱ��̶ȡ�
 * ���ﶨ��������Ϊ��Ա�����������(����֧��������)������Ӱ��̶ȵ�������Ϳ��Ժ������Ȩ�صĴ�С��
 * ��Ŀǰ���Է��֣�ƥ������ݶ�Ϊnull, �����٣�����ȱʧ���أ����Ի���ѧϰҲ��ѵ���ʺϵ�ģ�ͣ������������㹻�� ������� Ҳ���Ըı���㷨���� 
 * 
 *���Ʊ�������֤��һ����֤
 * Ŀ�꣺��ѯ����ά����Ⱥ�ľ���״�� ��������ά�ȶ������������������ 
 * �����ѵ㣺���еĽ�����ݶ���null,û��ƥ�䵽��ε����ݣ�����ȱʧ���� 
 * ��Ҫ��;��ͨ�����Ʊ�����ԭ��������Ȩ�أ���Ŀǰ���޷�ʹ�ã�û�����ݡ����� ����ѧϰ Ҳ���Ǻܷ��㡣
 */
create  or replace view  jkrq  as (-- ������Ⱥ 
	select  cysfz from t_xczxj_jtcyxx txj  
	where  CJDJ is  null  -- �м��ȼ� ������null
	and(JKZK<=2 or JKZK is null) -- ����������  null�ǽ���, ��JKZK<=1������ʵ��̫�٣�(������������������������������С��),JKZK<=2�������24�� ��δ�����ƥ������ƥ�䲻��
	and(cast(LDJN  as SIGNED) <= 3 ) -- �Ͷ�����Ϊ���԰��� 1�����Ͷ��� 2��ͨ�Ͷ��� 3���Ͷ�������Ͷ���
	and(cast(WHCD  as SIGNED) <= 3 ) -- �����Ļ��� 
)  -- 246 ��

-- ��ѯ ҽ��������Ϣ ��ҽ�Ʒ���Ϣ
 select cysfz,YLFZE  from jkrq left join t_xczxj_ybsjxx  
 on jkrq.cysfz = t_xczxj_ybsjxx.SFZH  
 where YLFZE is not null  -- 0��
 
 -- ����������Ϣ �����������Ϣ
 select cysfz,SZJE  from jkrq left join T_XCZXJ_JYBMXX  
 on jkrq.cysfz = T_XCZXJ_JYBMXX.SFZH  
 where T_XCZXJ_JYBMXX.SZJE is not null  -- 1�� 
 
 -- ��ƶ���������嵥��Ϣ ����������Ϣ
 select cysfz,LPJE  from jkrq left join T_XCZXJ_FPBXLPQDXX  
 on jkrq.cysfz = T_XCZXJ_FPBXLPQDXX.SFZH  
 where T_XCZXJ_FPBXLPQDXX.LPJE is not null -- 0��
 
 -- �ͱ�����Ϣ �Ļ����Ͻ��
 select cysfz,HJBZJE  from jkrq left join T_XCZXJ_DBHXX				
 on jkrq.cysfz = T_XCZXJ_DBHXX.SFZH 
 where T_XCZXJ_DBHXX.HJBZJE is not null  -- 1�� 
 
 -- ��������Ϣ �Ļ����Ͻ��
  select cysfz,HBZJE  from jkrq left join T_XCZXJ_TKGYDXHMCXX								
 on jkrq.cysfz = T_XCZXJ_TKGYDXHMCXX.SFZH 
 where T_XCZXJ_TKGYDXHMCXX.HBZJE is not null  -- 0��
 
 
 
 
 /**
  * ���Ʊ�������֤�ڶ�����֤
 * Ŀ�꣺��ѯ �м���Ⱥ�ľ���״��  ��������ά�ȶ������������������ 
 * �����ѵ㣺���еĽ�����ݶ���null,û��ƥ�䵽��ε�����
 */
create  or replace view  cjrq  as (
	select  cysfz from t_xczxj_jtcyxx txj  
	where CJDJ is not null  -- �м��� 
	and(JKZK != 1 and JKZK is not null) -- �ǽ����� 
	and(cast(LDJN  as SIGNED) <= 3 ) -- �Ͷ�����Ϊ���԰��� 1�����Ͷ��� 2��ͨ�Ͷ��� 3���Ͷ�������Ͷ���
	and(cast(WHCD  as SIGNED) <= 3   ) -- �����Ļ��� 
) -- 44�� 


-- ��ѯ ҽ��������Ϣ ��ҽ�Ʒ���Ϣ
 select cysfz,YLFZE  from cjrq left join t_xczxj_ybsjxx  
 on cjrq.cysfz = t_xczxj_ybsjxx.SFZH  
 where YLFZE is not null  -- 0��
 
 -- ����������Ϣ �����������Ϣ
 select cysfz,SZJE  from cjrq left join T_XCZXJ_JYBMXX  
 on cjrq.cysfz = T_XCZXJ_JYBMXX.SFZH  
 where T_XCZXJ_JYBMXX.SZJE is not null  -- 0�� 
 
 -- ��ƶ���������嵥��Ϣ ����������Ϣ
 select cysfz,LPJE  from cjrq left join T_XCZXJ_FPBXLPQDXX  
 on cjrq.cysfz = T_XCZXJ_FPBXLPQDXX.SFZH  
 where T_XCZXJ_FPBXLPQDXX.LPJE is not null -- 1��
 
 -- �ͱ�����Ϣ �Ļ����Ͻ��
 select cysfz,HJBZJE  from cjrq left join T_XCZXJ_DBHXX				
 on cjrq.cysfz = T_XCZXJ_DBHXX.SFZH 
 where T_XCZXJ_DBHXX.HJBZJE is not null  -- 1�� 
 
 -- ��������Ϣ �Ļ����Ͻ��
 select cysfz,HBZJE  from cjrq left join T_XCZXJ_TKGYDXHMCXX								
 on cjrq.cysfz = T_XCZXJ_TKGYDXHMCXX.SFZH 
 where T_XCZXJ_TKGYDXHMCXX.HBZJE is not null  -- 0��
 
 
 /**
  * ���Ʊ�������֤��������֤
 * Ŀ�꣺��ѯ�Ͷ����������Ⱥ�ľ���״�� ��������ά�ȶ������������������ 
 * �����ѵ㣺���еĽ�����ݶ���null,û��ƥ�䵽��ε����ݣ�����ȱʧ���� 
 * ��Ҫ��;��ͨ�����Ʊ�����ԭ��������Ȩ�أ���Ŀǰ���޷�ʹ�ã�û�����ݡ����� ����ѧϰ Ҳ���Ǻܷ��㡣
 */
create  or replace view  ldrrq  as ( 
	select  cysfz from t_xczxj_jtcyxx txj  
	where  CJDJ is not null  -- �м��ȼ� ������null
	and(JKZK=1 or JKZK is null) -- �ǽ����ģ�  null ��Ϊ�ǽ���
	and(cast(LDJN  as SIGNED) > 3 ) -- �Ͷ�����Ϊ���������
	and(cast(WHCD  as SIGNED) <= 3   ) -- �����Ļ� 
)  -- 4 �� ����̫�� �޷����� ƥ���ѯ������  


 
 