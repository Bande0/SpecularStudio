function write_json(data, out_file_path, out_file_name, varargin)
%  WRITE_JSON will will write the contents of a provided data variable to a
%  JSON file
%
%  WRITE_JSON(data, out_file_path, out_file_name) will write contents of
%  "data" to a JSON file with name "out_file_name" to a path
%  "out_file_path".
%
%  WRITE_JSON(data, out_file_path, out_file_name, json_beautifier) will
%  write the contents of the "data" to a JSON file with name 
%  "out_file_name" to a path "out_file_path", and will subsequently run the
%  "json beautifier" external python tool so that the resulting file is
%  human-readable

    if exist([out_file_path '\\' out_file_name], 'file')
       disp([out_file_name ' already exists! Skipping...']);
       return
    end
    
    % write json
    ds_info = jsonencode(data);
    ds_info = strrep(ds_info, '\', '\\');
    fid = fopen(fullfile(out_file_path, out_file_name), 'w');
    fprintf(fid, ds_info);
    fclose(fid);
    
    % if json beautifier tool was supported, run it
    if ~isempty(varargin)        
        command = ['cd ', out_file_path];
        system(command);
        command = ['python ' fullfile(pwd, varargin{1}) ' --file ', fullfile(out_file_path, out_file_name), ' -o'];
        system(command);
    end
end