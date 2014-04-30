$(document).ready(function(){
	$(document).tooltip();
	// Load new filter
	$('#select_filter').change(function(){
		select_value = $(this).val();
		html = "";

		$.ajax({
			url: '/cpm_management/get_'+select_value+'_filter',
			async: false,
			success: function(filter){
				html = filter;
			}
		});

		$('#active_filters').append("<div><input id='filter_"+select_value+"' class='enable_filter' type='checkbox' checked /> "+html+"</div>");
		
		$('option[value='+$(this).val()+']').prop('disabled',true);
		$('#select_filter').val("default");
	});

	// Enable/Disable filters
	$(document).on('click','.enable_filter',function(){
		id = $(this)[0].id

		if ($(this).is(':checked')){
			$('.'+id).prop('disabled',false);
			$('.'+id).show();
		} else {
			$('.'+id).prop('disabled',true);
			$('.'+id).hide();		
		}
	});

	// Show capacities search result
	$('#find_capacities').on('ajax:success', function(data, status, xhr){
		$('#resultado').html(status);
	});

	// Click on option "Hide empty rows"
	$(document).on('change','#hide_empty_users',function(){
		if ($(this).is(':checked')){
			hide_empty_results();
		} else {
			show_all_results();
		}

		strip_table("capacity_results");
	});

	// Click on option "Bar view"
	$(document).on('change','#bar_view',function(){
		if ($(this).is(':checked')){
			view_bars();
		} else {
			view_numbers();
		}

		strip_table("capacity_results");
	});


	// Generates and show modal window for user capacity edition
	$(document).on('click','.edit_user_capacities',function(){
/*
		id = $(this)[0].id;
		window.location.href = '/cpm_management/edit_form/'+id;
*/
		id = $(this)[0].id;
		html = "";

		$.ajax({
			url: '/cpm_management/edit_form/'+id,
			async: false,
			success: function(filter){
				html = filter;
			}
		});

		$('#dialog').html(html);
		$('#dialog').dialog({width:800, close: function(){ 
			$('.ui-dialog').remove();
			$('#find_capacities').submit();
		} });

	});

	// Update user capacity edition
	$(document).on('ajax:success', '.edit_cpm_user_capacity', function(data, status, xhr){
//		msg = status.getResponseHeader('X-Message');
//		msg = "mensaje";
		$('#dialog').html(status);
	});

	$(document).on('ajax:success', '.new_cpm_user_capacity', function(data, status, xhr){
		$('#dialog').html(status);
	});

});

// Hide all user rows with all capacities empty
function hide_empty_results(){
	$.each($('#capacity_results tr'),function(i,row){
		if (i>0){
			empty = true;
		
			$.each($('td',row),function(j,col){
				if (j>0 && $(col).attr('value')!=0){
					empty = false;
				}
			});

			if (empty){
				$(row).hide();
			}
		}
	});
}

// Show all user rows
function show_all_results(){
	$.each($('#capacity_results tr'),function(i,row){
		$(row).show();
	});
}

// Añade alternativamente las clases odd y even a las filas de la tabla indicada
function strip_table(table_id){
	nxt = 'odd';
	$('#'+table_id+' tbody tr').each(function(i,tr){
		if (i>0 && $(tr).is(':visible')){
			$(this).removeClass('even').removeClass('odd');
			$(this).addClass(nxt);

			if (nxt=='odd'){
				nxt = 'even';
			} else {
				nxt = 'odd';
			}
		}
	});
}

// Change capacity view mode to bars
function view_bars(){
	$.each($('#capacity_results tr'),function(i,row){
		if (i>0){
			$.each($('td',row),function(j,col){
				if (j>0){
					value = $(col).attr('value');
					fill_bar = parseInt(value/2);
					empty_bar = 50-fill_bar;
					$(col).html("<div class='bar_background'><div style='height:"+empty_bar+"px;' class='bar_empty'></div></div>")
				}
			});
		}
	});
}

// Change capacity view mode to numbers
function view_numbers(){
	$.each($('#capacity_results tr'),function(i,row){
		if (i>0){
			$.each($('td',row),function(j,col){
				if (j>0){
					value = $(col).attr('value');
					$(col).html(value)
				}
			});
		}
	});
}