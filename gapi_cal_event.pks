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
package gapi_cal_event
as
    
    type t_event is record (
        kind varchar2(20) := 'calendar#event'
      , id varchar2(300)
      , status varchar2(50)
      , html_link varchar2(500)
      , created timestamp with time zone
      , updated timestamp with time zone
      , summary varchar2(4000)
      , description varchar2(4000)
      , location varchar2(200)
      , color_id varchar2(10)
      , start_date timestamp with time zone
      , end_date timestamp with time zone
      , all_day BOOLEAN default FALSE
    );
    
    type t_event_sql is record (
        kind varchar2(20) := 'calendar#event'
      , id varchar2(300)
      , status varchar2(50)
      , html_link varchar2(500)
      , created timestamp with time zone
      , updated timestamp with time zone
      , summary varchar2(4000)
      , description varchar2(4000)
      , location varchar2(200)
      , color_id varchar2(10)
      , start_date timestamp with time zone
      , end_date timestamp with time zone
      , all_day GAPI.SQL_BOOL default GAPI.GC_FALSE
    );    
    
    type t_event_list is table of t_event index by PLS_INTEGER;
    type t_event_list_sql is table of t_event_sql;
    
    function insert_event(
        p_calendar_id in varchar2
      , p_title in varchar2
      , p_start_date in timestamp with time zone
      , p_end_date in timestamp with time zone
      , p_all_day in BOOLEAN default FALSE
      , p_location in varchar2 default NULL
      , p_description in varchar2 default NULL
      , p_access_token in varchar2
    ) return varchar2;
    
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
    );    
    
    procedure delete_event(
        p_calendar_id in varchar2
      , p_event_id in varchar2
      , p_access_token in varchar2);
      
    function get_event(
        p_calendar_id in varchar2
      , p_event_id in varchar2
      , p_access_token in varchar2) return t_event;
    
    function list_events(
        p_calendar_id in varchar2
      , p_max_results in NUMBER default 250
      , p_query in varchar2        
      , p_access_token in varchar2
    ) return t_event_list;
    
    function list_events_sql(
        p_calendar_id in varchar2
      , p_max_results in NUMBER default 250
      , p_query in varchar2
      , p_access_token in varchar2) return t_event_list_sql pipelined;
    

        

end gapi_cal_event;
/
