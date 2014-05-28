set serveroutput on

declare

  l_access_token varchar2(300) := '';
  l_events gapi_cal_event.t_event_list;
begin

  l_events :=
    gapi_cal_event.list_events(
      p_query => ''
    , p_calendar_id => ''
    , p_access_token => l_access_token
    --, p_max_results => 50
    );
    
    dbms_output.put_line(l_events.COUNT);  
    dbms_output.put_line(l_events(1).kind);
    dbms_output.put_line(l_events(1).id);
    dbms_output.put_line(l_events(1).status);
    dbms_output.put_line(l_events(1).html_link);
    dbms_output.put_line(l_events(1).created);
    dbms_output.put_line(l_events(1).updated);
    dbms_output.put_line(l_events(1).summary);
    dbms_output.put_line(l_events(1).description);
    dbms_output.put_line(l_events(1).location);
    dbms_output.put_line(l_events(1).color_id);
    dbms_output.put_line(l_events(1).start_date);
    dbms_output.put_line(l_events(1).end_date);
    if l_events(1).all_day
    then
    
      dbms_output.put_line('All day');
    else
      dbms_output.put_line('Not all day');
    end if;

end;
