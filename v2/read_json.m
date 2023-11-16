function json_data = read_json(path_to_json)
%  READ_JSON will read the contents of a valid JSON file
%
%  READ_JSON(path_to_json) will read the contents of JSON file and return
%  it as a matlab struct

    if ~exist(path_to_json, 'file')
        error(['Error! File does not exist:' newline '"' path_to_json '"']);
    end
    fid = fopen(path_to_json);
    raw_conf = fread(fid,inf);
    conf_str = char(raw_conf'); 
    fclose(fid); 
    json_data = jsondecode(conf_str);
end