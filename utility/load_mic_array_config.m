function R = load_mic_array_config(filename)
    rm = loadjson(filename);
    
    R = [];
    for i = 1:length(rm.data)
        rcv = Receiver(rm.data(i).location);
        rcv.idx = rm.data(i).idx;
        R = [R rcv];
    end
end

