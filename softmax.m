function out = softmax(in, temperature)
out = exp(in ./ temperature);
out = out ./ sum(out);
end