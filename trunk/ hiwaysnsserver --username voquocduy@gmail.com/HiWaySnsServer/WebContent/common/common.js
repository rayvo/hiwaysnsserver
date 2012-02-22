//<!--
	//페이지 이동.
	function js_change_page_no( page_no )
	{
		var frm_input	= document.form_main;
		frm_input.page_no.value		= page_no;
		//alert( location.pathname );
		return js_move_page_with_params( location.pathname );
		//alert( frm_input.page_no.value );
	}

	//자기자신 Refresh.
	function	js_page_refresh()
	{
		var frm_input	= document.form_main;
		frm_input.page_no.value	= 1;
		js_move_page_with_params( location.pathname );
	}

	//페이지 이동.
	function	js_move_page_with_params( url_target )
	{
		var frm_input		= document.form_main;
		var	page_no			= frm_input.page_no.value;
		var	page_size		= frm_input.page_size.value;
		var	sort_order		= frm_input.sort_order.value;
		var	search_type		= frm_input.search_type.value;
		var	search_text		= encodeURIComponent( frm_input.search_text.value );

		var	obj_param	= "page_no=" + page_no + "&page_size=" + page_size
							+ "&sort_order=" + sort_order
							+ "&search_type=" + search_type + "&search_text=" + search_text;
		self.location.href	= url_target + "?" + obj_param;
		return ( true );
	}


	//프로그램 종료.
	function	js_exit_program()
	{
		//사용자 확인.
		if ( !confirm("프로그램을 종료하면, 신규 편집내용은 저장되지 않습니다.\n그래도 프로그램을 종료합니까?") )	return;
		//모든 Session 정보 Reset.
		js_submit_page( "_self", "../menu/exit_process.jsp" );
		//윈도우 닫기.
		js_close_window();
	}
	//입력 Form의 Submit.
	function	js_submit_page( target_base, target_url )
	{
		var frm_input	= document.form_main;
		frm_input.target	= target_base;		//_self, _blank, top, etc.
		frm_input.action	= target_url;
		frm_input.submit();
		//return ( true );
		return( false );
	}

	//Popup 윈도우 닫기.
	function	js_close_window()
	{
		window.opener	= "nothing";
		window.open( '', '_parent', '' );
		window.close();
	}
	
	//Form 페이지로 이동.
	function	js_goto_form( type_action, url_target, id_record  )
	{
		var frm_input	= document.form_main;
		frm_input.type_action.value	= type_action;
		frm_input.id_record.value	= id_record;
		return js_move_page_with_params( url_target );
	}

	//현재 페이지 목록에 있는 모든 항목 선택.
	function	js_select_all_page( page_size )
	{
		//alert( page_size );
		var	select_all	= document.getElementById("select_all").checked;
		for ( var i = 0; i < page_size; i++ )
		{
			var	list_item		= document.getElementById("list_item[" + i + "]");
			list_item.checked	= select_all;
		}
		/*
		var	list_item	= document.getElementsByName( "list_item" );
		//alert( list_item.length );
		for ( var i = 0; i < list_item.length; i++ )
		{
			list_item[i].checked	= select_all;
		}
		*/
	}

	//데이터를 파일로 Export.
	function	js_export_data( url_target )
	{
		var frm_input	= document.form_main;
		frm_input.action	= url_target;
		frm_input.target	= "_blank";
		frm_input.submit();
		return( true );
	}

	//화면 크기 구하기.
	function	js_screen_size()
	{
		//화면 해상도 추출.
		var width	= screen.width;
		var res		= (((!(640-width))*1)+((!(800-width))*2)+((!(1024-width))*3)+((!(1152-width))*4)+((!(1280-width))*5)+((!(1600-width))*6));
		if ( !(res) )	res = 1;
		switch( res )
		{
		case "1":
			visitor_width	= "640";
			visitor_height	= "480";
			break;

		case "2":
			visitor_width	= "800";
			visitor_height	= "600";
			break;

		case "3":
			visitor_width	= "1024";
			visitor_height	= "768";
			break;

		case "4":
			visitor_width	= "1152";
			visitor_height	= "864";
			break;

		case "5":
			visitor_width	= "1280";
			visitor_height	= "1024";
			break;

		case "6":
			visitor_width	= "1600";
			visitor_height	= "1200";
			break;

		default:
			visitor_width	= screen.width;
			visitor_height	= screen.height;
			break;
		}
		return ( visitor_width * 10000 + visitor_height );
	}

	//팝업 레이어 Show/Hide
	function	show_layer(layer_id, display, x, y)
	{
		var div = document.getElementById( layer_id );

		if (x && y)
		{
			div.style.left = document.body.scrollLeft + x;
			div.style.top = document.body.scrollTop + y;
		}

		if (div.style.display == 'none' && display != 0)
		{
			div.style.display = 'inline';
		}
		else if (display != 1)
		{
			div.style.display = 'none';
		}
	}

	//메뉴판 저장 실패 Popup 윈도우 출력.
	function	js_show_save_fail( display )
	{
		//화면 해상도 추출.
		var	visitor_width	= 800;
		var	visitor_height	= 560;
		var	win_width		= 415;
		var	win_height		= 273;
		var	margin_left	= ( visitor_width - win_width ) / 2;
		var	margin_top	= ( visitor_height - win_height ) / 2;
		
		//팝업 윈도우 만들기.
		show_layer( "save_fail", display, margin_left, margin_top );
		return( false );
	}
	//메뉴판 저장 성공 Popup 윈도우 출력.
	function	js_show_save_ok( display )
	{
		//화면 해상도 추출.
		var	visitor_width	= 800;
		var	visitor_height	= 560;
		var	win_width		= 415;
		var	win_height		= 273;
		var	margin_left	= ( visitor_width - win_width ) / 2;
		var	margin_top	= ( visitor_height - win_height ) / 2;
		
		//팝업 윈도우 만들기.
		show_layer( "save_ok", display, margin_left, margin_top );
		return( false );
	}

//-->