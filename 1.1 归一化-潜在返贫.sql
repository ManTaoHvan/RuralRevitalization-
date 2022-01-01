/**
 * ǰ��ע��㣺�󲿷��������ַ��� ������ �Զ�����ת����ʱ�� �������� ©������������ǿ������ת�� ��ȫ��ת���ɹ� ������� Ҫע�� ������ǿ�� ����ת��
 *���֤�����ַ��� ���滹���ܰ�����ĸ �ڽ��б������ Ҫע�� ��� 
 */

-- 1.�м��ȼ�ƫ��ָ��===========================================================
/*
 * ���ݳ�ʼ����ţ�1.1
 * Ŀ�꣺���������쳣����ԭ������ݽ���һ�����²����� �м��ȼ� ����һ�������滻��������������ݱ�ʶ��ͳһ
 * �漰��a_gy_jxcyxx 
 */
UPDATE t_xczxj_jtcyxx SET CJDJ = 
	    CASE CJDJ 
	        WHEN '��' THEN 0 
	        WHEN '����' THEN 1 
	        WHEN 'һ��' THEN 1 
	        WHEN '����' THEN 2 
	        WHEN '����' THEN 3
	        WHEN '�ļ�' THEN 4
	    end 
	WHERE CJDJ IN ('��','����','һ��','����','����','�ļ�');

UPDATE t_xczxj_jtcyxx 	SET CJDJ =0  where CJDJ is null;

/**
 * �м��ȼ�ƫ��ָ�� ��ţ�1.2
 * Ŀ�꣺��ȡ��ͥ�м��ȼ��� ��ƶ�ȼ�Խ�߱����м�Խ���أ���ôƫ��Ҳ��Խ�� 
 */
create table a_yxj_cjdj_tmp ( 
	select -- �Ȼ�ȡһ���Ӳ�ѯ 
		res1.JTXX_ID, -- ��ͥid
		res1.CYSFZ, -- ��Ա���֤ 
		res1.CJDJ, -- �м��ȼ� ��1-4�� 0������ 
		CASE -- ������3���ж����� 
		  WHEN @Tmp = res1.CJDJ  THEN  @grade  -- ��һ��CJDJTmp ��Ϊnull���������������
		  WHEN @Tmp := res1.CJDJ  THEN  @grade := @grade + 1 -- := ��0�ĸ�ֵΪtrue��Ϊ0�ĸ�ֵΪfalse����һ��CJDJTmp 
		  WHEN @Tmp = 0  THEN  @grade := @grade + 1 -- := ��������Ϊfalse ��ô ����������� 
		END AS grade
	FROM (select 
	    JTXX_ID,
	    CYSFZ,
	    cast(txj.CJDJ as SIGNED) as CJDJ
	    from t_xczxj_jtcyxx txj 
		ORDER by cast(txj.CJDJ as SIGNED)   asc 
		) as res1, --  ��һ��������� 
		(SELECT
		 @grade := 0, -- ���ó�ʼֵΪ0 ��ʾ�ȼ� 
		 @Tmp := null -- ��ʱ�����������ݵ�����, ��һ������Ϊnull 
		) as res2  -- �ڶ���������� res2������� һ��Ҫȡ��, ��Ȼǰ�� ����Ҫ �õ�������� �������Ǳ�Ҫ��
	);
select * from a_yxj_cjdj_tmp;

/**
 * �м��ȼ�ƫ��ָ����ţ�1.3
 * Ŀ�꣺����ȼ�ƫ���ƶ�ȼ�Խ�߱����м�Խ���أ���ôƫ��Ҳ��Խ�� 
 */
select sum(grade)/count(grade)  into @PJ_CJDJ from a_yxj_cjdj_tmp where grade is not null  ; -- ����һ������ ���� ��� �ȼ�ƽ����  ,�� Ϊ�˱�֤ ����Ĺ淶 ��������� null ��
select @PJ_CJDJ; -- ��ѯ ��� ƽ����  
create table a_yxj_cjdj as( select JTXX_ID,CYSFZ,CJDJ ,grade,(grade-@PJ_CJDJ) as offset  from a_yxj_cjdj_tmp);  -- ƫ�� = ����ֵ - ƽ��ֵ
select * from a_yxj_cjdj; -- ��ѯ
drop table a_yxj_cjdj_tmp; -- ɾ����ʱ�� 

-- 2.�������ȼ�ƫ��ָ��===========================================================
/**
 * �������ȼ�ƫ��ָ�� ��ţ�2.1
 * Ŀ�꣺��ȡ������״���ȼ��� ��ƶ�ȼ�Խ�߱����������ȼ�Խ�ߣ���ôƫ��Ҳ��Խ�� 
 */
create table a_yxj_jkzkDJ_tmp ( 
	select -- �Ȼ�ȡһ���Ӳ�ѯ 
		res1.JTXX_ID, -- ��ͥid
		res1.CYSFZ, -- ��Ա���֤ 
		res1.JKZK, -- ����״��  1������2�������Բ���3�󲡡�4�м�
		CASE -- ������3���ж����� 
		  WHEN @Tmp = res1.JKZK  THEN  @grade  -- ��һ��CJDJTmp ��Ϊnull���������������
		  WHEN @Tmp := res1.JKZK  THEN  @grade := @grade + 1 -- := ��0�ĸ�ֵΪtrue��Ϊ0�ĸ�ֵΪfalse����һ��CJDJTmp 
		  WHEN @Tmp = 0  THEN  @grade := @grade + 1 -- := ��������Ϊfalse ��ô ����������� 
		END AS grade
	FROM (select 
	    JTXX_ID,
	    CYSFZ,
	    cast(txj.JKZK  as SIGNED) as JKZK
	    from t_xczxj_jtcyxx txj 
		ORDER by cast(txj.JKZK as SIGNED)   asc 
		) as res1, --  ��һ��������� 
		(SELECT
		 @grade := 0, -- ���ó�ʼֵΪ0 ��ʾ�ȼ� 
		 @Tmp := null -- ��ʱ�����������ݵ�����, ��һ������Ϊnull 
		) as res2 -- �ڶ���������� res2������� һ��Ҫȡ��, ��Ȼǰ�� ����Ҫ �õ�������� �������Ǳ�Ҫ��
	); 
select * from a_yxj_jkzkDJ_tmp;

/**
 * ������״���ȼ�ƫ��ָ����ţ�2.2
 * Ŀ�꣺����ȼ�ƫ� ��ƶ�ȼ�Խ�߱����������ȼ�Խ�ߣ���ôƫ��Ҳ��Խ�� 
 */
select sum(grade)/count(grade)  into @PJ_JKZK from a_yxj_jkzkDJ_tmp where  grade is not null  ; -- ����һ������ ���� ��� �ȼ�ƽ����  ע���Ա֧���ڲ��ֱ�û�����ݣ�ָ��ͳ�Ƶ�ʱ��Ҳ������ͳ��Ϊnull ,�� �ó�Ա �����������ּ�Ȩ��ά�ȣ����� ��ƶ�ĵȼ�Ҳ�ή�͡� 
select @PJ_JKZK; -- ��ѯ ��� ƽ����  
create table a_yxj_jkzkDJ as(select JTXX_ID,CYSFZ,JKZK ,grade,(grade-@PJ_JKZK) as offset  from a_yxj_jkzkDJ_tmp ); -- ƫ�� = ����ֵ - ƽ��ֵ
select * from a_yxj_jkzkDJ; -- ��ѯ�� 
drop table a_yxj_jkzkDJ_tmp; -- ɾ����ʱ�� 

-- 3.�Ͷ��������ȼ�ƫ��ָ��===========================================================
/**
 * ��ţ�3.1
 *  Ŀ�꣺���������쳣���������
 */
update  t_xczxj_jtcyxx set LDJN = null where cast(LDJN as SIGNED)  = 0  -- �Ͷ����� 0�ڹ��� Ϊ�ṩ ���ݺ��� Ŀǰ ���� �Ʋ���null�ĺ��� ���Ͷ����ܣ�1�����Ͷ��� 2��ͨ�Ͷ��� 3���Ͷ�������Ͷ��� 4ɥʧ�Ͷ��� 5���Ͷ����� 

/**
 * �Ͷ��������ȼ�ƫ��ָ�� ��ţ�3.1
 * Ŀ�꣺��ȡ�Ͷ��������ĵȼ� ����ƶ�ȼ�Խ�߱����Ͷ�����Խ������ôƫ��Ҳ��Խ�� 
 */
create table a_yxj_ldjnDJ_tmp ( 
	select -- �Ȼ�ȡһ���Ӳ�ѯ 
		res1.JTXX_ID, -- ��ͥid
		res1.CYSFZ, -- ��Ա���֤ 
		res1.LDJN, -- �Ͷ����ܣ�1�����Ͷ��� 2��ͨ�Ͷ��� 3���Ͷ�������Ͷ��� 4ɥʧ�Ͷ��� 5���Ͷ�����
		CASE -- ������3���ж����� 
		  WHEN @Tmp = res1.LDJN  THEN  @grade  -- ��һ��CJDJTmp ��Ϊnull���������������
		  WHEN @Tmp := res1.LDJN  THEN  @grade := @grade + 1 -- := ��0�ĸ�ֵΪtrue��Ϊ0�ĸ�ֵΪfalse����һ��CJDJTmp 
		  WHEN @Tmp = 0  THEN  @grade := @grade + 1 -- := ��������Ϊfalse ��ô ����������� 
		END AS grade
	FROM (select 
	    JTXX_ID,
	    CYSFZ,
	    cast(txj.LDJN  as SIGNED) as LDJN
	    from t_xczxj_jtcyxx txj 
		ORDER by cast(txj.LDJN as SIGNED)   asc 
		) as res1, --  ��һ��������� 
		(SELECT
		 @grade := 0, -- ���ó�ʼֵΪ0 ��ʾ�ȼ� 
		 @Tmp := null -- ��ʱ�����������ݵ�����, ��һ������Ϊnull 
		) as res2 -- �ڶ���������� res2������� һ��Ҫȡ��, ��Ȼǰ�� ����Ҫ �õ�������� �������Ǳ�Ҫ��
	); 
select * from a_yxj_ldjnDJ_tmp;

/**
 * �Ͷ��������ȼ�ƫ��ָ����ţ�3.2
 * Ŀ�꣺����ȼ�ƫ���ƶ�ȼ�Խ�߱����Ͷ�����Խ������ôƫ��Ҳ��Խ�� 
 */
select sum(grade)/count(grade)  into @PJ_LDJN from a_yxj_ldjnDJ_tmp where grade is not null ; -- ����һ������ ���� ��� �ȼ�ƽ���� 
select @PJ_LDJN; -- ��ѯ ��� ƽ����  
create table a_yxj_ldjnDJ as(select JTXX_ID,CYSFZ,LDJN ,grade,(grade-@PJ_LDJN) as offset  from a_yxj_ldjnDJ_tmp ); -- ƫ�� = ����ֵ - ƽ��ֵ
select * from a_yxj_ldjnDJ; -- ��ѯ�� 
drop table a_yxj_ldjnDJ_tmp; -- ɾ����ʱ�� 

-- 4.�Ļ��̶ȵ͵ȼ�ƫ��ָ��===========================================================

/**
 * �Ļ��̶ȵ͵ȼ�ƫ��ָ�� ��ţ�4.1
 * Ŀ�꣺��ȡ�Ļ��̶ȵ͵ĵȼ� ����ƶ�ȼ�Խ�߱����Ļ��̶ȵ�Խ�ͣ���ôƫ��Ҳ��Խ�� 
 */
create table a_yxj_whcdDJ_tmp ( 
	select -- �Ȼ�ȡһ���Ӳ�ѯ 
		res1.JTXX_ID, -- ��ͥid
		res1.CYSFZ, -- ��Ա���֤ 
		res1.whcd, -- �Ļ��̶� 1��ä�����ä��2Сѧ��3���У�4���У�5��ר��6��������
		CASE -- ������3���ж����� 
		  WHEN @Tmp = res1.WHCD  THEN  @grade  -- ��һ��CJDJTmp ��Ϊnull���������������
		  WHEN @Tmp := res1.WHCD  THEN  @grade := @grade + 1 -- := ��0�ĸ�ֵΪtrue��Ϊ0�ĸ�ֵΪfalse����һ��CJDJTmp 
		  WHEN @Tmp = 0  THEN  @grade := @grade + 1 -- := ��������Ϊfalse ��ô ����������� 
		END AS grade
	FROM (select 
	    JTXX_ID,
	    CYSFZ,
	    cast(txj.whcd  as SIGNED) as WHCD
	    from t_xczxj_jtcyxx txj 
		ORDER by cast(txj.whcd as SIGNED)   desc -- ע�� �����ǽ��� ��ǰ���ǲ�һ����  
		) as res1, --  ��һ��������� 
		(SELECT
		 @grade := 0, -- ���ó�ʼֵΪ0 ��ʾ�ȼ� 
		 @Tmp := null -- ��ʱ�����������ݵ�����, ��һ������Ϊnull 
		) as res2 -- �ڶ���������� res2������� һ��Ҫȡ��, ��Ȼǰ�� ����Ҫ �õ�������� �������Ǳ�Ҫ��
	); 
select * from a_yxj_whcdDJ_tmp;

/**
 * �Ļ��̶ȵ͵ȼ�ƫ��ָ����ţ�4.2
 * Ŀ�꣺����ȼ�ƫ���ƶ�ȼ�Խ�߱����Ļ��̶ȵͣ���ôƫ��Ҳ��Խ�� 
 */
select sum(grade)/count(grade)  into @PJ_WHCD from a_yxj_whcdDJ_tmp where grade is not null ; -- ����һ������ ���� ��� �ȼ�ƽ���� 
select @PJ_WHCD; -- ��ѯ ��� ƽ����  
create table a_yxj_whcdDJ as(select JTXX_ID,CYSFZ,WHCD ,grade,(grade-@PJ_WHCD) as offset  from a_yxj_whcdDJ_tmp ); -- ƫ�� = ����ֵ - ƽ��ֵ
select * from a_yxj_whcdDJ; -- ��ѯ�� 
drop table a_yxj_whcdDJ_tmp; -- ɾ����ʱ�� 



-- 5.��Ա��������ͥռ�ȸߵȼ�ƫ��ָ��===========================================================


/**
 * Ŀ�꣺��ȡ��ͥ�������� 
 *  ��ע�����ʣ���ͥ��Ա��Ϣ ���� �Ƿ� ���л������֤ ���𣺺��л������֤��(������ �в�������  ��ͬһ�Ҽ�ͥ,ȴû�������֤�ı�ʶ)
 */
create or replace view  JTRYcountTmp as (
	select  JTXX_ID,count(*) as JTRYcount  from t_xczxj_jtcyxx txj 
	group by JTXX_ID 
)
select * from  JTRYcountTmp

/**
 * Ŀ�꣺��ȡ����ԭ��Ͷ�Ӧ�ļ�ͥ id
 */
create or replace view  JTRYSWWTmp as (
	select  
		txj.JTXX_ID,
		txw.CYSFZH,
		txw.SWYY
	from t_xczxj_jtcyxx txj right join  t_xczxj_wjbmxx  txw -- where ����Ч�ʸ� ����Ͳ�֧�� ��ͼ
	on txj.CYSFZ = txw.CYSFZH 
	where SWYY is not null 
)
select * from  JTRYSWWTmp -- 306 ��


/**
 * Ŀ�꣺ͳ������ռ��
 */
create table JTRYSWZBtmp as 
	( select JTRYSWWTmp.JTXX_ID,JTRYSWWTmp.CYSFZH,JTRYSWWTmp.SWYY, 1/JTRYcountTmp.JTRYcount as JTRYSWZB -- JTRYSWZB ��ʾ ��Ա�����ڼ�ͥ�е�����ռ�� 
	from  JTRYSWWTmp left join JTRYcountTmp   -- ���� Ϊʲô�� 1/JTRYcountTmp.JTRYcount ��Ϊ 1��ʾ���Լ�һ�� 
	on JTRYSWWTmp.JTXX_ID= JTRYcountTmp.JTXX_ID -- 306��  
	)
select * from JTRYSWZBtmp


/**
 * ��Ա��������ͥռ�ȸߵȼ�ƫ��ָ�� ��ţ�5.1
 * Ŀ�꣺��ȡ��Ա��������ͥռ�ȸߵĵȼ� ����ƶ�ȼ�Խ�߱�����Ա��������ͥռ�ȸߣ���ôƫ��Ҳ��Խ�� 
 */
create table a_yxj_jtryswzbDJ_tmp as  (
	select -- �Ȼ�ȡһ���Ӳ�ѯ 
		res1.JTXX_ID, -- ��ͥid
		res1.CYSFZ, -- ��Ա���֤ 
		res1.JTRYSWZB, -- ��ͥ��Ա����ռ�� (����ָ����ռ��) 
		CASE -- ������3���ж����� 
		  WHEN @Tmp = res1.JTRYSWZB  THEN  @grade  -- ��һ��CJDJTmp ��Ϊnull���������������
		  WHEN @Tmp := res1.JTRYSWZB  THEN  @grade := @grade + 1 -- := ��0�ĸ�ֵΪtrue��Ϊ0�ĸ�ֵΪfalse����һ��CJDJTmp 
		  WHEN @Tmp = 0  THEN  @grade := @grade + 1 -- := ��������Ϊfalse ��ô ����������� 
		END AS grade
	FROM (select 
	    JTXX_ID,
	    CYSFZH as CYSFZ,
	    JTRYSWZB 
	    from JTRYSWZBtmp 
	    where JTRYSWZB <1 or JTRYSWZB is null   -- ��ע�� ����С��1 ��nullҲ�Զ����ˣ�����ռ�ȸߴ�100% ��ô ���޷�ʵʩ��ƶ �����ȹ��˵�   ��Ȼ ���� ֧�� ��null , �ں����ά�ȼ�Ȩ ���� ��Ϊ ���� ���ά�� 
		ORDER by JTRYSWZB asc 
		) as res1, --  ��һ��������� 
		(SELECT
		 @grade := 0, -- ���ó�ʼֵΪ0 ��ʾ�ȼ� 
		 @Tmp := null -- ��ʱ�����������ݵ�����, ��һ������Ϊnull 
		) as res2 -- �ڶ���������� res2������� һ��Ҫȡ��, ��Ȼǰ�� ����Ҫ �õ�������� �������Ǳ�Ҫ��
	); 
select * from a_yxj_jtryswzbDJ_tmp; 

/**
 * Ա��������ͥռ�ȸߵȼ�ƫ��ָ����ţ�5.2
 * Ŀ�꣺����ȼ�ƫ�Ա��������ͥռ�ȸߵȼ�Խ�߱�������ռ��Խ�ߣ���ôƫ��Ҳ��Խ�� 
 */
select sum(grade)/count(grade)  into @PJ_SWZB from a_yxj_jtryswzbDJ_tmp where grade is not null ; -- ����һ������ ���� ��� �ȼ�ƽ���� 
select @PJ_SWZB; -- ��ѯ ��� ƽ����  
create table a_yxj_jtryswzbDJ as(select JTXX_ID,CYSFZ, JTRYSWZB,grade,(grade-@PJ_SWZB) as offset  from a_yxj_jtryswzbDJ_tmp ); -- ƫ�� = ����ֵ - ƽ��ֵ
select * from a_yxj_jtryswzbDJ; -- ��ѯ�� 
drop table a_yxj_jtryswzbDJ_tmp; -- ɾ����ʱ�� 

-- 6.��ͨ�¹ʵȼ�ƫ��ָ��===========================================================

/**
 * Ŀ�꣺��ȡ��ͨ�¹ʺͶ�Ӧ�ļ�ͥid
 */
create or replace view JTSGTmp1 as (
	select  
		txj.JTXX_ID ,
		txg.SFZH  as cysfz ,
		txg.xx as sgdd -- �¹ʵص� 
	from t_xczxj_jtcyxx  txj  right join    t_xczxj_gajjbmxx txg -- where ����Ч�ʸ� ����Ͳ�֧�� ��ͼ
	on txj.cysfz = txg.SFZH  -- ע�� ƥ��Ϊnull�� ȷʵ��û�м�ͥid�� ��9������ 
	)

/**
 * Ŀ�꣺ͳ�� �ó�Ա ��Ӧ�ķ��ͽ�ͨ�¹ʵĴ��� 
 */
create or replace view  JTSGTmp2 as (
	select JTXX_ID,cysfz,count(cysfz) as JTSGcount  from JTSGTmp1
	group by cysfz  -- ͳ�� �ó�Ա ��Ӧ�ķ��ͽ�ͨ�¹ʵĴ��� 
	) 
	
select * from  JTSGTmp2 -- 3 ��

/**
 * ��ͨ�¹ʵȼ�ƫ��ָ�� ��ţ�6.1
 * Ŀ�꣺��ȡ ��ͨ�¹ʵĵȼ� ����ƶ�ȼ�Խ�߱����¹ʵȼ�Խ�ߣ���ôƫ��Ҳ��Խ�� 
 */
create table a_yxj_jtsgDJ_tmp ( 
	select -- �Ȼ�ȡһ���Ӳ�ѯ 
		res1.JTXX_ID, -- ��ͥid
		res1.CYSFZ, -- ��Ա���֤ 
		res1.JTSGcount, -- 
		CASE -- ������3���ж����� 
		  WHEN @Tmp = res1.JTSGcount  THEN  @grade  -- ��һ��CJDJTmp ��Ϊnull���������������
		  WHEN @Tmp := res1.JTSGcount  THEN  @grade := @grade + 1 -- := ��0�ĸ�ֵΪtrue��Ϊ0�ĸ�ֵΪfalse����һ��CJDJTmp 
		  WHEN @Tmp = 0  THEN  @grade := @grade + 1 -- := ��������Ϊfalse ��ô ����������� 
		END AS grade
	FROM (select 
	    JTXX_ID,
	    CYSFZ,
	    JTSGcount
	    from JTSGTmp2
		ORDER by  JTSGTmp2.JTSGcount  asc 
		) as res1, --  ��һ��������� 
		(SELECT
		 @grade := 0, -- ���ó�ʼֵΪ0 ��ʾ�ȼ� 
		 @Tmp := null -- ��ʱ�����������ݵ�����, ��һ������Ϊnull 
		) as res2 -- �ڶ���������� res2������� һ��Ҫȡ��, ��Ȼǰ�� ����Ҫ �õ�������� �������Ǳ�Ҫ��
	); 
select * from a_yxj_jtsgDJ_tmp;

/**
 * ��ͨ�¹ʵȼ�ƫ��ָ����ţ�6.2
 * Ŀ�꣺����ȼ�ƫ���ƶ�ȼ�Խ�߱�����ͨ�¹�Խ�ߣ���ôƫ��Ҳ��Խ�� 
 */
select sum(grade)/count(grade)  into @PJ_JTSG from a_yxj_jtsgDJ_tmp where grade is not null ; -- ����һ������ ���� ��� �ȼ�ƽ���� 
select @PJ_JTSG; -- ��ѯ ��� ƽ����  
create table a_yxj_jtsgDJ as(select JTXX_ID,CYSFZ,JTSGcount ,grade,(grade-@PJ_JTSG) as offset  from a_yxj_jtsgDJ_tmp ); -- ƫ�� = ����ֵ - ƽ��ֵ
select * from a_yxj_jtsgDJ; -- ��ѯ�� 
drop table a_yxj_jtsgDJ_tmp; -- ɾ����ʱ�� 


-- 7.��Ե���������ε͵ȼ�ƫ��ƫ��ָ��===========================================================

/**
 * Ŀ�꣺��ȡ��Ե���������ε͵ȺͶ�Ӧ�ļ�ͥid
 */
create or replace view SXDCTmp1 as (
	select  
		txj.JTXX_ID ,
		t_xczxj_yhbmxx.SFZH  as cysfz ,
		t_xczxj_yhbmxx.PJSXDC 
	from t_xczxj_jtcyxx  txj  right join  t_xczxj_yhbmxx    -- where ����Ч�ʸ� ����Ͳ�֧�� ��ͼ
	on txj.cysfz = t_xczxj_yhbmxx.SFZH  -- ע�� ƥ��Ϊnull�� ȷʵ��û�м�ͥid�� ��9������ 
	)


/**
 * ��ȡ��Ե���������ε͵ȼ�ƫ��ָ�� ��ţ�7.1
 * Ŀ�꣺��ȡ ��ȡ��Ե���������ε͵ȼ� ����ƶ�ȼ�Խ�߱�����ȡ��Ե���������ε͵ȼ�Խ�ߣ���ôƫ��Ҳ��Խ�� 
 */
create table a_yxj_sxdcDJ_tmp ( 
	select -- �Ȼ�ȡһ���Ӳ�ѯ 
		res1.JTXX_ID, -- ��ͥid
		res1.CYSFZ, -- ��Ա���֤ 
		res1.pjsxdc, -- �������ŵ��� A-D,D����Խ����,���ò���   
		CASE -- ������3���ж����� 
		  WHEN @Tmp = res1.pjsxdc  THEN  @grade  -- ��һ��CJDJTmp ��Ϊnull���������������
		  WHEN @Tmp := res1.pjsxdc  THEN  @grade := @grade + 1 -- := ��0�ĸ�ֵΪtrue��Ϊ0�ĸ�ֵΪfalse����һ��CJDJTmp 
		  WHEN @Tmp = 0  THEN  @grade := @grade + 1 -- := ��������Ϊfalse ��ô ����������� 
		END AS grade
	FROM (select 
	    JTXX_ID,
	    CYSFZ,
	    pjsxdc
	    from SXDCTmp1
		ORDER by  pjsxdc  asc 
		) as res1, --  ��һ��������� 
		(SELECT
		 @grade := 0, -- ���ó�ʼֵΪ0 ��ʾ�ȼ� 
		 @Tmp := null -- ��ʱ�����������ݵ�����, ��һ������Ϊnull 
		) as res2 -- �ڶ���������� res2������� һ��Ҫȡ��, ��Ȼǰ�� ����Ҫ �õ�������� �������Ǳ�Ҫ��
	); 
select * from a_yxj_sxdcDJ_tmp;

/**
 * ��ȡ��Ե���������ε͵ȼ�ƫ��ָ����ţ�7.2
 * Ŀ�꣺����ȼ�ƫ���ƶ�ȼ�Խ�߱�����ȡ��Ե����������Լ�ͣ���ôƫ��Ҳ��Խ�� 
 */
select sum(grade)/count(grade)  into @PJ_SXDC from a_yxj_sxdcDJ_tmp where grade is not null ; -- ����һ������ ���� ��� �ȼ�ƽ���� 
select @PJ_SXDC; -- ��ѯ ��� ƽ����  
create table a_yxj_sxdcDJ as(select JTXX_ID,CYSFZ,pjsxdc ,grade,(grade-@PJ_SXDC) as offset  from a_yxj_sxdcDJ_tmp ); -- ƫ�� = ����ֵ - ƽ��ֵ
select * from a_yxj_sxdcDJ; -- ��ѯ�� 
drop table a_yxj_sxdcDJ_tmp; -- ɾ����ʱ�� 





