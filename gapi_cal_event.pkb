/*******************************************************************

Copyright (C) Trent Schafer 2014

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

*******************************************************************/

create or replace
package body gapi_cal_event
as


    
    function get_event_json(
        p_title in varchar2
      , p_start_date in timestamp with time zone
      , p_end_date in timestamp with time zone
      , p_all_day in BOOLEAN default FALSE
      , p_location in varchar2 default NULL
      , p_description in varchar2 default NULL
    ) return JSON
    as
        l_event JSON;
        
        l_start JSON;
        l_end JSON;
    BEGIN
    
        l_event := JSON;
        
        l_event.put('summary', p_title);
        l_event.put('location', p_location);
        l_event.put('description', p_description);
        
        l_start := JSON;
        l_end := JSON;
        
        if p_all_day
        then
            l_start.put('date', to_char(p_start_date,'yyyy-mm-dd'));
            l_end.put('date', to_char(p_end_date,'yyyy-mm-dd'));            
        else
            l_start.put('dateTime', gapi.get_timestamp(p_start_date));
            l_end.put('dateTime', gapi.get_timestamp(p_end_date));            
        
        end if;
        
        l_event.put('start', l_start);
        l_event.put('end', l_end);
        
        return l_event;
    
    END get_event_json;


    /*
    
        Insert action: https://developers.google.com/google-apps/calendar/v3/reference/events/insert
    
    */
    function insert_event(
        p_calendar_id in varchar2
      , p_title in varchar2
      , p_start_date in timestamp with time zone
      , p_end_date in timestamp with time zone
      , p_all_day in BOOLEAN default FALSE
      , p_location in varchar2 default NULL
      , p_description in varchar2 default NULL
      , p_access_token in varchar2
    ) return varchar2
    AS
        l_request_url varchar2(200) := 'https://www.googleapis.com/calendar/v3/calendars/#ID#/events';
        
        l_payload JSON;
        l_start_JSON JSON;
        l_end_JSON JSON;
        
        l_response CLOB;
        l_response_json JSON;        
    BEGIN
    
        l_request_url := replace(l_request_url, '#ID#', p_calendar_id);
        
        l_payload := 
            get_event_json(
                p_title => p_title
              , p_start_date => p_start_date
              , p_end_date => p_end_date
              , p_all_day => p_all_day
              , p_location => p_location
              , p_description => p_description
            );
        
        l_response := 
            gapi.authorized_request(
                p_access_token => p_access_token
              , p_url => l_Request_url
              , p_method => 'POST'
              , p_payload => l_payload.to_char
            );
        
        l_response_json := JSON(l_response);
        
        return JSON_EXT.get_string(l_response_json, 'id');
        
    END insert_event;
    
    /*
    
        Patch action: https://developers.google.com/google-apps/calendar/v3/reference/events/patch
    
    */
    
    procedure update_event(
        p_calendar_id in varchar2
      , p_event_id in varchar2
      , p_title in varchar2
      , p_start_date in timestamp with time zone
      , p_end_date in timestamp with time zone
      , p_all_day in BOOLEAN default FALSE
      , p_location in varchar2 default NULL
      , p_description in varchar2 default NULL
      , p_access_token in varchar2
    )
    AS
        l_payload JSON;
        
        l_request_url varchar2(200) := 'https://www.googleapis.com/calendar/v3/calendars/#CALENDAR_ID#/events/#EVENT_ID#';
        
        l_response CLOB;
    BEGIN    
    
        l_request_url := replace(l_request_url, '#CALENDAR_ID#', p_calendar_id);
        l_request_url := replace(l_request_url, '#EVENT_ID#', p_event_id);    
    
        l_payload :=
            get_event_json(
                p_title => p_title
              , p_start_date => p_start_date
              , p_end_date => p_end_date
              , p_all_day => p_all_day
              , p_location => p_location
              , p_description => p_description
            );
            
        l_response :=
            gapi.authorized_request(
                p_access_token => p_access_token
              , p_url => l_request_url
              , p_method => 'PATCH'
              , p_payload => l_payload.to_char
            );
    
    END update_event;
        
        
    /*
    
        Delete action: https://developers.google.com/google-apps/calendar/v3/reference/events/delete
    
    */
    
    procedure delete_event(
        p_calendar_id in varchar2
      , p_event_id in varchar2
      , p_access_token in varchar2)
    AS
    
        l_request_url varchar2(200) := 'https://www.googleapis.com/calendar/v3/calendars/#CALENDAR_ID#/events/#EVENT_ID#';
        
        l_response CLOB;
    BEGIN
    
        l_request_url := replace(l_request_url, '#CALENDAR_ID#', p_calendar_id);
        l_request_url := replace(l_request_url, '#EVENT_ID#', p_event_id);
        
        l_response :=
            gapi.authorized_request(
                p_access_token => p_access_token
              , p_url => l_request_url
              , p_method => 'DELETE'
              , p_payload => NULL
            );

        --response is NULL if successful
    
    
    END delete_event;
    
    function get_event_from_json(
        p_event_json in CLOB
    ) return t_event AS
    
        l_json JSON;
        l_event t_event;
        
        l_start JSON;
        l_start_time varchar2(30);
        
        l_end JSON;
        l_end_time varchar2(30);        
    BEGIN
    
        l_json := JSON(p_event_json);
        
        l_event.id := json_ext.get_string(l_json, 'id');
        l_event.status := json_ext.get_string(l_json, 'status');
        l_event.html_link:= json_ext.get_string(l_json, 'htmlLink');
        l_event.created := gapi.get_local_timestamp(json_ext.get_string(l_json, 'created'));
        l_event.updated:= gapi.get_local_timestamp(json_ext.get_string(l_json, 'updated'));
        l_event.summary := json_ext.get_string(l_json, 'summary');
        l_event.description := json_ext.get_string(l_json, 'description');
        l_event.location := json_ext.get_string(l_json, 'location');
        l_event.color_id := json_ext.get_string(l_json, 'colorId');
        
        l_start := json_ext.get_json(l_json, 'start');
        l_end := json_ext.get_json(l_json, 'end');
        l_start_time := json_ext.get_string(l_start, 'dateTime');
        
        if l_start_time is not null
        then
            l_end_time := json_ext.get_string(l_end, 'dateTime');

            l_event.start_date := to_timestamp_tz(l_start_time, 'yyyy-mm-dd"T"hh24:mi:sstzh:tzm');
            l_event.end_date := to_timestamp_tz(l_end_time, 'yyyy-mm-dd"T"hh24:mi:sstzh:tzm');                        

        else  
            l_event.all_day := TRUE;
            
            l_start_time := json_ext.get_string(l_start, 'date');            
            l_end_time := json_ext.get_string(l_end, 'date');            
            
            l_event.start_date := to_timestamp_tz(l_start_time, 'yyyy-mm-dd');
            l_event.end_date := to_timestamp_tz(l_end_time, 'yyyy-mm-dd');                                    
        
        end if;
        
        return l_event;
        
    
    END get_event_from_json;    
    
    function get_event(
        p_calendar_id in varchar2
      , p_event_id in varchar2
      , p_access_token in varchar2) return t_event
    AS
    
        l_request_url varchar2(200) := 'https://www.googleapis.com/calendar/v3/calendars/#CALENDAR_ID#/events/#EVENT_ID#';
        
        l_response CLOB;
        l_event t_event;
    BEGIN
        
        l_request_url := replace(l_request_url, '#CALENDAR_ID#', p_calendar_id);
        l_request_url := replace(l_request_url, '#EVENT_ID#', p_event_id);
        
        
        l_response :=
            gapi.authorized_request(
                p_access_token => p_access_token
              , p_url => l_request_url
              , p_method => 'GET'
              , p_payload => NULL
            );
    
        l_event := get_event_from_json(l_response);
        
        return l_event;
    
    END get_event;    
    
    /*
    
        List action: https://developers.google.com/google-apps/calendar/v3/reference/events/list
    
    */
    function list_events(
        p_calendar_id in varchar2
      , p_max_results in NUMBER default 250
      , p_query in varchar2
      , p_access_token in varchar2
    ) return t_event_list
    AS
    
    
        l_request_url varchar2(200) := 'https://www.googleapis.com/calendar/v3/calendars/#ID#/events?maxResults=#MAX_RESULTS#&q=#QUERY#';
        
        l_response CLOB;
        l_event_list t_event_list;
        l_item CLOB;
        
        l_cur_event t_event;
        
        l_response_json JSON;
        l_json_Event_list JSON_LIST;
    
    BEGIN
    
        dbms_lob.createtemporary(l_item, TRUE);
    
        l_request_url := replace(l_request_url, '#ID#', p_calendar_id);
        l_request_url := replace(l_request_url, '#MAX_RESULTS#', p_max_results);
        l_request_url := replace(l_request_url, '#QUERY#', p_query);                
        
        l_response :=
            gapi.authorized_request(
                p_access_token => p_access_token
              , p_url => l_request_url
              , p_method => 'GET'
              , p_payload => NULL
            );
            
        l_response_json := JSON(l_response);
        
        l_json_event_list := JSON_EXT.get_json_list(l_response_json, 'items');
        
        for i in 1..l_json_Event_list.COUNT
        LOOP
            l_json_event_list.get(i).to_clob(l_item);
            l_cur_event := get_event_from_json(l_item);
            l_event_list(i) := l_cur_event;
        END LOOP;
            
        return l_event_list;
    
    END list_events; 
    
    function list_events_sql(
        p_calendar_id in varchar2
      , p_max_results in NUMBER default 250
      , p_query in varchar2
      , p_access_token in varchar2) return t_event_list_sql pipelined
    AS
    
        l_event_list t_event_list;
        l_event t_event_sql;
    
    BEGIN
    
    
        l_event_list := 
            list_events(
                p_calendar_id => p_calendar_id
              , p_max_results => p_max_results
              , p_query => p_query
              , p_Access_token => p_access_token
            );
        
        
        for i in 1..l_event_list.COUNT
        LOOP
            
            l_event.kind            := l_event_list(i).kind;
            l_event.id              := l_event_list(i).id;
            l_event.status          := l_event_list(i).status;
            l_event.html_link       := l_event_list(i).html_link;
            l_event.created         := l_event_list(i).created;
            l_event.updated         := l_event_list(i).updated;
            l_event.summary         := l_event_list(i).summary;
            l_event.description     := l_event_list(i).description;
            l_event.location        := l_event_list(i).location;
            l_event.color_id        := l_event_list(i).color_id;
            l_event.start_date      := l_event_list(i).start_date;
            l_event.end_date        := l_event_list(i).end_date;
            l_event.all_day         := case when l_event_list(i).all_day then GAPI.GC_TRUE else GAPI.GC_FALSE end;
            
            pipe row (l_event);
            
            l_event := NULL;
        
        
        END LOOP;
              
              
            
    
    END list_events_sql;    

        

end gapi_cal_event;
/
