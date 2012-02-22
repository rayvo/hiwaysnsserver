/*
 * 
 *	Hi-Way SNS ����.
 *
 * Copyrights (c) 2010-2011, (��)��ũ����. All rights reserved.
 *
 * ������: ����(Yoo, Seok)
 *
 */
package kr.co.ex.hiwaysns.lib;

public class TrOasisConstants
{
	/*
	 * Constant ����.
	 */
	//�������.
	public	static	final	int		DIRECT_NONE				= 0;			//�������: ����.
																			//��� : ������� ���� = link ���� �����ϴ� ����.
																			//���� : ������� ���� = link ���� �����ϴ� ����.

	//�г����� ���� ����� �̸�.
	public	static	final	String	NICKNAME_NOBODY			= "����";
	
	//�޽��� ���͸� �ð�.
	public	static	final	long	FILTER_TIME_MSG			= 3600;			//�޽��� ��ȿ�ð�: 1�ð� = 3,600��.
	public	static	final	long	FILTER_TIME_LOGIN		= 600;			//Login ����� ������ ��ȿ�ð�: 10�� = 600��.

	//Node ����
	public	static	final	int		NODE_TYPE_IC			= 1;			//IC: �����.
	public	static	final	int		NODE_TYPE_JC			= 2;			//JC: �б���.
	public	static	final	int		NODE_TYPE_RA			= 3;			//�ްԼ�.
	public	static	final	int		NODE_TYPE_TG			= 4;			//TG: ��ݼ�.
	public	static	final	int		NODE_TYPE_ETC			= 5;			//��Ÿ.
	
	//Node�� Alternative Type.
	public	static	final	int		NODE_TYPE_ALT_DEF		= 0;			//����⿡ ��� �����ϴ� �ްԼ�.			
	public	static	final	int		NODE_TYPE_ALT_INC		= 1;			//Link ID�� �����ϴ� ���⿡ �����ϴ� �ްԼ�.			
	public	static	final	int		NODE_TYPE_ALT_DEC		= -1;			//Link ID�� �����ϴ� ���⿡  �����ϴ� �ްԼ�.			

	//�ִ�ġ.
	public	static	final	int		MAX_COUNT_MESSAGE		= 10;			//1���� �����ϴ� �޽����� �ְ� ����.
	public	static	final	int		MAX_COUNT_MEMBER		= 100;			//1���� �����ϴ� ����� �ְ� ����.
	public	static	final	int		MAX_COUNT_USER_TRAFFIC	= 100;			//1���� �����ϴ� ����� ���������� �ְ� ����.
	
	//����� ��� �������� �з�.
	public	static	final	int		TYPE_1_USER					= 10;								//����� ����.
	public	static	final	int		TYPE_2_ACCIDENT_FOUND		= (TYPE_1_USER + 1);				//���߻�.
	public	static	final	int		TYPE_2_ACCIDENT_CLOSED		= (TYPE_2_ACCIDENT_FOUND + 1);		//���ó���Ϸ�.
	public	static	final	int		TYPE_2_DELAY_START			= (TYPE_2_ACCIDENT_CLOSED + 1);		//����ü ����.
	public	static	final	int		TYPE_2_DELAY_END			= (TYPE_2_DELAY_START + 1);			//����ü ����.
	public	static	final	int		TYPE_2_CONSTRUCTION_FOUND	= (TYPE_2_DELAY_END + 1);			//����˸�.
	public	static	final	int		TYPE_2_BROCKEN_CAR_FOUND	= (TYPE_2_CONSTRUCTION_FOUND + 1);	//�������� �˸�.
	public	static	final	int		TYPE_2_USER_CAR_FLOW		= (TYPE_2_BROCKEN_CAR_FOUND + 1);	//��������.
	public	static	final	int		TYPE_2_USER_SNS				= (TYPE_2_USER_CAR_FLOW + 1);		//SNS �޽���.


	public	static	final	int		TYPE_1_ACCIDENT		= (TYPE_1_USER + 100);			//��� ����.
	public	static	final	int		TYPE_1_DELAY		= (TYPE_1_ACCIDENT + 100);		//����ü ����.
	public	static	final	int		TYPE_1_CONSTRUCTION	= (TYPE_1_DELAY + 100);			//���� ����.
	public	static	final	int		TYPE_1_BROCKEN_CAR	= (TYPE_1_CONSTRUCTION + 100);	//���� ����.

	//�ΰ����� ����.
	public	static	final	int		TYPE_ETC_NONE		= 0;						//�ΰ����� ����.
	public	static	final	int		TYPE_ETC_PICTURE	= (TYPE_ETC_NONE + 1);				//����.
	public	static	final	int		TYPE_ETC_VOICE		= (TYPE_ETC_PICTURE + 1);			//����.
	public	static	final	int		TYPE_ETC_MOTION		= (TYPE_ETC_VOICE + 1);				//������.
	
	//���� �������.
	public	static	final	int		DRIVE_STATUS_FINE	= 0;								//���� ����.
	public	static	final	int		DRIVE_STATUS_SLOW	= (DRIVE_STATUS_FINE + 1);			//����.
	public	static	final	int		DRIVE_STATUS_DELAY	= (DRIVE_STATUS_SLOW + 1);			//��ü.
	public	static	final	int		DRIVE_STATUS_BLOCK	= (DRIVE_STATUS_DELAY + 1);			//��ü.
	
	public	static	final	int		DRIVE_STATUS_COND_HI_SLOW	= 70;			//��ӵ��μ��� ���� ���� 71Km/h �̻�.
	public	static	final	int		DRIVE_STATUS_COND_HI_DELAY	= 30;			//��ӵ��μ��� ����/��ü ���� 30~70Km/h ����.
	public	static	final	int		DRIVE_STATUS_COND_HI_BLOCK	= 10;			//��ӵ��μ��� ��ü ���� 11~30Km/h ����.
	
	public	static	final	int		DRIVE_STATUS_COND_SLOW		= 30;			//�Ϲݵ��μ��� ���� ���� 31Km/h �̻�.
	public	static	final	int		DRIVE_STATUS_COND_DELAY		= 10;			//�Ϲݵ��μ��� ����/��ü ���� 6~30Km/h ����.
	public	static	final	int		DRIVE_STATUS_COND_BLOCK		= 5;			//�Ϲݵ��μ��� ��ü ���� 5Km/h ����.

	
	//�������� ������ ��������
	public	static	final	String	TROASIS_COMM_STATUS				= "comm_error";
	public	static	final	int		TROASIS_COMM_TYPE_STATUS		= 0;
	public	static	final	int		TROASIS_COMM_TYPE_MEMBER_LIST	= (TROASIS_COMM_TYPE_STATUS + 1);
	public	static	final	int		TROASIS_COMM_TYPE_MESSAGE_LIST	= (TROASIS_COMM_TYPE_MEMBER_LIST + 1);

	
	/*
	 * Class �� Instance Variable ����.
	 */

	
	/*
	 * Method ����.
	 */
}
