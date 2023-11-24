function plot_irs(ir, i_src)
    figure()
    cols = floor(sqrt(size(ir, 2)));
    rows = size(ir, 2) / cols;
    cnt = 1;
    for i = 1:rows
        for j = 1:cols
            subplot(rows, cols, cnt)
            plot(ir{i_src, cnt});
            cnt = cnt + 1;
        end
    end
end

