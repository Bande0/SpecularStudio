function plot_irs(ir, i_src)
    max_val = max(max([ir{i_src, :}]));
    min_val = min(min([ir{i_src, :}]));
    rng = max_val - min_val; 
    plt_max = max_val + 0.1*rng;
    plt_min = min_val - 0.1*rng;

    figure()
    cols = floor(sqrt(size(ir, 2)));
    rows = size(ir, 2) / cols;
    cnt = 1;
    for i = 1:rows
        for j = 1:cols
            subplot(rows, cols, cnt)
            plot(ir{i_src, cnt});
            ylim([plt_min plt_max]);
            xlim([0 length(ir{i_src, cnt})])
            title(sprintf('Src: %d, mic: %d', i_src, cnt));
            cnt = cnt + 1;
        end
    end    
end

