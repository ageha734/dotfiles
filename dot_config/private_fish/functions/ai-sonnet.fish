function ai-sonnet --description "Switch Claude model to Sonnet"
    set -gx ANTHROPIC_MODEL 'global.anthropic.claude-sonnet-4-5-20250929-v1:0'
    echo "Model: Claude Sonnet 4.5"
end
