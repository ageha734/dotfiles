function __android_emulator
    set selected_emulator (emulator -list-avds | fzf --query "$LBUFFER")

    echo "Selected Emulator: $selected_emulator"

    if [ -n "$selected_emulator" ]
        emulator -avd $selected_emulator -no-snapshot -no-boot-anim
        commandline -f repaint
    else
        echo "No emulator selected."
    end
end

function __xcode_simulator
    set selected_simulator (xcrun simctl list devices | grep -E "iPhone" | grep -v unavailable | fzf --query "$LBUFFER")

    if [ -z "$selected_simulator" ]
        echo "No simulator selected."
        return 1 # Exit if no simulator was selected
    end

    # Extract simulator ID using grep and regex (this part is working for you)
    set simulator_id (echo $selected_simulator | grep -oE '[0-9A-F]{8}-([0-9A-F]{4}-){3}[0-9A-F]{12}')

    # Extract the state, which is the last field (e.g., "(Booted)", "(Shutdown)")
    set simulator_state (echo $selected_simulator | awk '{print $NF}')

    echo "Selected: $selected_simulator" # For context
    echo "Extracted ID: $simulator_id"
    echo "Current State: $simulator_state"

    if [ -z "$simulator_id" ]
        echo "Error: Could not extract Simulator ID from '$selected_simulator'."
        return 1 # Exit if ID extraction failed
    end

    switch $simulator_state
        case "(Booted)"
            echo "Simulator $simulator_id is already booted."
            echo "Bringing Simulator app to the foreground..."
            open -a Simulator # This will bring the Simulator application to the front
        case "(Shutdown)"
            echo "Simulator $simulator_id is shutdown. Booting..."
            if xcrun simctl boot $simulator_id
                echo "Simulator $simulator_id booted successfully."
                # Booting usually brings the simulator window up and focuses the app.
                # You can still ensure the app is frontmost if desired.
                open -a Simulator
            else
                echo "Error: Failed to boot simulator $simulator_id."
            end
        case "(Booting)" "(Shutting Down)" "(Creating)"
            echo "Simulator $simulator_id is currently in state: $simulator_state."
            echo "Please wait for the current operation to complete and try again."
        case "*" # Handles any other unexpected state
            echo "Simulator $simulator_id is in an unrecognized state: $simulator_state."
            echo "Attempting to boot as a fallback..."
            if xcrun simctl boot $simulator_id
                echo "Simulator $simulator_id attempted boot."
            else
                echo "Error: Failed to boot simulator $simulator_id from state $simulator_state."
            end
    end

    # Repaint the command line (fish shell specific)
    commandline -f repaint
end
