function sig_out = absorb(obj, sig_in)
    % TODO
    % Right now the absorption is modelled by a single damping constant
    sig_out = sig_in * obj.abs_coeff;
end