function ai-opus --description "Switch Claude model to Opus"
    set -gx ANTHROPIC_MODEL 'global.anthropic.claude-opus-4-5-20251101-v1:0'
    echo "Model: Claude Opus 4.5"
end
