function save_mic_array_config(R, array_params, filename)
    mic_array_config.data = R;
    mic_array_config.config = array_params;
    savejson('', mic_array_config, filename);
end

