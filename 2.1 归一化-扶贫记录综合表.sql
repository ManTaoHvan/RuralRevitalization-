/**
 * ǰ��ע��㣺�󲿷��������ַ��� ������ �Զ�����ת����ʱ�� �������� ©������������ǿ������ת�� ��ȫ��ת���ɹ� ������� Ҫע�� ������ǿ�� ����ת��
 *���֤�����ַ��� ���滹���ܰ�����ĸ �ڽ��б������ Ҫע�� ��� 
 */

-- 1.ҽ���ܵ�����ý��ƫ��ָ��===========================================================
/*
 * ������֤��ţ�1.1
 * Ŀ�꣺��������δ�ṩ�Ĺ�ʽ��ϵ����ԭ������ݽ���һ����� ����ҽ��������Ϣ��Ѱ�Һ��ʵ����ݹ�ʽ
 * ���н����ҽ�Ʒ��ܶ� �� (����ҽ��֧��+ �󲡱������+������ƶ�����ڱ������+������ƶ�����ⱨ�����+ҽ�ƾ���+��������+��������е�+�����Ը�) ,���ɲ��Է��Ƴ���Ź�ʽ�� ���ߵĲ�ֵ��Χ�� -183 ~ -30 Ԫ֮�� ��
 *ע��㣺 �����ҽ���ܵ�����ã����������֧���ķ��ã� ���� ҽ���ܵ���� = ҽ�Ʒ��ܶ� - �����Ը� 
 */
select YLFZE,JBYBZF+DBBX+NBX+WBX+YLJZ+CZDD+DDJGCD+GRZF as sum1,YLFZE - (JBYBZF+DBBX+NBX+WBX+YLJZ+CZDD+DDJGCD+GRZF) as  sub1
from t_xczxj_ybsjxx txy  

/*
 * ҽ���ܵ�����ý��ƫ����ţ�1.2
 * Ŀ�꣺�����ҽ�������������õ�ƫ�� ��ƫ��=����ֵ-ƽ��ֵ 
 */
select sum(YLFZE - ifNULL(GRZF,0)) / count(YLFZE) into @PJ_DM from T_XCZXJ_YBSJXX where YLFZE is not null   -- ����ʵ�ʷ����ķ��� �� һ��Ҫ������null ���� null ��ֱ�������� ���κε�sql �漰null����һ�� ���� ȥִ�еĸ�sql , 
select @PJ_DM; -- ��ѯ ��� ƽ����  

create  table a_je_DMFY as ( -- DMFY��ʾ�������
	 select  SFZH as CYSFZ,txj.JTXX_ID, (YLFZE-GRZF) as DMFY,(YLFZE-GRZF) - @PJ_DM as offset  from T_XCZXJ_YBSJXX -- ƫ�� 
	 left join t_xczxj_jtcyxx txj on T_XCZXJ_YBSJXX.SFZH = txj.CYSFZ
) 

-- 2.�������ƫ��ָ��===========================================================

/*
 * �������ƫ��ָ����ţ�2.1 
 * Ŀ�꣺���������Լ�ͥѧ�����������ƫ�� ��ƫ��=����ֵ-ƽ��ֵ 
 */
select sum(SZJE) / count(SZJE) into @PJ_ZXJ from T_XCZXJ_JYBMXX where SZJE is not null   
select @PJ_ZXJ; -- ��ѯ ��� ƽ����  

create  table a_je_ZXJ as ( --  ZXJ��ʾ��ѧ�� 
	select  SFZH as CYSFZ,txj.JTXX_ID, SZJE ,SZJE- @PJ_ZXJ as offset  from T_XCZXJ_JYBMXX 
	left join t_xczxj_jtcyxx txj on T_XCZXJ_JYBMXX.SFZH = txj.CYSFZ
	) 
	
-- 3.������ƫ��ƫ��ָ��===========================================================

/*
 * ������ƫ��ƫ��ָ����ţ�3.1 
 * Ŀ�꣺�����Ա������ƫ�� ��ƫ��=����ֵ-ƽ��ֵ 
 */
select sum(LPJE) / count(LPJE) into @PJ_LPJE from T_XCZXJ_FPBXLPQDXX where LPJE is not null   -- ƽ��ֵ

select @PJ_LPJE; -- ��ѯ ��� ƽ����  

create  table a_je_LPJE as ( -- LPJE��ʾ ������
	select  SFZH as CYSFZ,txj.JTXX_ID, LPJE ,LPJE- @PJ_LPJE as offset  from T_XCZXJ_FPBXLPQDXX 
	left join t_xczxj_jtcyxx txj on T_XCZXJ_FPBXLPQDXX.SFZH = txj.CYSFZ
	) 

select * from a_je_LPJE

-- 4.�ͱ������Ͻ��ƫ��ָ��===========================================================


/*
 * �ͱ��� �����Ͻ�� ƫ��ָ����ţ�4.1 
 * Ŀ�꣺�����Ա�ͱ��� �����Ͻ�� ��ƫ��=����ֵ-ƽ��ֵ 
 */
select sum(HJBZJE) / count(HJBZJE) into @PJ_HJBZJE from T_XCZXJ_DBHXX  where HJBZJE is not null   -- ƽ��ֵ ��ע��㣺�����õͱ��� �Ļ����Ͻ��( ������˾���װ���Ļ� ���Լ����˳�Ա��û���˾���װ������Ϣ�ġ� ���ǵͱ�����������Ϣ�����ջ�����һ���˵���Ϣ   )  
select @PJ_HJBZJE; 

create  table a_je_HBZJE as ( -- �����Ͻ�� 
	select  SFZH as CYSFZ,txj.JTXX_ID,  HJBZJE ,HJBZJE- @PJ_HJBZJE as offset  from T_XCZXJ_DBHXX		
	left join t_xczxj_jtcyxx txj on T_XCZXJ_DBHXX.SFZH = txj.CYSFZ
	) 

select * from a_je_HJBZJE 

-- 5.�����������Ͻ��ƫ��ָ��===========================================================

/*
 * ���������˾����Ͻ��ƫ��ָ����ţ�5.1 
 * Ŀ�꣺�����Ա���������˾����Ͻ�� ��ƫ��=����ֵ-ƽ��ֵ 
 */
select sum(HBZJE) / count(HBZJE) into @PJ_HBZJE from T_XCZXJ_TKGYDXHMCXX  where HBZJE is not null   -- ƽ��ֵ

select @PJ_HBZJE; -- ��ѯ ��� ƽ����   876.8571428571429

create  table a_je_TKHBZJE as ( -- ���������Ͻ�� 
	select  SFZH as CYSFZ,txj.JTXX_ID, HBZJE ,HBZJE- @PJ_HBZJE as offset  from T_XCZXJ_TKGYDXHMCXX	
	left join t_xczxj_jtcyxx txj on T_XCZXJ_TKGYDXHMCXX.SFZH = txj.CYSFZ
	) 

select * from a_je_TKHJBZJE 



