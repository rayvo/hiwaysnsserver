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

import	java.sql.*;
import java.text.SimpleDateFormat;
import java.util.Locale;

public class HiWayDbServer
{
	/*
	 * Constant.
	 */
	/* 집 로칼.
	public	static	String	mDbHost		= "127.0.0.1";			//DB 서버의 IP 주소-로칼.
	//private	static	String	mDbName		= "troasis_re";			//로칼 테스트용 DB 이름.
	private	static	String	mDbName		= "troasis";			//DB 이름.
	private	static	String	mDbUserID	= "root";				//DB 접근을 위한 계정의 User ID.
	private	static	String	mDbPasswd	= "";					//DB 접근을 위한 계정의 비밀번호.
	*/
	///* 도공 계정.
	public	static	String	mDbHost		= "127.0.0.1";			//DB 서버의 IP 주소-로칼.
	//public	static	String	mDbHost		= "192.9.100.79";		//DB 서버의 IP 주소-도공.
	//public	static	String	mDbHost		= "127.0.0.1";		//중계 서버의 IP 주소-도공.
	//public	static	String	mDbHost		= "112.216.189.154";		//중계 서버의 IP 주소-도공.
	private	static	String	mDbName		= "troasis";			//DB 이름.
	private	static	String	mDbUserID	= "root";				//DB 접근을 위한 계정의 User ID.
	private	static	String	mDbPasswd	= "cewit123";					//DB 접근을 위한 계정의 비밀번호.
	//*/
	// 효성 ITX 계정.
	//public	static	String	mDbHost		= "127.0.0.1";		//DB 서버의 IP 주소-로칼.
//	public	static	String	mDbHost		= "180.182.57.147";		//Set 1 DB 서버의 IP 주소-효성ITX.
//	public	static	String	mDbHost		= "180.182.57.167";		//Set 2 DB 서버의 IP 주소-효성ITX.
//	public	static	String	mDbHost		= "180.182.57.168";		//Set 3 DB 서버의 IP 주소-효성ITX.
//	public	static	String	mDbHost		= "180.182.57.169";		//Set 4 DB 서버의 IP 주소-효성ITX.
//	private	static	String	mDbName		= "troasis";			//DB 이름.
//	private	static	String	mDbUserID	= "root";				//DB 접근을 위한 계정의 User ID.
//	private	static	String	mDbPasswd	= "dgitx00";			//DB 접근을 위한 계정의 비밀번호.

	/*
	 * Variables.
	 */
	public	String		mStrDbIP		= mDbHost;
	public	Connection	mDbConnection	= null;
	public	Statement	mDbStatement	= null;
	public	Statement	mDbStatement2	= null;
	public	Statement	mDbStatement3	= null;
	public	ResultSet	mDbRs			= null;
	public	ResultSet	mDbRs2			= null;
	public	ResultSet	mDbRs3			= null;
	
	
	/*
	 * Constructors.
	 */
	public	HiWayDbServer()
	{
		//Default DB 서버 지정.
		mStrDbIP		= mDbHost;

		mDbConnection	= null;
		mDbStatement	= null;
	}
	
	public	HiWayDbServer( String strServerIP )
	{
		//사용자가 지정한 DB 서버 지정.
		mStrDbIP		= strServerIP;

		mDbConnection	= null;
		mDbStatement	= null;
	}
	
	/*
	 * Methods.
	 */
	//DB Open
	public	boolean	db_open() throws Exception
	{
		try
		{
			Class.forName( "org.gjt.mm.mysql.Driver" );
			
			String	szDbAccess	= "jdbc:mysql://" + mStrDbIP + ":3306/" + mDbName + "?useUnicode=true&characterEncoding=UTF-8";
			//String	szDbAccess	= "jdbc:mysql://localhost:3306/db_calipers";
			mDbConnection	= DriverManager.getConnection( szDbAccess, mDbUserID, mDbPasswd );
			mDbStatement	= mDbConnection.createStatement();
			mDbStatement2	= mDbConnection.createStatement();
			mDbStatement3	= mDbConnection.createStatement();
		}
		catch( Exception ex )
		{
			throw new Exception( ex );
		}
	
		return true;
	}
	
	//DB Close.
	public	void	db_close() throws Exception
	{
		try
		{
			if ( mDbConnection != null )	mDbConnection.close();
			mDbConnection	= null;

			if ( mDbStatement != null )		mDbStatement.close();
			mDbStatement	= null;
			if ( mDbStatement2 != null )	mDbStatement2.close();
			mDbStatement2	= null;
			if ( mDbStatement3 != null )	mDbStatement3.close();
			mDbStatement3	= null;

			if ( mDbRs != null )	mDbRs.close();
			mDbRs	= null;
			if ( mDbRs2 != null )	mDbRs2.close();
			mDbRs2	= null;
			if ( mDbRs3 != null )	mDbRs3.close();
			mDbRs3	= null;
		}
		catch( Exception ex )
		{
			throw new Exception( ex );
		}
	}

	
	/*
	 * 트렌잭션 관리.
	 */
	//Begin a new transaction.
	public	void	tran_begin()
	{
	}

	//Commit the transaction.
	public	void	tran_commit()
	{
	}
	
	//Rollback the transaction.
	public	void	tran_rollback()
	{
	}

	
	/*
	 * Query 실행.
	 */
	//데이터 검색 Query 실행.
	public	ResultSet	exec_query( String strQuery ) throws Exception
	{
		try
		{
			//System.out.println( "(QUERY) " + strQuery );
			mDbRs	= mDbStatement.executeQuery( strQuery );
		}
		catch( Exception ex )
		{
			throw new Exception( ex );
		}
		return mDbRs;
	}
	
	//데이터 변경 Query 실행.
	public	void	exec_update( String strQuery ) throws Exception
	{
		try
		{
			//System.out.println( "(QUERY) " + strQuery );
			mDbStatement.executeUpdate( strQuery );
		}
		catch( Exception ex )
		{
			throw new Exception( ex );
		}
	}
	
	//데이터 검색 Query 실행 #2.
	public	ResultSet	exec_query2( String strQuery ) throws Exception
	{
		try
		{
			//System.out.println( "(QUERY) " + strQuery );
			mDbRs2	= mDbStatement2.executeQuery( strQuery );
		}
		catch( Exception ex )
		{
			throw new Exception( ex );
		}
		return mDbRs2;
	}
	
	//데이터 변경 Query 실행 #2.
	public	void	exec_update2( String strQuery ) throws Exception
	{
		try
		{
			//System.out.println( "(QUERY) " + strQuery );
			mDbStatement2.executeUpdate( strQuery );
		}
		catch( Exception ex )
		{
			throw new Exception( ex );
		}
	}
	
	//데이터 검색 Query 실행 #3.
	public	ResultSet	exec_query3( String strQuery ) throws Exception
	{
		try
		{
			//System.out.println( "(QUERY) " + strQuery );
			mDbRs3	= mDbStatement3.executeQuery( strQuery );
		}
		catch( Exception ex )
		{
			throw new Exception( ex );
		}
		return mDbRs3;
	}
	
	//데이터 변경 Query 실행 #3.
	public	void	exec_update3( String strQuery ) throws Exception
	{
		try
		{
			//System.out.println( "(QUERY) " + strQuery );
			mDbStatement3.executeUpdate( strQuery );
		}
		catch( Exception ex )
		{
			throw new Exception( ex );
		}
	}
	
	/*
	 * Utilities.
	 */
	//DB에서 작업이 수행된 시각의 Timestamp.
	public	long	getCurrentTimestamp()
	{	
		//1970년 1월 1일 0시를 기준으로 1초 단위의 값을 사용한다.
		return( System.currentTimeMillis() / 1000 );
	}
	
	//시각의 Timestamp를 해독 가능한 문자열로 변환.
	//주어진 Timestamp는 1970년 1월 1일 0시를 기준으로 1초 단위의 값을 사용한다.
	public	String	getTimestampString( long timestamp )
	{
		if ( timestamp == 0 )	return( "" );
		SimpleDateFormat formatter = new SimpleDateFormat( "yyyy.MM.dd HH:mm:ss", Locale.KOREA );
		return formatter.format ( timestamp * 1000 );
	}

	//시각의 Timestamp를 DB에서 검색에 사용 가능한 문자열로 변환.
	//주어진 Timestamp는 1970년 1월 1일 0시를 기준으로 1초 단위의 값을 사용한다.
	public	String	getTimestampLog( long timestamp )
	{
		if ( timestamp == 0 )	return( "" );
		SimpleDateFormat formatter = new SimpleDateFormat( "yyyyMMdd000000", Locale.KOREA );
		return formatter.format ( timestamp * 1000 );
	}

	/*
	 * 지도 데이터 엑셀파일 Upload.
	 */
	public	void	uploadMapData() throws Exception
	{
		String	strQuery;
		String	strTableNode	= "troasis_map_node";
		String	strTableLink	= "troasis_map_link";
		
		try
		{
			//트랜잭션 시작.
			tran_begin();
			
			int		road_no;
			int		node_id;
			int		node_type, node_type_alt;
			String	node_name;
			int		loc_lng, loc_lat;

			//모든 Node 데이터 검색.
			strQuery	= "SELECT *";
			strQuery	= strQuery + " FROM " + strTableNode;
			strQuery	= strQuery + " WHERE flag_deleted = 0";
			exec_query( strQuery );
			
			while ( mDbRs.next() )
			//if ( mDbRs.next() )
			{
				node_id			= mDbRs.getInt( "node_id" );
				node_type		= mDbRs.getInt( "node_type" );
				node_name		= mDbRs.getString( "name" );
				node_type_alt	= mDbRs.getInt( "node_type_alt" );
				loc_lng			= mDbRs.getInt( "loc_lng" );
				loc_lat			= mDbRs.getInt( "loc_lat" );
			
				//Link 테이블의 Node 정보 갱신.
				strQuery	= "UPDATE";
				strQuery	= strQuery + " " + strTableLink + " SET";
				strQuery	= strQuery + " start_node_type = " + node_type + "";
				strQuery	= strQuery + ", start_name = '" + node_name + "'";
				strQuery	= strQuery + ", start_node_type_alt = " + node_type_alt + "";
				strQuery	= strQuery + ", start_loc_lng = " + loc_lng + "";
				strQuery	= strQuery + ", start_loc_lat = " + loc_lat + "";
				strQuery	= strQuery + " WHERE start_node_id = " + node_id + "";
				strQuery	= strQuery + " AND flag_deleted = 0";

				exec_update2( strQuery );
								
				strQuery	= "UPDATE";
				strQuery	= strQuery + " " + strTableLink + " SET";
				strQuery	= strQuery + " end_node_type = " + node_type + "";
				strQuery	= strQuery + ", end_name = '" + node_name + "'";
				strQuery	= strQuery + ", end_node_type_alt = " + node_type_alt + "";
				strQuery	= strQuery + ", end_loc_lng = " + loc_lng + "";
				strQuery	= strQuery + ", end_loc_lat = " + loc_lat + "";
				strQuery	= strQuery + " WHERE end_node_id = " + node_id + "";
				strQuery	= strQuery + " AND flag_deleted = 0";

				exec_update2( strQuery );
			}
			
			//모든 도로의 시작 Node 정보 검색.
			strQuery	= "SELECT road_no, MIN(start_node_id)";
			strQuery	= strQuery + " FROM " + strTableLink;
			strQuery	= strQuery + " WHERE flag_deleted = 0";
			strQuery	= strQuery + " GROUP BY road_no";
			exec_query( strQuery );
			
			while ( mDbRs.next() )
			{
				road_no		= mDbRs.getInt( "road_no" );
				node_id		= mDbRs.getInt( 2 );
				
				//각 노드의 상세정보 검색.
				strQuery	= "SELECT *";
				strQuery	= strQuery + " FROM " + strTableNode;
				strQuery	= strQuery + " WHERE flag_deleted = 0";
				strQuery	= strQuery + " AND node_id = " + node_id;
				exec_query2( strQuery );
				
				while ( mDbRs2.next() )
				{
					node_type		= mDbRs2.getInt( "node_type" );
					node_name		= mDbRs2.getString( "name" );
					node_type_alt	= mDbRs2.getInt( "node_type_alt" );
					loc_lng			= mDbRs2.getInt( "loc_lng" );
					loc_lat			= mDbRs2.getInt( "loc_lat" );
					
					//각 Link의 도로정보 갱신.
					strQuery	= "UPDATE";
					strQuery	= strQuery + " " + strTableLink + " SET";
					strQuery	= strQuery + " road_start_node_id = " + node_id + "";
					strQuery	= strQuery + ", road_start_node_type = " + node_type + "";
					strQuery	= strQuery + ", road_start_name = '" + node_name + "'";
					strQuery	= strQuery + ", road_start_node_type_alt = " + node_type_alt + "";
					strQuery	= strQuery + ", road_start_loc_lng = " + loc_lng + "";
					strQuery	= strQuery + ", road_start_loc_lat = " + loc_lat + "";
					strQuery	= strQuery + " WHERE road_no = " + road_no + "";
					strQuery	= strQuery + " AND flag_deleted = 0";

					exec_update3( strQuery );
				}
			}
			
			//모든 도로의 마지막 Node 정보 검색.
			strQuery	= "SELECT road_no, MAX(end_node_id)";
			strQuery	= strQuery + " FROM " + strTableLink;
			strQuery	= strQuery + " WHERE flag_deleted = 0";
			strQuery	= strQuery + " GROUP BY road_no";
			exec_query( strQuery );
			
			while ( mDbRs.next() )
			{
				road_no		= mDbRs.getInt( "road_no" );
				node_id		= mDbRs.getInt( 2 );
				
				//각 노드의 상세정보 검색.
				strQuery	= "SELECT *";
				strQuery	= strQuery + " FROM " + strTableNode;
				strQuery	= strQuery + " WHERE flag_deleted = 0";
				strQuery	= strQuery + " AND node_id = " + node_id;
				exec_query2( strQuery );
				
				while ( mDbRs2.next() )
				{
					node_type		= mDbRs2.getInt( "node_type" );
					node_name		= mDbRs2.getString( "name" );
					node_type_alt	= mDbRs2.getInt( "node_type_alt" );
					loc_lng			= mDbRs2.getInt( "loc_lng" );
					loc_lat			= mDbRs2.getInt( "loc_lat" );
					
					//각 Link의 도로정보 갱신.
					strQuery	= "UPDATE";
					strQuery	= strQuery + " " + strTableLink + " SET";
					strQuery	= strQuery + " road_end_node_id = " + node_id + "";
					strQuery	= strQuery + ", road_end_node_type = " + node_type + "";
					strQuery	= strQuery + ", road_end_name = '" + node_name + "'";
					strQuery	= strQuery + ", road_end_node_type_alt = " + node_type_alt + "";
					strQuery	= strQuery + ", road_end_loc_lng = " + loc_lng + "";
					strQuery	= strQuery + ", road_end_loc_lat = " + loc_lat + "";
					strQuery	= strQuery + " WHERE road_no = " + road_no + "";
					strQuery	= strQuery + " AND flag_deleted = 0";

					exec_update3( strQuery );
				}
			}
			
			
			//트랜잭션 Commit.
			tran_commit();
		}
		catch(Exception e)
		{
			//트랜잭션 Rollback.
			tran_rollback();
			
			throw new Exception( e.toString() );
		}
	}
}

/*
 * End of File.
 */