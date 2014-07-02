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
package body gapi_cal_calendar
as


    function get_calendar_from_json(
        p_calendar_json CLOB) return t_calendar
    AS
        l_calendar t_calendar;
        l_json JSON;
    BEGIN
    
        l_json := JSON(p_calendar_json);
        
        l_calendar.id := json_ext.get_string(l_json, 'id');
        l_calendar.summary := json_ext.get_string(l_json, 'summary');
        l_calendar.description:= json_ext.get_string(l_json, 'description');
        l_calendar.location := json_ext.get_string(l_json, 'location');
        l_calendar.time_zone := json_ext.get_string(l_json, 'timeZone');
        l_calendar.summary_override := json_ext.get_string(l_json, 'summaryOverride');
        l_calendar.color_id := json_ext.get_string(l_json, 'colorId');
        l_calendar.background_color:= json_ext.get_string(l_json, 'backgroundColor');
        l_calendar.foreground_color := json_ext.get_string(l_json, 'foregroundColor');
        l_calendar.hidden := json_ext.get_bool(l_json, 'hidden');
        l_calendar.selected:= json_ext.get_bool(l_json, 'selected');
        l_calendar.access_role := json_ext.get_string(l_json, 'accessRole');
        l_calendar.primary := json_ext.get_bool(l_json, 'primary');
        l_calendar.deleted := json_ext.get_bool(l_json, 'deleted');
        
        return l_calendar;
    
    END get_calendar_from_json;

    /*
    
        List action: https://developers.google.com/google-apps/calendar/v3/reference/calendarList/list
    
    */
    function list_calendars(
        p_access_token in varchar2
    ) return t_calendar_list
    AS
        l_request_url varchar2(200) := 'https://www.googleapis.com/calendar/v3/users/me/calendarList';
        
        l_response CLOB;
        l_response_json JSON;
        l_json_calendar_list JSON_LIST;
        
        l_calendar t_calendar;
        l_calendar_list t_calendar_list;        
    BEGIN
        
        l_response := 
            gapi.authorized_request(
                p_access_token => p_access_token
              , p_url => l_Request_url
              , p_method => 'GET'
              , p_payload => NULL
            );
        
        l_response_JSON := JSON(l_response);
            
        l_json_calendar_list := JSON_EXT.get_json_list(l_Response_json, 'items');
            
        for i in 1..l_json_calendar_list.COUNT
        LOOP
        
            l_calendar := get_calendar_from_json(l_json_calendar_list.get(i).to_char);
            l_calendar_list(i) := l_Calendar;
        
        END LOOP;
        
        
        return l_calendar_list;
        
    END list_calendars;
    
    function list_calendars_sql(
        p_access_token in varchar2
    ) return t_calendar_list_sql pipelined
    AS
        l_Calendar_list t_calendar_list;
        l_calendar t_calendar_sql;
    BEGIN
    
        l_calendar_list := list_calendars(p_access_token);
        
        for i in 1..l_calendar_list.COUNT
        LOOP
        
            l_calendar.kind := l_calendar_list(i).kind;
            l_calendar.id := l_calendar_list(i).id;
            l_calendar.summary := l_calendar_list(i).summary;
            l_calendar.description:= l_calendar_list(i).description;
            l_calendar.location := l_calendar_list(i).location;
            l_calendar.time_zone := l_calendar_list(i).time_zone;
            l_calendar.summary_override := l_calendar_list(i).summary_override;
            l_calendar.color_id := l_calendar_list(i).color_id;
            l_calendar.background_color:= l_calendar_list(i).background_color;
            l_calendar.foreground_color := l_calendar_list(i).foreground_color;
            l_calendar.hidden := case when l_calendar_list(i).hidden then gapi.GC_TRUE else gapi.GC_FALSE end;
            l_calendar.selected:= case when l_calendar_list(i).selected then gapi.GC_TRUE else gapi.GC_FALSE end;
            l_calendar.access_role := l_calendar_list(i).access_role;
            l_calendar.primary := case when l_calendar_list(i).primary then gapi.GC_TRUE else gapi.GC_FALSE end;
            l_calendar.deleted := case when l_calendar_list(i).deleted then gapi.GC_TRUE else gapi.GC_FALSE end;
            
            pipe row (l_calendar);
            l_calendar := NULL;
        
        END LOOP;
    
    END list_calendars_sql;
    
    /*
    
    Insert action: https://developers.google.com/google-apps/calendar/v3/reference/calendars/insert
    
    */
    
    function create_calendar(
        p_title in varchar2
      , p_access_token in varchar2) return varchar2
    AS
        l_request_url varchar2(200) := 'https://www.googleapis.com/calendar/v3/calendars';
        
        l_response CLOB;
        l_response_JSON JSON;
        
        l_payload JSON;
    BEGIN
    
        l_payload := JSON;
        
        l_payload.put('summary', p_title);
    
        l_response := 
            gapi.authorized_request(
                p_access_token => p_access_token
              , p_url => l_Request_url
              , p_method => 'POST'
              , p_payload => l_payload.to_char
            );    
            
        l_response_JSON := JSON(l_response);    
          
        return json_Ext.get_string(l_response_json, 'id');               
    END create_calendar;    

        

end gapi_cal_calendar;
/
