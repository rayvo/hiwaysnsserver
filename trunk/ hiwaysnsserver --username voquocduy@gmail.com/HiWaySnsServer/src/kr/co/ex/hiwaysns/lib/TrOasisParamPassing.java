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

public class TrOasisParamPassing
{
	/*
	 * Constant ����.
	 */

	
	/*
	 * Class �� Instance ���� ����.
	 */
	
	
	/*
	 * ��ü ������.
	 */
	public	TrOasisParamPassing()
	{
	}
	
	
	/*
	 * �Է����� ó��.
	 */
	//GET �Ǵ� POST ������� ���޵Ǵ� �Է����� �����ϱ�.
	public	String	get_input_param( String strParam )
	{
		if ( strParam == null )	strParam = "";
		try
		{
			strParam	= new String( strParam.getBytes("8859_1"), "utf-8" );
		}
		catch( Exception e ) { }
		
		return strParam;
	}
	
	//���ڿ� ���ڸ� ������ ���ڷ� ��ȯ.
	public	int		get_param_int( String strValue )
	{
		int		nValue	= 0;
		if ( strValue.length() > 0 )	nValue = Integer.parseInt(strValue);
		return nValue;
	}
	
	//���ڿ� ���ڸ�  Long Ÿ�� ������ ���ڷ� ��ȯ.
	public	long	get_param_long( String strValue )
	{
		long	nValue	= 0;
		if ( strValue.length() > 0 )	nValue = Long.parseLong(strValue);
		return nValue;
	}
	
	//���ڿ� ���ڸ�  Float Ÿ�� �Ǽ��� ���ڷ� ��ȯ.
	public	float	get_param_float( String strValue )
	{
		float	fValue	= 0;
		if ( strValue.length() > 0 )	fValue = Float.parseFloat(strValue);
		return fValue;
	}
	
	//���ڿ� ���ڸ�  Double Ÿ�� �Ǽ��� ���ڷ� ��ȯ.
	public	double	get_param_double( String strValue )
	{
		double	fValue	= 0;
		if ( strValue.length() > 0 )	fValue = Double.parseDouble(strValue);
		return fValue;
	}

	
	/*
	 * ������ ��� ó��.
	 */
	public	String	put_page_list( int count, int page_size, int page_no )
	{
		//����ó��.
		if ( count < 1 )		count = 0;
		if ( page_no < 1 )		page_no = 1;
		if ( page_size < 1 )	page_size = 10;
			
		//������ ������ ��ȣ ���ϱ�.
		int	page_last	= (int) Math.ceil((double)count / (double)page_size);
		if ( page_last < 1 )	page_last = 1;
		//System.out.println( "page_size=" + page_size + ", count=" + count + ", page_last=" + page_last );

		//����/���� 10 �������� �̵��ϱ�.
		int	page_prev	= (int) Math.floor((double)(page_no -1) / 10.0) * 10 + 1 - 10;
		if ( page_prev < 1 )			page_prev = 1;

		int	page_next	= (int) Math.floor((double)(page_no - 1) / 10.0) * 10 + 1 + 10;
		if ( page_next > page_last )	page_next = page_last;

		int	page_count	= (int) Math.ceil( (double)count / (double)page_size );
			
		int	page_start	= (int) Math.floor( (double)(page_no - 1) / 10.0 ) * 10 + 1;
		int	page_end	= page_start + 10;
		if ( page_end > page_last )	page_end = page_last + 1;

		String	strResult	= "";
		//Prev 10 Pages��...
		if ( page_no > 10 )
		{
			strResult = strResult + "<a href='#' target='_self' onclick='return js_change_page_no(" + page_prev + ");' onkeypress='return js_change_page_no(" + page_prev + ");'>[����10������]&nbsp<img src='images/page_prev.gif' border='0' alt='����10������'>&nbsp</a>&nbsp";
		}
		else
		{
			strResult = strResult + "[���� 10������]&nbsp<img src='images/page_prev.gif' border='0' alt='���� 10������'>&nbsp&nbsp";
		}

		//10���� ������ ���.
		for ( int i = page_start; i < page_end; i++ )
		{
			if ( i == page_no )
			{
				strResult = strResult + "&nbsp;<strong>" + i + "</strong>&nbsp;";
			}
			else
			{
				strResult = strResult + "&nbsp;<a href='#' target='_self' onclick='return js_change_page_no(" + i + ");' onkeypress='return js_change_page_no(" + i + ");'>" + i + "</a>&nbsp;";
			}
		};
		//���� 10 ��������...
		if ( (page_last + 1) > page_end )
		{
			strResult = strResult + "&nbsp<a href='#' target='_self' onclick='return js_change_page_no(" + page_next + ");' onkeypress='return js_change_page_no(" + page_next + ");'>&nbsp<img src='images/page_next.gif' border='0' alt='next'>&nbsp[���� 10������]</a>";
		}
		else
		{
			strResult = strResult + "&nbsp&nbsp<img src='images/page_next.gif' border='0' alt='next'>&nbsp[���� 10������]";
		}
		
		return strResult;
	}
}

/*
 * End of File.
 */