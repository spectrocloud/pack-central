#!/bin/bash

# Simple YAML Indentation Validation Script
# Validates only the indentation consistency in values.yaml files

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global variables
ERROR_COUNT=0
WARNING_COUNT=0

# Logging functions
log_error() {
    echo -e "${RED}ERROR: $1${NC}"
    ERROR_COUNT=$((ERROR_COUNT + 1))
}

log_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
    WARNING_COUNT=$((WARNING_COUNT + 1))
}

log_info() {
    echo -e "${BLUE}INFO: $1${NC}"
}

log_success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

# Help function
show_help() {
    cat << EOF
Usage: $0 [OPTIONS] <values.yaml-file>

Validate YAML indentation in values.yaml files.

OPTIONS:
    -h, --help              Show this help message
    -v, --verbose           Enable verbose output
    --strict                Enable strict validation (treat warnings as errors)

EXAMPLES:
    $0 stable/networking/calico_3.25.0/values.yaml
    $0 --verbose values.yaml
    $0 --strict values.yaml

EOF
}

# Parse command line arguments
VERBOSE=false
STRICT=false
VALUES_FILE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --strict)
            STRICT=true
            shift
            ;;
        -*)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            VALUES_FILE="$1"
            shift
            ;;
    esac
done

# Check if values file is provided
if [ -z "$VALUES_FILE" ]; then
    log_error "No values.yaml file specified"
    show_help
    exit 1
fi

# Check if values file exists
if [ ! -f "$VALUES_FILE" ]; then
    log_error "Values file not found: $VALUES_FILE"
    exit 1
fi

# Function to validate YAML syntax
validate_yaml_syntax() {
    local file="$1"
    log_info "Validating YAML syntax for: $file"
    
    if ! yq eval '.' "$file" > /dev/null 2>&1; then
        log_error "Invalid YAML syntax in $file"
        return 1
    fi
    
    log_success "YAML syntax is valid"
    return 0
}

# Function to check indentation consistency
check_indentation() {
    local file="$1"
    log_info "Checking indentation consistency for: $file"
    
    local line_num=0
    local errors=0
    local warnings=0
    local prev_indent=0
    local prev_line=""
    local in_manifests_calico=false
    local calico_indent=0
    
    while IFS= read -r line; do
        line_num=$((line_num + 1))
        
        # Skip empty lines and comments
        if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
            continue
        fi
        
        # Calculate current indentation (spaces only)
        local spaces_only=$(echo "$line" | sed 's/[^ ].*//' | wc -c)
        local current_indent=$((spaces_only - 1))
        
        # Check for tabs
        if [[ "$line" =~ $'\t' ]]; then
            log_error "Line $line_num: Contains tabs (use spaces only)"
            errors=$((errors + 1))
        fi
        
        # Check for mixed tabs and spaces
        if [[ "$line" =~ $'\t' && "$line" =~ " " ]]; then
            log_error "Line $line_num: Mixed tabs and spaces in indentation"
            errors=$((errors + 1))
        fi
        
        # Check for inconsistent indentation (should be multiples of 2)
        if [ $current_indent -gt 0 ] && [ $((current_indent % 2)) -ne 0 ]; then
            log_error "Line $line_num: Inconsistent indentation ($current_indent spaces, should be multiple of 2)"
            errors=$((errors + 1))
        fi
        
        # Check for excessive indentation
        if [ $current_indent -gt 20 ]; then
            log_warning "Line $line_num: Excessive indentation ($current_indent spaces)"
            warnings=$((warnings + 1))
        fi
        
        # Check for trailing spaces
        if [[ "$line" =~ [[:space:]]+$ ]]; then
            log_warning "Line $line_num: Trailing spaces"
            warnings=$((warnings + 1))
        fi
        
        # Check for structural indentation issues
        if [[ "$line" =~ ^[[:space:]]*manifests:$ ]]; then
            in_manifests_calico=false
        elif [[ "$line" =~ ^[[:space:]]*calico:$ ]]; then
            in_manifests_calico=true
            calico_indent=$current_indent
        elif [ "$in_manifests_calico" = true ] && [ $current_indent -gt 0 ]; then
            # Check if content under calico is properly indented
            local expected_indent=$((calico_indent + 2))
            if [ $current_indent -lt $expected_indent ]; then
                log_error "Line $line_num: Content under 'manifests.calico' should be indented at least $expected_indent spaces (found $current_indent)"
                errors=$((errors + 1))
            fi
        fi
        
        prev_indent=$current_indent
        prev_line="$line"
        
    done < "$file"
    
    if [ $errors -eq 0 ]; then
        log_success "Indentation is consistent"
    else
        log_error "Found $errors indentation errors"
    fi
    
    if [ $warnings -gt 0 ]; then
        log_warning "Found $warnings indentation warnings"
    fi
    
    return $errors
}

# Function to check basic structure (just to ensure it's a valid values.yaml)
check_basic_structure() {
    local file="$1"
    log_info "Checking basic structure for: $file"
    
    # Check if file has pack section
    if ! yq eval '.pack' "$file" > /dev/null 2>&1; then
        log_warning "No 'pack' section found (this might not be a valid values.yaml)"
    else
        log_success "Found 'pack' section"
    fi
    
    # Check if file has either manifests or charts section
    local has_manifests=false
    local has_charts=false
    
    if yq eval '.manifests' "$file" > /dev/null 2>&1; then
        has_manifests=true
        log_success "Found 'manifests' section"
    fi
    
    if yq eval '.charts' "$file" > /dev/null 2>&1; then
        has_charts=true
        log_success "Found 'charts' section"
    fi
    
    if [ "$has_manifests" = false ] && [ "$has_charts" = false ]; then
        log_warning "Neither 'manifests' nor 'charts' section found"
    fi
}

# Function to validate structural indentation
validate_structural_indentation() {
    local file="$1"
    log_info "Validating structural indentation for: $file"
    
    local errors=0
    local line_num=0
    local current_indent=0
    local in_manifests=false
    local in_calico=false
    local calico_indent=0
    
    while IFS= read -r line; do
        line_num=$((line_num + 1))
        
        # Skip empty lines and comments
        if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
            continue
        fi
        
        # Calculate current indentation
        local spaces_only=$(echo "$line" | sed 's/[^ ].*//' | wc -c)
        current_indent=$((spaces_only - 1))
        
        # Track section boundaries
        if [[ "$line" =~ ^[[:space:]]*manifests:$ ]]; then
            in_manifests=true
            in_calico=false
        elif [[ "$line" =~ ^[[:space:]]*calico:$ ]] && [ "$in_manifests" = true ]; then
            in_calico=true
            calico_indent=$current_indent
        elif [[ "$line" =~ ^[[:space:]]*[a-zA-Z] ]] && [ "$in_calico" = true ]; then
            # Check if content under calico is properly indented
            local expected_indent=$((calico_indent + 2))
            if [ $current_indent -lt $expected_indent ]; then
                log_error "Line $line_num: Content under 'manifests.calico' should be indented at least $expected_indent spaces (found $current_indent)"
                log_error "  Expected: $expected_indent spaces, Found: $current_indent spaces"
                errors=$((errors + 1))
            fi
        fi
        
    done < "$file"
    
    if [ $errors -eq 0 ]; then
        log_success "Structural indentation is correct"
    else
        log_error "Found $errors structural indentation errors"
    fi
    
    return $errors
}

# Main validation function
validate_values_file() {
    local file="$1"
    
    echo "=================================================================="
    echo "Validating YAML indentation: $file"
    echo "=================================================================="
    
    # Reset counters
    ERROR_COUNT=0
    WARNING_COUNT=0
    
    # Run validations
    validate_yaml_syntax "$file"
    check_indentation "$file"
    validate_structural_indentation "$file"
    check_basic_structure "$file"
    
    # Summary
    echo "=================================================================="
    echo "Validation Summary:"
    echo "=================================================================="
    echo "Errors: $ERROR_COUNT"
    echo "Warnings: $WARNING_COUNT"
    
    if [ $ERROR_COUNT -eq 0 ]; then
        if [ "$STRICT" = true ] && [ $WARNING_COUNT -gt 0 ]; then
            log_error "Validation failed due to warnings in strict mode"
            exit 1
        else
            log_success "Validation completed successfully"
            exit 0
        fi
    else
        log_error "Validation failed with $ERROR_COUNT error(s)"
        exit 1
    fi
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    validate_values_file "$VALUES_FILE"
fi 