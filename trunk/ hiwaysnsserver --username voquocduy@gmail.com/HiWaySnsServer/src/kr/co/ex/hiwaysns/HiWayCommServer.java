/*
 * 
 *	Hi-Way SNS 서버.
 *
 * Copyrights (c) 2010-2011, (주)맨크레드. All rights reserved.
 *
 * 저작자: 유석(Yoo, Seok)
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
	public	static	final	int		RADIUS_MAP_MATCH			= 3000;		//Map Matching 반경 3Km = 3,000M.
	public	static	final	int		DIRECT_MIN_MOVE				= 50;		//방향 감지를 위한 최소한의 이동거리 50M.
	public	static	final	int		MATCH_MAX_LENGTH			= 400;		//Link에 matching 가능한 최대 거리.
	public	static	final	int		MATCH_AMBIGU_LENGTH			= 500;		//Link matching이 모호한 최소 거리.

	public	static	final	int		RADIUS_MEMBER_SEARCH		= 10000;					//길벗 검색을 위한 반경 10Km = 10,000M.
	public	static	final	int		RADIUS_MEMBER_SEARCH_MIN	= RADIUS_MEMBER_SEARCH;		//길벗 검색을 위한 반경 10Km = 10,000M.
	public	static	final	int		RADIUS_MEMBER_SEARCH_MAX	= 1000000;					//길벗 검색을 위한 반경 1,000Km = 1,000,000M.
	public	static	final	int		RADIUS_FTMS_SEARCH			= 20000;					//FTMS Matching 반경 20Km = 20,000M.
	public	static	final	int		RADIUS_VMS_SEARCH			= 20000;					//VMS Matching 반경 20Km = 20,000M.
	public	static	final	int		RADIUS_CCTV_MATCH			= RADIUS_VMS_SEARCH;		//VMS Matching 반경 10Km = 10,000M.
	public	static	final	int		RADIUS_TRAFFIC_SEARCH		= RADIUS_MEMBER_SEARCH;		//교통정보 검색을 위한 반경 10Km = 10,000M.

	public	static	final	int		MAX_DIRECTION_INC			= 2;		//하행방향 가중치의 Upper Bound.
	public	static	final	int		MAX_DIRECTION_DEC			= -2;		//상행방향 가중치의 Lower Bound.
	
	//손님의 User ID.
	public	static	final	String	NICKNAME_GUEST				= "guest";

	
	/*
	 * Variables.
	 */
	public	int				status_code	= 0;
	public	String			status_msg	= "";
	
	//가장 최근의 사용자 위치 정보.
	public	String			mNickname		= "";		//사용자 Nickname.
	public	int				mRoadNo			= 0;		//사용자가 위치하고 있는 도로의 번호.
	public	long			mLinkeID		= 0;		//사용자가 위치한 Link의 ID.
	public	int				mDirection		= 0;		//사용자의 진행방향.
	public	long			mDistance		= 0;		//Link가 소속된 도로의 종점으로부터의 거리(단위는 M).
	public	int				mAccessCount	= 0;		//FTMS 교통정보 접근회수.
	//Map matching 결과.
	public	TrOasisMapLink	mMapLink	= null;			//사용자가 위치하고 있는 Link 정보.
	public	TrOasisMapLink	mMapLink2	= null;			//이정의 기점을 포함하는 Link 정보.
	
	//주어진 범위안에 있는 위도 경도 범위.
	public	double			mRange_lat_from, mRange_lat_to, mRange_lng_from, mRange_lng_to;
	//주어진 범위안에 있는 Link 목록.
	protected	int			mIndexSel		= -1;
	protected	List<TrOasisMapLink>	mMapLinkList	= new ArrayList<TrOasisMapLink>();
	public		int			mRadiusSearch	= 0;		//최소한 1명 이상의 길벗을 찾기위한 탐색범위.

	
	/*
	 * 객체생성자.
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
	//주어진사용자 User ID의 유효성 검사 - Login용.
	public	boolean	isValidUserID( String strUserID )
	{
		if ( strUserID.length() < 1 )
		{
			status_code	= 2;
			status_msg	= "유효하지 않은 사용자 User ID 사용.";
			return( false );
		}
		return( true );
	}
	
	//주어진사용자와 위치정보의 유효성 검사 - Web service용.
	public	boolean	isValidUser( String strActiveID, String strUserID, int nPosLat, int nPosLng )
	{
		if ( isValidUserLocation(nPosLat, nPosLng) == false )	return( false );
		if ( isValidActiveID(strUserID, strActiveID) == false )	return( false );
		return( true );
	}
	
	//주어진사용자 Active ID의 유효성 검사 -Logout용.
	public	boolean	isValidActiveID( String strUserID, String strActiveID )
	{
		if ( isValidUserID(strUserID) == false )	return( false );
//		if ( strUserID.compareToIgnoreCase(NICKNAME_GUEST) == 0 )	return( true );
		
		if ( strActiveID.length() < 1 )
		{
			status_code	= 2;
			status_msg	= "유효하지 않은 사용자 Active ID 사용.";
			return( false );
		}
		
		boolean		bResult	= true;
		try
		{
			//DB 연결.
			db_open();

			//주어진 User ID, Active ID의 사용자가 존재하는지 검사한다.	
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
				mNickname		= mDbRs.getString( "nickname" );	//사용자 Nickname.
				mRoadNo			= mDbRs.getInt( "road_no" );		//사용자가 위치한 도로의 번호.
				mLinkeID		= mDbRs.getLong( "link_id" );		//사용자가 위치한 Link의 ID.
				mDirection		= mDbRs.getInt( "direction" );		//사용자의 진행방향.
				mDistance		= mDbRs.getLong( "distance" );		//Link가 소속된 도로의 종점으로부터의 거리(단위는 M).
				mAccessCount	= mDbRs.getInt( "access_count" );	//FTMS 교통정보 접근회수.
			}
			else
			{
				status_code	= 2;
				status_msg	= "유효하지 않은 사용자 User ID, Activity ID 사용.";
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
			//DB 연결 닫기.
			try
			{
				db_close();
			}
			catch( Exception e2 ) { }
		}

		return( bResult );
	}
	
	//주어진사용자위치정보의 유효성 검사.
	public	boolean	isValidUserLocation( int nPosLat, int nPosLng )
	{
		if ( nPosLat == 0 && nPosLng == 0 )
		{
			status_code	= 0;
			status_msg	= "사용자의 위치정보가 정의되지 않았습니다.";
			return( false );
		}
		return( true );
	}
	
	
	//메시지 목록 검색.
	public	boolean		retrieveMsgList()
	{
		return( true );
	}
	
	/*
	 * Map Matching 지원.
	 */
	//주어진 거리 범위에 해당하는 위도 경도 범위.
	//위도 경도 값은 GeoPoint를 사용한다.
	public	int	findFtmsRange( int nPosLat, int nPosLng )
	{
		setGeoPtRange( RADIUS_FTMS_SEARCH, nPosLat, nPosLng );			//FTMS Agent 탐색 반경.
		return RADIUS_FTMS_SEARCH;
	}

	public	int	findVmsRange( int nPosLat, int nPosLng )
	{
		setGeoPtRange( RADIUS_VMS_SEARCH, nPosLat, nPosLng );			//FTMS Agent 탐색 반경.
		return RADIUS_VMS_SEARCH;
	}

	public	int	findTrafficRange( int nPosLat, int nPosLng )
	{
		setGeoPtRange( RADIUS_TRAFFIC_SEARCH, nPosLat, nPosLng );		//교통정보 탐색 반경.
		return RADIUS_TRAFFIC_SEARCH;
	}

	public	int	findSearchRange( int nPosLat, int nPosLng )
	{
		setGeoPtRange( RADIUS_MEMBER_SEARCH, nPosLat, nPosLng );		//길벗 탐색 반경.
		return RADIUS_MEMBER_SEARCH;
	}

	public	int	nextSearchRange( int radius_search, int nPosLat, int nPosLng )
	{
		radius_search	= radius_search * 2;							//길벗 탐색반경을 2배로 확대.
		//System.out.println( "radius_search=" + radius_search );
		setGeoPtRange( radius_search, nPosLat, nPosLng );
		return radius_search;
	}
	
	//최소한 1명이상의 길벗이 반견될 때까지 Searching 범위 탐색.
	public	int	setSearchRange( String strActiveID, int nPosLat, int nPosLng ) throws Exception
	{
	 	long	currentTime	= getCurrentTimestamp();
		
		// Match Making을 위한 Group의 범위 설정.
		mRadiusSearch	= RADIUS_MEMBER_SEARCH_MIN;
		setGeoPtRange( mRadiusSearch, nPosLat, nPosLng );			//길벗 탐색 반경.
		
		int		count_friends	= 1;
		/* --2011.01.09 by s.yoo : 기능 삭제.
		//최소한 1명 이상의 길벗이 존재할 때까지 탐색범위 확대.
		int		count_friends	= 0;
		int		radius_search	= 0;
		try
		{
			String	strQuery	= "";
			while ( mRadiusSearch <= RADIUS_MEMBER_SEARCH_MAX )		//500Km 이하에 대해서만 검색.
			{
				strQuery	= "SELECT COUNT(*)";
				strQuery	= strQuery + subQueryFriend(strActiveID, currentTime);
				//System.out.println( "strQuery=" + strQuery );
				exec_query( strQuery );
				
				//길벗의 존재여부 검사.
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
				
				//탐색범위를 확대해서 재탐색.
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
		
		//발견된 길벗의 개수 전달.
		return count_friends;
	}
	
	//길벗 목록 검색을 위한 Sub-Query 문자열 생성.
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
		strQuery	= strQuery + " AND time_log_last >= " + (currentTime - TrOasisConstants.FILTER_TIME_LOGIN);	//장시간 무응답자 무시.
		if ( mLinkeID > 0 )				//고속도로에 위치하는 경우 진행방향 고려.
		{
			//일반도로의 같은 방향, 다른 고속도로의 양방향(JC를 고려해서) 또는 동일 고속도로의 같은 방향.
			if ( mDirection > 0 )			//고속도로 Link ID가 증가하는 방향으로 이동하는 경우.
			{
				//고속도로가 아닌 도로에서 나와 같은 방향이거나
				strQuery	= strQuery + " AND ( (link_id = 0 AND direction > 0) ";
				//또는 고속도로에서 나와 다른 도로에 있거나(JC를 고려해서)
				strQuery	= strQuery + "  OR (link_id > 0 AND road_no <> " + mRoadNo + ")";
				//또는 고속도로에서 나와 같은 도로의 같은 방향으로 진행하는 경우
				strQuery	= strQuery + "  OR (link_id > 0 AND road_no = " + mRoadNo  + " AND direction > 0) )";
			}
			else if ( mDirection < 0 )		//고속도로 Link ID가 감소하는 방향으로 이동하는 경우.
			{
				//고속도로가 아닌 도로에서 나와 같은 방향이거나
				strQuery	= strQuery + " AND ( (link_id = 0 AND direction < 0) ";
				//또는 고속도로에서 나와 다른 도로에 있거나(JC를 고려해서)
				strQuery	= strQuery + "  OR (link_id > 0 AND road_no <> " + mRoadNo + ")";
				//또는 고속도로에서 나와 같은 도로의 같은 방향으로 진행하는 경우
				strQuery	= strQuery + "  OR (link_id > 0 AND road_no = " + mRoadNo  + " AND direction < 0) )";
			}
		}
		return strQuery;
	}

	//Map Matching 수행 - 사용자 위치에 대한 Map matching.
	public	long	procMapMatching( int nPosLat, int nPosLng, int prev_road, long prev_link, int pre_direction, long prev_distance ) throws Exception
	{
		//주어진 반경안에 있는 Node 목록 검색.
		long	link_id_min	= -1;
		try
		{
			//주어진 GPS 좌표에 해당하는 Link 검색.
			//System.out.println( "GPS=" + nPosLat + ", " + nPosLng );
			//link_id_min	= procFindMapLink( nPosLat, nPosLng );
			link_id_min	= buildLocationInfo( nPosLat, nPosLng, pre_direction );

			//Matching되는 Link가 없는 경우에는.
			if ( link_id_min <= 0 )	return( link_id_min );

			//Default Link 정보 설정.
			mMapLink	= new TrOasisMapLink();
			mMapLink.road_no	= prev_road;
			mMapLink.link_id	= prev_link;
			mMapLink.direction	= pre_direction;
			mMapLink.distance	= prev_distance;
			
			//Matching된 Link가 다른 도로이면서 너무 근접해서 확실치 않은 경우에는, 다음에 Map Matching을 다시 수행.
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

			//기존에 Matching된 Link가 없는 경우에는, 가장 근접한 Link에 Matching.
			if ( prev_link <= 0 )
			{
				if ( mIndexSel < 0 )	return( prev_link );
				mMapLink	= mMapLinkList.get( mIndexSel );
			}
			//기존에 Matching된 Link와 현재 판별된 Link의 연계성 검사.
			else
			{
				//(TBD)
				mMapLink	= mMapLinkList.get( mIndexSel );
			}
			
			//Matching된 Link의 ID 설정.
			link_id_min	= mMapLink.link_id;
			mMapLink.direction	= pre_direction;
			mMapLink.distance	= prev_distance;
			
			//Link가 소속된 도로의 End Node 기점(Link ID가 가장 큰 Node)으로부터의 현재까지의 거리 계산.
			long	distance	= (long)distGeoPts( mMapLink.road_end_loc_lat, mMapLink.road_end_loc_lng, nPosLat, nPosLng );

			//최소한의 거리차이가 없다면, 방향은 무시한다.
			//System.out.println( "current distance=" + distance + ", prev_distance=" + prev_distance + ", pre_direction=" + pre_direction );
			if ( Math.abs(distance - prev_distance) >= DIRECT_MIN_MOVE )
			{
				//Link가 소속된 도로의 End Node 기점(Link ID가 가장 큰 Node)으로부터의 현재까지의 거리 저장.
				mMapLink.distance	= distance;

				//사용자의 이동방향 판별.
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
		
		//발견된 Link의 ID 반환.
		return link_id_min;
	}
	
	//Map Matching 수행 - 주어진 위경도 좌표에 대한 Map matching.
	public	long	procFindMapLink( int nPosLat, int nPosLng ) throws Exception
	{
		mIndexSel		= -1;
		long	link_id	= 0;
		try
		{
			//주어진 영역에 존재하는 Link 목록 및 최단거리의 Link 검색.
			int	index_sel	= findMapLinkList( nPosLat, nPosLng );

			//Matching되는 Link가 없는 경우에는....
			if ( index_sel < 0 )	return( link_id );

			//Matching된 거리가 일정범위를 초과하면, Matching 실패로 간주한다.
			TrOasisMapLink	objMapLink	= mMapLinkList.get(index_sel);
			//System.out.println( "[" + index_sel + "] " + objMapLink.link_id + " objMapLink.start_loc_lng=" + objMapLink.start_loc_lng );
			double	distMetric	= distToLinkMeter( objMapLink.start_loc_lng, objMapLink.start_loc_lat,
										objMapLink.end_loc_lng, objMapLink.end_loc_lat, nPosLng, nPosLat );
			if ( 0 <= distMetric && distMetric > MATCH_MAX_LENGTH )	return( link_id );
			//System.out.println( "mMapLinkList.size()=" + mMapLinkList.size() + ", index_sel=" + index_sel + ", distMetric=" + distMetric );

			//Matching된 Link의 ID 전달.
			mIndexSel	= index_sel;
			mMapLink	= mMapLinkList.get(mIndexSel);
			link_id 	= mMapLink.link_id;
		}
		catch(Exception e)
		{
			throw new Exception( e.toString() );
		}		
		
		//발견된 Link의 ID 반환.
		return link_id;
	}
	
	//Map Matching 수행 - 주어진 위경도 좌표에 대한 위치정보 구성.
	public	long	buildLocationInfo( int nPosLat, int nPosLng, int pre_direction ) throws Exception
	{
		//주어진 반경안에 있는 Node 목록 검색.
		long	link_id	= 0;
		try
		{
			//주어진 영역에 존재하는 Link 목록 및 최단거리의 Link 검색.
			int	index_sel	= findMapLinkList( nPosLat, nPosLng );

			//Matching되는 Link가 없는 경우에는....
			if ( index_sel < 0 )	return( link_id );
			
			//Matching된 거리가 일정범위를 초과하면, Matching 실패로 간주한다.
			TrOasisMapLink	objMapLink	= mMapLinkList.get(index_sel);
			double	distMetric	= distToLinkMeter( objMapLink.start_loc_lng, objMapLink.start_loc_lat,
										objMapLink.end_loc_lng, objMapLink.end_loc_lat, nPosLng, nPosLat );
			//System.out.println( "distMetric=" + distMetric + ", link=" + objMapLink.link_id );
			if ( distMetric > MATCH_MAX_LENGTH )	return( link_id );

			//Matching된 Link의 ID 전달.
			mIndexSel	= index_sel;
			mMapLink	= mMapLinkList.get(mIndexSel);
			link_id 	= mMapLink.link_id;
			
			//전방에 있는 기점정보 검색.
			calcNodeDistance( link_id, pre_direction, nPosLat, nPosLng );
			
			//전방에 있는 기점 노드의 이름과의 거리 계산.
			String	strBaseNodeName	= "";
			long	distance		= 0;
			if ( mMapLink2 != null )
			{
				if( pre_direction >= 0 )	//Link ID 증가방향
				{
					strBaseNodeName = mMapLink2.end_node_name;
					distance		= (long) distGeoPts( mMapLink2.end_loc_lat, mMapLink2.end_loc_lng, nPosLat, nPosLng );
				}
				else						//Link ID 감소방향
				{
					strBaseNodeName = mMapLink2.start_node_name;
					distance		= (long) distGeoPts( mMapLink2.start_loc_lat, mMapLink2.start_loc_lng, nPosLat, nPosLng );
				}
			}
			
			//거리 형식 지정.
			DecimalFormat	df		= new DecimalFormat( "##.#" );
			String			dist_km	= df.format(distance / 1000.0) + "Km";
		
			//Matching된 Link의 위치설명 구성.
			String	location_msg	= "";
			if( pre_direction >= 0 )		//Link ID 증가방향
			{
				location_msg	= location_msg + mMapLink.road_name;							//도로명.
				location_msg	= location_msg + " " + mMapLink.road_end_node_name + " 방향";	//방향.
			}
			else							//Link ID 감소방향
			{
				location_msg	= location_msg + mMapLink.road_name;							//도로명.
				location_msg	= location_msg + " " + mMapLink.road_start_node_name + " 방향";	//방향.
			}
			location_msg	= location_msg + " " + strBaseNodeName + " 전방";					//기점.
			location_msg	= location_msg + " " + dist_km + " 지점";							//거리.

			//System.out.println( "pre_direction=" + pre_direction + ", mMapLink.road_name=" + mMapLink.road_name );
			//System.out.println( "mMapLink.road_start_node_name=" + mMapLink.road_start_node_name + ", dist_km=" + dist_km );
			//System.out.println( "link_id=" + link_id + ", location_msg=" + location_msg );
			mMapLink.location_msg	= location_msg;
		}
		catch(Exception e)
		{
			throw new Exception( e.toString() );
		}		
		
		//발견된 Link의 ID 반환.
		return link_id;
	}
	
	//주어진 Link의 전방에 위치하는 기점 및 기점과의 거리 계산.
	protected	void	calcNodeDistance( long link_id, int direction, int nPosLat, int nPosLng ) throws Exception
	{
		String	strQuery;
		String	strTableLink	= "troasis_map_link";

		try
		{
			//기점 Node를 포함하는 Link 검색.
			if ( direction >= 0 )	//Link ID가 증가하는 방향.
			{
				strQuery	= "SELECT MIN(link_id)";
				strQuery	= strQuery + " FROM " + strTableLink;
				strQuery	= strQuery + " WHERE link_id >= " + link_id;
				strQuery	= strQuery + " AND (end_node_type = " + TrOasisConstants.NODE_TYPE_IC;
				strQuery	= strQuery + " OR end_node_type = " + TrOasisConstants.NODE_TYPE_JC + ")";
			}
			else					//Link ID가 감소하는 방향.
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
			
			//기점 노드의 정보 검색.
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
	//주어진 거리 범위에 해당하는 위도 경도 범위.
	//위도 경도 값은 GeoPoint를 사용한다.
	public	void	setGeoPtRange( long distMetric, int nPosLat, int nPosLng )
	{
		double	rangeLat	= (distMetric * 1000000.0 / 111034.0);		//위도 1도 = 약 111.034Km.
		double	rangeLng	= (distMetric * 1000000.0 /  85397.0);		//경도 1도 = 약 85.397Km.
		//System.out.println( "distMetric=" + distMetric + ", range=" + rangeLat +","+rangeLng);
		mRange_lat_from	= nPosLat - rangeLat;
		mRange_lat_to	= nPosLat + rangeLat;
		mRange_lng_from	= nPosLng - rangeLng;
		mRange_lng_to	= nPosLng + rangeLng;
	}

	//주어진 범위 안에 존재하는 Link 목록 검색.
	protected	int	findMapLinkList( int nPosLat, int nPosLng ) throws Exception
	{
		// Match Making을 위한 Group의 범위 설정.
		setGeoPtRange( RADIUS_MAP_MATCH, nPosLat, nPosLng );		//Map matching 거리.
			
		//주어진 반경안에 있는 Link 목록 검색.
		String	strQuery;
		String	strTableLink	= "troasis_map_link";
		
		int		index_min	= -1;
		double	distDegMin	= -1;
		try
		{
			//Match Making을 통해, 그룹에 소속된 회원들의 목록 검색..	
			//주어진 영역에 존재하는 Node 목록 검색.
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
				//Link 정보를 DB에서 읽어오기.
				TrOasisMapLink	objMapLink	= new TrOasisMapLink();
				objMapLink.loadLinkInfo(mDbRs);

				//Link와의 거리 계산(Degree 단위) 및 가장 가까운 거리의 Link 판정.
				objMapLink.distDegree	= distToLinkDegree( objMapLink.start_loc_lng, objMapLink.start_loc_lat,
												objMapLink.end_loc_lng, objMapLink.end_loc_lat, nPosLng, nPosLat );
				if ( objMapLink.distDegree >= 0 && (index_min < 0 || objMapLink.distDegree < distDegMin) )
				{
					index_min	= i;
					distDegMin	= objMapLink.distDegree;
				}
				//System.out.println( "objMapLink.link_id=" + objMapLink.link_id + ", objMapLink.distDegree=" + objMapLink.distDegree );
				
				//Link 목록에 등록.
				mMapLinkList.add( objMapLink );
			}
		}
		catch(Exception e)
		{
			throw new Exception( e.toString() );
		}		
		
		//Link 목록에서 거리가 가장 가까운 Link의 위치(Index) 판별.
		return index_min;
	}

	
	//사용자의 이동방향 판별.
	//
	//	양수 : Link ID가 증가하는 방향으로 이동.
	//	음수 : Link ID가 감소하는 방향으로 이동.
	//
	//	이전과 현재의 이동방향이 일치하다면, 판별된 이동방향 사용.
	//	이전과 현재의 이동방향이 일치하지 않는다면, 다음에 판별된 이동방향으로 이동방향 판별.
	protected	void	findUserDirection( int pre_direction, long prev_distance )
	{
		//End Node(Link ID가 가장 큰 Node)를 기점으로 이전보다 더 먼 거리로 이동하고 있는 경우.
		if ( mMapLink.distance > prev_distance )
		{
			//Link가 감소하는 방향으로 가중치 증가.
			mMapLink.direction = pre_direction - 1;
			if ( mMapLink.direction < MAX_DIRECTION_DEC )	mMapLink.direction = MAX_DIRECTION_DEC;
		}
		//End Node(Link ID가 가장 큰 Node)를 기점으로 이전보다 더 가까운 거리로 이동하고 있는 경우.
		else if ( mMapLink.distance < prev_distance )
		{
			//Link ID가 증가하는 방향으로 가중치 증가.
			mMapLink.direction = pre_direction + 1;
			if ( mMapLink.direction > MAX_DIRECTION_INC )	mMapLink.direction = MAX_DIRECTION_INC;
		}
	}
	
	
	/*
	 * 수선의 발 길이
	 */
	//점 (x3, y3)로부터 (x1, y1), (x2, y2)로 구성된 link와의 거리 계산. 결과는 위경도 좌표 Degree 단위로 반환.
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
		
		//수선의 좌표 계산.
		//(1) Link의 방정식: y = (y2 - y1)/(x2 - x1) * (x - x1) + y1
		//(2) 수선의 방정식: y = -(x2 - x1)/(y2 - y1) * (x - x3) + y3
		//연립 방정식을 풀면... 1번식 - 2번식
		//					0 = (ax - ax1 + y1) - (-x/a + x3/a + y3)
		//					0 = (a + 1/a)x - ax1 + y1 - x3/a - y3
		//					x = (-ax1 + y1 - x3/a - y3)/(a + 1/a)
		double	a			= (y2 - y1) / (x2 - x1);
		double	a_reverse	= 1 / a;
		double	x4	= ( a*x1 - y1 + x3*a_reverse + y3) / (a + a_reverse);
		double	y4	= a*(x4 - x1) + y1;

		//수선의 접점이 Link 위에 있는지 검사한다.
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
				
		//직선과 수선 사이의 거리 계산.
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

	//점 (x3, y3)로부터 (x1, y1), (x2, y2)로 구성된 link와의 거리 계산. 결과는 Meter 단위로 반환.
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
		
		//수선의 좌표 계산.
		//(1) Link의 방정식: y = (y2 - y1)/(x2 - x1) * (x - x1) + y1
		//(2) 수선의 방정식: y = -(x2 - x1)/(y2 - y1) * (x - x3) + y3
		//연립 방정식을 풀면... 1번식 - 2번식
		//					0 = (ax - ax1 + y1) - (-x/a + x3/a + y3)
		//					0 = (a + 1/a)x - ax1 + y1 - x3/a - y3
		//					x = (-ax1 + y1 - x3/a - y3)/(a + 1/a)
		double	a			= (y2 - y1) / (x2 - x1);
		double	a_reverse	= 1 / a;
		double	x4	= ( a*x1 - y1 + x3*a_reverse + y3) / (a + a_reverse);
		double	y4	= a*(x4 - x1) + y1;

		//수선의 접점이 Link 위에 있는지 검사한다.
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

		//직선과 수선 사이의 거리 계산.
		return distGeoPts(y3, x3, y4, x4);
	}

	/*
	 * 위경도 좌표를 사용한 거리 계산.
	 */
	/* 
	 * 위도와 좌표가 Degree(도) 단위로 표현된 2 지점 사이의 거리 계산.
	 * 사용방법 : Vincenty inverse formula for ellipsoids
	 */
	//GeoPoint로 표현된 2 지점사이의 거리 계산.
	public	double	distGeoPts( double geoLat1, double geoLng1, double geoLat2, double geoLng2 )
	{
		double	lat1	= parseGeo2Degree( geoLat1 );
		double	lon1	= parseGeo2Degree( geoLng1 );
		double	lat2	= parseGeo2Degree( geoLat2 );
		double	lon2	= parseGeo2Degree( geoLng2 );
		return distVincenty(lat1, lon1, lat2, lon2);
	}
	//Location으로 표현된 2 지점사이의 거리 계산.
	public	double	distLocPts( double geoLat1, double geoLng1, double geoLat2, double geoLng2 )
	{
		double	lat1	= parseLoc2Degree( geoLat1 );
		double	lon1	= parseLoc2Degree( geoLng1 );
		double	lat2	= parseLoc2Degree( geoLat2 );
		double	lon2	= parseLoc2Degree( geoLng2 );
		return distVincenty(lat1, lon1, lat2, lon2);
	}
	
	// 위도와 좌표가 Degree(도) 단위로 표현된 2 지점 사이의 거리 계산.
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
			//if (isNaN(cos2SigmaM)) cos2SigmaM = 0;	// equatorial line: cosSqAlpha=0 (§6)
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
	 * GPS에서 전달된 위경도 값을 Degree(도) 단위로 변환.
	 *		GPS 값 37.500478	=> 37도 50.0478분
	 *		1도 = 60분
	 *		50.0478분 / 60.0 = 0.83414도.
	 */ 
	//GeoPoint로 표현된 GPS 입력값을 Degree(도) 단위로 변환.
	public	double	parseGeo2Degree( double gps_geo )
	{ 
		return parseLoc2Degree( ((double)gps_geo) / 1000000.0 );
	}
	
	//Location으로 표현된 GPS 입력값을 Degree(도) 단위로 변환.
	public	double	parseLoc2Degree( double gps_loc )
	{
		return( gps_loc );
	}
	
	/*
	 * 각도를 radian으로 변환.
	 */
	public	double	cnvtDegree2Radian( double degree )
	{
		return( degree * Math.PI / 180 );
	}
}

/*
 * End of File.
 */