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

import java.sql.ResultSet;

public class TrOasisMapLink
{
	/*
	 * Constants.
	 */
	
	
	/*
	 * Variables.
	 */
	public	long	link_id;			//Link ID.
	public	int		link_type;
	public	int		start_node_id, end_node_id;
	public	int		start_node_type, end_node_type;
	public	String	start_node_name, end_node_name;
	public	int		start_node_type_alt, end_node_type_alt;
	public	int		start_loc_lat, end_loc_lat;
	public	int		start_loc_lng, end_loc_lng;

	public	String	road_name;
	public	int		road_no;
	public	int		road_start_node_id, road_end_node_id;
	public	int		road_start_node_type, road_end_node_type;
	public	String	road_start_node_name, road_end_node_name;
	public	int		road_start_node_type_alt, road_end_node_type_alt;
	public	int		road_start_loc_lat, road_end_loc_lat;
	public	int		road_start_loc_lng, road_end_loc_lng;

	public	int		max_speed;
	public	String	remark;
	
	public	double	distDegree;			//������� ������ġ�κ��� ������ �� �Ÿ�(������ Degree).
	public	int		direction;			//������� �������.
	public	long	distance;			//End Node �������κ��� ���� ����� �Ÿ�.
	public	String	location_msg;		//��ġ�� ���� ����.
	
	
	/*
	 * Constructors.
	 */
	public	TrOasisMapLink()
	{
		
	}
	
	
	/*
	 * Methods.
	 */
	public	void	loadLinkInfo(ResultSet mDbRs) throws Exception
	{
		try
		{
			link_id					= mDbRs.getLong( "link_id" );
			link_type				= mDbRs.getInt( "link_type" );
			start_node_id			= mDbRs.getInt( "start_node_id" );
			end_node_id				= mDbRs.getInt( "end_node_id" );
			start_node_type			= mDbRs.getInt( "start_node_type" );
			end_node_type			= mDbRs.getInt( "end_node_type" );
			start_node_name			= mDbRs.getString( "start_name" );
			end_node_name			= mDbRs.getString( "end_name" );
			start_node_type_alt		= mDbRs.getInt( "start_node_type_alt" );
			end_node_type_alt		= mDbRs.getInt( "end_node_type_alt" );
			start_loc_lat			= mDbRs.getInt( "start_loc_lat" );
			end_loc_lat				= mDbRs.getInt( "end_loc_lat" );
			start_loc_lng			= mDbRs.getInt( "start_loc_lng" );
			end_loc_lng				= mDbRs.getInt( "end_loc_lng" );
			
			road_name				= mDbRs.getString( "road_name" );
			road_no					= mDbRs.getInt( "road_no" );
			road_start_node_id		= mDbRs.getInt( "road_start_node_id" );
			road_end_node_id		= mDbRs.getInt( "road_end_node_id" );
			road_start_node_type	= mDbRs.getInt( "road_start_node_type" );
			road_end_node_type		= mDbRs.getInt( "road_end_node_type" );
			road_start_node_name	= mDbRs.getString( "road_start_name" );
			road_end_node_name		= mDbRs.getString( "road_end_name" );
			road_start_node_type_alt	= mDbRs.getInt( "road_start_node_type_alt" );
			road_end_node_type_alt	= mDbRs.getInt( "road_end_node_type_alt" );
			road_start_loc_lat		= mDbRs.getInt( "road_start_loc_lat" );
			road_end_loc_lat		= mDbRs.getInt( "road_end_loc_lat" );
			road_start_loc_lng		= mDbRs.getInt( "road_start_loc_lng" );
			road_end_loc_lng		= mDbRs.getInt( "road_end_loc_lng" );
			
			max_speed				= mDbRs.getInt( "max_speed" );
			remark					= mDbRs.getString( "remark" );
			
			distDegree		= 0;			//������� ������ġ�κ��� ������ �� �Ÿ�(������ Degree).
			direction		= 0;			//������� �������.
			distance		= 0;			//End Node �������κ��� ���� ����� �Ÿ�.
			location_msg	= "";			//��ġ�� ���� ����.
		}
		catch(Exception e)
		{
			throw new Exception( e.toString() );
		}		
	}
	

	
	/*
	 * Implementations.
	 */
}
