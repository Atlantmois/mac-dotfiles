function ompmin --wraps omp --description 'OMP minimal mode: tiny prompt, one coherent tool set, no aux LLM calls'
    if not test -x "$HOME/.local/bin/ompmin"
        echo "ompmin: launcher missing at ~/.local/bin/ompmin" >&2
        echo "ompmin: install it from the bundle, e.g. cp <bundle>/ompmin ~/.local/bin/" >&2
        return 127
    end
    command "$HOME/.local/bin/ompmin" $argv
end
