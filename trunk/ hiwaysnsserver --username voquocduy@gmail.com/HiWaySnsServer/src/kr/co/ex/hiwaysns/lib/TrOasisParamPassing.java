/*
 * 
 *	Hi-Way SNS 서버.
 *
 * Copyrights (c) 2010-2011, (주)맨크레드. All rights reserved.
 *
 * 저작자: 유석(Yoo, Seok)
 *
 */

package kr.co.ex.hiwaysns.lib;

public class TrOasisParamPassing
{
	/*
	 * Constant 정의.
	 */

	
	/*
	 * Class 및 Instance 변수 정의.
	 */
	
	
	/*
	 * 객체 생성자.
	 */
	public	TrOasisParamPassing()
	{
	}
	
	
	/*
	 * 입력인자 처리.
	 */
	//GET 또는 POST 방식으로 전달되는 입력인자 수신하기.
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
	
	//문자열 인자를 정수형 인자로 변환.
	public	int		get_param_int( String strValue )
	{
		int		nValue	= 0;
		if ( strValue.length() > 0 )	nValue = Integer.parseInt(strValue);
		return nValue;
	}
	
	//문자열 인자를  Long 타입 정수형 인자로 변환.
	public	long	get_param_long( String strValue )
	{
		long	nValue	= 0;
		if ( strValue.length() > 0 )	nValue = Long.parseLong(strValue);
		return nValue;
	}
	
	//문자열 인자를  Float 타입 실수형 인자로 변환.
	public	float	get_param_float( String strValue )
	{
		float	fValue	= 0;
		if ( strValue.length() > 0 )	fValue = Float.parseFloat(strValue);
		return fValue;
	}
	
	//문자열 인자를  Double 타입 실수형 인자로 변환.
	public	double	get_param_double( String strValue )
	{
		double	fValue	= 0;
		if ( strValue.length() > 0 )	fValue = Double.parseDouble(strValue);
		return fValue;
	}

	
	/*
	 * 페이지 목록 처리.
	 */
	public	String	put_page_list( int count, int page_size, int page_no )
	{
		//예외처리.
		if ( count < 1 )		count = 0;
		if ( page_no < 1 )		page_no = 1;
		if ( page_size < 1 )	page_size = 10;
			
		//마지막 페이지 번호 구하기.
		int	page_last	= (int) Math.ceil((double)count / (double)page_size);
		if ( page_last < 1 )	page_last = 1;
		//System.out.println( "page_size=" + page_size + ", count=" + count + ", page_last=" + page_last );

		//이전/다음 10 페이지로 이동하기.
		int	page_prev	= (int) Math.floor((double)(page_no -1) / 10.0) * 10 + 1 - 10;
		if ( page_prev < 1 )			page_prev = 1;

		int	page_next	= (int) Math.floor((double)(page_no - 1) / 10.0) * 10 + 1 + 10;
		if ( page_next > page_last )	page_next = page_last;

		int	page_count	= (int) Math.ceil( (double)count / (double)page_size );
			
		int	page_start	= (int) Math.floor( (double)(page_no - 1) / 10.0 ) * 10 + 1;
		int	page_end	= page_start + 10;
		if ( page_end > page_last )	page_end = page_last + 1;

		String	strResult	= "";
		//Prev 10 Pages로...
		if ( page_no > 10 )
		{
			strResult = strResult + "<a href='#' target='_self' onclick='return js_change_page_no(" + page_prev + ");' onkeypress='return js_change_page_no(" + page_prev + ");'>[이전10페이지]&nbsp<img src='images/page_prev.gif' border='0' alt='이전10페이지'>&nbsp</a>&nbsp";
		}
		else
		{
			strResult = strResult + "[이전 10페이지]&nbsp<img src='images/page_prev.gif' border='0' alt='이전 10페이지'>&nbsp&nbsp";
		}

		//10개의 페이지 목록.
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
		//다음 10 페이지로...
		if ( (page_last + 1) > page_end )
		{
			strResult = strResult + "&nbsp<a href='#' target='_self' onclick='return js_change_page_no(" + page_next + ");' onkeypress='return js_change_page_no(" + page_next + ");'>&nbsp<img src='images/page_next.gif' border='0' alt='next'>&nbsp[다음 10페이지]</a>";
		}
		else
		{
			strResult = strResult + "&nbsp&nbsp<img src='images/page_next.gif' border='0' alt='next'>&nbsp[다음 10페이지]";
		}
		
		return strResult;
	}
}

/*
 * End of File.
 */