#!/bin/bash
# ============================================================
#  S1B SNAPSHOT WRAPPER - Unified snapshot management
#  Usage: s1b-snapshot [create|restore|list|delete] [name]
#  ============================================================

S1B_ROOT="$HOME/Desktop/S1Bs1stem"

case "${1:-help}" in
    create|c)
        shift
        "$S1B_ROOT/scripts/rollback/snapshot_create.sh" "$@"
        ;;
    restore|r)
        shift
        "$S1B_ROOT/scripts/rollback/snapshot_restore.sh" "$@"
        ;;
    list|l)
        "$S1B_ROOT/scripts/rollback/snapshot_list.sh"
        ;;
    delete|d)
        shift
        "$S1B_ROOT/scripts/rollback/snapshot_delete.sh" "$@"
        ;;
    help|h|*)
        cat << HELP
S1B Snapshot Manager - Usage:
  create|c [name]  - Create a new snapshot
  restore|r <name> - Restore from snapshot
  list|l           - List all snapshots
  delete|d <name>  - Delete a snapshot
  help|h           - Show this help

Examples:
  s1b-snapshot create my_backup
  s1b-snapshot list
  s1b-snapshot restore my_backup
  s1b-snapshot delete old_backup

Short commands:
  s1b-create
  s1b-restore
  s1b-list
  s1b-delete
HELP
        ;;
esac
