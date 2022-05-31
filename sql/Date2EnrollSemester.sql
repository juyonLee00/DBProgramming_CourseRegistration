/*
[Date2EnrollSemester]
    IN �Ķ����
        p1: ���� ��¥
    ���� ���
        ������
        ������û�ϴ� �б� ����
    9~12, 1~2 : 1�б�
    3~8: 2�б�
*/

/*
    Set ServerOutput on;
    VAR sem NUMBER;
    EXECUTE :sem := Date2EnrollSemester(SYSDATE)
    PRINT sem;
*/

/*SYSDATE -> �б� ����*/
CREATE OR REPLACE FUNCTION Date2EnrollSemester(dDate IN DATE)
RETURN NUMBER
IS
	v_month VARCHAR2(2);
	v_sem NUMBER;
BEGIN
	v_month := TO_CHAR(dDate, 'MM');

	IF (v_month >= '03' and v_month <= '08') THEN
	v_sem := 2;

	ELSIF (v_month >= '09' and v_month <= '12') OR (v_month >= '01' and v_month <= '02') THEN
	v_sem := 1;
	END IF;

--	DBMS_OUTPUT.PUT_LINE(v_month);
	RETURN v_sem;
END;
/