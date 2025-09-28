#!/bin/bash

# PP MAMS Debug Log Analyzer
# Concurrent grep analysis with progress feedback

LOG_FILE="/home/steam/.config/EgoSoft/X4/1426376/debuglog.txt"
TEMP_DIR="/tmp/pp_mams_analysis_$$"
mkdir -p "$TEMP_DIR"

echo "🔍 PP MAMS Debug Log Analyzer v1.0"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📁 Analyzing: $LOG_FILE"
echo "⏰ Started at: $(date '+%H:%M:%S')"
echo ""

# Function to run search with feedback
run_search() {
    local name="$1"
    local pattern="$2"
    local output_file="$3"
    local icon="$4"

    echo "$icon Searching for $name..."
    sudo grep -i "$pattern" "$LOG_FILE" > "$output_file" 2>/dev/null
    local count=$(wc -l < "$output_file" 2>/dev/null || echo "0")

    if [ "$count" -gt 0 ]; then
        echo "  ✅ Found $count matches for $name"
    else
        echo "  ❌ No matches found for $name"
    fi

    return $count
}

# Launch concurrent searches
echo "🚀 Launching concurrent searches..."
echo ""

# Background searches with progress indicators
(run_search "pp_mams references" "pp_mams" "$TEMP_DIR/pp_mams.txt" "🔍") &
PID1=$!

(run_search "PP MAMS references" "PP MAMS" "$TEMP_DIR/PP_MAMS.txt" "📝") &
PID2=$!

(run_search "mdscript loading" "mdscript.*pp_mams\|pp_mams.*mdscript\|pp_mams\.xml" "$TEMP_DIR/mdscript.txt" "📄") &
PID3=$!

(run_search "extension loading" "Loading extension\|Extension.*loaded" "$TEMP_DIR/extensions.txt" "🔧") &
PID4=$!

(run_search "merit/personnel" "merit\|personnel\|pilot.*assignment" "$TEMP_DIR/merit.txt" "👨‍✈️") &
PID5=$!

# Get recent entries (last 50 lines) for context
echo "📋 Getting recent log entries..."
sudo tail -50 "$LOG_FILE" > "$TEMP_DIR/recent.txt" 2>/dev/null
echo "  ✅ Captured recent entries"

# Wait for all background jobs with spinner
echo ""
echo "⏳ Waiting for searches to complete..."
wait $PID1 $PID2 $PID3 $PID4 $PID5

echo ""
echo "📊 ANALYSIS RESULTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Display results
for file in "$TEMP_DIR"/*.txt; do
    filename=$(basename "$file" .txt)
    count=$(wc -l < "$file" 2>/dev/null || echo "0")

    case "$filename" in
        "pp_mams") title="🔍 pp_mams references" ;;
        "PP_MAMS") title="📝 PP MAMS references" ;;
        "mdscript") title="📄 MDScript loading" ;;
        "extensions") title="🔧 Extension loading" ;;
        "merit") title="👨‍✈️ Merit/Personnel" ;;
        "recent") title="📋 Recent entries (last 50)" ;;
        *) title="❓ $filename" ;;
    esac

    echo ""
    echo "$title: $count lines"

    if [ "$count" -gt 0 ] && [ "$filename" != "recent" ]; then
        echo "┌─ Sample results:"
        head -3 "$file" | sed 's/^/│ /'
        if [ "$count" -gt 3 ]; then
            echo "│ ... and $((count - 3)) more"
        fi
        echo "└─"
    elif [ "$filename" = "recent" ] && [ "$count" -gt 0 ]; then
        echo "┌─ Most recent entries:"
        tail -5 "$file" | sed 's/^/│ /'
        echo "└─"
    fi
done

# Summary
echo ""
echo "🎯 SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

pp_mams_count=$(wc -l < "$TEMP_DIR/pp_mams.txt" 2>/dev/null || echo "0")
PP_MAMS_count=$(wc -l < "$TEMP_DIR/PP_MAMS.txt" 2>/dev/null || echo "0")
total_pp_mams=$((pp_mams_count + PP_MAMS_count))

if [ "$total_pp_mams" -gt 0 ]; then
    echo "✅ PP MAMS mod appears to be active in debug log ($total_pp_mams total references)"
else
    echo "❌ PP MAMS mod not found in debug log - possible loading issue"
fi

extension_count=$(wc -l < "$TEMP_DIR/extensions.txt" 2>/dev/null || echo "0")
echo "📊 Total extension loading events: $extension_count"

echo ""
echo "🗂️  Full results saved in: $TEMP_DIR"
echo "⏰ Completed at: $(date '+%H:%M:%S')"
echo "🧹 Run 'rm -rf $TEMP_DIR' to clean up temp files"
echo ""