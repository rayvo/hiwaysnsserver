/*
 * 
 *	Hi-Way SNS ����.
 *
 * Copyrights (c) 2010-2011, (��)��ũ����. All rights reserved.
 *
 * ������: ����(Yoo, Seok)
 *
 */

package kr.co.ex.hiwaysns;

import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;

import kr.co.ex.hiwaysns.lib.*;

public class HiWayCommServer extends HiWayDbServer
{
	/*
	 * Constant.
	 */
	public	static	final	int		RADIUS_MAP_MATCH			= 3000;		//Map Matching �ݰ� 3Km = 3,000M.
	public	static	final	int		DIRECT_MIN_MOVE				= 50;		//���� ������ ���� �ּ����� �̵��Ÿ� 50M.
	public	static	final	int		MATCH_MAX_LENGTH			= 400;		//Link�� matching ������ �ִ� �Ÿ�.
	public	static	final	int		MATCH_AMBIGU_LENGTH			= 500;		//Link matching�� ��ȣ�� �ּ� �Ÿ�.

	public	static	final	int		RADIUS_MEMBER_SEARCH		= 10000;					//��� �˻��� ���� �ݰ� 10Km = 10,000M.
	public	static	final	int		RADIUS_MEMBER_SEARCH_MIN	= RADIUS_MEMBER_SEARCH;		//��� �˻��� ���� �ݰ� 10Km = 10,000M.
	public	static	final	int		RADIUS_MEMBER_SEARCH_MAX	= 1000000;					//��� �˻��� ���� �ݰ� 1,000Km = 1,000,000M.
	public	static	final	int		RADIUS_FTMS_SEARCH			= 20000;					//FTMS Matching �ݰ� 20Km = 20,000M.
	public	static	final	int		RADIUS_VMS_SEARCH			= 20000;					//VMS Matching �ݰ� 20Km = 20,000M.
	public	static	final	int		RADIUS_CCTV_MATCH			= RADIUS_VMS_SEARCH;		//VMS Matching �ݰ� 10Km = 10,000M.
	public	static	final	int		RADIUS_TRAFFIC_SEARCH		= RADIUS_MEMBER_SEARCH;		//�������� �˻��� ���� �ݰ� 10Km = 10,000M.

	public	static	final	int		MAX_DIRECTION_INC			= 2;		//������� ����ġ�� Upper Bound.
	public	static	final	int		MAX_DIRECTION_DEC			= -2;		//������� ����ġ�� Lower Bound.
	
	//�մ��� User ID.
	public	static	final	String	NICKNAME_GUEST				= "guest";

	
	/*
	 * Variables.
	 */
	public	int				status_code	= 0;
	public	String			status_msg	= "";
	
	//���� �ֱ��� ����� ��ġ ����.
	public	String			mNickname		= "";		//����� Nickname.
	public	int				mRoadNo			= 0;		//����ڰ� ��ġ�ϰ� �ִ� ������ ��ȣ.
	public	long			mLinkeID		= 0;		//����ڰ� ��ġ�� Link�� ID.
	public	int				mDirection		= 0;		//������� �������.
	public	long			mDistance		= 0;		//Link�� �Ҽӵ� ������ �������κ����� �Ÿ�(������ M).
	public	int				mAccessCount	= 0;		//FTMS �������� ����ȸ��.
	//Map matching ���.
	public	TrOasisMapLink	mMapLink	= null;			//����ڰ� ��ġ�ϰ� �ִ� Link ����.
	public	TrOasisMapLink	mMapLink2	= null;			//������ ������ �����ϴ� Link ����.
	
	//�־��� �����ȿ� �ִ� ���� �浵 ����.
	public	double			mRange_lat_from, mRange_lat_to, mRange_lng_from, mRange_lng_to;
	//�־��� �����ȿ� �ִ� Link ���.
	protected	int			mIndexSel		= -1;
	protected	List<TrOasisMapLink>	mMapLinkList	= new ArrayList<TrOasisMapLink>();
	public		int			mRadiusSearch	= 0;		//�ּ��� 1�� �̻��� ����� ã������ Ž������.

	
	/*
	 * ��ü������.
	 */
	public	HiWayCommServer()
	{
		super();
	}
	
	
	/*
	 * Overrides.
	 */
	
	
	/*
	 * Methods.
	 */
	//�־�������� User ID�� ��ȿ�� �˻� - Login��.
	public	boolean	isValidUserID( String strUserID )
	{
		if ( strUserID.length() < 1 )
		{
			status_code	= 2;
			status_msg	= "��ȿ���� ���� ����� User ID ���.";
			return( false );
		}
		return( true );
	}
	
	//�־�������ڿ� ��ġ������ ��ȿ�� �˻� - Web service��.
	public	boolean	isValidUser( String strActiveID, String strUserID, int nPosLat, int nPosLng )
	{
		if ( isValidUserLocation(nPosLat, nPosLng) == false )	return( false );
		if ( isValidActiveID(strUserID, strActiveID) == false )	return( false );
		return( true );
	}
	
	//�־�������� Active ID�� ��ȿ�� �˻� -Logout��.
	public	boolean	isValidActiveID( String strUserID, String strActiveID )
	{
		if ( isValidUserID(strUserID) == false )	return( false );
//		if ( strUserID.compareToIgnoreCase(NICKNAME_GUEST) == 0 )	return( true );
		
		if ( strActiveID.length() < 1 )
		{
			status_code	= 2;
			status_msg	= "��ȿ���� ���� ����� Active ID ���.";
			return( false );
		}
		
		boolean		bResult	= true;
		try
		{
			//DB ����.
			db_open();

			//�־��� User ID, Active ID�� ����ڰ� �����ϴ��� �˻��Ѵ�.	
			String	strQuery;
			String	strTableActive	= "troasis_active";
			
			strQuery	= "SELECT nickname, road_no, link_id, direction, distance, access_count";
			strQuery	= strQuery + " FROM " + strTableActive;
			strQuery	= strQuery + " WHERE id = " + strActiveID + "";
			if ( strUserID.compareToIgnoreCase(NICKNAME_GUEST) != 0 )
				strQuery	= strQuery + " AND user_id = '" + strUserID + "'";
			strQuery	= strQuery + " AND flag_deleted = 0";
			//System.out.println( "strQuery=" + strQuery );
			exec_query( strQuery );
			
			if ( mDbRs.next() )
			{
				mNickname		= mDbRs.getString( "nickname" );	//����� Nickname.
				mRoadNo			= mDbRs.getInt( "road_no" );		//����ڰ� ��ġ�� ������ ��ȣ.
				mLinkeID		= mDbRs.getLong( "link_id" );		//����ڰ� ��ġ�� Link�� ID.
				mDirection		= mDbRs.getInt( "direction" );		//������� �������.
				mDistance		= mDbRs.getLong( "distance" );		//Link�� �Ҽӵ� ������ �������κ����� �Ÿ�(������ M).
				mAccessCount	= mDbRs.getInt( "access_count" );	//FTMS �������� ����ȸ��.
			}
			else
			{
				status_code	= 2;
				status_msg	= "��ȿ���� ���� ����� User ID, Activity ID ���.";
				bResult	= false;
			}
			if ( mNickname.length() < 1 )	mNickname = strUserID;
			if ( mNickname.length() < 1 )	mNickname = TrOasisConstants.NICKNAME_NOBODY;
		}
		catch( Exception e )
		{
			status_code	= 2;
			status_msg	= e.toString();
			bResult	= false;
		}
		finally
		{
			//DB ���� �ݱ�.
			try
			{
				db_close();
			}
			catch( Exception e2 ) { }
		}

		return( bResult );
	}
	
	//�־����������ġ������ ��ȿ�� �˻�.
	public	boolean	isValidUserLocation( int nPosLat, int nPosLng )
	{
		if ( nPosLat == 0 && nPosLng == 0 )
		{
			status_code	= 0;
			status_msg	= "������� ��ġ������ ���ǵ��� �ʾҽ��ϴ�.";
			return( false );
		}
		return( true );
	}
	
	
	//�޽��� ��� �˻�.
	public	boolean		retrieveMsgList()
	{
		return( true );
	}
	
	/*
	 * Map Matching ����.
	 */
	//�־��� �Ÿ� ������ �ش��ϴ� ���� �浵 ����.
	//���� �浵 ���� GeoPoint�� ����Ѵ�.
	public	int	findFtmsRange( int nPosLat, int nPosLng )
	{
		setGeoPtRange( RADIUS_FTMS_SEARCH, nPosLat, nPosLng );			//FTMS Agent Ž�� �ݰ�.
		return RADIUS_FTMS_SEARCH;
	}

	public	int	findVmsRange( int nPosLat, int nPosLng )
	{
		setGeoPtRange( RADIUS_VMS_SEARCH, nPosLat, nPosLng );			//FTMS Agent Ž�� �ݰ�.
		return RADIUS_VMS_SEARCH;
	}

	public	int	findTrafficRange( int nPosLat, int nPosLng )
	{
		setGeoPtRange( RADIUS_TRAFFIC_SEARCH, nPosLat, nPosLng );		//�������� Ž�� �ݰ�.
		return RADIUS_TRAFFIC_SEARCH;
	}

	public	int	findSearchRange( int nPosLat, int nPosLng )
	{
		setGeoPtRange( RADIUS_MEMBER_SEARCH, nPosLat, nPosLng );		//��� Ž�� �ݰ�.
		return RADIUS_MEMBER_SEARCH;
	}

	public	int	nextSearchRange( int radius_search, int nPosLat, int nPosLng )
	{
		radius_search	= radius_search * 2;							//��� Ž���ݰ��� 2��� Ȯ��.
		//System.out.println( "radius_search=" + radius_search );
		setGeoPtRange( radius_search, nPosLat, nPosLng );
		return radius_search;
	}
	
	//�ּ��� 1���̻��� ����� �ݰߵ� ������ Searching ���� Ž��.
	public	int	setSearchRange( String strActiveID, int nPosLat, int nPosLng ) throws Exception
	{
	 	long	currentTime	= getCurrentTimestamp();
		
		// Match Making�� ���� Group�� ���� ����.
		mRadiusSearch	= RADIUS_MEMBER_SEARCH_MIN;
		setGeoPtRange( mRadiusSearch, nPosLat, nPosLng );			//��� Ž�� �ݰ�.
		
		int		count_friends	= 1;
		/* --2011.01.09 by s.yoo : ��� ����.
		//�ּ��� 1�� �̻��� ����� ������ ������ Ž������ Ȯ��.
		int		count_friends	= 0;
		int		radius_search	= 0;
		try
		{
			String	strQuery	= "";
			while ( mRadiusSearch <= RADIUS_MEMBER_SEARCH_MAX )		//500Km ���Ͽ� ���ؼ��� �˻�.
			{
				strQuery	= "SELECT COUNT(*)";
				strQuery	= strQuery + subQueryFriend(strActiveID, currentTime);
				//System.out.println( "strQuery=" + strQuery );
				exec_query( strQuery );
				
				//����� ���翩�� �˻�.
				if ( mDbRs.next() )
				{
					count_friends	= mDbRs.getInt( 1 );
					if ( count_friends > 0 )
					{
						if ( radius_search <= 0 )	radius_search = mRadiusSearch;
						//System.out.println( "1. radius_search=" + radius_search );
						if ( mRadiusSearch >= RADIUS_MEMBER_SEARCH )	break;
						mRadiusSearch	= RADIUS_MEMBER_SEARCH / 2;
					}
				}
				
				//Ž�������� Ȯ���ؼ� ��Ž��.
				mRadiusSearch	= nextSearchRange(mRadiusSearch, nPosLat, nPosLng);
			}
		}
		catch( Exception e )
		{
			throw new Exception( e.toString() );
		}
		//System.out.println( "2. radius_search=" + radius_search );
		if ( radius_search > 0 )	mRadiusSearch = radius_search;
		if ( count_friends < 1 )	mRadiusSearch = RADIUS_MEMBER_SEARCH_MIN;
		//System.out.println( "3. mRadiusSearch=" + mRadiusSearch );
		 */
		
		//�߰ߵ� ����� ���� ����.
		return count_friends;
	}
	
	//��� ��� �˻��� ���� Sub-Query ���ڿ� ����.
	public	String	subQueryFriend( String strActiveID, long currentTime )
	{
		String	strTableActive	= "troasis_active";
		String	strQuery		= "";

		//strQuery	= "SELECT COUNT(*)";
		strQuery	= strQuery + " FROM " + strTableActive;
		strQuery	= strQuery + " WHERE id <> " + strActiveID;
		strQuery	= strQuery + " AND loc_lat >= " + mRange_lat_from + " AND loc_lat <= " + mRange_lat_to;
		//strQuery	= strQuery + " WHERE loc_lat >= " + mRange_lat_from + " AND loc_lat <= " + mRange_lat_to;
		strQuery	= strQuery + " AND loc_lng >= " + mRange_lng_from + " AND loc_lng <= " + mRange_lng_to;
		strQuery	= strQuery + " AND flag_deleted = 0";
		strQuery	= strQuery + " AND time_log_last >= " + (currentTime - TrOasisConstants.FILTER_TIME_LOGIN);	//��ð� �������� ����.
		if ( mLinkeID > 0 )				//��ӵ��ο� ��ġ�ϴ� ��� ������� ���.
		{
			//�Ϲݵ����� ���� ����, �ٸ� ��ӵ����� �����(JC�� ����ؼ�) �Ǵ� ���� ��ӵ����� ���� ����.
			if ( mDirection > 0 )			//��ӵ��� Link ID�� �����ϴ� �������� �̵��ϴ� ���.
			{
				//��ӵ��ΰ� �ƴ� ���ο��� ���� ���� �����̰ų�
				strQuery	= strQuery + " AND ( (link_id = 0 AND direction > 0) ";
				//�Ǵ� ��ӵ��ο��� ���� �ٸ� ���ο� �ְų�(JC�� ����ؼ�)
				strQuery	= strQuery + "  OR (link_id > 0 AND road_no <> " + mRoadNo + ")";
				//�Ǵ� ��ӵ��ο��� ���� ���� ������ ���� �������� �����ϴ� ���
				strQuery	= strQuery + "  OR (link_id > 0 AND road_no = " + mRoadNo  + " AND direction > 0) )";
			}
			else if ( mDirection < 0 )		//��ӵ��� Link ID�� �����ϴ� �������� �̵��ϴ� ���.
			{
				//��ӵ��ΰ� �ƴ� ���ο��� ���� ���� �����̰ų�
				strQuery	= strQuery + " AND ( (link_id = 0 AND direction < 0) ";
				//�Ǵ� ��ӵ��ο��� ���� �ٸ� ���ο� �ְų�(JC�� ����ؼ�)
				strQuery	= strQuery + "  OR (link_id > 0 AND road_no <> " + mRoadNo + ")";
				//�Ǵ� ��ӵ��ο��� ���� ���� ������ ���� �������� �����ϴ� ���
				strQuery	= strQuery + "  OR (link_id > 0 AND road_no = " + mRoadNo  + " AND direction < 0) )";
			}
		}
		return strQuery;
	}

	//Map Matching ���� - ����� ��ġ�� ���� Map matching.
	public	long	procMapMatching( int nPosLat, int nPosLng, int prev_road, long prev_link, int pre_direction, long prev_distance ) throws Exception
	{
		//�־��� �ݰ�ȿ� �ִ� Node ��� �˻�.
		long	link_id_min	= -1;
		try
		{
			//�־��� GPS ��ǥ�� �ش��ϴ� Link �˻�.
			//System.out.println( "GPS=" + nPosLat + ", " + nPosLng );
			//link_id_min	= procFindMapLink( nPosLat, nPosLng );
			link_id_min	= buildLocationInfo( nPosLat, nPosLng, pre_direction );

			//Matching�Ǵ� Link�� ���� ��쿡��.
			if ( link_id_min <= 0 )	return( link_id_min );

			//Default Link ���� ����.
			mMapLink	= new TrOasisMapLink();
			mMapLink.road_no	= prev_road;
			mMapLink.link_id	= prev_link;
			mMapLink.direction	= pre_direction;
			mMapLink.distance	= prev_distance;
			
			//Matching�� Link�� �ٸ� �����̸鼭 �ʹ� �����ؼ� Ȯ��ġ ���� ��쿡��, ������ Map Matching�� �ٽ� ����.
			int		road_no		= 0;
			double	distDegMin	= 0;
			if( mIndexSel >= 0 )
			{
				road_no		= mMapLinkList.get(mIndexSel).road_no;
				distDegMin	= mMapLinkList.get(mIndexSel).distDegree;
			}
			for ( int i = 0; i < mMapLinkList.size(); i++ )
			{
				//System.out.println( "distDegMin =" + distDegMin + ", MapLinkList.get(i).distDegree=" + mMapLinkList.get(i).distDegree);
				if ( i != mIndexSel
						&& road_no != mMapLinkList.get(i).road_no
						&& mMapLinkList.get(i).distDegree >= 0
						&& Math.abs(distDegMin - mMapLinkList.get(i).distDegree) <= MATCH_AMBIGU_LENGTH )	return(prev_link);
			}

			//������ Matching�� Link�� ���� ��쿡��, ���� ������ Link�� Matching.
			if ( prev_link <= 0 )
			{
				if ( mIndexSel < 0 )	return( prev_link );
				mMapLink	= mMapLinkList.get( mIndexSel );
			}
			//������ Matching�� Link�� ���� �Ǻ��� Link�� ���輺 �˻�.
			else
			{
				//(TBD)
				mMapLink	= mMapLinkList.get( mIndexSel );
			}
			
			//Matching�� Link�� ID ����.
			link_id_min	= mMapLink.link_id;
			mMapLink.direction	= pre_direction;
			mMapLink.distance	= prev_distance;
			
			//Link�� �Ҽӵ� ������ End Node ����(Link ID�� ���� ū Node)���κ����� ��������� �Ÿ� ���.
			long	distance	= (long)distGeoPts( mMapLink.road_end_loc_lat, mMapLink.road_end_loc_lng, nPosLat, nPosLng );

			//�ּ����� �Ÿ����̰� ���ٸ�, ������ �����Ѵ�.
			//System.out.println( "current distance=" + distance + ", prev_distance=" + prev_distance + ", pre_direction=" + pre_direction );
			if ( Math.abs(distance - prev_distance) >= DIRECT_MIN_MOVE )
			{
				//Link�� �Ҽӵ� ������ End Node ����(Link ID�� ���� ū Node)���κ����� ��������� �Ÿ� ����.
				mMapLink.distance	= distance;

				//������� �̵����� �Ǻ�.
				if ( prev_distance > 0 )
					findUserDirection( pre_direction, prev_distance );
				//System.out.println("pre_direction=" + pre_direction + " prev_distance=" + prev_distance);
				//System.out.println("mMapLink.direction=" + mMapLink.direction + " mMapLink.distance=" + mMapLink.distance);
			}
		}
		catch(Exception e)
		{
			throw new Exception( e.toString() );
		}		
		
		//�߰ߵ� Link�� ID ��ȯ.
		return link_id_min;
	}
	
	//Map Matching ���� - �־��� ���浵 ��ǥ�� ���� Map matching.
	public	long	procFindMapLink( int nPosLat, int nPosLng ) throws Exception
	{
		mIndexSel		= -1;
		long	link_id	= 0;
		try
		{
			//�־��� ������ �����ϴ� Link ��� �� �ִܰŸ��� Link �˻�.
			int	index_sel	= findMapLinkList( nPosLat, nPosLng );

			//Matching�Ǵ� Link�� ���� ��쿡��....
			if ( index_sel < 0 )	return( link_id );

			//Matching�� �Ÿ��� ���������� �ʰ��ϸ�, Matching ���з� �����Ѵ�.
			TrOasisMapLink	objMapLink	= mMapLinkList.get(index_sel);
			//System.out.println( "[" + index_sel + "] " + objMapLink.link_id + " objMapLink.start_loc_lng=" + objMapLink.start_loc_lng );
			double	distMetric	= distToLinkMeter( objMapLink.start_loc_lng, objMapLink.start_loc_lat,
										objMapLink.end_loc_lng, objMapLink.end_loc_lat, nPosLng, nPosLat );
			if ( 0 <= distMetric && distMetric > MATCH_MAX_LENGTH )	return( link_id );
			//System.out.println( "mMapLinkList.size()=" + mMapLinkList.size() + ", index_sel=" + index_sel + ", distMetric=" + distMetric );

			//Matching�� Link�� ID ����.
			mIndexSel	= index_sel;
			mMapLink	= mMapLinkList.get(mIndexSel);
			link_id 	= mMapLink.link_id;
		}
		catch(Exception e)
		{
			throw new Exception( e.toString() );
		}		
		
		//�߰ߵ� Link�� ID ��ȯ.
		return link_id;
	}
	
	//Map Matching ���� - �־��� ���浵 ��ǥ�� ���� ��ġ���� ����.
	public	long	buildLocationInfo( int nPosLat, int nPosLng, int pre_direction ) throws Exception
	{
		//�־��� �ݰ�ȿ� �ִ� Node ��� �˻�.
		long	link_id	= 0;
		try
		{
			//�־��� ������ �����ϴ� Link ��� �� �ִܰŸ��� Link �˻�.
			int	index_sel	= findMapLinkList( nPosLat, nPosLng );

			//Matching�Ǵ� Link�� ���� ��쿡��....
			if ( index_sel < 0 )	return( link_id );
			
			//Matching�� �Ÿ��� ���������� �ʰ��ϸ�, Matching ���з� �����Ѵ�.
			TrOasisMapLink	objMapLink	= mMapLinkList.get(index_sel);
			double	distMetric	= distToLinkMeter( objMapLink.start_loc_lng, objMapLink.start_loc_lat,
										objMapLink.end_loc_lng, objMapLink.end_loc_lat, nPosLng, nPosLat );
			//System.out.println( "distMetric=" + distMetric + ", link=" + objMapLink.link_id );
			if ( distMetric > MATCH_MAX_LENGTH )	return( link_id );

			//Matching�� Link�� ID ����.
			mIndexSel	= index_sel;
			mMapLink	= mMapLinkList.get(mIndexSel);
			link_id 	= mMapLink.link_id;
			
			//���濡 �ִ� �������� �˻�.
			calcNodeDistance( link_id, pre_direction, nPosLat, nPosLng );
			
			//���濡 �ִ� ���� ����� �̸����� �Ÿ� ���.
			String	strBaseNodeName	= "";
			long	distance		= 0;
			if ( mMapLink2 != null )
			{
				if( pre_direction >= 0 )	//Link ID ��������
				{
					strBaseNodeName = mMapLink2.end_node_name;
					distance		= (long) distGeoPts( mMapLink2.end_loc_lat, mMapLink2.end_loc_lng, nPosLat, nPosLng );
				}
				else						//Link ID ���ҹ���
				{
					strBaseNodeName = mMapLink2.start_node_name;
					distance		= (long) distGeoPts( mMapLink2.start_loc_lat, mMapLink2.start_loc_lng, nPosLat, nPosLng );
				}
			}
			
			//�Ÿ� ���� ����.
			DecimalFormat	df		= new DecimalFormat( "##.#" );
			String			dist_km	= df.format(distance / 1000.0) + "Km";
		
			//Matching�� Link�� ��ġ���� ����.
			String	location_msg	= "";
			if( pre_direction >= 0 )		//Link ID ��������
			{
				location_msg	= location_msg + mMapLink.road_name;							//���θ�.
				location_msg	= location_msg + " " + mMapLink.road_end_node_name + " ����";	//����.
			}
			else							//Link ID ���ҹ���
			{
				location_msg	= location_msg + mMapLink.road_name;							//���θ�.
				location_msg	= location_msg + " " + mMapLink.road_start_node_name + " ����";	//����.
			}
			location_msg	= location_msg + " " + strBaseNodeName + " ����";					//����.
			location_msg	= location_msg + " " + dist_km + " ����";							//�Ÿ�.

			//System.out.println( "pre_direction=" + pre_direction + ", mMapLink.road_name=" + mMapLink.road_name );
			//System.out.println( "mMapLink.road_start_node_name=" + mMapLink.road_start_node_name + ", dist_km=" + dist_km );
			//System.out.println( "link_id=" + link_id + ", location_msg=" + location_msg );
			mMapLink.location_msg	= location_msg;
		}
		catch(Exception e)
		{
			throw new Exception( e.toString() );
		}		
		
		//�߰ߵ� Link�� ID ��ȯ.
		return link_id;
	}
	
	//�־��� Link�� ���濡 ��ġ�ϴ� ���� �� �������� �Ÿ� ���.
	protected	void	calcNodeDistance( long link_id, int direction, int nPosLat, int nPosLng ) throws Exception
	{
		String	strQuery;
		String	strTableLink	= "troasis_map_link";

		try
		{
			//���� Node�� �����ϴ� Link �˻�.
			if ( direction >= 0 )	//Link ID�� �����ϴ� ����.
			{
				strQuery	= "SELECT MIN(link_id)";
				strQuery	= strQuery + " FROM " + strTableLink;
				strQuery	= strQuery + " WHERE link_id >= " + link_id;
				strQuery	= strQuery + " AND (end_node_type = " + TrOasisConstants.NODE_TYPE_IC;
				strQuery	= strQuery + " OR end_node_type = " + TrOasisConstants.NODE_TYPE_JC + ")";
			}
			else					//Link ID�� �����ϴ� ����.
			{
				strQuery	= "SELECT MAX(link_id)";
				strQuery	= strQuery + " FROM " + strTableLink;
				strQuery	= strQuery + " WHERE link_id <= " + link_id;
				strQuery	= strQuery + " AND (start_node_type = " + TrOasisConstants.NODE_TYPE_IC;
				strQuery	= strQuery + " OR start_node_type = " + TrOasisConstants.NODE_TYPE_JC + ")";
			}
			exec_query( strQuery );
			//System.out.println( "strQuery=" + strQuery );
			
			long	base_link_id	= -1;
			if ( mDbRs.next() )	base_link_id = mDbRs.getLong( 1 );
			
			mMapLink2	= null;
			if ( base_link_id < 0 )	return;
			
			//���� ����� ���� �˻�.
			strQuery	= "SELECT *";
			strQuery	= strQuery + " FROM " + strTableLink;
			strQuery	= strQuery + " WHERE link_id = " + base_link_id;
			exec_query( strQuery );
			//System.out.println( "strQuery=" + strQuery );
			
			if ( mDbRs.next() )
			{
				mMapLink2	= new TrOasisMapLink();
				mMapLink2.loadLinkInfo(mDbRs);
			}
		}
		catch(Exception e)
		{
			throw new Exception( e );
		}
	}
	
	
	/*
	 * Implementations.
	 */
	//�־��� �Ÿ� ������ �ش��ϴ� ���� �浵 ����.
	//���� �浵 ���� GeoPoint�� ����Ѵ�.
	public	void	setGeoPtRange( long distMetric, int nPosLat, int nPosLng )
	{
		double	rangeLat	= (distMetric * 1000000.0 / 111034.0);		//���� 1�� = �� 111.034Km.
		double	rangeLng	= (distMetric * 1000000.0 /  85397.0);		//�浵 1�� = �� 85.397Km.
		//System.out.println( "distMetric=" + distMetric + ", range=" + rangeLat +","+rangeLng);
		mRange_lat_from	= nPosLat - rangeLat;
		mRange_lat_to	= nPosLat + rangeLat;
		mRange_lng_from	= nPosLng - rangeLng;
		mRange_lng_to	= nPosLng + rangeLng;
	}

	//�־��� ���� �ȿ� �����ϴ� Link ��� �˻�.
	protected	int	findMapLinkList( int nPosLat, int nPosLng ) throws Exception
	{
		// Match Making�� ���� Group�� ���� ����.
		setGeoPtRange( RADIUS_MAP_MATCH, nPosLat, nPosLng );		//Map matching �Ÿ�.
			
		//�־��� �ݰ�ȿ� �ִ� Link ��� �˻�.
		String	strQuery;
		String	strTableLink	= "troasis_map_link";
		
		int		index_min	= -1;
		double	distDegMin	= -1;
		try
		{
			//Match Making�� ����, �׷쿡 �Ҽӵ� ȸ������ ��� �˻�..	
			//�־��� ������ �����ϴ� Node ��� �˻�.
			strQuery	= "SELECT *";
			strQuery	= strQuery + " FROM " + strTableLink;
			strQuery	= strQuery + " WHERE ";
			strQuery	= strQuery + "(start_loc_lat >= " + mRange_lat_from + " AND start_loc_lat <= " + mRange_lat_to;
			strQuery	= strQuery + " AND start_loc_lng >= " + mRange_lng_from + " AND start_loc_lng <= " + mRange_lng_to + ")";
			strQuery	= strQuery + " OR (end_loc_lat >= " + mRange_lat_from + " AND end_loc_lat <= " + mRange_lat_to;
			strQuery	= strQuery + " AND end_loc_lng >= " + mRange_lng_from + " AND end_loc_lng <= " + mRange_lng_to + ")";
			exec_query( strQuery );
			//System.out.println( "strQuery=" + strQuery );
			
			for ( int i = 0; mDbRs.next(); i++ )
			{
				//Link ������ DB���� �о����.
				TrOasisMapLink	objMapLink	= new TrOasisMapLink();
				objMapLink.loadLinkInfo(mDbRs);

				//Link���� �Ÿ� ���(Degree ����) �� ���� ����� �Ÿ��� Link ����.
				objMapLink.distDegree	= distToLinkDegree( objMapLink.start_loc_lng, objMapLink.start_loc_lat,
												objMapLink.end_loc_lng, objMapLink.end_loc_lat, nPosLng, nPosLat );
				if ( objMapLink.distDegree >= 0 && (index_min < 0 || objMapLink.distDegree < distDegMin) )
				{
					index_min	= i;
					distDegMin	= objMapLink.distDegree;
				}
				//System.out.println( "objMapLink.link_id=" + objMapLink.link_id + ", objMapLink.distDegree=" + objMapLink.distDegree );
				
				//Link ��Ͽ� ���.
				mMapLinkList.add( objMapLink );
			}
		}
		catch(Exception e)
		{
			throw new Exception( e.toString() );
		}		
		
		//Link ��Ͽ��� �Ÿ��� ���� ����� Link�� ��ġ(Index) �Ǻ�.
		return index_min;
	}

	
	//������� �̵����� �Ǻ�.
	//
	//	��� : Link ID�� �����ϴ� �������� �̵�.
	//	���� : Link ID�� �����ϴ� �������� �̵�.
	//
	//	������ ������ �̵������� ��ġ�ϴٸ�, �Ǻ��� �̵����� ���.
	//	������ ������ �̵������� ��ġ���� �ʴ´ٸ�, ������ �Ǻ��� �̵��������� �̵����� �Ǻ�.
	protected	void	findUserDirection( int pre_direction, long prev_distance )
	{
		//End Node(Link ID�� ���� ū Node)�� �������� �������� �� �� �Ÿ��� �̵��ϰ� �ִ� ���.
		if ( mMapLink.distance > prev_distance )
		{
			//Link�� �����ϴ� �������� ����ġ ����.
			mMapLink.direction = pre_direction - 1;
			if ( mMapLink.direction < MAX_DIRECTION_DEC )	mMapLink.direction = MAX_DIRECTION_DEC;
		}
		//End Node(Link ID�� ���� ū Node)�� �������� �������� �� ����� �Ÿ��� �̵��ϰ� �ִ� ���.
		else if ( mMapLink.distance < prev_distance )
		{
			//Link ID�� �����ϴ� �������� ����ġ ����.
			mMapLink.direction = pre_direction + 1;
			if ( mMapLink.direction > MAX_DIRECTION_INC )	mMapLink.direction = MAX_DIRECTION_INC;
		}
	}
	
	
	/*
	 * ������ �� ����
	 */
	//�� (x3, y3)�κ��� (x1, y1), (x2, y2)�� ������ link���� �Ÿ� ���. ����� ���浵 ��ǥ Degree ������ ��ȯ.
	public	double	distToLinkDegree( double x1, double y1, double x2, double y2, double x3, double y3 )
	{
		/*
		//System.out.println( "x1=" + (int)x1 + ", y1=" + (int)y1 + ", x2=" + (int)x2 + ", y2=" + (int)y2 + ", x3=" + (int)x3 + ", y3=" + (int)y3);
		//if ( x1 == x2 )	return -1;
		if ( x1 == x2 )
		{
			double	dist	= Math.abs( x3 - x1 );
			//System.out.println("1: dist=" + dist);
			return dist;
		}

		double	base_x	= x2 - x1;
		double	base_y	= y2 - y1;
		double	base_a	= base_y / base_x;
		//double	base_b	= -1;
		double	dist	= Math.abs( base_a * x3 - y3 - base_a * x1 + y1 ) / Math.sqrt(base_a*base_a + 1);

		//System.out.println("2: dist=" + dist);
		return dist;
		*/
		//if ( x1 == x2 || y1 == y2 )	return -1;
		if ( x1 == x2 )
		{
			double	x4	= x1;
			double	y4	= y3;
			return degGeoPts(y3, x3, y4, x4);		
		}
		else if ( y1 == y2 )
		{
			double	x4	= x3;
			double	y4	= y1;
			return degGeoPts(y3, x3, y4, x4);		
		}
		
		//������ ��ǥ ���.
		//(1) Link�� ������: y = (y2 - y1)/(x2 - x1) * (x - x1) + y1
		//(2) ������ ������: y = -(x2 - x1)/(y2 - y1) * (x - x3) + y3
		//���� �������� Ǯ��... 1���� - 2����
		//					0 = (ax - ax1 + y1) - (-x/a + x3/a + y3)
		//					0 = (a + 1/a)x - ax1 + y1 - x3/a - y3
		//					x = (-ax1 + y1 - x3/a - y3)/(a + 1/a)
		double	a			= (y2 - y1) / (x2 - x1);
		double	a_reverse	= 1 / a;
		double	x4	= ( a*x1 - y1 + x3*a_reverse + y3) / (a + a_reverse);
		double	y4	= a*(x4 - x1) + y1;

		//������ ������ Link ���� �ִ��� �˻��Ѵ�.
		double	min_x = x1, max_x = x2; 
		double	min_y = y1, max_y = y2;
		if ( x1 > x2 )
		{
			min_x = x2;
			max_x = x1;
		}
		if ( y1 > y2 )
		{
			min_y = y2;
			max_y = y1;
		}
		//System.out.println( "min_x=" + (int)min_x + ", max_x=" + (int)max_x + ", x4=" + (int)x4);
		//System.out.println( "min_y=" + (int)min_y + ", max_y=" + (int)max_y + ", y4=" + (int)y4);
		if ( min_x > x4 || x4 > max_x )return -1;
		if ( min_y > y4 || y4 > max_y )return -1;
				
		//������ ���� ������ �Ÿ� ���.
		//System.out.println( "x4=" + x4 + ", y4=" + y4);
		return degGeoPts(y3, x3, y4, x4);
	}
	public	double	degGeoPts( double geoLat1, double geoLng1, double geoLat2, double geoLng2 )
	{
		double	base_x	= geoLng2 - geoLng1;
		double	base_y	= geoLat2 - geoLat1;
		
		double	distDeg	= Math.sqrt( base_x*base_x + base_y*base_y );

		//System.out.println("2: distDeg=" + distDeg);
		return distDeg;
	}

	//�� (x3, y3)�κ��� (x1, y1), (x2, y2)�� ������ link���� �Ÿ� ���. ����� Meter ������ ��ȯ.
	public	double	distToLinkMeter( double x1, double y1, double x2, double y2, double x3, double y3 )
	{
		//if ( x1 == x2 || y1 == y2 )	return -1;
		if ( x1 == x2 )
		{
			double	x4	= x1;
			double	y4	= y3;
			return distGeoPts(y3, x3, y4, x4);		
		}
		else if ( y1 == y2 )
		{
			double	x4	= x3;
			double	y4	= y1;
			return distGeoPts(y3, x3, y4, x4);		
		}
		
		//������ ��ǥ ���.
		//(1) Link�� ������: y = (y2 - y1)/(x2 - x1) * (x - x1) + y1
		//(2) ������ ������: y = -(x2 - x1)/(y2 - y1) * (x - x3) + y3
		//���� �������� Ǯ��... 1���� - 2����
		//					0 = (ax - ax1 + y1) - (-x/a + x3/a + y3)
		//					0 = (a + 1/a)x - ax1 + y1 - x3/a - y3
		//					x = (-ax1 + y1 - x3/a - y3)/(a + 1/a)
		double	a			= (y2 - y1) / (x2 - x1);
		double	a_reverse	= 1 / a;
		double	x4	= ( a*x1 - y1 + x3*a_reverse + y3) / (a + a_reverse);
		double	y4	= a*(x4 - x1) + y1;

		//������ ������ Link ���� �ִ��� �˻��Ѵ�.
		double	min_x = x1, max_x = x2; 
		double	min_y = y1, max_y = y2;
		if ( x1 > x2 )
		{
			min_x = x2;
			max_x = x1;
		}
		if ( y1 > y2 )
		{
			min_y = y2;
			max_y = y1;
		}
		//System.out.println( "min_x=" + (int)min_x + ", max_x=" + (int)max_x + ", x4=" + (int)x4);
		//System.out.println( "min_y=" + (int)min_y + ", max_y=" + (int)max_y + ", y4=" + (int)y4);
		if ( min_x > x4 || x4 > max_x )return -1;
		if ( min_y > y4 || y4 > max_y )return -1;

		//������ ���� ������ �Ÿ� ���.
		return distGeoPts(y3, x3, y4, x4);
	}

	/*
	 * ���浵 ��ǥ�� ����� �Ÿ� ���.
	 */
	/* 
	 * ������ ��ǥ�� Degree(��) ������ ǥ���� 2 ���� ������ �Ÿ� ���.
	 * ����� : Vincenty inverse formula for ellipsoids
	 */
	//GeoPoint�� ǥ���� 2 ���������� �Ÿ� ���.
	public	double	distGeoPts( double geoLat1, double geoLng1, double geoLat2, double geoLng2 )
	{
		double	lat1	= parseGeo2Degree( geoLat1 );
		double	lon1	= parseGeo2Degree( geoLng1 );
		double	lat2	= parseGeo2Degree( geoLat2 );
		double	lon2	= parseGeo2Degree( geoLng2 );
		return distVincenty(lat1, lon1, lat2, lon2);
	}
	//Location���� ǥ���� 2 ���������� �Ÿ� ���.
	public	double	distLocPts( double geoLat1, double geoLng1, double geoLat2, double geoLng2 )
	{
		double	lat1	= parseLoc2Degree( geoLat1 );
		double	lon1	= parseLoc2Degree( geoLng1 );
		double	lat2	= parseLoc2Degree( geoLat2 );
		double	lon2	= parseLoc2Degree( geoLng2 );
		return distVincenty(lat1, lon1, lat2, lon2);
	}
	
	// ������ ��ǥ�� Degree(��) ������ ǥ���� 2 ���� ������ �Ÿ� ���.
	public	double	distVincenty(double lat1, double lon1, double lat2, double lon2)
	{
		double a = 6378137, b = 6356752.3142,f = 1/298.257223563;	// WGS-84 ellipsiod
		double L = cnvtDegree2Radian( lon2 - lon1 );
		double U1 = Math.atan( (1-f) * Math.tan(cnvtDegree2Radian(lat1)) );
		double U2 = Math.atan( (1-f) * Math.tan(cnvtDegree2Radian(lat2)) );
		double sinU1 = Math.sin(U1), cosU1 = Math.cos(U1);
		double sinU2 = Math.sin(U2), cosU2 = Math.cos(U2);
		 
		double lambda = L, lambdaP, iterLimit = 100;
		double	cosSqAlpha = 0, sinSigma = 0, cos2SigmaM = 0, sigma = 0, cosSigma = 0;
		do
		{
			double sinLambda = Math.sin(lambda), cosLambda = Math.cos(lambda);
			sinSigma = Math.sqrt((cosU2*sinLambda) * (cosU2*sinLambda) + (cosU1*sinU2-sinU1*cosU2*cosLambda) * (cosU1*sinU2-sinU1*cosU2*cosLambda));
			if (sinSigma==0) return 0;		// co-incident points
			cosSigma = sinU1*sinU2 + cosU1*cosU2*cosLambda;
			sigma = Math.atan2(sinSigma, cosSigma);
			double sinAlpha = cosU1 * cosU2 * sinLambda / sinSigma;
			cosSqAlpha = 1 - sinAlpha*sinAlpha;
			cos2SigmaM = cosSigma - 2*sinU1*sinU2/cosSqAlpha;
			//if (isNaN(cos2SigmaM)) cos2SigmaM = 0;	// equatorial line: cosSqAlpha=0 (��6)
			double C = f/16*cosSqAlpha*(4+f*(4-3*cosSqAlpha));
			lambdaP = lambda;
			lambda = L + (1-C) * f * sinAlpha * (sigma + C*sinSigma*(cos2SigmaM+C*cosSigma*(-1+2*cos2SigmaM*cos2SigmaM)));
		} while ( Math.abs(lambda-lambdaP) > 1e-12 && --iterLimit > 0 );
		
		if ( iterLimit == 0 ) return 0;	// formula failed to converge
		
		double uSq = cosSqAlpha * (a*a - b*b) / (b*b);
		double A = 1 + uSq/16384*(4096+uSq*(-768+uSq*(320-175*uSq)));
		double B = uSq/1024 * (256+uSq*(-128+uSq*(74-47*uSq)));
		double deltaSigma = B*sinSigma*(cos2SigmaM+B/4*(cosSigma*(-1+2*cos2SigmaM*cos2SigmaM)- B/6*cos2SigmaM*(-3+4*sinSigma*sinSigma)*(-3+4*cos2SigmaM*cos2SigmaM)));
		double s = b*A*(sigma-deltaSigma);
		 
		//s = s.toFixed(3); // round to 1mm precision
		return s;
	} 
	 
	/*
	 * GPS���� ���޵� ���浵 ���� Degree(��) ������ ��ȯ.
	 *		GPS �� 37.500478	=> 37�� 50.0478��
	 *		1�� = 60��
	 *		50.0478�� / 60.0 = 0.83414��.
	 */ 
	//GeoPoint�� ǥ���� GPS �Է°��� Degree(��) ������ ��ȯ.
	public	double	parseGeo2Degree( double gps_geo )
	{ 
		return parseLoc2Degree( ((double)gps_geo) / 1000000.0 );
	}
	
	//Location���� ǥ���� GPS �Է°��� Degree(��) ������ ��ȯ.
	public	double	parseLoc2Degree( double gps_loc )
	{
		return( gps_loc );
	}
	
	/*
	 * ������ radian���� ��ȯ.
	 */
	public	double	cnvtDegree2Radian( double degree )
	{
		return( degree * Math.PI / 180 );
	}
}

/*
 * End of File.
 */