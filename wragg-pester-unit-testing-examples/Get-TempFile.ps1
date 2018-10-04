function Get-TempFile ($Path) {
    Get-ChildItem "$Path\*tmp*"
}