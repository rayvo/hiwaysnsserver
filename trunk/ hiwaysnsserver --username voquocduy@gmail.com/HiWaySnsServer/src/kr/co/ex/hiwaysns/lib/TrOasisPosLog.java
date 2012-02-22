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

public class TrOasisPosLog
{
	/*
	 * Constant 정의.
	 */
	

	/*
	 * Class 및 Instance Variable 정의.
	 */
	public	long		mTimestamp	= 0;
	public	int			mPosLat		= 0;
	public	int			mPosLng		= 0;
	public	int			mSpeed		= 0;
	public	int			mSpeedAvg	= 0;

	
	/*
	 * Method 정의.
	 */
	public	TrOasisPosLog()
	{
		mTimestamp	= 0;
		mPosLat		= 0;
		mPosLng		= 0;
		mSpeed		= 0;
		mSpeedAvg	= 0;
	}
}
