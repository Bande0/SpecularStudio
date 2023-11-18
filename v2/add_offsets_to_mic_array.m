function R = add_offsets_to_mic_array(R, x_offset, y_offset, z_offset)

    for i = 1:length(R)
        R(i).location(1) = R(i).location(1) + x_offset;
        R(i).location(2) = R(i).location(2) + y_offset;
        R(i).location(3) = R(i).location(3) + z_offset;
    end

end

