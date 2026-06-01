function ai-sonnet1m --description "Switch Claude model to Sonnet 1M context"
    set -gx ANTHROPIC_MODEL 'global.anthropic.claude-sonnet-4-5-20250929-v1:0[1m]'
    echo "Model: Claude Sonnet 4.5 (1M context)"
end
