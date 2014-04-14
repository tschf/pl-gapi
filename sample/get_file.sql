set serveroutput on

declare

    l_access_token varchar2(100);
    l_file gapi_drive.t_file;

begin

    l_access_token := gapi_auth.get_access_token('');
    
    l_file :=
        gapi_drive.get_file(
            p_file_id       => ''
          , p_access_token      => l_access_token);
    
    
    dbms_output.put_line('Kind: ' || l_file.kind);    
    dbms_output.put_line('ID: ' || l_file.id);
    dbms_output.put_line('Self link: ' || l_file.self_link);
    dbms_output.put_line('Alternate link: ' || l_file.alternate_link);
    dbms_output.put_line('Embed link: ' || l_file.embed_link);
    dbms_output.put_line('Icon link: ' || l_file.icon_link);
    dbms_output.put_line('Thumbnail link: ' || l_file.thumbnail_link);
    dbms_output.put_line('Title: ' || l_file.title);
    dbms_output.put_line('Description: ' || l_file.description);
    dbms_output.put_line('Mime type: ' || l_file.mime_type);
    
    dbms_output.put_line('Starred: ' || case when l_file.starred then 'T' else 'F' end);
    dbms_output.put_line('Hidden: ' || case when l_file.hidden then 'T' else 'F' end);
    dbms_output.put_line('Trashed: ' || case when l_file.trashed then 'T' else 'F' end);
    dbms_output.put_line('Restricted: ' || case when l_file.restricted then 'T' else 'F' end);
    dbms_output.put_line('Viewed: ' || case when l_file.viewed then 'T' else 'F' end);
    
    dbms_output.put_line('Created: ' || l_file.created_date);
    dbms_output.put_line('Modified: ' || l_file.modified_date);
    dbms_output.put_line('Modified by me: ' || l_file.modified_by_me_date);
    dbms_output.put_line('Last viewed by me: ' || l_file.last_viewed_by_me_date);
    dbms_output.put_line('Quota bytes used: ' || l_file.quota_bytes_used);
    dbms_output.put_line('Last modifying user: ' || l_file.last_modifying_user_name);
    dbms_output.put_line('Editable: ' || case when l_file.editable then 'T' else 'F' end);
    dbms_output.put_line('Copyable: ' || case when l_file.copyable then 'T' else 'F' end);
    dbms_output.put_line('Writers can share: ' || case when l_file.writers_can_share then 'T' else 'F' end);
    dbms_output.put_line('Shared: ' || case when l_file.shared then 'T' else 'F' end);
    dbms_output.put_line('App data contents: ' || case when l_file.app_data_contents then 'T' else 'F' end);

end;
