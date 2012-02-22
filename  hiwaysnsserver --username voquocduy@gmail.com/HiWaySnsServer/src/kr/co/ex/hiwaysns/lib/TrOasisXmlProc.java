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

import java.io.ByteArrayInputStream;
import java.util.ArrayList;
import java.util.List;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserFactory;

public class TrOasisXmlProc
{
	/*
	 * Constant ����.
	 */
	public	static	final	String	XML_LEADING	= "<?xml version='1.0' encoding='UTF-8'?>";

	
	/*
	 * Class �� Instance Variable ����.
	 */
	//XML ������ ����.
	private	String	mXmlData	= "";
	

	/*
	 * Method ����.
	 */
	//XML ������ ���� ����.
	public	void	startXML()
	{
		mXmlData	= XML_LEADING;
	}

	//XML�� �ű� �ʵ� �߰�.
	public	String	appendField( String fieldName, String fieldValue )
	{
		mXmlData	= mXmlData + "<" + fieldName + ">" + fieldValue + "</" + fieldName + ">";
		return mXmlData;
	}

	public	String	appendField_Int( String fieldName, int fieldValue )
	{
		String	strValue	= String.valueOf(fieldValue);
		return appendField( fieldName, strValue );
	}

	public	String	appendField_Long( String fieldName, long fieldValue )
	{
		String	strValue	= String.valueOf(fieldValue);
		return appendField( fieldName, strValue );
	}

	//XML�� �ű� �ʵ� �߰��� ���� �۾�����.
	public	String	startField( String fieldName )
	{
		mXmlData	= mXmlData + "<" + fieldName + ">";
		return mXmlData;
	}

	//XML�� �ű� �ʵ� �߰��� ���� �۾��Ϸ�.
	public	String	endField( String fieldName )
	{
		mXmlData	= mXmlData + "</" + fieldName + ">";
		return mXmlData;
	}
	
	//XML ������ ���� �Ϸ�.
	public	String	endXML()
	{
		return mXmlData;
	}

	
	
	//GET �Ǵ� POST ������� ���ŵ� XML �Է����� �Ľ�.
	public	String[][]	parseInputXML( String strInputXml, String[][] inputList )
	{
		try
		{
			//�Է����� ����� ������ �ʱ�ȭ.
			for ( int j = 0; j < inputList.length; j++ )	inputList[j][1] = "";

			//�Է� XML �������� �Է������� ������ ���� �� ����.
			/*
			DocumentBuilderFactory	factory	= DocumentBuilderFactory.newInstance();
			DocumentBuilder			builder	= factory.newDocumentBuilder();
			
			InputSource	is	= new InputSource( new StringReader(strInputXml) );
			Document	doc	= builder.parse( is );
			NodeList	troasis	= doc.getElementsByTagName("troasis");
			NodeList	channel	= troasis.item(0).getChildNodes();
			int		countList	= (int)channel.getLength();
			String	tagName;
			for ( int i = 0; i < countList; i++ )
			{
				tagName		= channel.item(i).getNodeName();
				if ( tagName.length() < 1 || tagName.getBytes()[0] == '#' )	continue;
				for ( int j = 0; j < inputList.length; j++ )
				{
					if ( tagName.compareToIgnoreCase(inputList[j][0]) == 0 )
						inputList[j][1] = channel.item(i).getNodeValue();
				}
			}
			*/
		XmlPullParserFactory	factory	= XmlPullParserFactory.newInstance(); 
		factory.setNamespaceAware( true ); 
		XmlPullParser			xpp		= factory.newPullParser(); 
		//InputSource	is	= new InputSource( new StringReader(strInputXml) );
		ByteArrayInputStream is	= new ByteArrayInputStream(strInputXml.toString().getBytes("UTF-8"));
		xpp.setInput( is, "utf-8" ); 
		int			eventType	= xpp.getEventType(); 
		String		tagName;
		String		strValue;
		//System.out.println(strInputXml ); 
		while ( eventType != XmlPullParser.END_DOCUMENT )
		{
			tagName	= xpp.getName();
			switch( eventType )
			{
			case XmlPullParser.START_DOCUMENT	:
				//System.out.println( "Start document");
				break;
				
			case XmlPullParser.END_DOCUMENT		:
				//System.out.println( "End document");
				break;
				
			case XmlPullParser.START_TAG		:
				//System.out.println( "Start tag " + tagName);
				if ( tagName.length() < 1 || tagName.getBytes()[0] == '#' )
				{
					eventType = xpp.next(); 
					continue;
				}
				//System.out.println( "Start tag :" + tagName + " : " + xpp.nextToken() + "," + xpp.getText() );
				//System.out.println( "Start tag :" + tagName + " : " + "," + xpp.getText() );
				for ( int j = 0; j < inputList.length; j++ )
				{
					if ( tagName.equalsIgnoreCase(inputList[j][0]) )
					{
						xpp.nextToken();
						strValue	= xpp.getText();
 							if ( strValue == null || strValue.startsWith("</") )	strValue = "";
 							inputList[j][1]	= strValue;
						//System.out.println( "Field=" + tagName + ", Value=" + strValue ); 
					}
				}
				break;
				
			case XmlPullParser.END_TAG	:
				//System.out.println("End tag : " + tagName );
				break;
				
			case XmlPullParser.TEXT		:
				//System.out.println("Text : " + tagName + " : " + xpp.getText() );
				break;
				
			default						:
				//System.out.println("Else : " + tagName + " With : " + eventType );
				break;
			}
				
			eventType = xpp.next(); 
		}
		}
		catch( Exception e )
		{
		}
		
		//�Է������� ����� ��� ��ȯ.
		return inputList;
	}
	
	//GET �Ǵ� POST ������� ���ŵ� XML �Է����� �Ľ�.
	public	List<String[]>	parseMemberXML( String strInputXml, String subMember, String[] listMember )
	{
		//�Է����� ����� ������ �ʱ�ȭ.
		List<String[]>	listMemberValue	= new ArrayList<String[]>();

		try
		{
			//�Է� XML �������� �Է������� ������ ���� �� ����.
		XmlPullParserFactory	factory	= XmlPullParserFactory.newInstance(); 
		factory.setNamespaceAware( true ); 
		XmlPullParser			xpp		= factory.newPullParser(); 
		//InputSource	is	= new InputSource( new StringReader(strInputXml) );
		ByteArrayInputStream is	= new ByteArrayInputStream(strInputXml.toString().getBytes("UTF-8"));
		xpp.setInput( is, "utf-8" ); 
		int			eventType	= xpp.getEventType(); 
		String		tagName;
		int			index	= -1;
		String		strValue;
		//System.out.println(strInputXml ); 
		while ( eventType != XmlPullParser.END_DOCUMENT )
		{
			tagName	= xpp.getName();
			switch( eventType )
			{
			case XmlPullParser.START_DOCUMENT	:
				//System.out.println( "Start document");
				break;
				
			case XmlPullParser.END_DOCUMENT		:
				//System.out.println( "End document");
				break;
				
			case XmlPullParser.START_TAG		:
				//System.out.println( "Start tag " + tagName);
				if ( tagName.length() < 1 || tagName.getBytes()[0] == '#' )
				{
					eventType = xpp.next(); 
					continue;
				}
				//System.out.println( "Start tag :" + tagName + " : " + xpp.nextToken() + "," + xpp.getText() );
				//System.out.println( "Start tag :" + tagName + " : " + "," + xpp.getText() );
				//System.out.println("Start tag=" + tagName + " : subMember=" + subMember );
				//����׸� �߰�.
				if ( tagName.equalsIgnoreCase(subMember) )
				{
					listMemberValue.add( new String[listMember.length] );
					index++;
						//System.out.println( "index :" + index ); 
				}
				//����׸� ����.
				for ( int j = 0; j < listMember.length; j++ )
				{
					if ( tagName.equalsIgnoreCase(listMember[j]) )
					{
						xpp.nextToken();
						strValue	= xpp.getText();
 							if ( strValue == null || strValue.startsWith("</") )	strValue = "";
						listMemberValue.get(index)[j]	= strValue;
						//System.out.println( "Field=" + tagName + ", Value=" + strValue ); 
					}
				}
				break;
				
			case XmlPullParser.END_TAG	:
				//System.out.println("End tag : " + tagName );
				break;
				
			case XmlPullParser.TEXT		:
				//System.out.println("Text : " + tagName + " : " + xpp.getText() );
				break;
				
			default						:
				//System.out.println("Else : " + tagName + " With : " + eventType );
				break;
			}
				
			eventType = xpp.next(); 
		}
		}
		catch( Exception e )
		{
		}
		
		//�Է������� ����� ��� ��ȯ.
		return listMemberValue;
	}
	
	
	/*
	 * Attribute ����.
	 */
	public	String	getXmlData()
	{
		return mXmlData;
	}

	
	/*
	 * Implementation ����.
	 */
}

/*
 * End of File.
 */