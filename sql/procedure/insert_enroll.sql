CREATE OR REPLACE PROCEDURE INSERT_ENROLL
(
	USER_S_ID IN ENROLL.S_ID%TYPE,
    USER_C_ID IN ENROLL.C_ID%TYPE,
    USER_C_NO IN ENROLL.C_NO%TYPE,
    result OUT VARCHAR2
)
IS
    v_year NUMBER;
    v_sem NUMBER;
    v_course COURSE%ROWTYPE;
    v_state VARCHAR2(10) := '����';
    
    MAX_CREDIT = -- �ִ� ���� ���� ����
    nTotalCredit NUMBER := 0;
    nDup NUMBER;
    nTime NUMBER;
BEGIN
	result := '';
	
	/* �⵵, �б� */
	v_year := Date2EnrollYear(SYSDATE);
	v_sem := Date2EnrollSemester(SYSDATE);
	
    SELECT *
    INTO v_course.c_id, v_course.c_no, v_course.c_name, v_course.c_time, v_course.c_day, 
    v_course.c_grade, v_course.c_credit, v_course.c_max, v_course.c_crnt, v_course.c_spare, v_course.c_prof 
    FROM COURSE
    WHERE c_id = 21003994 and c_no = 1;
 
    /* ����1: �ִ����� �ʰ����� */
    SELECT SUM(c_credit)
    INTO nTotalCredit
    FROM ENROLL
    WHERE s_id = USER_S_ID and e_year = v_year and e_sem = v_sem ;
     
    IF (nTotalCredit + v_course.c_credit > MAX_CREDIT) THEN
    	RAISE MAX_CREDIT_EXCEPT;
    END IF
    
    /* ����2: ������ ���� ��û ���� */
    SELECT COUNT(*)
    INTO nDup
    FROM ENROLL
    WHERE s_id = USER_S_ID and e_year = v_year and e_sem = v_sem and c_id=USER_C_ID and c_no=USER_C_NO;
    
    IF (nDup > 0) THEN
    	RAISE DUP_COURSE_EXCEPT;
    END IF;
    
    /* ����3: �ð� �ߺ� ���� */
    SELECT COUNT(*)
    INTO nTime
    FROM ENROLL
    WHERE s_id = USER_S_ID and e_year = v_year and e_sem = v_sem and c_day=v_course.c_day and c_time=v_course.c_time;
    
    IF (nTime > 0) THEN
    	RAISE DUP_TIME_EXCEPT;
    END IF;
    
    /* ���� ���� */
    v_course.c_spare := v_course.c_spare-1;
   	IF ( v_course.c_spare < 0) THEN
   		v_course.c_spare := 0;
   	END IF;
    INSERT INTO ENROLL VALUES (USER_S_ID, v_course.c_id, v_course.c_no, v_course.c_name, v_course.c_time, v_course.c_day, 
    						v_course.c_grade, v_course.c_credit, v_course.c_max, v_course.c_crnt+1, v_course.c_spare, v_course.c_prof,
    						v_year, v_sem, v_state);
    COMMIT;
    result := '������û ����� �Ϸ�Ǿ����ϴ�.';

EXCEPTION
	WHEN MAX_CREDIT_EXCEPT THEN
		result := '�ִ� ������ �ʰ��Ͽ����ϴ�.';
    WHEN DUP_COURSE_EXCEPT THEN
    	reuslt := '�̹� ��ϵ� ������ ��û�Ͽ����ϴ�';
    WHEN DUP_TIME_EXCEPT THEN 
    	result := '�̹� ��ϵ� ���� �� �ߺ��Ǵ� �ð��� �����մϴ�';
    WHEN OTHERS THEN
    	result := SQLCODE;
END;
/